---
name: code-style
description: 코드 작성 및 수정 시 적용할 코딩 스타일 규칙. 코드를 생성하거나 편집할 때 자동으로 참조한다.
user-invocable: false
---

# 코딩 스타일 규칙

코드를 작성하거나 수정할 때 아래 규칙을 따른다.

## 제어문 중괄호

`if`, `else`, `else if`, `for`, `while`, `do` 등 모든 제어문은 **반드시 중괄호(`{}`)를 사용**하고, **본문은 반드시 줄바꿈**한다. 한 줄짜리 본문이어도 중괄호를 생략하거나 한 줄로 축약하지 않는다.

```
// ✅ Good
if (condition) {
    return value;
}

// ❌ Bad
if (condition) return value;

// ❌ Bad — 한 줄 축약
if (condition) { return value; }
```

## 조기 void return 금지 — if-else 사용

특정 값을 반환하는 early return(`return false`, `return 0` 등)은 허용하되, **void return으로 함수를 빠져나가는 guard clause는 사용하지 않는다**. 대신 if-else 구조로 처리한다.

```
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

```
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

```
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

변수 선언(`const`, `let`, `var`) 블록 다음에는 **항상 빈 줄 하나**를 넣어 분리한다. `return`문 앞이라도 예외 없이 빈 줄을 넣는다. 객체 리터럴(`{ ... }`)로 초기화하는 변수도 동일하게 적용한다. **이 규칙은 함수/메서드 본문뿐 아니라 if, else, try, catch 등 모든 블록 내부에도 동일하게 적용한다.**

```
// ✅ Good — 변수 선언 후 빈 줄
const msg = {
    reqid_s: REQ.MOVE,
    param1: targetPos
};

await this.send(msg, callback);

// ✅ Good — return 앞에도 빈 줄
const state = this.getSocketState();

return !state || state === WebSocket.CLOSED;

// ❌ Bad — 변수 선언 후 빈 줄 없음
const state = this.getSocketState();
return !state || state === WebSocket.CLOSED;
```

## 메서드/함수 정의 사이 빈 줄

클래스 멤버, 메서드, 함수 정의 사이에는 **반드시 빈 줄 하나**를 넣어 구분한다.

## 메서드/함수 종류별 정리

클래스 내 메서드는 **종류별로 모아서 배치**한다. 관련된 메서드끼리 그룹핑하여 가독성을 높인다. 예시 순서: 생성/소멸 → 연결 → 상태 조회 → 통신/프로토콜 → 비즈니스 로직(제어 명령) → 파라미터/컨텍스트 관리 → 유틸리티 → check 함수(개별 → 복합).

## 메서드 내 불필요한 빈 줄 금지

메서드/함수 본문 안에서 빈 줄은 **변수 선언 블록 뒤에만** 허용한다. 실행문 사이, if/else/try/catch 블록(`}`) 앞뒤, 주석 앞뒤 등 그 외 모든 위치에는 빈 줄을 넣지 않는다. 이 규칙은 if, else, try, catch, 콜백 등 모든 블록 내부에도 동일하게 적용한다.

```
// ✅ Good — 실행문끼리 빈 줄 없이 붙임, 변수 선언 뒤에만 빈 줄
this.info('e-Stop Off');
const msg = {
    reqid_s: REQ.RESET_ESTOP,
    param1: type
};

return this.send(msg, callback);

// ✅ Good — 블록 내부에서도 동일
if (reqeust) {
    const { tid, reject, callback, msg } = reqeust;
    const translatedRequest = this.translateRequest(msg);

    this.commError(`${translatedRequest} NAK 수신`);
    clearTimeout(tid);
}

// ❌ Bad — 실행문 사이에 불필요한 빈 줄
this.info('e-Stop Off');

const msg = {
    reqid_s: REQ.RESET_ESTOP,
    param1: type
};

// ❌ Bad — 블록(}) 뒤에 불필요한 빈 줄
if (condition) {
    doSomething();
}

doOther();
```

## 불필요한 async 제거

`await`를 사용하지 않는 함수에는 `async`를 붙이지 않는다.

## 인라인 콜백 함수 분리

매개변수로 전달되는 **콜백 함수가 길어지면**(대략 5줄 이상) 별도의 메서드/함수로 분리하여 호출한다.

```
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

```
// ✅ Good
const unsubscribe = scadaWs.onBroadcast('warehouse/status', handler)
const handler = (data) => { ... }

// ❌ Bad
const unsub = scadaWs.onBroadcast('warehouse/status', h)
const h = (data) => { ... }
```

## 전제조건 검증 패턴 (check 함수)

장비 제어 등 동작 전 전제조건을 검증하는 경우, **`check` 접두사의 개별 함수로 분리**하고 복합 함수로 조합한다.

### 개별 check 함수

조건 하나를 검증하고 실패 시 throw하는 단위 함수. 이름은 `check` + 검증 대상으로 짓는다. **check 함수는 검증만 수행하며, 값을 반환하지 않는다.** 값이 필요하면 검증과 조회를 분리한다.

```
// ✅ Good — 검증만 수행, 값 반환 없음
checkVehicleType = () => {
    if (!this.getVehicleType()) {
        throw new Error('차종 정보를 찾을 수 없습니다.');
    }
};

// 사용: 검증 후 별도로 값 조회
this.checkVehicleType();
const vehicleType = this.getVehicleType();

// ❌ Bad — check 함수가 값을 반환
checkVehicleType = () => {
    const vehicleType = this.getVehicleType();
    if (!vehicleType) {
        throw new Error('차종 정보를 찾을 수 없습니다.');
    }
    return vehicleType; // check 함수는 값을 반환하지 않는다
};
```

### 복합 check 함수

여러 개별 check를 조합한 함수. 내부에서 개별 check 함수를 호출한다.

```
// ✅ Good — 복합 check 함수 (개별 조합)
checkReady = () => {
    this.checkConnection();
    this.checkServoOn();
};

checkMovable = async (liftHomeHeight) => {
    this.checkConnection();
    await this.checkLiftHomeWait(liftHomeHeight);
    this.checkServoOn();
    this.checkServoInitDone();
    this.checkNotDriveLocked();
    this.checkNotEstop();
};

// ✅ Good — 파라미터에 따라 조건부 체크하는 복합 함수
checkServoSettable = (setValue) => {
    this.checkConnection();
    if (!setValue && this.isDriveServoOn()) {
        this.checkLiftHomePosition();
        this.checkNotDriving();
    }
};

// ❌ Bad — 복합 함수에서 조건을 직접 검사
checkMovable = async () => {
    if (!this.getTag()) { throw ... }
    if (!this.isDriveServoOn()) { throw ... }
};

// ❌ Bad — 메서드 본문에서 조건부로 check 함수를 분기 호출
if (!setValue) {
    this.checkServoOffSafe();
} else {
    this.checkConnection();
}
```

### check 함수 배치

check 함수는 클래스 파일 하단에 모아서 배치한다. **개별 check → 복합 check** 순서로 정리한다.

### 메서드에서의 사용

공통 패턴은 복합 함수로, 메서드 고유 조건이 추가되면 복합 + 개별을 조합한다. 한 곳에서만 쓰이더라도 복합 함수로 분리한다. **메서드 본문에서 check 호출을 if-else로 분기하지 않고, 파라미터를 받는 복합 함수로 묶는다.** 메서드 본문에서 전제조건 검증을 위한 인라인 throw는 사용하지 않고, 반드시 check 함수로 분리한다.

```
// ✅ Good — 복합으로 깔끔하게
moveSafe = async (position, liftHomeHeight, callback) => {
    await this.checkMovable(liftHomeHeight);
    await this.move(position, callback);
};

// ✅ Good — 복합으로 1줄, 이후 값 조회는 별도
liftInching = async (param, callback) => {
    this.checkReady();
    this.checkVehicleType();
    const vehicleType = this.getVehicleType();
    // ... param 검증 등
};

// ❌ Bad — 메서드 본문에 개별 check를 길게 나열
moveSafe = async (position, liftHomeHeight, callback) => {
    this.checkConnection();
    this.checkServoOn();
    this.checkServoInitDone();
    this.checkNotDriveLocked();
    this.checkNotEstop();
    await this.move(position, callback);
};
```

### Promise.reject 대신 throw 사용

async 함수에서는 `Promise.reject` 대신 `throw`를 사용하고, `return this.send()` 대신 `await this.send()`를 사용한다. `new Promise(async (resolve, reject) => ...)` 안티패턴은 사용하지 않는다.

```
// ✅ Good
move = async (targetPos, callback) => {
    const vehicleType = this.checkVehicleType();
    const msg = { reqid_s: REQ.MOVE, param1: targetPos, param2: vehicleType };
    await this.send(msg, callback);
};

// ❌ Bad — Promise.reject 혼용
move = async (targetPos, callback) => {
    if (!vehicleType) {
        return Promise.reject(new Error('차종 정보 없음'));
    }
    return this.send(msg, callback);
};

// ❌ Bad — new Promise(async) 안티패턴
setServo = (setValue, callback) => {
    return new Promise(async (resolve, reject) => {
        try { ... resolve(); }
        catch (e) { reject(e); }
    });
};
```
