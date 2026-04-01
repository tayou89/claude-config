---
name: typescript-migration
description: JS → TS 전환 작업 시 적용할 규칙. JS 파일을 TypeScript로 변환하는 작업에서만 참조한다. 일반 TypeScript 작성 시에는 typescript 스킬을 참조한다.
user-invocable: false
---

# JS → TS 전환 규칙

JavaScript 파일을 TypeScript로 변환할 때 아래 규칙을 따른다.

## 핵심 원칙: 타입만 추가, 동작은 보존

전환 작업의 목표는 **기존 런타임 동작을 100% 보존**하면서 타입 정보를 추가하는 것이다. 타입이 맞지 않는다고 동작을 바꾸지 않는다.

## 인스턴스 프로퍼티 보존

JS에서 `this.xxx = ...`로 저장된 인스턴스 프로퍼티를 **지역 변수(`const xxx`)로 바꾸지 않는다.** 인스턴스 프로퍼티를 지역 변수로 바꾸면 외부에서 `obj.xxx`로 접근하던 소비자 코드가 런타임에 `undefined`를 받는다.

TS의 `private` 키워드는 컴파일 타임 제약만 추가할 뿐, JS 소비자 코드는 타입 체크 없이 접근하므로 런타임 버그를 막지 못한다.

**전환 전 반드시 소비자 코드 확인:**
```bash
# 해당 클래스의 프로퍼티를 외부에서 직접 접근하는지 grep
grep -rn "\._comm\.socket\|\._comm\.taskManager\|\.ref\.socket" equipment/ controller/
```

```
// ✅ Good — 인스턴스 프로퍼티 유지
this.socket = this.socketManager.getSocket();
this.socket.on('data', this.parseFrame.bind(this));

// ❌ Bad — 인스턴스 프로퍼티를 지역 변수로 교체 (외부 접근 불가)
const socket = this.socketManager.getSocket();
socket.on('data', this.parseFrame.bind(this));
```

## 값 보존 원칙

타입 전환 중 **함수에 전달되는 값, 콜백 인자, 반환값**을 절대로 변경하지 않는다. 타입이 맞지 않을 때 값을 바꾸는 대신 **타입을 넓혀서** 원본 값을 그대로 전달한다.

대표적인 위반 패턴:
- `callback(null, error)` → `callback(undefined, error.message)` ← 값을 변경하지 말 것
- `callback(err, msg)` → `callback(new Error(msg))` ← 파라미터 개수/타입 변경 금지
- `this._client = undefined` 등 dispose 로직 누락 ← 원본 cleanup 코드 보존

```
// ✅ Good — 원본 값 유지, 타입만 넓힘
// CommCallback의 errorMessage 타입을 string | Error로 선언
callback(undefined, error as Error);  // 원본: callback(null, error)

// ❌ Bad — 타입을 맞추려고 값을 변경
callback(undefined, (error as Error).message);  // error 객체가 message 문자열로 바뀜
```

## 코드 구조 보존

타입 추가, import 변경 등 코드 구조를 바꿀 필요가 없는 전환 작업에서는 원본 JS 코드의 구조(변수 선언 위치, 디스트럭처링 패턴, 제어 흐름 등)를 **그대로 유지**한다.

- 타입 어노테이션만 추가하고, 변수 추출/분리/인라인화 등 구조 변경을 하지 않는다
- 리팩터링과 타입 전환을 섞지 않는다. 구조를 바꾸고 싶으면 **별도 작업으로 분리**하고 사용자에게 제안한다
- 타입 시스템 제약으로 구조 변경이 불가피한 경우에만 **사용자에게 설명하고 승인**받는다

```
// ✅ Good — 원본 구조 유지, 타입만 추가
const { addr, type } = list.reduce<WriteBlockTree | WriteBlockLeaf>((obj, e) => {
    ...
}, this._writeBlocks) as WriteBlockLeaf;

// ❌ Bad — 불필요하게 중간 변수 추출 (원본에 없던 구조 변경)
const leaf = list.reduce<WriteBlockTree | WriteBlockLeaf>((obj, e) => {
    ...
}, this._writeBlocks);
const { addr, type } = leaf as WriteBlockLeaf;
```

## 전환 완료 후 검증

전환 완료 후 반드시 원본 JS와 compiled JS output을 비교하여 값/동작 변경 여부를 확인한다.

```bash
# 원본 JS (git history에서)
git show <이전커밋>:path/to/file.js

# compiled output
cat path/to/file.js
```

**핵심 체크리스트:**
1. 콜백/함수에 전달되는 값이 동일한가?
2. 인스턴스 프로퍼티가 그대로 인스턴스 프로퍼티로 남아있는가?
3. dispose/cleanup 로직이 누락되지 않았는가?
4. 소비자 코드(equipment, controller 등)가 접근하는 프로퍼티가 모두 유지됐는가?

## export = 과도기 규칙

JS 소비자가 `require()`로 사용하는 모듈은 모든 소비자가 TS로 전환될 때까지 `export =` 방식을 유지한다. 모든 소비자 전환 후 named export로 변경한다.
