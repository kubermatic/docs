+++
title = "Check Catalog"
linkTitle = "Check Catalog"
date = 2026-07-29T10:00:00+02:00
description = "Reference for KubeLB Insights checks, prerequisites, findings, and remediation."
weight = 10
+++

This catalog lists every check the insights engine runs. Check IDs are permanent: findings, the `kubelb.k8c.io/insight-check` label, `Config.spec.insights.disabledChecks` and these links all use them. Retired IDs are never reissued, so the numbering has gaps.

Some checks need a feature to be meaningful. A WAF check on an installation without the WAF would report every route as unprotected, so instead it is skipped and counted in `kubelb_manager_insights_checks_skipped_total`.

| Capability | Comes from |
|------------|------------|
| WAF | The `--enable-waf` manager flag |
| EnvoyCache | The manager's own xDS snapshot cache |
| MTLS | `Config.spec.backendTransport.mode: MTLS`, or a tenant still running that dataplane |

## KLB001

`waf-detection-only` · security · medium · needs WAF

A WAF policy has run with `SecRuleEngine DetectionOnly` or `Off` for more than two weeks. It inspects and logs, and blocks nothing. SecLang has no separate audit-mode field, so this state is easy to leave behind after tuning and hard to notice afterwards.

Set `SecRuleEngine On` in the policy directives, or delete the policy if it is no longer wanted. Dismiss with `working_as_intended` if you deliberately run a logging-only ruleset.

## KLB002

`waf-validation-disabled` · security · high · needs WAF

`spec.waf.skipValidation` is set while WAF policies exist. Every policy is reported as valid without its directives being parsed, so a malformed rule set is only discovered by Envoy at request time.

Unset the field and fix whichever policy then fails validation.

## KLB003

`xds-endpoint-truncation` · reliability · high

A workload resolves to more upstream addresses than `spec.envoyProxy.maxEndpointsPerCluster` allows. The surplus never reaches Envoy and those backends receive no traffic. Nothing else reports this.

Raise the limit above the largest endpoint count, or reduce the number of endpoints behind the service.

## KLB010

`deprecated-proxy-topology` · hygiene · info

`spec.envoyProxy.topology` is `dedicated` or `global`. Both are deprecated and already behave as `shared`, so traffic is unaffected today. The field only accepts a change back to `shared`, so leaving it in place will fail a future upgrade.

## KLB011

`reference-grants-disabled` · security · medium

This tenant accepts cross-namespace backend and TLS certificate references without a `ReferenceGrant`, while other tenants in the fleet require one. The finding is comparative on purpose: a fleet that uniformly does not enforce grants has made a choice, and one tenant differing from its peers is usually an oversight.

Set `spec.gatewayAPI.enforceReferenceGrants` on the `Tenant`, or on the `Config` for everyone.

## KLB012

`backend-transport-change-pending` · hygiene · info

A `backendTransport` mode change is configured but was never confirmed, so the tenant still runs the old topology and the `Config` disagrees with the running dataplane. Annotate the `Config` with `kubelb.k8c.io/confirm-backend-transport-change` set to the target mode, or revert the change.

## KLB013

`ingress-conversion-stuck` · migration · medium

An Ingress did not finish converting to Gateway API and is stuck as pending, partial or failed. Read `kubelb.k8c.io/conversion-warnings` on the source Ingress and fix what the converter could not translate, or annotate it with `kubelb.k8c.io/skip-conversion` to leave it as an Ingress.

## KLB014

`hostname-collision` · reliability · high

Two tenants claim the same hostname. Both believe they own it, and traffic resolves to whichever claim the dataplane programmed last. Neither tenant cluster can see the other, so this is invisible from both sides and only the management cluster can detect it.

Decide which tenant owns the hostname and change the other. To prevent it recurring, scope hostnames per tenant with `spec.allowedDomains`.

## KLB015

`cert-annotations-stripped` · security · high

A tenant asked for a certificate and KubeLB removed the cert-manager annotations, because certificate automation is disabled for the tenant or the hostname falls outside `spec.certificates.allowedDomains`. No certificate is issued and no error is reported. From inside the tenant cluster this looks like cert-manager is broken.

Add the hostname to the tenant's certificate `allowedDomains`, clear `spec.certificates.disable`, or tell the tenant the hostname is not permitted. Dismiss with `working_as_intended` when the refusal is deliberate and the tenant knows.

## KLB016

`waf-unprotected-route` · security · high · needs WAF

An HTTP route serves traffic with no WAF policy while other tenants' routes are protected. Coverage is resolved with the same resolvers the dataplane uses, so a route counted as protected here is one Envoy actually filters.

Attach a `WAFPolicy` to the route, or set one with `spec.global` to cover everything without a policy of its own.

## KLB017

`waf-failure-mode-asymmetry` · security · low · needs WAF

This tenant lets its own policies decide what happens when the WAF filter fails to load, while its peers are forced closed. A tenant policy that fails to load passes traffic here and blocks it elsewhere.

Set `spec.waf.enforceFailureMode` on the `Tenant`, or on the `Config` for the fleet.

## KLB018

`quota-headroom` · reliability · medium or high

A tenant is at 80% of a limit, or 95% for the higher severity. Past the limit, new resources are refused with only a controller log to explain the refusal, and the tenant sees no error in its own cluster.

Raise the limit on the `Tenant` or `Config`, or have the tenant remove what it no longer uses.

## KLB020

`netpol-asymmetry` · security · low

This tenant's namespace has no managed network policies while its peers do, so it accepts traffic inside the management cluster that the others refuse. Set `spec.networkPolicy.enable` on the `Tenant`, or on the `Config`.

## KLB021

`xds-snapshot-missing` · reliability · critical · needs EnvoyCache

The tenant has admitted traffic configuration that never reached the Envoy control plane, so its dataplane is serving nothing. Configuration younger than five minutes is treated as still in flight, and rejected routes are ignored because they are meant to be absent.

Check the manager logs for the Envoy control plane controller and this tenant's namespace. The configuration exists and was admitted, so the gap sits between admission and the snapshot.

This check reads the cache in the manager replica that ran the sweep. The control plane runs on every replica, so a clean result means that replica's view is complete rather than the whole fleet's.

## KLB022

`mtls-rotation-stuck` · security · high · needs MTLS

A backend transport certificate entered its rotation window and was never reissued. Reissue is automatic once a certificate is within 30 days of expiry, so material this old means the rotation itself is stuck, and on expiry the tenant proxy and the management Envoy stop trusting each other. Certificates issued in the last two days are left alone, since the controller has not had its daily pass over them yet.

Reissue is automatic, so this is not configuration you set. Check that the manager still has RBAC to write Secrets, and whether the `Tenant` reports `BackendCertificateConflict`, which means a tenant proxy `SyncSecret` the manager does not own is blocking the write. Otherwise capture the manager logs for the tenant proxy certificate controller along with `kubelb_manager_mtls_certificate_rotation_failures_total` and open a support case.

The root CA is reported differently: it rotates by standing up a successor rather than being reissued in place, so it is only a finding when that successor is missing.
