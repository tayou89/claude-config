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

## 주석 최소화 + 명시적 네이밍

코드에 **불필요한 주석을 넣지 않는다**. 대신 변수명, 함수명, 상수명을 명시적으로 지어 주석 없이도 의미가 드러나도록 한다.

- 코드가 "무엇을 하는지" 설명하는 주석은 넣지 않는다 — 네이밍으로 해결한다
- "왜 이렇게 했는지" 설명이 필요한 경우에만 주석을 허용한다
- 섹션 구분용 주석(`// === 유틸 ===`, `// 작업`, `// AGV` 등)은 넣지 않는다

```
// ✅ Good — 이름만으로 의미 전달
const LONG_PRESS_DURATION = 500;
const batteryStatusColors: Record<BatteryStatus, string> = { ... };

// ✅ Good — "왜"를 설명하는 주석 (허용)
// 크레인이 동작 중일 때 슬롯 이동을 차단해야 충돌을 방지할 수 있음
if (crane.isMoving) { ... }

// ❌ Bad — 코드를 그대로 반복하는 주석
// 배터리 상태 색상 매핑
const batteryStatusColors = { ... };

// ❌ Bad — 섹션 구분 주석
// === 유틸 함수 ===
// 작업
// AGV
```

## 문자열 리터럴 상수화

코드 내에서 **반복되거나 의미를 가진 문자열 리터럴은 `const` 상수로 정의**한다. 함수 인자, 이벤트 타입, 식별자 등에 문자열을 직접 넣지 않는다.

```
// ✅ Good — 상수로 정의 후 사용
const BROADCAST_TYPE = {
    AGV: 'agv',
    WAREHOUSE: 'warehouse',
    CHARGER: 'charger',
};

this.broadcastStatus(BROADCAST_TYPE.AGV, agvId, status);

// ❌ Bad — 문자열 리터럴 직접 사용
this.broadcastStatus('agv', agvId, status);
```

## TypeScript 규칙

### any 금지

`any` 타입을 사용하지 않는다. 타입을 모르는 경우 구체적인 타입을 정의하거나, 외부 경계에서만 `unknown`을 사용한다.

```
// ✅ Good
function parseMessage(raw: unknown): ScadaResponse {
    const data = raw as Record<string, unknown>;
    // 타입 가드로 좁히기
}

// ❌ Bad
function parseMessage(raw: any): any { }
```

### unknown 사용 범위

`unknown`은 **외부 경계에서만** 허용한다. 외부 경계란 하드웨어에서 읽은 raw 데이터, WebSocket 수신 메시지, JSON.parse 결과 등 런타임에 타입을 보장할 수 없는 지점을 말한다. 내부 코드 간 전달(함수 파라미터, 반환값, 스토어 상태 등)에는 반드시 구체적 타입을 사용한다.

```
// ✅ Good — 외부 경계
ws.onmessage = (event: MessageEvent) => {
    const data: unknown = JSON.parse(event.data);
    if (isStatusBatch(data)) { /* 타입이 좁혀짐 */ }
};

// ✅ Good — 내부 코드
function processWork(data: WorkStatus): void { }

// ❌ Bad — 내부 코드에 unknown
function processWork(data: unknown): void { }
```

### interface vs type

**객체 형태는 `interface`**, 유니온/인터섹션/유틸리티 타입은 **`type`**으로 정의한다.

```
// ✅ Good — 객체 형태는 interface
interface AgvStatus {
    tags: AgvTags;
    params: AgvStatusParams;
}

// ✅ Good — 유니온/유틸리티는 type
type DeviceType = 'agv' | 'charger' | 'door';
type Nullable<T> = T | null;

// ❌ Bad — 객체 형태를 type으로
type AgvStatus = {
    tags: AgvTags;
    params: AgvStatusParams;
};
```

### enum vs const object

TypeScript `enum`을 사용하지 않는다. **`as const` 객체**를 사용한다.

```
// ✅ Good
const DEVICE = {
    AGV: 'agv',
    CHARGER: 'charger',
} as const;

type DeviceType = (typeof DEVICE)[keyof typeof DEVICE];

// ❌ Bad
enum Device {
    AGV = 'agv',
    CHARGER = 'charger',
}
```

### 함수 스타일

- **클래스 메서드**: arrow function (`=`) 사용 (this 바인딩 보장, eventBus 콜백 전달 시 안전)
- **모듈 레벨 유틸리티**: function declaration 사용

```
// ✅ Good — 클래스 메서드: arrow
class Work {
    alloc = (plateNo: string): void => { };
}

// ✅ Good — 모듈 레벨: function
function parseTag<T>(path: string): T { }

// ❌ Bad — 클래스 메서드에 function
class Work {
    alloc(plateNo: string): void { }  // eventBus 콜백 시 this 유실 위험
}
```

### null vs undefined

**`undefined`를 기본으로** 사용한다. optional 파라미터(`param?: Type`)와 자연스럽게 호환된다. `null`은 **"의도적으로 비어있음"을 명시**할 때만 사용한다 (예: API 응답에서 데이터 없음).

```
// ✅ Good — undefined 기본
interface ScadaState {
    agv?: AgvStatusMap;          // 아직 수신 안 됨
}

// ✅ Good — null은 명시적 빈 값
interface ScadaResponse<T> {
    data: T | null;              // 서버가 "데이터 없음"을 명시적으로 응답
}

// ❌ Bad — 내부 상태에 null 남용
interface ScadaState {
    agv: AgvStatusMap | null;    // undefined면 충분
}
```

### 타입 파일 위치

- **여러 파일에서 공유하는 타입**: `types/` 폴더에 정의 (장비 데이터, 이벤트 타입, API 타입 등)
- **해당 파일에서만 사용하는 내부 타입**: 파일 상단에 인라인 정의

```
// ✅ Good — 공유 타입: types/ 폴더
// types/device/agv.ts
export interface AgvStatus { ... }

// ✅ Good — 내부 전용: 인라인
// controller/work.ts
interface AllocLock {
    [workplaceId: number]: boolean;
}
class Work { ... }
```

### 반환 타입 명시

함수/메서드의 반환 타입을 명시한다. 타입 추론에 의존하지 않는다.

```
// ✅ Good
isConnected = (): boolean => {
    return this._commStatus.connected;
};

getStatus = (): WorkStatus => {
    return { waiting: this._section.waiting, allocated: this._section.allocated };
};

// ❌ Bad — 반환 타입 생략
isConnected = () => {
    return this._commStatus.connected;
};
```

## 중복 코드 최소화

동일한 코드가 반복되면 **공통 위치로 추출**한다. switch-case에서 모든 case가 동일한 결과를 반환하면 switch 밖으로 빼고, case별로 결과가 다르면 각 case에서 설정한다.

```
// ✅ Good — 모든 case가 동일한 결과: switch 밖에서 한 번만
try {
    switch (command) {
        case CMD.A: {
            doA();
            break;
        }
        case CMD.B: {
            doB();
            break;
        }
    }
    resultData = { success: true };
} catch (error) {
    resultData = error;
}

// ✅ Good — case별로 결과가 다름: 각 case에서 설정
switch (command) {
    case CMD.GET_STATUS: {
        resultData = this.getStatus();
        break;
    }
    case CMD.ALLOC: {
        await this.alloc();
        resultData = { success: true };
        break;
    }
}

// ❌ Bad — 모든 case에 동일한 resultData 반복
switch (command) {
    case CMD.A: {
        doA();
        resultData = { success: true };
        break;
    }
    case CMD.B: {
        doB();
        resultData = { success: true };
        break;
    }
}
```
