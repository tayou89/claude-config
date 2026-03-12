---
name: git-commit
description: 변경사항을 검토하고 커밋 메시지를 작성한 뒤 커밋합니다
allowed-tools: Bash(git *)
---

# Commit Workflow

## 1. 변경사항 확인

```bash
git status
git diff --stat
```

## 2. 커밋 메시지 규칙

**형식:** `<Type>: <subject>`

### Type (첫 글자 대문자)
| Type | 사용 시점 |
|------|----------|
| `Feat` | 새로운 기능 추가 |
| `Fix` | 버그 수정 |
| `Refactor` | 기능 변경 없이 코드 개선 |
| `Chore` | 설정, 빌드, 의존성 등 기타 작업 |
| `Merge` | 브랜치 병합 |

### Subject 규칙
- **영어**로 작성
- **동사 원형**으로 시작 (add, fix, update, remove, improve, resolve, integrate 등)
- 마침표 없음
- **구체적**으로 무엇을 했는지 명시

### 예시
```
Feat: add sub-compatible battery check on slot-fixed work allocation
Fix: resolve sync pending deadlock on warehouse task cancellation
Fix: skip mail send when no recipients defined
Refactor: improve logger strategy, file output, and log level audit
Chore: disable gpuServer pin detection service calls in transport
Merge: dev into taegab/feat/teams-webhook for trial operation
```

## 3. 파일 스테이징 및 커밋

```bash
git add <파일명>   # 특정 파일만 스테이징 (.env, 민감정보 제외)
git commit -m "<Type>: <subject>"
```

## 4. 연속 커밋 흡수 (amend)

커밋 전에 `git log --oneline -3`으로 최근 커밋을 확인한다.
현재 변경사항이 **직전 커밋과 동일한 작업의 연속/보완**이면:

1. 사용자에게 `--amend`로 흡수할지 확인한다
2. 승인 시 `git commit --amend -m "<새 메시지>"`로 기존 커밋에 흡수하고 커밋 메시지를 갱신한다
   - 변경 범위가 넓어졌으면 커밋 메시지도 그에 맞게 수정
3. 이미 push된 커밋이면 `--force-with-lease`가 필요하므로 반드시 사용자에게 알린다

**amend 대상 판단 기준:**
- 같은 파일을 같은 목적으로 수정한 경우
- 이전 커밋의 누락분을 보완하는 경우
- 같은 plan/feature에 대한 수정인 경우

**amend 하지 않는 경우:**
- 목적이 다른 별개 작업
- 다른 사람이 이미 pull한 커밋

## 주의사항
- `.env`, 인증키, 비밀번호 등 민감 정보 커밋 금지
- 관련 없는 변경사항은 별도 커밋으로 분리
- `git add -A` 또는 `git add .` 사용 주의 — 불필요한 파일 포함 가능성
