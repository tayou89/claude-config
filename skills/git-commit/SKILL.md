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

## 주의사항
- `.env`, 인증키, 비밀번호 등 민감 정보 커밋 금지
- 관련 없는 변경사항은 별도 커밋으로 분리
- `git add -A` 또는 `git add .` 사용 주의 — 불필요한 파일 포함 가능성
