#!/usr/bin/env python3
"""PreToolUse hook for Bash: deny direct `git commit`, point to wrapper.

Strips quoted strings and heredoc bodies before regex match so commit
messages, descriptions, or doc text mentioning the phrase are not
mistaken for command invocations.

Recognized command-position contexts:
  - start of command string
  - after a chain operator (;  &&  ||  | )
  - after one or more env-var assignments (VAR=value cmd)
"""

import json
import re
import sys


def strip_strings_and_heredocs(text: str) -> str:
    """Remove quoted strings and heredoc bodies from a shell command.

    Conservative: keeps the rest of the structure intact so chain
    operators and env prefixes outside quotes are still detectable.
    """
    text = re.sub(
        r"<<-?\s*['\"]?(\w+)['\"]?\n.*?\n\1\b",
        "\n",
        text,
        flags=re.DOTALL,
    )
    text = re.sub(r"'[^']*'", "''", text)
    text = re.sub(r'"(?:[^"\\]|\\.)*"', '""', text)
    return text


def looks_like_git_commit_command(command: str) -> bool:
    cleaned = strip_strings_and_heredocs(command)
    pattern = (
        r"(?:^|[;&|]|^\s*(?:[A-Z_][A-Z0-9_]*=\S+\s+)+)"
        r"\s*git\s+commit(?:\s|$)"
    )
    if re.search(pattern, cleaned, flags=re.MULTILINE):
        return True
    if re.search(r"\bgit\s+commit\b(?!-)", cleaned):
        chain_or_start = re.compile(
            r"(?:^|[;&|\n])\s*(?:[A-Z_][A-Z0-9_]*=\S+\s+)*git\s+commit\b"
        )
        return bool(chain_or_start.search(cleaned))
    return False


def main() -> None:
    payload = json.load(sys.stdin)
    command = payload.get("tool_input", {}).get("command", "")

    if not looks_like_git_commit_command(command):
        return

    reason = (
        "Direct git commit blocked. Use ~/.claude/scripts/claude-commit.sh "
        "with message and files as args (prepend --amend if amending). "
        "The wrapper validates subject/body format (type prefix, line "
        "length, body lines, bullet count, no internal terms), runs "
        "amend check, stages exact files, prints diff --cached --stat "
        "plus verification table, then invokes git commit via subprocess "
        "so this hook does not re-fire."
    )
    output = {
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": reason,
        }
    }
    print(json.dumps(output))


if __name__ == "__main__":
    main()
