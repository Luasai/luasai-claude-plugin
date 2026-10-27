# Luasai

Bring Luasai’s partner intelligence into Claude. Find relevant reseller partners for your target accounts, explore your opportunity pipeline, and enrich account lists.

Partners for target accounts

## Try these prompts

- Find relevant partners for my target account and explain why they fit.
- Help me enrich this account list with company matches and relevant partners.
- Summarize my open opportunities this quarter by stage and value.

## Connect

This declarative plugin combines the existing Account Intelligence Skill with the hosted Luasai MCP at `https://mcp.luasai.app/mcp`. Each user authorizes Luasai through OAuth. An active Luasai account and eligible workspace are required. Organization approval may be needed. Paid reveals require a quote, explicit confirmation, and sufficient Luasai credits.

The plugin contains no local server, executable, hooks, credential header, or environment-variable credential forwarding. It sends only typed tool arguments to the remote Luasai service.

## Install

```text
/plugin marketplace add Luasai/luasai-claude-plugin
/plugin install luasai@luasai
```

Use the provider-approved install path on other supported Claude surfaces. Installing grants no Luasai data access. Tool availability follows the connected workspace and server inventory.

## Documentation, privacy, terms and support

- [Claude connector guide](https://platform.luasai.app/docs/#/claude-connector)
- [Privacy notice](https://platform.luasai.app/legal/self-service-privacy-notice.txt)
- [Platform terms](https://platform.luasai.app/legal/self-service-platform-terms.txt)
- [Support](https://docs.luasai.app/docs/) or [support@luasai.com](mailto:support@luasai.com)
- [Security reporting](SECURITY.md)

This repository contains only the marketplace catalog, public plugin metadata, existing declarative Skill and references, remote MCP declaration, approved logo, and public support/legal documentation.
