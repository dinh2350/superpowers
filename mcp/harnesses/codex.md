# Codex CLI

**Status: NOT tested.** Codex was not installed when this was written, and Codex uses TOML rather than JSON. Treat the example as a starting point and check it against `codex mcp add --help`.

## Where config goes

`~/.codex/config.toml`, one `[mcp_servers.<name>]` table per server.

## Preferred approach

Let Codex write its own config instead of hand-editing TOML. Take `command` / `args` / `url` from the server's `mcp.json`:

```bash
codex mcp add context7 -- npx -y @upstash/context7-mcp@4.7.3
codex mcp add exa --url https://mcp.exa.ai/mcp        # form shown in Exa's own README
```

## TOML shape (unverified)

```toml
[mcp_servers.context7]
command = "npx"
args = ["-y", "@upstash/context7-mcp@4.7.3"]

[mcp_servers.github]
url = "https://api.githubcopilot.com/mcp/readonly"
bearer_token_env_var = "GITHUB_PERSONAL_ACCESS_TOKEN"
```

Secrets are passed by environment variable **name**, not by `${VAR}` interpolation. Export the variables in the shell that launches `codex`.
