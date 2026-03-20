---
name: code-plan
description: 새 기능 추가, 구조 변경, 복잡한 버그 수정 등 비trivial한 구현 작업을 시작하기 전에 계획서를 작성하고 사용자 승인을 받습니다. 코드를 작성하거나 파일을 생성/수정하는 구현 요청 시 자동으로 트리거됩니다.
model: opus
allowed-tools: Read, Write, Edit, Bash(mkdir *), Bash(cat *), Bash(ls *), Bash(git config *), Bash(grep *), Bash(echo *), Glob
---

# Plan Workflow

구현 작업 전 계획서를 작성하고 사용자 승인을 받는 워크플로우.

## 1. 프로젝트 루트 및 claude-plans 폴더 확인

현재 작업 중인 프로젝트 루트에 `claude-plans/` 폴더를 준비한다.

```bash
mkdir -p claude-plans
```

### gitignore 확인

글로벌 gitignore(`~/.gitignore_global`)에 `claude-plans/`가 등록되어 있는지 확인한다.
등록되어 있지 않으면 글로벌 gitignore에 추가하고, `core.excludesfile` 설정도 확인한다:

```bash
# 글로벌 gitignore 파일에 claude-plans/ 추가
grep -qxF 'claude-plans/' ~/.gitignore_global 2>/dev/null || echo 'claude-plans/' >> ~/.gitignore_global

# core.excludesfile이 설정되어 있지 않으면 설정
git config --global core.excludesfile 2>/dev/null || git config --global core.excludesfile ~/.gitignore_global
```

## 2. 계획서 파일 결정

- 파일명 형식: `plan-{feature-name}.md` (영어 kebab-case)
- 기존 파일이 있으면 새 버전을 파일 상단에 추가 (이전 버전 유지)
- 신규 파일이면 새로 생성

## 3. 코드 스타일 참조

계획서에 코드 수정이 포함된 경우, `code-style` 스킬 문서(`~/.claude/skills/code-style/SKILL.md`)를 읽고 해당 규칙을 diff 코드와 구현 코드에 모두 적용한다.

## 4. 계획서 작성 형식

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

### Architecture (구조 변경이 있는 경우)
모듈 관계, 데이터 흐름, 상속 구조 등을 ASCII 도식으로 표현한다.
단순 파일 수정만 있는 경우 생략 가능.

### Files to Modify / Create
- `path/to/file.ts` — 변경 이유
- ...

### Test Approach
- 어떻게 검증할지

---
```

수정 버전의 경우:
- 위 내용을 기존 파일 **맨 위**에 삽입하고, 이전 버전의 상태 표시(`PENDING APPROVAL`)를 `SUPERSEDED`로 변경한다.
- **새 버전은 독립적이고 완전한 계획서**여야 한다. Goal, Implementation Steps, Files to Modify / Create, Test Approach 등 모든 섹션을 새로 작성한다. 이전 버전의 내용을 참조하거나 "v2와 동일" 같은 표현을 사용하지 않는다.
- 이전 버전은 이력으로 그대로 보존한다 (삭제하지 않음).

## 5. 승인 요청

계획서 작성 후 반드시 사용자에게 다음을 전달한다:

```
계획서를 작성했습니다: claude-plans/plan-{feature-name}.md

[계획서 내용 요약]

승인하시면 구현을 시작하겠습니다.
```

그 후 **명시적 승인을 기다린다**. 승인 전에는 어떠한 구현 코드도 작성하지 않는다.

## 6. 승인 후

승인되면 해당 버전의 상태를 `APPROVED`로 변경하고 구현을 시작한다.

## 7. 구현 중 코드 수정이 필요한 경우

이미 승인된 계획서가 있는 상태에서 코드 변경이 필요한 경우, **변경 규모에 따라** 처리 방식이 다르다:

### 설계 변경이 있는 수정 (새 버전)
구현 방향, 로직 구조, API 설계 등이 바뀌는 경우:
1. **새 버전(v{N+1})을 작성**한다 — 4절의 계획서 형식 규칙을 그대로 따른다 (독립적이고 완전한 계획서)
2. 이전 버전의 상태를 `SUPERSEDED`로 변경한다
3. 사용자에게 변경 내용을 보여주고 **승인을 받는다**
4. 승인 후 코드를 수정한다

### 사소한 수정 (인라인 수정)
파라미터 변경, 오타, 사용자가 직접 "이거 수정해줘"라고 명시한 경우:
- 기존 버전에 **인라인으로 수정**하고 코드도 함께 수정 가능 (별도 승인 불필요)
