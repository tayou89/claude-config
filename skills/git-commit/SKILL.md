---
name: git-commit
description: 변경사항을 검토하고 커밋 메시지를 작성한 뒤 커밋합니다
allowed-tools: Bash(git *)
---

# Commit Workflow

## 1. 브랜치 확인 (세션 첫 커밋 시)

해당 세션에서 **첫 번째 커밋**을 진행하기 전에, 현재 브랜치를 확인한다.

```bash
git branch --show-current
```

`main`, `dev` 등 **기본 브랜치에 있는 경우**, 새 브랜치를 생성할지 사용자에게 확인한다:

> 현재 `dev` 브랜치에 있습니다. 작업용 브랜치를 새로 생성할까요? (예: `fix/xxx`, `feat/xxx`)

- 사용자가 브랜치 생성을 원하면 `git checkout -b <브랜치명>`으로 생성 후 커밋을 진행한다
- 사용자가 현재 브랜치에서 진행하겠다고 하면 그대로 진행한다
- 이미 작업용 브랜치(`fix/`, `feat/`, `refactor/` 등)에 있으면 확인 없이 진행한다
- 두 번째 커밋부터는 이 확인을 생략한다

## 2. 변경사항 확인

```bash
git status
git diff --stat
```

## 3. 코드 리뷰

커밋 메시지 작성 전, 변경된 코드를 리뷰한다.

### 확인 항목
- **논리적 오류/버그**: 변경된 코드에 race condition, 미초기화 변수, 누락된 에러 처리 등이 없는지
- **커밋 범위**: 이번 작업과 관련 없는 변경(테스트 설정, 디버깅 코드, 다른 기능 수정 등)이 섞여 있는지
- **보안**: 하드코딩된 키, 토큰, 비밀번호 등이 포함되지 않았는지
- **빌드 산출물 정합성**: `.ts`와 함께 `.js`/`.js.map`이 변경된 경우 빌드 결과가 소스와 일치하는지
- **빌드 부수효과**: 빌드(`tsc` 등) 실행 후 작업과 무관한 파일이 변경되었는지 확인 (줄바꿈 LF/CRLF 차이 등). 무관한 변경은 `git restore`로 되돌린다. 단, `tsbuildinfo`는 TypeScript 전환이 진행 중인 프로젝트에서는 유의미한 변경이므로 커밋에 포함한다

### 리뷰 결과 보고
- 문제가 없으면 간단히 "코드 리뷰 완료 — 이상 없음"으로 넘어간다
- 문제가 있으면 **구체적으로 알리고** 커밋 진행 여부를 사용자에게 확인받는다
- 커밋 범위에서 제외해야 할 파일이 있으면 사용자에게 알린다

## 4. 커밋 메시지 규칙

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
- **50자 이내** 권장 (최대 72자)

### Body 규칙
- 첫 줄(subject) 아래에 **빈 줄** 후 `- ` 항목으로 변경 상세를 나열
- **영어**로 작성 (subject와 동일)
- **변경 목적(무엇을 위해)을 반드시 포함**한다. 이 변경이 최종적으로 무엇을 달성하기 위한 것인지(예: 모바일 HMI에서 작업자가 작업 정보를 확인할 수 있도록)를 명시한다. 목적을 알고 있으면 사용자에게 확인 후 기입하고, 모르면 반드시 사용자에게 물어본 뒤 기입한다
- diff만으로는 알 수 없는 **맥락(왜, 어떤 문제, 어떤 판단)** 에 집중한다. 코드 레벨 설명(파일명, 함수명)은 diff에서 확인 가능하므로 반복하지 않는다
- **내부 용어 금지**: 계획서 내부 용어(Step 1, Phase 2-a, 패턴 3 등)를 커밋 메시지에 사용하지 않는다. 계획서는 원격 저장소에 올라가지 않으므로 다른 개발자가 이해할 수 없다. 대신 **변경 내용 자체를 서술**한다 (예: "Step 4-a" → "convert equipment map files to TypeScript")
- 한 줄은 **72자 이내**로 작성. 길면 줄바꿈하여 가독성을 유지한다
- 단순 변경(한 가지만 수정)이라도 body를 작성하여 맥락을 남긴다
- Merge 커밋의 경우 포함된 브랜치/변경사항, 충돌 해결 내역을 상세히 기록

### 예시
```
Feat: add sub-compatible battery check on slot-fixed work allocation

- Prevent incompatible batteries from being assigned to slot-fixed work
- Filter candidates by sub-compatibility before slot assignment

Fix: resolve sync pending deadlock on warehouse task cancellation

- Cancel handler was not clearing syncPending flag, causing dispose() to wait indefinitely
- Add error recovery to reset pending state when task throws

Merge: dev into taegab/feat/teams-webhook for trial operation

- Merge feature/update-api-response-types (API response types V2 spec)
- Merge taegab/fix/warehouse-cancel-sync-pending (deadlock fix, GPU service disable)
- Resolve conflicts:
  - equipment/scada.js: adopt dev condition + info level
  - controller/transport.js: fix workplaceId bug → swapWorkIdx + info level
```

## 5. 파일 스테이징 및 커밋

```bash
git add <파일명>   # 특정 파일만 스테이징 (.env, 민감정보 제외)
```

### 커밋 단위 — 토픽별 분리

하나의 커밋은 **하나의 토픽(목적)**만 포함한다. 서로 다른 토픽의 변경사항이 섞여 있으면 토픽별로 커밋을 분리한다. 단, 같은 토픽의 소스 파일과 빌드 산출물은 반드시 같은 커밋에 포함한다.

**기능 작업 중 발견한 버그 수정 처리:**
- 아직 커밋 전이라면 — 기능 커밋에 그냥 포함한다 (별도 Fix 커밋 불필요)
- 이미 커밋했다면 — 직전 기능 커밋에 `--amend`로 흡수한다

두 경우 모두 커밋 body에 "Fix X" 형태로 나열하지 않는다. 수정이 기능의 일부로 자연스럽게 포함된 것이므로 별도 언급이 불필요하다.

- 스테이징 전에 변경사항을 토픽별로 분류한다
- 토픽이 2개 이상이면 각각 별도 커밋으로 진행한다
- `.ts` 소스와 그 빌드 산출물(`.js`, `.js.map`)을 별도 커밋으로 분리하지 않는다

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

## 6. 연속 커밋 흡수 (amend)

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

## 7. 푸쉬 확인

커밋 완료 후 사용자에게 push 여부를 물어본다. 승인 시 `git push`를 실행한다.

## 주의사항
- `.env`, 인증키, 비밀번호 등 민감 정보 커밋 금지
- **작업과 무관한 변경사항은 절대 스테이징/커밋하지 않는다** (테스트 설정 변경, 디버깅 코드, 다른 기능 수정 등)
- `git add -A` 또는 `git add .` 사용 주의 — 불필요한 파일 포함 가능성
- `Co-Authored-By` 등 자동 생성 trailer를 커밋 메시지에 넣지 않는다
- `~/.claude/settings.json`은 변경이 있으면 **항상 커밋에 포함**한다 — 세션 중 Claude Code가 자동 축적한 허용 도구 목록(allowedTools)이 포함되므로 다른 환경과 동기화하기 위해 필요하다
