---
name: code-plan
description: 구현 전 계획서를 작성하고 사용자 승인을 받습니다. 계획은 프로젝트 루트의 plans/ 폴더에 버전 관리됩니다.
model: opus
allowed-tools: Read, Write, Edit, Bash(mkdir *), Bash(cat *), Bash(ls *), Glob
---

# Plan Workflow

구현 작업 전 계획서를 작성하고 사용자 승인을 받는 워크플로우.

## 1. 프로젝트 루트 및 plans 폴더 확인

현재 작업 중인 프로젝트 루트에 `plans/` 폴더를 준비한다.

```bash
mkdir -p plans
```

`.gitignore`에 `plans/` 항목이 없으면 추가한다:
```bash
grep -qxF 'plans/' .gitignore 2>/dev/null || echo 'plans/' >> .gitignore
```

## 2. 계획서 파일 결정

- 파일명 형식: `plan-{feature-name}.md` (영어 kebab-case)
- 기존 파일이 있으면 새 버전을 파일 상단에 추가 (이전 버전 유지)
- 신규 파일이면 새로 생성

## 3. 계획서 작성 형식

계획서는 아래 형식을 따른다. 신규 계획이면 v1, 수정이면 이전 버전 번호 +1.

```markdown
## v{N} — {YYYY-MM-DD} | PENDING APPROVAL
{수정인 경우에만: ### Changes from v{N-1}\n- 변경 사항 목록}

### Goal
무엇을 왜 구현하는지 간결하게.

### Implementation Steps
1. 단계별 구현 계획
2. ...

각 단계에서 코드 수정이 있는 경우 before/after 코드 블록으로 구체적인 변경 내용을 표현한다:

\`\`\`diff
# path/to/file.ts (L42-45)
- 기존 코드
+ 변경 코드
\`\`\`

### Files to Modify / Create
- `path/to/file.ts` — 변경 이유
- ...

### Test Approach
- 어떻게 검증할지

---
```

수정 버전의 경우 위 내용을 기존 파일 **맨 위**에 삽입하고, 이전 버전의 상태 표시(`PENDING APPROVAL`)를 `SUPERSEDED`로 변경한다.

## 4. 승인 요청

계획서 작성 후 반드시 사용자에게 다음을 전달한다:

```
계획서를 작성했습니다: plans/plan-{feature-name}.md

[계획서 내용 요약]

승인하시면 구현을 시작하겠습니다.
```

그 후 **명시적 승인을 기다린다**. 승인 전에는 어떠한 구현 코드도 작성하지 않는다.

## 5. 승인 후

승인되면 해당 버전의 상태를 `APPROVED`로 변경하고 구현을 시작한다.
