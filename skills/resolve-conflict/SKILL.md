---
name: resolve-conflict
description: Analyze git push/rebase/merge conflicts, record resolution plan as a version revision, and resolve after user approval.
---

# Resolve Conflict Workflow

## 1. Assess Conflict State

```bash
git status
git diff --name-only --diff-filter=U   # conflicted files
```

## 2. Analyze Cause

- Check what commits were added to remote (`git log origin/main --oneline`)
- Compare both sides' changes in conflicted files
- Identify conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`) location and content

## 3. Add Plan Revision

Add a **new version at the top** of the existing plan file (`claude-plans/plan-{feature-name}.md`):

```markdown
## v{N} — {YYYY-MM-DD} | PENDING APPROVAL

### Changes from v{N-1}
- Add conflict resolution steps

### Conflict Cause
- What happened (remote changes)
- Which files, where conflicts occurred

### Conflict Details
| Item | Local commit | Remote current |
|------|-------------|----------------|
| ... | ... | ... |

### Resolution Steps
1. Step-by-step resolution plan
2. ...
```

Mark previous version as `SUPERSEDED`.

## 4. Request Approval

Summarize and present to user. **Wait for explicit approval** before starting resolution.

## 5. Resolve After Approval

Mark version as `APPROVED` and proceed:
- Rebase conflict: `git rebase --abort` → clean pull → reapply changes
- Merge conflict: resolve → `git add` → `git merge --continue`
- Commit & push

## Rules

- No `git push --force` without user confirmation
- Never arbitrarily overwrite the other side's changes
- Verify both sides' changes are preserved after resolution
