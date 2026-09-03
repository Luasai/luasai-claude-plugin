# Luasai Account Intelligence for Claude

This public repository contains the declarative Luasai plugin for Claude Code
and Cowork. It combines the Account Intelligence Skill with the hosted Luasai
MCP at `https://mcp.luasai.app/mcp`.

It contains no Luasai backend code, credentials, customer data, hooks,
executables, local servers, or installation scripts.

## What it does

The Account Intelligence Skill helps a user enrich an account list using the
governed Luasai organization and partner graph. Claude keeps the user’s file
and decision context; Luasai supplies bounded organization and relationship
results. The Skill requires positive identity evidence and reports an explicit
abstention when it cannot identify an organization safely.

Installing the plugin grants no data access. Each user must authorize Luasai
through OAuth, and the server applies that user’s active tenant membership and
scopes. Paid relationship reveals remain subject to the server quote and the
active client’s confirmation flow.

## Install

For Claude Code, add this marketplace source and then install the named plugin:

```text
/plugin marketplace add Luasai/luasai-claude-plugin
/plugin install luasai@luasai
```

For Cowork or other Claude plugin surfaces, use the provider-approved plugin
installation path for this repository. An organization administrator may need
to approve the plugin and the Luasai remote connector. After installation,
connect the Luasai MCP when Claude prompts for OAuth.

## Support and privacy

- Privacy policy: <https://platform.luasai.app/privacy>
- Support: <mailto:support@luasai.com>
- Security reporting: see [SECURITY.md](SECURITY.md)

## Repository contents

- `.claude-plugin/marketplace.json` — marketplace catalog.
- `plugins/luasai/.claude-plugin/plugin.json` — plugin identity and release
  metadata.
- `plugins/luasai/.mcp.json` — the production remote MCP declaration.
- `plugins/luasai/skills/account-intelligence/` — declarative Skill and its
  public references.

This repository is intentionally limited to reviewable release assets. Luasai
operates the remote MCP and OAuth service separately.
