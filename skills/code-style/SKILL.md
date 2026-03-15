---
name: code-style
description: 코드 작성 및 수정 시 적용할 코딩 스타일 규칙. 코드를 생성하거나 편집할 때 자동으로 참조한다.
user-invocable: false
---

# 코딩 스타일 규칙

코드를 작성하거나 수정할 때 아래 규칙을 따른다.

## 제어문 중괄호

`if`, `else`, `else if`, `for`, `while`, `do` 등 모든 제어문은 **반드시 중괄호(`{}`)를 사용**한다. 한 줄짜리 본문이어도 중괄호를 생략하지 않는다.

```javascript
// ✅ Good
if (condition) {
    return value;
}

// ❌ Bad
if (condition) return value;
```

## 조기 void return 금지 — if-else 사용

특정 값을 반환하는 early return(`return false`, `return 0` 등)은 허용하되, **void return으로 함수를 빠져나가는 guard clause는 사용하지 않는다**. 대신 if-else 구조로 처리한다.

```javascript
// ✅ Good
subscribe = async (routingKey) => {
    if (this._channel) {
        // 메인 로직
    } else {
        this._logger.warn('채널 없음');
    }
};

// ❌ Bad
subscribe = async (routingKey) => {
    if (!this._channel) {
        this._logger.warn('채널 없음');
        return;
    }
    // 메인 로직
};
```

## 긍정 조건 우선

가능하면 if문의 조건은 **부정문(`!`)보다 긍정문**으로 작성한다. else 분기가 없는 단순 조건에서 부정이 자연스러운 경우는 예외로 허용한다.

```javascript
// ✅ Good
if (this._channel) {
    // 메인 로직
} else {
    // 에러 처리
}

// ❌ Bad
if (!this._channel) {
    // 에러 처리
    return;
}
// 메인 로직
```

## 모든 분기에 else 명시

if문에서 값을 반환하거나 처리를 분기하는 경우, **마지막 분기도 반드시 else로 감싼다**. 함수 끝에 if 바깥으로 빠져나와 return하는 패턴을 사용하지 않는다.

```javascript
// ✅ Good
if (errorCode) {
    return `에러코드: ${errorCode}`;
} else {
    return '에러코드 없음';
}

// ❌ Bad
if (errorCode) {
    return `에러코드: ${errorCode}`;
}
return '에러코드 없음';
```

## 변수 선언 후 빈 줄

연속된 변수 선언(`const`, `let`, `var`) 블록의 **마지막 줄 다음에 빈 줄 하나**를 넣어 로직과 분리한다.

## 메서드 내 불필요한 빈 줄 금지

변수 선언 블록 이후의 빈 줄을 제외하고, 메서드/함수 본문 안에서 **실행문 사이에 빈 줄을 넣지 않는다**. 빈 줄은 메서드 간, 클래스 멤버 간 구분에만 사용한다.

## 불필요한 async 제거

`await`를 사용하지 않는 함수에는 `async`를 붙이지 않는다.

## 인라인 콜백 함수 분리

매개변수로 전달되는 **콜백 함수가 길어지면**(대략 5줄 이상) 별도의 메서드/함수로 분리하여 호출한다.

```javascript
// ✅ Good
const { consumerTag } = await this._channel.consume(this._queueName, this._onMessage);

// ❌ Bad
const { consumerTag } = await this._channel.consume(this._queueName, (msg) => {
    // 10줄 이상의 긴 처리 로직...
});
```

## try-catch 범위

특별한 이유가 없다면 try-catch는 **함수 본문 전체를 감싸는 형태**로 작성한다. 부분적 try-catch는 에러 처리가 구간별로 달라야 할 때만 사용한다.

## 약어 사용 자제

변수명, 함수명 등에 **약어(abbreviation)를 가능한 사용하지 않는다**. 이름이 너무 길어지지 않는 한 전체 단어를 사용한다.

```javascript
// ✅ Good
const unsubscribe = scadaWs.onBroadcast('warehouse/status', handler)
const handler = (data) => { ... }

// ❌ Bad
const unsub = scadaWs.onBroadcast('warehouse/status', h)
const h = (data) => { ... }
```
