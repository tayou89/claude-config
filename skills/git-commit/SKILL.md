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

## 2. 코드 리뷰

커밋 메시지 작성 전, 변경된 코드를 리뷰한다.

### 확인 항목
- **논리적 오류/버그**: 변경된 코드에 race condition, 미초기화 변수, 누락된 에러 처리 등이 없는지
- **커밋 범위**: 이번 작업과 관련 없는 변경(테스트 설정, 디버깅 코드, 다른 기능 수정 등)이 섞여 있는지
- **보안**: 하드코딩된 키, 토큰, 비밀번호 등이 포함되지 않았는지
- **빌드 산출물 정합성**: `.ts`와 함께 `.js`/`.js.map`이 변경된 경우 빌드 결과가 소스와 일치하는지

### 리뷰 결과 보고
- 문제가 없으면 간단히 "코드 리뷰 완료 — 이상 없음"으로 넘어간다
- 문제가 있으면 **구체적으로 알리고** 커밋 진행 여부를 사용자에게 확인받는다
- 커밋 범위에서 제외해야 할 파일이 있으면 사용자에게 알린다

## 3. 커밋 메시지 규칙

**형식:**
```
<Type>: <subject>

- <변경 상세 1>
- <변경 상세 2>
```

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

### Body 규칙
- 첫 줄(subject) 아래에 **빈 줄** 후 `- ` 항목으로 변경 상세를 나열
- **영어**로 작성 (subject와 동일)
- 각 항목은 **무엇을 왜 변경했는지** 구체적으로 기술 (파일명, 함수명, 증상 → 원인 → 수정 내용)
- 단순 변경(한 가지만 수정)이라도 body를 작성하여 맥락을 남긴다
- Merge 커밋의 경우 포함된 브랜치/변경사항, 충돌 해결 내역을 상세히 기록

### 예시
```
Feat: add sub-compatible battery check on slot-fixed work allocation

- warehouse.js: add isSubCompatible() check before slot assignment
- work.js: filter out incompatible batteries in getAvailableBatteries()

Fix: resolve sync pending deadlock on warehouse task cancellation

- work-control.js: clear syncPending flag in cancel handler to prevent deadlock
- warehouse.js: add finally block to reset pending state on error

Merge: dev into taegab/feat/teams-webhook for trial operation

- Merge feature/update-api-response-types (API response types V2 spec)
- Merge taegab/fix/warehouse-cancel-sync-pending (deadlock fix, GPU service disable)
- Resolve conflicts:
  - equipment/scada.js: adopt dev condition + info level
  - controller/transport.js: fix workplaceId bug → swapWorkIdx + info level
```

## 4. 파일 스테이징 및 커밋

```bash
git add <파일명>   # 특정 파일만 스테이징 (.env, 민감정보 제외)
```

### 스테이징 확인 (필수)

커밋 실행 전에 반드시 `git diff --cached --stat`으로 스테이징된 파일 목록을 사용자에게 보여주고 확인받는다. **사용자 승인 없이 `git commit`을 실행하지 않는다.**

- 작업과 무관한 파일이 포함되어 있으면 `git restore --staged <파일명>`으로 제외한다
- 테스트 설정, 디버깅 코드, 다른 기능 수정 등이 섞여 있으면 사용자에게 알리고 제외 여부를 확인한다

```bash
git commit -m "$(cat <<'EOF'
<Type>: <subject>

- <변경 상세 1>
- <변경 상세 2>
EOF
)"
```

## 5. 연속 커밋 흡수 (amend)

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
- **작업과 무관한 변경사항은 절대 스테이징/커밋하지 않는다** (테스트 설정 변경, 디버깅 코드, 다른 기능 수정 등)
- `git add -A` 또는 `git add .` 사용 주의 — 불필요한 파일 포함 가능성
- `Co-Authored-By` 등 자동 생성 trailer를 커밋 메시지에 넣지 않는다
