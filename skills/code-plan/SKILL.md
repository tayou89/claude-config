---
name: code-plan
description: Write implementation plans and get user approval before starting non-trivial work (new features, structural changes, complex bug fixes). Auto-triggered on implementation requests.
---

# Plan Workflow

## 1. Prepare claude-plans Folder

Ensure `claude-plans/` exists in the project root. Verify `claude-plans/` is in global gitignore (`~/.gitignore_global`) and `core.excludesfile` is set.

## 2. Determine Plan File

- Filename: `plan-{feature-name}.md` (English kebab-case)
- Existing file: add new version at top (keep previous versions)
- New file: create fresh
- **Parent-child structure**: Child plans live in a subfolder named after the parent's topic (parent filename without `plan-` prefix and `.md` suffix). When a plan first gains children, the parent itself moves INTO that folder (`plan-foo.md` → `foo/plan-foo.md`). Children sit alongside the parent (`foo/plan-bar.md`). Grandchildren recurse: `foo/bar/plan-baz.md`. Standalone plans (no children) stay flat at `claude-plans/plan-xxx.md`.
- **Split rule**: If parent file exceeds ~30k tokens OR a task is conceptually separate, create a child plan following the structure above. Include `### Parent Plan` section with sibling path (`plan-foo.md`) or ancestor path (`../plan-foo.md`), version, task reference, prerequisites. Update parent's task entry with a cross-reference to the new file.
- **Completion marking**: When a plan's latest version's work is fully complete (all implementation steps committed, no follow-up scope remaining, no further versions expected), rename `plan-foo.md` to `plan-foo.done.md` and change the latest version's status line to `COMPLETED`. Parent plan references to this file must update to the new `.done.md` suffix. Plans with any pending/active work stay as `plan-foo.md`. Filter active plans with `find claude-plans -name 'plan-*.md' ! -name '*.done.md'`.

## 3. Reference Code Style

If plan includes code changes, read `code-style` skill and apply rules to diff code and implementation code.

## Language

All plan content (headings, descriptions, steps, commit messages) MUST be written in **English**.

## 4. Plan Format

New plan = v1, revision = previous version + 1.

```markdown
## v{N} — {YYYY-MM-DD} | PENDING APPROVAL
{revision only: ### Changes from v{N-1}\n- change list}

### Goal
What and why, concisely.

### Implementation Steps
1. Step-by-step plan with before/after diff blocks:

\`\`\`diff
# path/to/file.ts (L42-45)
- old code
+ new code
\`\`\`

### Architecture (if structural changes)
Module relationships, data flow, inheritance in ASCII diagrams. Skip for simple file edits.

### Files to Modify / Create
- `path/to/file.ts` — reason

### Test Approach
- How to verify
```

**Revision rules**: Mark previous version as `SUPERSEDED`. New version must be **independent and complete** — don't reference previous versions ("same as v2"). Keep previous versions as history.

## 5. Request Approval

Show plan summary and wait for **explicit approval**. No implementation code before approval.

## 6. After Approval

Mark version as `APPROVED` and begin implementation.

## 7. Mid-Implementation Changes

**Design changes** (logic, API, architecture): write new version (v{N+1}), mark previous as SUPERSEDED, get approval.
**Minor fixes** (params, typos, user-directed): inline edit in current version, no separate approval needed.
