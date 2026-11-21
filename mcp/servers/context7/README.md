# context7

Fetches current, version-specific documentation and code examples for libraries and frameworks into the agent's context.

- **Use when:** the project depends on fast-moving libraries where the model's training data may be stale (frameworks, SDKs, CLIs).
- **Skip when:** stdlib-only code, or the docs you need already live in the repo.
- **Transport:** stdio via `npx`, pinned to `@upstash/context7-mcp@4.7.3`. Needs Node >= 20.18.1.
- **Tools:** 2 (`resolve-library-id`, `query-docs`).

## Auth

None required. An API key gives higher rate limits and access to private repos. To use one, add
to the server entry and set `CONTEXT7_API_KEY` (see `../../.env.example`):

```json
"env": { "CONTEXT7_API_KEY": "${CONTEXT7_API_KEY}" }
```

## Risks

- Your queries (library names, topics) are sent to Upstash's service. Don't paste proprietary code into them.
- Returned documentation is third-party text entering the agent's context.

## Last verified

2026-11-21: pinned version started, answered `initialize`, listed 2 tools.
