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

## 3. Reference Relevant Skills

Plans must apply the same skill rules as implementation code. Before drafting diff blocks or step descriptions, read every skill whose trigger condition matches the plan's content. Common cases:

- **code-style**: any code change
- **typescript**: `.ts` file changes — includes type-system reasoning needed at planning time (e.g. structural-compat check before declaring an index signature dead)
- **typescript-migration**: JS→TS conversion
- **integration-testing**: live/simulator runtime test
- **agent-usage**: plans that spawn agents

Skipping this step produces avoidable plan revisions when implementation surfaces skill-documented constraints.

## 4. Pattern Alignment Check

For structural decisions (new file layout, where a new type lives, module split, naming), grep 2-3 analogous cases in the same codebase. Match the dominant local pattern, or justify the deviation in the plan. Skill rules don't override local conventions. If no precedent exists, flag it.

## Language

Plan content (headings, descriptions, steps) must be written in **Korean**.
Filenames stay English kebab-case (filesystem convention).
Commit messages follow git-commit skill rules separately.

## 5. Plan Format

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

## 6. Request Approval

Show plan summary and wait for **explicit approval**. No implementation code before approval.

## 7. After Approval

Mark version as `APPROVED` and begin implementation.

## 8. Mid-Implementation Changes

**Design changes** (logic, API, architecture): write new version (v{N+1}), mark previous as SUPERSEDED, get approval.
**Minor fixes** (params, typos, user-directed): inline edit in current version, no separate approval needed.

## 9. Commit Granularity

Plan steps ≠ commit count. Group steps so each commit is **independently buildable, self-sufficient (a reviewer understands why without reading the next commit), and revertable as one topic**. Write proposed commit groups in the plan alongside the step list — don't default to one-commit-per-step.

Belong-together signals: a definition with its first consumer ("introduce X" with X actually used); a producer change with the contract tightening it enables; small follow-up cleanup that depends on a prior structural change. If splitting them leaves one commit reading as "why is Y still stale?", fold into one. Decide by topic, not by step count or LOC.

If a partial commit was already made and the follow-up completes the picture, amend (`git commit --amend`) before pushing rather than landing the orphan commit.

## 10. Verification Batching

Verification with high setup cost (live runtime, simulator startup, external service stubs, manual operator steps) should be **batched across plans that touch the same system or pattern**. Don't run the same expensive verification twice when one round can cover both.

Batch-together signals: shared external system, shared simulator/harness setup, shared operator-driven flow, same pattern being introduced across multiple plans (validation, retry, caching, etc.). Don't batch unrelated topics — a problem in one section blocks the whole batch.

When deferring verification, record in the plan **what other plans the verification will batch with** so the deferral isn't forgotten and individual plans don't get pushed without coverage.
