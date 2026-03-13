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

## 변수 선언 후 빈 줄

연속된 변수 선언(`const`, `let`, `var`) 블록의 **마지막 줄 다음에 빈 줄 하나**를 넣어 로직과 분리한다.

## 메서드 내 불필요한 빈 줄 금지

변수 선언 블록 이후의 빈 줄을 제외하고, 메서드/함수 본문 안에서 **실행문 사이에 빈 줄을 넣지 않는다**. 빈 줄은 메서드 간, 클래스 멤버 간 구분에만 사용한다.

```javascript
// ✅ Good
connect = async () => {
    const { hostname, port } = this._config.options;
    const url = `${protocol}://${hostname}:${port}`;

    this._logger.info(`연결 시도: ${hostname}:${port}`);
    this._connection = await amqp.connect(url);
    this._channel = await this._connection.createConfirmChannel();
    await this._channel.prefetch(this._config.prefetch);
    await this._setupTopology();
    this._connection.on('close', this._onClose);
    this._connection.on('error', this._onError);
    this._logger.info('연결 성공');
};

// ❌ Bad
connect = async () => {
    const { hostname, port } = this._config.options;
    const url = `${protocol}://${hostname}:${port}`;

    this._logger.info(`연결 시도: ${hostname}:${port}`);

    this._connection = await amqp.connect(url);
    this._channel = await this._connection.createConfirmChannel();

    await this._channel.prefetch(this._config.prefetch);
    await this._setupTopology();

    this._connection.on('close', this._onClose);
    this._connection.on('error', this._onError);

    this._logger.info('연결 성공');
};
```
