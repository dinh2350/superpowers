# github

GitHub's official, GitHub-hosted MCP server: issues, pull requests, repo/code search, Actions, code scanning, Dependabot.

- **Use when:** the agent has no shell access, or you want structured access to alerts, code scanning, or Actions runs.
- **Skip when:** `gh` is installed and authenticated. `gh` covers most tasks without adding any tool definitions to context.
- **Transport:** remote HTTP (`https://api.githubcopilot.com/mcp/readonly`). Not versionable; GitHub controls it.
- **Tools:** not measured here (needs a real token). The default toolset is large; narrow it, see below.

## Auth

A **fine-grained** personal access token in `GITHUB_PERSONAL_ACCESS_TOKEN`. Limit it to the specific repositories and the read permissions you need.

## Variants

| Want | Change the `url` to |
| --- | --- |
| Read-only (shipped default) | `https://api.githubcopilot.com/mcp/readonly` |
| Allow writes (create issues/PRs, comment) | `https://api.githubcopilot.com/mcp/` |
| Only one toolset | `https://api.githubcopilot.com/mcp/x/<toolset>`, e.g. `x/actions`, `x/code_security`, `x/discussions`. Append `/readonly` to any of them. |
| No remote access (e.g. GitHub Enterprise Server) | Run the local server: `docker run -i --rm -e GITHUB_PERSONAL_ACCESS_TOKEN ghcr.io/github/github-mcp-server` |

## Risks

- The server reads issues, PR descriptions and comments written by anyone. On public repos that is a prompt-injection channel. Keep it read-only unless writes are needed.
- Do **not** use the npm package `@modelcontextprotocol/server-github`. It is deprecated and unmaintained.

## Last verified

2026-11-21: the endpoint exists and rejected a dummy token with `invalid_token`. **Not tested with a real token.**
