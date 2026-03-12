---
name: resolve-conflict
description: Git push/rebase/merge 충돌 발생 시 원인을 분석하고, 계획서에 버전 리비전으로 기록한 뒤 사용자 승인 후 해결합니다.
model: opus
allowed-tools: Read, Write, Edit, Bash(git *), Bash(grep *), Bash(cat *), Bash(ls *), Glob, Grep
---

# Resolve Conflict Workflow

Git 충돌 발생 시 원인 파악 → 계획서 리비전 → 승인 후 해결하는 워크플로우.

## 1. 충돌 상태 확인

현재 충돌 상태를 파악한다:

```bash
git status
git diff --name-only --diff-filter=U   # 충돌 파일 목록
```

## 2. 원인 분석

충돌 원인을 분석한다:

- 리모트에 어떤 커밋이 추가됐는지 확인 (`git log origin/main --oneline`)
- 충돌 파일에서 양측 변경 내용 비교
- 충돌 마커(`<<<<<<<`, `=======`, `>>>>>>>`) 위치와 내용 확인

## 3. 계획서에 리비전 추가

기존 계획서(`plans/plan-{feature-name}.md`)에 **새 버전을 맨 위에 추가**한다.

```markdown
## v{N} — {YYYY-MM-DD} | PENDING APPROVAL

### Changes from v{N-1}
- 충돌 해결 단계 추가

### 충돌 원인
- 무슨 일이 있었는지 (리모트 변경 내역)
- 어떤 파일, 어느 위치에서 충돌이 발생했는지

### 충돌 세부 내역
| 항목 | 로컬 커밋 기준 | 리모트 현재 |
|------|--------------|------------|
| ... | ... | ... |

### 해결 단계
1. 단계별 해결 방법
2. ...

---
```

이전 버전의 상태를 `SUPERSEDED`로 변경한다.

## 4. 승인 요청

계획서 내용을 요약하고 사용자에게 전달한다:

```
충돌 분석을 완료하고 계획서를 업데이트했습니다: plans/plan-{feature-name}.md

[원인 요약]
[해결 방법 요약]

승인하시면 충돌 해결을 진행하겠습니다.
```

**명시적 승인을 기다린다.** 승인 전에는 충돌 해결 작업을 시작하지 않는다.

## 5. 승인 후 해결 진행

승인되면 해당 버전의 상태를 `APPROVED`로 변경하고 해결을 진행한다:

1. rebase 충돌인 경우: `git rebase --abort` → clean pull → 변경사항 재적용
2. merge 충돌인 경우: 충돌 해결 → `git add` → `git merge --continue`
3. 커밋 & push

## 주의사항

- `git push --force` 사용 금지 — 반드시 사용자 확인 필요
- 충돌 해결 시 상대방 변경사항을 임의로 덮어쓰지 않는다
- 해결 후 양측 변경사항이 모두 반영됐는지 검증한다
