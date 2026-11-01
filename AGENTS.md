# Agent Instructions

## Agent skills

Shared skills (from [mattpocock/skills](https://github.com/mattpocock/skills)) live in `.agents/skills/`, which Codex and Kimi Code read directly. `.claude/skills/` symlinks to the same folders for Claude Code. Other models (e.g. DeepSeek) pick them up through whichever of these harnesses runs them. Versions are pinned in `skills-lock.json`; update with `npx skills update -p`.

### Issue tracker

GitHub Issues for this repo, via the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

Default vocabulary (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: `GLOSSARY.md` and `docs/adr/` at the repo root, created lazily. See `docs/agents/domain.md`.
