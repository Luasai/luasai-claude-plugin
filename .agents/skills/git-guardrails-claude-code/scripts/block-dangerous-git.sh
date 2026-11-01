#!/bin/bash
# Claude Code PreToolUse hook: blocks destructive git commands.
# Uses POSIX character classes only, so it behaves the same with GNU and BSD/macOS grep.

INPUT=$(cat)

if command -v jq >/dev/null 2>&1; then
  if ! COMMAND=$(printf '%s' "$INPUT" | jq -er '.tool_input.command // empty' 2>/dev/null) || [ -z "$COMMAND" ]; then
    # Can't read the command: block only if the raw input mentions git at all.
    if printf '%s' "$INPUT" | grep -q 'git'; then
      echo "BLOCKED: git guardrail hook could not read this command, so it was not allowed." >&2
      exit 2
    fi
    exit 0
  fi
else
  # No jq: fall back to the raw JSON so non-git commands still run.
  COMMAND=${INPUT//\\\"/\"}
fi

SP='[[:space:]]'
NS='[^[:space:]]'
VAL="(\"[^\"]*\"|'[^']*'|${NS}+)"
# "git" plus any global options before the subcommand
# (-C <dir>, -C<dir>, -c k=v, --git-dir=<dir>, --git-dir <dir>, --no-pager, ...).
GIT="(^|[^[:alnum:]_./-])git(${SP}+(-[Cc]${SP}*${VAL}|--(git-dir|work-tree|namespace|exec-path)(=|${SP}+)${VAL}|-[[:alpha:]]|--[[:alpha:]][-[:alnum:]]*(=${VAL})?))*${SP}+"
# Rest of a single shell command (stops at ; & |)
ARGS="([^;&|]*${SP})?"
END="(${SP}|\$|[;&|\"])"

DANGEROUS_PATTERNS=(
  "${GIT}push${END}"
  "${GIT}reset${SP}${ARGS}--hard"
  "${GIT}clean${SP}${ARGS}(-[[:alpha:]]*f|--force)"
  "${GIT}branch${SP}${ARGS}(-[[:alpha:]]*D|--delete${SP}${ARGS}--force|--force${SP}${ARGS}(-d|--delete))"
  "${GIT}checkout${SP}${ARGS}\\.${END}"
  "${GIT}restore${SP}${ARGS}\\.${END}"
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if printf '%s\n' "$COMMAND" | grep -qE -- "$pattern"; then
    echo "BLOCKED: this is a destructive git command. The user has prevented you from doing this." >&2
    exit 2
  fi
done

exit 0
