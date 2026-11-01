#!/bin/bash
# Claude Code PreToolUse hook: blocks destructive git commands.
# Fails closed: if the hook input can't be parsed, the command is blocked.

if ! command -v jq >/dev/null 2>&1; then
  echo "BLOCKED: git guardrail hook needs jq to inspect commands, and jq is not installed." >&2
  exit 2
fi

INPUT=$(cat)
if ! COMMAND=$(printf '%s' "$INPUT" | jq -er '.tool_input.command // empty' 2>/dev/null) || [ -z "$COMMAND" ]; then
  echo "BLOCKED: git guardrail hook could not read the command from its input." >&2
  exit 2
fi

# "git" plus any global options before the subcommand
# (e.g. -C <dir>, -c k=v, --git-dir=<dir>, --no-pager).
GIT='(^|[^[:alnum:]_./-])git(\s+(-[Cc]\s+\S+|--(git-dir|work-tree|namespace|exec-path)(=|\s+)\S+|-[[:alpha:]]|--[[:alpha:]][-[:alnum:]]*(=\S+)?))*\s+'
# Rest of a single shell command (stop at ; & |)
ARGS='([^;&|]*\s)?'

DANGEROUS_PATTERNS=(
  "${GIT}push(\s|$)"
  "${GIT}reset\s${ARGS}--hard"
  "${GIT}clean\s${ARGS}(-[[:alpha:]]*f|--force)"
  "${GIT}branch\s${ARGS}(-[[:alpha:]]*D|--delete\s${ARGS}--force|--force\s${ARGS}(-d|--delete))"
  "${GIT}checkout\s${ARGS}\.(\s|$|[;&|])"
  "${GIT}restore\s${ARGS}\.(\s|$|[;&|])"
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if printf '%s\n' "$COMMAND" | grep -qE -- "$pattern"; then
    echo "BLOCKED: '$COMMAND' is a destructive git command. The user has prevented you from doing this." >&2
    exit 2
  fi
done

exit 0
