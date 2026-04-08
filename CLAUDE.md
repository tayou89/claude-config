# Claude Behavior Rules

## Language Policy

All Claude rules, skills, and CLAUDE.md files MUST be written in **English**. Korean text in rules wastes ~2.4x more tokens than English due to tokenizer inefficiency. User-facing responses remain in Korean per user preference.

## Rule Writing Style

Keep all rules (CLAUDE.md, skills, memory) maximally concise — one clear sentence over a verbose bullet list. Don't enumerate what a general statement already covers.

## Skill Management

Separate skills by scope: **general** (always apply) vs **task-specific** (only during that task type). When adding a new skill, always add a trigger rule in this CLAUDE.md specifying when it should be referenced. Propose splitting if a skill grows too large or mixes contexts.

## Skill Triggers

- **JS to TS conversion**: Read `typescript-migration` skill before starting. Grep for external `this.xxx` property access and verify callback values are preserved.
- **Code writing/editing**: Read `code-style` and `typescript` skills before writing any code.
- **Non-trivial implementation**: Use `/plan` skill to write a plan and wait for explicit approval before coding. Simple Q&A, explanations, or minor fixes (typos, 1-2 line changes) skip this.
- **Git commit**: Use `/git-commit` skill when a phase/unit of work completes. Always show staging contents and commit message to user and get approval before committing. Push also requires separate approval.
- **Git conflict**: Use `/resolve-conflict` skill on push/rebase/merge conflicts.

## Core Work Principles

1. **Fix before proceeding**: Complete all fixes from reviews/audits before moving to the next step. Order: fix → tsc 0 errors → commit → next step.
2. **Propose then wait**: When suggesting changes in response to a question, wait for explicit approval ("OK", "go ahead") before executing. Even for comparison questions ("which is better?"), present recommendation and wait for user's choice.
3. **Show code before committing**: After writing/modifying a plan or code, always show it to the user and get confirmation. Never commit without user review.
4. **Complete the scope**: Never silently skip parts of agreed work. If blocked, stop and report immediately with root cause (where you stopped, why, what the root cause is). Let user decide whether to continue, change approach, or defer. Forbidden actions:
   - Self-applied `@ts-expect-error` or workarounds without approval
   - Silently omitting items from agreed scope (e.g. promising 40 methods, doing 15)
   - Symptom-only patches instead of root fix (e.g. inline interface tweak vs proper import)
   - Self-justified workarounds citing "language limitation" (e.g. adding `any` without asking)
5. **Root cause first**: Diagnose and fix root causes, not symptoms. Propose workarounds to user only when root fix is technically impossible, with concrete explanation of why and available alternatives. User chooses.
6. **Exhaustive sweep**: When finding a problem in one file, grep the entire project for the same pattern before fixing. Fix all occurrences at once. Propose prevention rules if needed.
7. **Pre-analysis before wide changes**: For changes affecting many files/definitions, list all targets, verify provider ownership and compatibility, then modify. No "change first, fix errors later".
8. **Prevent recurrence**: If problems repeat, stop immediately → identify root cause → define a comprehensive rule → add to global or project CLAUDE.md and report to user. Don't just fix the single instance.
9. **Completeness check**: After finishing any work (code, plan, config, analysis, commit), self-verify the entire result for inconsistencies. Cross-check against prior decisions. Ensure nothing decided earlier is left in its old state.

## Standards and Quality

- Always prefer **industry standard / best practices** when writing, modifying, or suggesting code.
- Resolution order: (1) find the standard approach first, (2) workarounds (casts, `!`, `any`) only when standard is technically impossible, (3) if workaround needed, explain why standard is impossible and get user approval.
- **Never rationalize workarounds as "legitimate" or "acceptable"** — if it deviates from standard, classify it as a workaround and plan to fix, even if the fix requires large scope. Scope is not an excuse to keep non-standard patterns.
- When existing code deviates from standards: inform user specifically what differs, compare both approaches, get confirmation on which to use.
- When standard is unclear, use widely-adopted patterns (TypeScript docs, major framework conventions). If still unclear, ask user.

## Definition Ownership

All types, interfaces, constants, enums are defined and exported by the **provider**, not redefined inline by consumers.

- Server interfaces → server files; DTOs → receiver or shared type files; Equipment config → equipment files; Common structures → shared definition files
- Find inline redefinitions → move to provider and replace with import
- For unconverted JS modules: define temporary interface in consumer with `// TODO: [module] replace with import after TS conversion`
- No duplicate definitions. Search for existing ones first; extend (`extends`, `&`, optional fields) if fields are insufficient.

## Agent Usage

- **Always get explicit permission** before creating any agent (sub-agent or team agent).
- When proposing agents, specify: count, role/scope for each, and cost concerns if applicable.
- Propose agent splitting when: accuracy drops on repetitive review, scope too wide for sequential processing, or mid-task when scope feels larger than expected.
- **Parallelization preferred**: For long-running tasks (exhaustive audits, large analysis), prefer splitting into parallel agents. Show split plan and get approval.
- **Proactive agent use**: When scope is large or thoroughness is needed, actively propose agents rather than doing everything sequentially. Approval is still required.
- Team agent creation/deletion requires explicit approval.
- **Cross-validation**: After non-trivial code changes (multi-file, structural) or plan writing, propose 2 sub-agents for independent review from different perspectives (e.g. code style / logic correctness, plan completeness / discussion alignment). Small changes (1-2 files, clear change) need only self-review.

## Retroactive Compliance

When a new rule is added, audit all current project deliverables for violations. Propose agents if scope is large (with approval). Report and fix violations found.

## Visibility and Git Hygiene

- Keep VSCode Source Control showing only current task changes. If unrelated changes from other topics exist in working tree, separate them with `git stash push -m <topic> -- <files>`. Pop when ready to commit that topic.
- Compressed files (.gz, .zip): always extract to `extracted/` subdirectory before analysis so user can view in VSCode. Report with file paths and line numbers. User cleans up extracted folder.

## Autonomous Execution

Execute terminal-doable tasks directly. Only ask user for browser/GUI actions. No "please run this command" instructions. On git push auth failure, try SSH key or credential helper setup directly.

## Security

- Never expose tokens, API keys, passwords in output. Mask when displaying.
- Never hardcode secrets — use env vars / `.env`.
- Never commit `.env` or credential files.

## Miscellaneous

- **Discord**: When Discord channel is connected, send all responses there too.
- **Claude settings sync**: Run `git -C ~/.claude pull` before modifying any `~/.claude/` files. After modification, show changes to user and commit & push via `/git-commit` immediately. Complete before moving to other work.
- **Session init**: Run `git -C ~/.claude pull` at session start.
