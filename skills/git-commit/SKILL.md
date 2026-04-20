---
name: git-commit
description: Review changes, write commit message, and commit with user approval.
---

# Commit Workflow

## 1. Branch Check (First Commit of Session Only)

Check current branch with `git branch --show-current`. If on `main`, `dev`, or other base branch, ask user if they want a new working branch (e.g. `fix/xxx`, `feat/xxx`). Skip if already on a working branch (`fix/`, `feat/`, `refactor/`). Skip for subsequent commits.

## 2. Review Changes

```bash
git status
git diff --stat
```

## 3. Code Review

Before writing commit message, review changed code:

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

**Subject**: English, start with verb (add, fix, update, remove), no period, specific, max 72 chars (50 recommended).

**Body**: English `- ` bullets after blank line. First bullet carries purpose (*why* + *what*). 3-5 bullets, ~6-8 lines total. Focus on context not visible from diff — delete bullets that restate the diff. No internal terms (Step 1, Phase 2-a). Max 72 chars/line. Merge commits: list branches and conflict resolution.

## 5. Staging and Commit

**One commit = one topic.** If multiple topics are mixed, separate into multiple commits. `.ts` source and its build output (`.js`, `.js.map`) must be in the same commit.

**Bug found during feature work**: if not yet committed, include in feature commit (no separate Fix). If already committed, amend into previous commit.

**Staging verification (required)**: Before committing, show `git diff --cached --stat` to user and get approval. **Never run `git commit` without user approval.**

Remove unrelated files with `git restore --staged <file>` if found.

**Hook bypass**: Direct `git commit` is blocked by a PreToolUse hook. The skill-driven commit MUST prepend `CLAUDE_SKILL_GIT_COMMIT=1` to bypass the hook. This env var has no runtime effect — it's purely a marker proving the skill workflow was followed.

```bash
CLAUDE_SKILL_GIT_COMMIT=1 git commit -m "$(cat <<'EOF'
<Type>: <subject>

- <detail 1>
- <detail 2>
EOF
)"
```

For amend, same pattern: `CLAUDE_SKILL_GIT_COMMIT=1 git commit --amend ...`

## 6. Amend Check

Check `git log --oneline -3` before committing. If current changes are a continuation/supplement of the previous commit:
1. Propose `--amend` to user
2. On approval: `git commit --amend -m "<updated message>"`
3. If already pushed: warn about `--force-with-lease` requirement

Amend when: same file/same purpose, filling gaps from previous commit, same plan/feature.
Don't amend: different purpose, already pulled by others.

## 7. Push

Ask user about push after commit. Push only on approval.

## Rules

- Never commit `.env`, auth keys, passwords
- Never stage/commit unrelated changes
- Use `git add -A` / `git add .` with caution
- **No `Co-Authored-By`** or auto-generated trailers
- `~/.claude/settings.json` changes should **always be included** in commits (syncs allowedTools across environments)
