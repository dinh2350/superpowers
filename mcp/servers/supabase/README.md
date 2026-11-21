# supabase

Supabase's official, Supabase-hosted MCP server. Lets the agent inspect and query a Supabase project and search Supabase docs.

- **Use when:** the backend is Supabase and the agent needs to see the real schema or data while working.
- **Skip when:** `supabase` CLI plus `psql` is enough, or the only project you could connect is production.
- **Transport:** remote HTTP (`https://mcp.supabase.com/mcp`). Not versionable; Supabase controls it.
- **Tools:** not measured (needs login). The `features=` parameter limits which groups load.

## Auth

OAuth. The client prompts you to log in on first use; no token goes in the config. Choose the organization that contains the project you want. The only variable is `SUPABASE_PROJECT_REF` (a **development** project).

## Shipped defaults and variants

The URL carries `project_ref=…&read_only=true&features=database,docs`: scoped to one project, no mutating tools, only database and docs tools.

| Want | Change |
| --- | --- |
| Apply migrations / write | Remove `read_only=true`. Do this against a dev project only. |
| More tool groups | Edit `features=`. Supabase documents an interactive URL builder at <https://supabase.com/mcp>. |
| Fully local | With the Supabase CLI running locally, use `http://localhost:54321/mcp` (limited tools, no OAuth). |

## Risks

- Read Supabase's security guidance first: <https://supabase.com/docs/guides/ai-tools/mcp#security-risks>.
- Rows may contain user-authored text, which can carry injected instructions. Never connect it to a production project.

## Last verified

2026-11-21: the endpoint exists and answers `401` with OAuth protected-resource metadata. **Not tested after a real login.**
