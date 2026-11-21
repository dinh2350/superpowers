# Catalog

Pick 3–5 per project. "Tools" is the number of tool definitions the server adds to context, measured by
starting the server with the config shipped here. `n/m` means not measured, because the server needs real
credentials or a login. Where a server ships a restricted default, the full-size figure is in its README.

## Developer essentials

| Server | Gives the agent | Transport | Auth | Tools | Use MCP or CLI? |
| --- | --- | --- | --- | --- | --- |
| [context7](servers/context7/README.md) | Current, version-specific library docs | stdio (npm, pinned) | none (key optional) | 2 | MCP. Cheap and high value for fast-moving libraries. |
| [github](servers/github/README.md) | Issues, PRs, code search, Actions, security alerts | remote HTTP | PAT in env | n/m (default toolset is large) | Prefer `gh` CLI if available. MCP when there is no shell or you need alerts/code scanning. |
| [playwright](servers/playwright/README.md) | Drive a real browser to check UI behaviour | stdio (npm, pinned) | none | 25 | MCP for exploring; `npx playwright test` to run a test suite. |
| [chrome-devtools](servers/chrome-devtools/README.md) | Console, network, performance traces of a live page | stdio (npm, pinned) | none | 33 | MCP. Heavy; use `--slim` or choose it **instead of** Playwright when debugging, not both. |
| [sequential-thinking](servers/sequential-thinking/README.md) | A structured step-by-step reasoning scratchpad | stdio (npm, pinned) | none | 1 | Marginal with reasoning-capable models. Try without it first. |
| [memory](servers/memory/README.md) | Knowledge graph persisted across sessions | stdio (npm, pinned) | none | 9 | Usually unnecessary: `AGENTS.md`/`CLAUDE.md` are versioned and free. See its README. |

## Data and infrastructure

All of these can reach real data or real machines. Each ships read-only by default and each README says how that was
checked. Read-only here hides tools; it is not a permission boundary. Pair it with a least-privilege credential.

| Server | Gives the agent | Transport | Auth | Tools | Use MCP or CLI? |
| --- | --- | --- | --- | --- | --- |
| [dbhub](servers/dbhub/README.md) | SQL + schema search for Postgres, MySQL, MariaDB, SQL Server, SQLite | stdio (npm, pinned) | DSN in env | 2 | `psql`/`mysql` CLI works. MCP gives enforced read-only and a row limit. **Needs `.mcp/dbhub.toml`.** |
| [mongodb](servers/mongodb/README.md) | Collections, schemas, queries on MongoDB | stdio (npm, pinned) | connection string in env | 20 (31 with writes) | `mongosh` works. MCP gives enforced `--readOnly`. |
| [kubernetes](servers/kubernetes/README.md) | Read cluster resources and logs | stdio (npm, pinned) | your kubeconfig | 15 (21 with writes) | `kubectl` is usually enough. MCP enforces read-only and blocks Secrets. **Needs `.mcp/kubernetes-mcp-server.toml`.** |
| [datadog](servers/datadog/README.md) | Traces, logs, metrics, monitors | remote HTTP | OAuth | n/m | MCP. In Claude Code, Datadog recommends its own plugin instead. |
| [supabase](servers/supabase/README.md) | Query/inspect a Supabase **dev** project, search docs | remote HTTP | OAuth | n/m (scoped by `features=`) | `supabase` CLI + `psql` cover much of it. MCP adds docs search and project ops. |
| [sentry](servers/sentry/README.md) | Production errors, stack traces, release health | remote HTTP | OAuth | n/m | MCP. There is no lighter equivalent for pulling issues into context. |
| [portainer](servers/portainer/README.md) | Docker/Kubernetes inventory through Portainer | stdio (PyPI via `uvx`) | API token in env | 40 (239 default) | **Homelab/non-production only**, per Portainer. `docker` CLI otherwise. |

## Calling APIs

| Server | Gives the agent | Transport | Auth | Tools | Use MCP or CLI? |
| --- | --- | --- | --- | --- | --- |
| [postman](servers/postman/README.md) | Read collections, environments, specs from a Postman workspace | stdio (npm, pinned) | API key in env | 23 (42 default, 234 full) | Manages Postman artifacts; **does not send ad-hoc requests**. |
| [openapi](servers/openapi/README.md) | Call any API that has an OpenAPI spec as typed tools | stdio (npm, pinned, community) | per-API headers in env | 3 (`dynamic` mode) | MCP when you want schemas and env-held secrets. `curl` for a one-off. |

## Starter combinations

- **Web app with a UI:** context7 + playwright (+ github if no `gh`)
- **Debugging a front-end issue:** context7 + chrome-devtools
- **Backend on Postgres/MySQL:** context7 + dbhub
- **Supabase backend:** context7 + supabase (dev project, read-only)
- **MongoDB backend:** context7 + mongodb
- **Kubernetes / on-call:** kubernetes + datadog (+ sentry if you use it)
- **Integrating a third-party API:** context7 + openapi (or postman if the team keeps specs there)

## Verified candidates, not packaged yet

Confirmed from vendor docs or the registry but not tested here. Add a `servers/<id>/` entry when a project needs one.

| Server | Config | Why it is not in the menu |
| --- | --- | --- |
| Exa (web search) | remote `https://mcp.exa.ai/mcp`, OAuth preferred (API key optional) | Claude Code already has web search/fetch. Useful in harnesses that don't. |
| Firecrawl (crawl/scrape) | `npx -y firecrawl-mcp` with `FIRECRAWL_API_KEY` | Needs a paid key; only worth it for large crawls. Latest checked: 3.41.0. |
| Postgres MCP Pro | `uvx postgres-mcp --access-mode=restricted`, `DATABASE_URI` (PyPI 0.3.0, Python >= 3.12) | `dbhub` already covers Postgres. Pick this for index tuning and health checks. |
| MySQL (community) | `npx @benborla29/mcp-server-mysql` (2.0.9), `MYSQL_*` env, read-only by default | `dbhub` already covers MySQL. |
| Kubernetes (Flux159) | `npx mcp-server-kubernetes` (4.2.3), non-destructive mode | `kubernetes` already covers it. |

## Deliberately excluded

| Server | Reason |
| --- | --- |
| `@modelcontextprotocol/server-github` | Deprecated on npm: "Archived and unmaintained; no security guarantees." Use GitHub's official server (see `github`). |
| `@modelcontextprotocol/server-postgres` | Same deprecation notice. Use `dbhub`. |
| `@modelcontextprotocol/server-filesystem` | Coding harnesses already have file tools. Only useful for sandboxed chat clients. |
| git, fetch servers | The `git` CLI and the harness's built-in web fetch do the same with no extra context. |

## Context budget

Every enabled server's tools are loaded on every request. Rough sizes from this catalog: Playwright 25, Chrome DevTools 33,
MongoDB 20, Kubernetes 15, Postman `--code` 23. Portainer with its defaults would add 239 and Postman `--full` 234, which is why
those ship narrowed. If the agent starts choosing tools badly, remove servers before anything else.
