# chrome-devtools

Google's Chrome DevTools MCP server. Gives the agent what a developer gets from DevTools: console messages, network requests, performance traces, DOM and CSS inspection of a live page.

- **Use when:** debugging a front-end problem or a performance issue on a running page.
- **Skip when:** you only need to click through a flow; Playwright is lighter. Choose one of the two per task. Together they add 58 tool definitions.
- **Transport:** stdio via `npx`, pinned to `chrome-devtools-mcp@1.13.0`. Needs a current Node LTS and current stable Chrome.
- **Tools:** 33. The `--slim` flag exposes a reduced set for basic browser tasks.

## Shipped defaults

`--no-usage-statistics`: the server collects usage statistics by default; this opts out. You can also set `CHROME_DEVTOOLS_MCP_NO_UPDATE_CHECKS` to stop its update checks.

## Risks

- The agent can read whatever is in the browser it controls. If you attach it to a browser you are signed in to, it can see that session. Prefer a dedicated profile.
- Page content is a prompt-injection channel.

## Last verified

2026-11-21: pinned version started, answered `initialize`, listed 33 tools. No browser session was driven.
