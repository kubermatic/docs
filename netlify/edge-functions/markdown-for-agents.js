// Netlify Edge Function: Markdown for Agents
//
// When a request includes "Accept: text/markdown", rewrites to the
// pre-generated index.md that Hugo places alongside each index.html.
// Returns Content-Type: text/markdown and x-markdown-tokens as per
// the Cloudflare Markdown for Agents spec.

export default async (request, context) => {
  const accept = request.headers.get("accept") ?? "";
  if (!accept.includes("text/markdown")) {
    return;
  }

  const url = new URL(request.url);
  let path = url.pathname;
  if (!path.endsWith("/")) {
    path += "/";
  }
  url.pathname = path + "index.md";

  const response = await context.rewrite(url);
  if (!response || !response.ok) {
    return;
  }

  const body = await response.text();
  if (!body.trim()) {
    return;
  }
  const headers = new Headers(response.headers);
  headers.set("content-type", "text/markdown; charset=utf-8");
  headers.set("vary", "Accept");
  // Approximate token count (1 token ≈ 4 chars)
  headers.set("x-markdown-tokens", String(Math.ceil(body.length / 4)));

  return new Response(body, { status: 200, headers });
};

export const config = {
  path: "/*",
  excludedPath: [
    "/_redirects",
    "/robots.txt",
    "/sitemap.xml",
    "/search.json",
    "/llms.txt",
    "/llms-full.txt",
    "/css/*",
    "/js/*",
    "/fonts/*",
    "/webfonts/*",
    "/img/*",
    "/mermaid/*",
  ],
};
