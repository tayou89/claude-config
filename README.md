# Shared AI Configuration

This repository contains existing Claude Code configuration and shared writing guidance for Claude Code and Codex.

## Writing guidance

- [Shared Writing Principles](rules/writing.md) is the source for project-independent writing rules.
- [Codex global instructions](codex/AGENTS.md) is an identical copy for Codex's global instruction file.
- [Claude behavior rules](CLAUDE.md) links to the shared principles.

The shared rules cover heading hierarchy, paragraphs and lists, precise wording, preservation of meaning, and final review. They contain no project examples.

## Apply on a computer

| Tool | User-level destination | Scope |
| --- | --- | --- |
| Codex | `~/.codex/AGENTS.md` | All projects for that user when Codex loads its instruction chain |
| Claude Code | `~/.claude/rules/writing.md` | All projects for that user when Claude Code loads user rules |

Use the configured home directory if `CODEX_HOME` or `CLAUDE_CONFIG_DIR` is customized. These are tool-specific user instructions, not an operating-system-wide setting for every app.

Before installation, inspect and preserve any existing instruction files. For Codex, merge the content of `codex/AGENTS.md` into the existing global file rather than overwriting unrelated instructions. Check for `AGENTS.override.md`, which takes precedence at the global level. Start a new session to verify loading.

For Claude Code, place `rules/writing.md` in the user-level rules directory. If this repository is checked out directly at `~/.claude`, that file is already in its user-level location. No additional import is required. Existing project guidance must remain consistent with these rules.

## Maintaining the shared rules

Edit `rules/writing.md` and keep `codex/AGENTS.md` identical in the same change. After updating GitHub, explicitly refresh the installed local copies. GitHub updates alone do not synchronize them.

Keep machine-specific paths, permissions, plugins, hooks, and credentials separate from the shared writing guidance. Installing the writing rules does not require copying `settings.json` or installing the existing Claude-only scripts and skills.

## References

- [Codex global instructions](https://learn.chatgpt.com/docs/agent-configuration/agents-md)
- [Claude Code user-level rules](https://code.claude.com/docs/en/memory#user-level-rules)
