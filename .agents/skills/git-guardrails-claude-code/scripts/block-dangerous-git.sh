#!/bin/bash
# Claude Code PreToolUse hook: blocks destructive git commands.
# A literal pattern check that stops mistakes. It does not parse shell syntax, so
# indirection such as variables, eval or aliases is out of scope.
# Uses POSIX character classes only, so it behaves the same with GNU and BSD/macOS grep.

INPUT=$(cat)

# Without jq the command can't be decoded reliably. Fail closed for anything that
# mentions git and let everything else through.
if ! command -v jq >/dev/null 2>&1; then
  if printf '%s' "$INPUT" | grep -q 'git'; then
    echo "BLOCKED: install jq so the git guardrail can check git commands." >&2
    exit 2
  fi
  exit 0
fi

if ! COMMAND=$(printf '%s' "$INPUT" | jq -er '.tool_input.command // empty' 2>/dev/null) || [ -z "$COMMAND" ]; then
  if printf '%s' "$INPUT" | grep -q 'git'; then
    echo "BLOCKED: git guardrail hook could not read this command, so it was not allowed." >&2
    exit 2
  fi
  exit 0
fi

# Join backslash-newline continuations the way the shell does.
COMMAND=$(printf '%s' "$COMMAND" | sed -e ':a' -e '/\\$/N; s/\\\n//; ta')

SP='[[:space:]]'
NS='[^[:space:]]'
VAL="(\"[^\"]*\"|'[^']*'|${NS}+)"
# "git" (or a path to it, e.g. /usr/bin/git) plus any global options before the subcommand
# (-C <dir>, -C<dir>, -c k=v, --git-dir=<dir>, --git-dir <dir>, --no-pager, ...).
GIT="(^|[^[:alnum:]_.-])(${NS}*/)?git(${SP}+(-[Cc]${SP}*${VAL}|--(git-dir|work-tree|namespace|exec-path)(=|${SP}+)${VAL}|-[[:alpha:]]|--[[:alpha:]][-[:alnum:]]*(=${VAL})?))*${SP}+"
# Rest of a single shell command (stops at ; & |)
ARGS="([^;&|]*${SP})?"
END="(${SP}|\$|[;&|\"')])"

DANGEROUS_PATTERNS=(
  "${GIT}push${END}"
  "${GIT}reset${SP}${ARGS}--hard"
  "${GIT}clean${SP}${ARGS}(-[[:alpha:]]*f|--force)"
  "${GIT}branch${SP}${ARGS}(-[[:alpha:]]*D|-[[:alpha:]]*d[[:alpha:]]*f|-[[:alpha:]]*f[[:alpha:]]*d|(-d|--delete)${SP}${ARGS}(-f|--force)|(-f|--force)${SP}${ARGS}(-d|--delete))"
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
