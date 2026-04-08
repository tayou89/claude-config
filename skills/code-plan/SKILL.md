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

## 3. Reference Code Style

If plan includes code changes, read `code-style` skill and apply rules to diff code and implementation code.

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
