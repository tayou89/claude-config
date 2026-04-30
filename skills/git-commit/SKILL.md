---
name: git-commit
description: Review changes, write commit message, and commit with user approval via the claude-commit.sh wrapper.
---

# Commit Workflow

All commits MUST go through `~/.claude/scripts/claude-commit.sh`. Direct `git commit` is denied by a PreToolUse hook with no bypass. The wrapper enforces the full checklist (subject prefix, line-length, body-lines, bullet-count, internal-terms, amend check, staged-stat review, stage-matches-argv) automatically — Claude can no longer skip a step.

## 1. Branch Check (First Commit of Session Only)

Check current branch with `git branch --show-current`. If on `main`, `dev`, or other base branch, ask user if they want a new working branch (e.g. `fix/xxx`, `feat/xxx`). Skip if already on a working branch (`fix/`, `feat/`, `refactor/`). Skip for subsequent commits.

## 2. Review Changes (informational, before drafting message)

```bash
git status
git diff --stat
```

## 3. Code Review (before drafting message)

- **Logic errors/bugs**: race conditions, uninitialized vars, missing error handling
- **Commit scope**: no unrelated changes (test config, debug code, other features) mixed in
- **Security**: no hardcoded keys, tokens, passwords
- **Build artifact consistency**: if `.ts` changed with `.js`/`.js.map`, verify build output matches source
- **Build side effects**: check for unrelated file changes after `tsc` (LF/CRLF diffs etc). Restore unrelated changes with `git restore`. Exception: `tsbuildinfo` is always meaningful during TS migration.

Report: "Code review done — no issues" if clean. If issues found, report specifically and confirm with user. Flag files that should be excluded.

## 4. Commit Message Format

```
<Type>: <subject>

- <detail 1>
- <detail 2>
```

**Type** (capitalized): `Feat`, `Fix`, `Refactor`, `Chore`, `Merge`

**Subject**: English, start with verb (add, fix, update, remove), no period, specific, **≤72 chars** (50 recommended).

**Body**: English `- ` bullets after blank line. First bullet carries purpose (*why* + *what*). **3-5 bullets, ≤8 non-blank body lines, ≤72 chars/line**. Focus on context not visible from diff — delete bullets that restate the diff. **No internal terms** (Step N, Phase N, Pattern N).

The wrapper rejects messages violating any of: type prefix, subject ≤72, line length ≤72, body lines 1-8, bullets 3-5, internal-term ban.

## 5. Show User Before Invoking Wrapper

Before running the wrapper, show user:
- Drafted message (with line-length self-check noted)
- File list to stage
- One-line code-review summary

Get explicit approval ("응 진행해줘" or equivalent). The wrapper then runs deterministically and commits.

## 6. Run the Wrapper

```bash
~/.claude/scripts/claude-commit.sh "$(cat <<'EOF'
<Type>: <subject>

- <bullet 1>
- <bullet 2>
- <bullet 3>
EOF
)" <file1> <file2> ...
```

For amend:

```bash
~/.claude/scripts/claude-commit.sh --amend "$(cat <<'EOF'
<updated message>
EOF
)" <file1> ...
```

The wrapper:
1. Validates subject prefix + length, body line length, body line count, bullet count, internal-term ban
2. Prints `git log --oneline -3` for amend awareness
3. Stages exact files passed as argv
4. Prints `git diff --cached --stat`
5. Verifies no extra files staged beyond argv (FAIL exit 3 otherwise)
6. Prints verification table
7. Invokes `git commit` (subprocess, hook does not re-fire) with `CLAUDE_SKILL_GIT_COMMIT=1` marker

Exit codes: `0` success, `1` git error, `2` message validation, `3` staging mismatch, `4` usage error.

## 7. Amend Check

Before drafting a new commit, check `git log --oneline -3`. If current changes are a continuation/supplement of the previous commit:
1. Propose `--amend` to user
2. On approval: invoke wrapper with `--amend`
3. If already pushed: warn about `--force-with-lease` requirement

Amend when: same file/same purpose, filling gaps from previous commit, same plan/feature.
Don't amend: different purpose, already pulled by others.

## 8. Push

Ask user about push after commit. Push only on approval.

## Rules

- Never commit `.env`, auth keys, passwords
- Never stage/commit unrelated changes
- Use `git add -A` / `git add .` with caution (the wrapper stages exactly what argv specifies)
- **No `Co-Authored-By`** or auto-generated trailers
- `~/.claude/settings.json` changes should **always be included** in commits (syncs allowedTools across environments)
