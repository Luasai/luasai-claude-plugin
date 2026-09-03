# Security

This repository is a declarative plugin only. It must never contain secrets,
tokens, customer data, backend source code, executable hooks, local servers,
or installation scripts.

The plugin points to the Luasai remote MCP. OAuth happens between the user and
the Luasai authorization service; installing the plugin does not grant access
to any Luasai tenant or data.

Report suspected security issues privately to
[support@luasai.com](mailto:support@luasai.com). Do not include credentials,
access tokens, customer records, or sensitive screenshots in a public issue.
