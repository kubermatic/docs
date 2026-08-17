+++
title = "MCP Gateway"
weight = 4
+++

The MCP gateway exposes the KDP MCP server as a public HTTPS endpoint that AI coding
assistants can connect to, so users need no kubeconfig and nothing installed locally. It runs
[agentgateway](https://agentgateway.dev) in front of `kdp-mcp-server` and:

- validates the OIDC token presented by the assistant against your identity provider,
- serves the MCP OAuth metadata that assistants use to discover how to log in,
- applies a per-instance rate limit,
- forwards the caller's token unchanged, so the MCP server acts as that user against kcp.

Once it is enabled, users connect as described in
[AI Tooling]({{< relref "../../platform-users/ai-tooling" >}}).

## Prerequisites

- A running KDP installation (see the [Quickstart]({{< relref "../quickstart" >}})).
- Dex, or another OIDC provider, reachable over HTTPS from the cluster.
- The public API domain you already use for the kcp front proxy
  (`kdp.frontProxy.publicDomain`). The gateway reuses its certificate and DNS record, so no
  new hostname is needed.

## Enable the gateway

Both the MCP server and the gateway are part of the `developer-platform` chart. Add the
following to your KDP values (`kdp.values.yaml` if you followed the Quickstart):

```yaml
{{< readfile "developer-platform/v1.2/setup/mcp-gateway/data/kdp.mcp-gateway.values.yaml" >}}
```

Replace `<DOMAIN>` and `<NAMESPACE>`, then upgrade the release. The gateway is served at
`/mcp` on the public API domain through its own Ingress, so MCP traffic bypasses the kcp front
proxy while everything else on that host is unaffected.

Values worth knowing about:

| Value | Default | Meaning |
|---|---|---|
| `kdp.mcpGateway.enabled` | `true` | Only takes effect when `kdp.mcpServer.enabled` is also true. |
| `oidc.audience` | `kdp-mcp` | The `aud` claim tokens must carry. This is the OIDC client ID registered for MCP. |
| `oidc.crossClientAudience` | *(empty)* | Client ID that agents additionally request a token for, so kcp accepts it. |
| `oidc.provider` | `authentik` | Adapter used to derive the OAuth metadata. Dex needs this; see below. |
| `oidc.clientId` | *(empty)* | Client ID handed to assistants. Falls back to `oidc.audience`. |
| `rateLimit` | 60 requests / 60s | Token bucket per gateway instance. Requests over the limit get HTTP 429. |
| `ingress.host` | `kdp.frontProxy.publicDomain` | Override only if MCP lives on another hostname. |

If the gateway is enabled with an empty `oidc.issuer`, `jwksURL`, `audience` or `resource`,
the chart fails to render rather than deploying an unauthenticated gateway.

{{% notice note %}}
`oidc.provider` is set to `authentik` for Dex on purpose. Dex does not implement OAuth Dynamic
Client Registration and publishes its metadata via OIDC Discovery rather than the RFC 8414
path. The `authentik` adapter fits that same shape: the gateway serves the authorization-server
metadata from Dex's discovery document and answers registration requests with the
pre-registered client ID, which is what lets standard MCP clients complete the login.
{{% /notice %}}

## Configure the identity provider

{{% notice warning %}}
The endpoint returns `401` for every request until these two changes are made. They are the
most common cause of a gateway that deploys cleanly but cannot be used.
{{% /notice %}}

Add a public `kdp-mcp` client, and allow it to act for the client kcp already trusts:

```yaml
{{< readfile "developer-platform/v1.2/setup/mcp-gateway/data/dex.mcp-client.values.yaml" >}}
```

Dex reads its configuration at startup and does not watch the file, so restart it afterwards.

### Why `trustedPeers` is needed

kcp authenticates users with a single expected audience (`--oidc-client-id`, normally
`kdp-kubelogin`). Tokens minted for the MCP gateway carry `kdp-mcp` instead, and kcp would
reject them.

`trustedPeers` enables Dex's cross-client trust: because `kdp-kubelogin` names `kdp-mcp` as a
trusted peer, an assistant can request the dynamic scope
`audience:server:client_id:kdp-kubelogin` — which `oidc.crossClientAudience` makes the gateway
advertise automatically. Dex then issues a token whose `aud` claim contains **both** client
IDs. The gateway accepts it because `kdp-mcp` is present, and kcp accepts it because
`kdp-kubelogin` is present, with no change to your kcp configuration.

The trade-off is worth stating plainly: a token issued this way is equivalent to a normal user
token, so it grants the same access a user's own kubeconfig would. Isolating MCP access more
tightly requires moving kcp to a structured `AuthenticationConfiguration`, which can trust
several audiences and constrain the authorized party.

## Verify

Check that the gateway is running and serving its OAuth metadata:

```bash
kubectl get deployment kdp-mcp-gateway kdp-mcp-server -n <NAMESPACE>

curl -s https://public.api.<DOMAIN>/.well-known/oauth-protected-resource/mcp | jq .
```

The response should name your endpoint as the `resource`, and `scopes_supported` should include
the cross-client scope:

```json
{
  "resource": "https://public.api.<DOMAIN>/mcp",
  "bearer_methods_supported": ["header"],
  "scopes_supported": [
    "openid",
    "email",
    "groups",
    "audience:server:client_id:kdp-kubelogin"
  ]
}
```

An unauthenticated request must be refused, with a challenge pointing at that metadata:

```bash
curl -s -o /dev/null -w '%{http_code}\n' -X POST https://public.api.<DOMAIN>/mcp
# 401
```

Finally, connect an assistant as described in
[AI Tooling]({{< relref "../../platform-users/ai-tooling" >}}) and confirm the browser login
completes and the tools are listed.

## Troubleshooting

**Every request returns 401, and the gateway log says `no bearer token found`.**
Expected without a token. If it also happens after a successful login, the token's audience
does not match `oidc.audience` — check that the client ID in the assistant's configuration is
the one the gateway expects.

**Login fails with `redirect_uri did not match` in the Dex log.**
The assistant used a callback URL that is not registered. Dex matches redirect URIs exactly,
and a wildcard applies only to a public client with no `RedirectURIs` listed at all — and even
then only for the host `localhost`, not `127.0.0.1`. Read the URI Dex logged and add it
verbatim.

**Login succeeds, but every tool call fails with an authentication or permission error from
kcp.** The token reached the gateway but kcp rejected it, which means the cross-client audience
is missing: verify `oidc.crossClientAudience` is set and that `trustedPeers` on the kcp client
lists `kdp-mcp`. Decoding the token's `aud` claim should show both client IDs.

**The assistant cannot complete registration, or asks for a client secret.**
The `kdp-mcp` client must be public (`public: true`) with no `secret`. A secret makes it
confidential, and Dex then rejects the PKCE token request.

**Requests intermittently return 429.**
The rate limit is per gateway instance; raise `kdp.mcpGateway.rateLimit`.

## See also

- [AI Tooling]({{< relref "../../platform-users/ai-tooling" >}}) — connecting an assistant and
  what the tools can do.
- [RBAC]({{< relref "../../platform-users/rbac" >}}) — the permissions an agent inherits.
