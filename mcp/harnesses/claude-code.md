# Claude Code

**Status: tested.** The shape below was produced by `claude mcp add --scope project` and matches the `mcp.json` files.

## Where config goes

| Scope | File | Notes |
| --- | --- | --- |
| Project (shared with the team) | `.mcp.json` in the repo root | Safe to commit: it contains only `${VAR}` references. Claude Code asks for approval the first time it sees a project server. |
| Just you, one project | `claude mcp add --scope local …` | Stored in your user config, not in the repo. |
| Just you, all projects | `claude mcp add --scope user …` | |

## Steps

1. Merge the chosen servers' `mcpServers` entries into `.mcp.json` (create it if missing). Keep existing entries.
2. Make the variables available in the environment Claude Code is **launched from**. Claude Code expands `${VAR}` (and `${VAR:-default}`) from that environment; it does not read `.env` itself. Options: your shell profile, direnv, or the `env` block of `.claude/settings.local.json` (gitignored).
3. Check: `claude mcp list`. A freshly added project server shows **Pending approval** and is not started or health-checked until the human runs `claude` and approves it. This is a trust decision; the agent must not bypass it.
4. After approval, `claude mcp list` reports connected or failed. OAuth servers (`sentry`, `supabase`) need the human to log in via `/mcp` inside a session.

## CLI equivalents

```bash
claude mcp add --scope project --transport http sentry https://mcp.sentry.dev/mcp
claude mcp add --scope project context7 -- npx -y @upstash/context7-mcp@4.7.3
claude mcp add --scope project --transport http github https://api.githubcopilot.com/mcp/readonly \
  -H 'Authorization: Bearer ${GITHUB_PERSONAL_ACCESS_TOKEN}'   # single quotes keep ${...} literal
```
