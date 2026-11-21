# sentry

Sentry's official, Sentry-hosted MCP server. Pulls issues, stack traces and event details into context so the agent can diagnose real production errors.

- **Use when:** the project reports errors to Sentry and you want the agent to fix a specific issue from its trace.
- **Skip when:** the project doesn't use Sentry.
- **Transport:** remote HTTP (`https://mcp.sentry.dev/mcp`). Not versionable; Sentry controls it.
- **Tools:** not measured (needs login).

## Auth

OAuth. Authenticate from the client on first use (in Claude Code, run `/mcp`). No secret goes in the config.

## Alternatives

- Sentry CLI can run the same server as `sentry mcp` using its own login: <https://cli.sentry.dev/commands/mcp/>.
- The npm package `@sentry/mcp-server` (0.50.0 at the time of checking, license FSL-1.1-ALv2, not OSI open source) runs it over stdio. For self-hosted Sentry it needs `SENTRY_HOST` and `SENTRY_AUTH_TOKEN`. Not pinned or smoke-tested here.

## Risks

- Event payloads contain user-supplied strings and can contain personal data. Treat them as untrusted input; do not paste them into other tools.

## Last verified

2026-11-21: the endpoint exists and answers `401` with OAuth protected-resource metadata. **Not tested after a real login.**
