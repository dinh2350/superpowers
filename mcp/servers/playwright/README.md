# playwright

Microsoft's Playwright MCP server. Lets the agent drive a real browser (navigate, click, type, read the page) to see whether a UI change actually works.

- **Use when:** verifying front-end changes in a real browser, exploring a flow, reproducing a UI bug.
- **Skip when:** you already have a Playwright test suite. Run it with `npx playwright test`; that is cheaper and repeatable. Use the MCP for exploration, then turn what you learn into a test.
- **Transport:** stdio via `npx`, pinned to `@playwright/mcp@0.0.86`. Needs Node >= 20.
- **Tools:** 25.

## Shipped defaults and variants

The config passes `--isolated`: the browser profile lives in memory, so cookies and logins are not saved to disk.

| Want | Change |
| --- | --- |
| Keep logins between runs | Remove `--isolated` (a persistent profile can serve only one client at a time) |
| Headless (CI, servers) | Add `--headless` |
| Another browser | `--browser chrome\|firefox\|webkit\|msedge` |
| Restrict navigation | `--allowed-origins "https://a.com;https://b.com"`. Playwright's own docs say this is **not** a security boundary. |

If a browser binary is missing on first run, install one with `npx playwright install <browser>`.

## Risks

- It browses arbitrary pages; page content is a prompt-injection channel. Don't point it at untrusted sites with a logged-in profile.

## Last verified

2026-11-21: pinned version started (reported Playwright 1.66.0-alpha), listed 25 tools. No browser session was driven.
