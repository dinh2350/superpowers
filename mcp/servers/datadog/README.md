# datadog

Datadog's official, Datadog-hosted MCP server. Gives the agent access to observability data (APM, logs, metrics, monitors and more, depending on the enabled toolsets) so it can investigate incidents with real telemetry.

- **Use when:** the team runs on Datadog and the agent should diagnose from traces, logs or monitors.
- **Skip when:** you don't use Datadog, or only need a one-off lookup (the web UI is faster).
- **Transport:** remote HTTP. The endpoint depends on your Datadog site, so it comes from `DATADOG_MCP_URL`. Not versionable; Datadog controls it.
- **Tools:** not measured (needs login). Toolsets can be limited, see below.

## In Claude Code, prefer Datadog's plugin

Datadog's docs recommend the official plugin for Claude Code: `/plugin install datadog@claude-plugins-official`, then `/ddsetup` (pick your site and log in) and `/ddtoolsets` (choose toolsets). Their docs also say to **remove a manually added Datadog MCP server** to avoid conflicts. Use this `mcp.json` for other harnesses, or when the plugin isn't available.

## Setup

1. Find the MCP endpoint for **your** Datadog site in Datadog's MCP setup docs: <https://docs.datadoghq.com/mcp_server/setup/> (pick your site in the selector). Set it as `DATADOG_MCP_URL`.
   - US1 (checked): `https://mcp.datadoghq.com/api/unstable/mcp-server/mcp`. Note the `unstable` segment in the path.
2. To limit toolsets, append `?toolsets=apm,llmobs` (Datadog's example; `toolsets=all` enables every generally available toolset). Fewer toolsets means less context.
3. Authenticate with OAuth when the client prompts (in Claude Code, `/mcp`). Datadog documents API and application keys as an alternative; follow its docs for the exact variables. No secret goes in this config.

## Risks

- Logs and traces often contain personal data, tokens and user-supplied strings. Treat everything returned as untrusted input.
- Access follows the permissions of the account that logged in. Use a least-privilege role.
- Datadog's docs note that the MCP server is not supported on every site. Confirm yours.

## Last verified

2026-11-21: the US1 endpoint exists and answers `401` with OAuth protected-resource metadata. **Not tested after a real login**, and other sites' endpoints were not checked.
