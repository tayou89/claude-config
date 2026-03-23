---
name: code-style
description: 코드 작성 및 수정 시 적용할 코딩 스타일 규칙. 코드를 생성하거나 편집할 때 자동으로 참조한다.
user-invocable: false
---

# 코딩 스타일 규칙

코드를 작성하거나 수정할 때 아래 규칙을 따른다. **계획서, 설명, 예시 코드 등 모든 곳에서 코드를 작성할 때도 동일하게 적용한다.** 실제 코드든 예시 코드든 스타일 규칙에 예외는 없다.

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

## 조기 void return / guard throw 금지 — if-else 또는 check 함수 사용

특정 값을 반환하는 early return(`return false`, `return 0` 등)은 허용하되, **void return이나 guard throw로 함수를 빠져나가는 패턴은 사용하지 않는다**.

- **단일 조건**: if-else 구조로 처리한다
- **복수 조건**: 별도 check 함수로 분리한다 (전제조건 검증 패턴 참고)

```
// ✅ Good — 단일 조건: if-else
const data = this.getTag('warehouse.control');

if (data) {
    const { cmd } = data;
    // 메인 로직
} else {
    throw new Error('warehouse.control 태그 없음');
}

// ✅ Good — 복수 조건: check 함수로 분리
checkWarehouseControl = (): void => {
    if (!this.getTag('warehouse.control')) {
        throw new Error('warehouse.control 태그 없음');
    }
    if (!this.isConnected()) {
        throw new Error('연결 끊김');
    }
};

// ❌ Bad — guard throw
const data = this.getTag('warehouse.control');

if (!data) {
    throw new Error('warehouse.control 태그 없음');
}
const { cmd } = data;

// ❌ Bad — guard return
if (!this._channel) {
    this._logger.warn('채널 없음');
    return;
}
// 메인 로직
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

## const 우선 사용

변수가 재할당되지 않으면 반드시 `const`를 사용한다. `let`은 실제로 재할당되는 경우에만 사용한다.

```
// ✅ Good
const timeStamp = new Date().getTime();
const { area, start } = this.getArea(addr);

// ❌ Bad — 재할당 없는데 let 사용
let timeStamp = new Date().getTime();
```

## 반복 사용되는 리터럴 값은 상수로 정의

코드 구조에서 의미를 가지는 문자열/숫자 리터럴이 **2곳 이상**에서 반복되면 상수로 정의하여 사용한다. 특히 객체 키 목록, 상태 코드, 설정 값 등 구조적 의미가 있는 값은 인라인 리터럴 대신 상수를 참조한다. 상수는 기존 상수 정의 파일의 패턴(객체 형태 등)에 맞춰 정의한다.

```
// ✅ Good — 기존 패턴에 맞는 객체 형태로 상수 정의
TASK_STEP_KEYS: {
    PRECHECK: 'precheck',
    REQUEST: 'request',
    POSTCHECK: 'postcheck',
},

for (const key of Object.values(TASK_STEP_KEYS)) {
    this.resolveTaskDoneCallback(task[key]);
}

// ❌ Bad — 기존 패턴과 다른 배열 형태로 정의
TASK_STEP_KEYS: ['precheck', 'request', 'postcheck'],
```

## 상수 정의 위치 — 사용 범위에 따라 결정

상수는 **실제 사용 범위**에 맞는 위치에 정의한다.

- **여러 파일에서 참조**: 공통 상수 정의 파일(예: `property.js`)에 정의
- **한 파일/클래스에서만 사용**: 해당 파일 상단 또는 클래스 내부에 정의

공통 상수 파일에는 외부에서 참조되는 값만 넣는다. 내부에서만 쓰는 상수를 공통 파일에 넣지 않는다.

## TypeScript 소스와 빌드 산출물

`.ts` 파일과 대응하는 `.js` 파일이 함께 존재하면, `.js`는 빌드 산출물이다. **반드시 `.ts` 파일을 수정하고 빌드(`tsc`)하여 `.js`를 생성**한다. `.js`를 직접 수정하지 않는다. 수정 전에 대응하는 `.ts` 파일이 존재하는지 항상 확인한다.

## Promise 체인 대신 await 사용

`.then().catch()` 체인 대신 `async/await` + `try/catch`를 사용한다.

```
// ✅ Good
try {
    const result = await reader(start, length);
    const payload = result.response.body.valuesAsBuffer;

    callback({ cmd, timeStamp, payload });
} catch (error) {
    callback(undefined, (error as Error).message);
}

// ❌ Bad
reader(start, length)
    .then((result) => {
        callback({ cmd, timeStamp, result.response.body.valuesAsBuffer });
    })
    .catch((error) => {
        callback(undefined, error.message);
    });
```

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

특별한 이유가 없다면 try-catch는 **함수 본문 전체를 감싸는 형태**로 작성한다. 부분적 try-catch는 에러 처리가 구간별로 달라야 할 때만 사용한다. **동일한 에러 처리를 하는 try-catch를 중첩하지 않는다.**

```
// ✅ Good — 하나의 try-catch로 충분
write = async (addr, values, type, callback) => {
    try {
        // ... 전처리 + await ...
        await writePromise;
        callback({ cmd, timeStamp });
    } catch (error) {
        callback(undefined, error.message);
    }
};

// ❌ Bad — 동일한 에러 처리를 하는 중복 try-catch
write = async (addr, values, type, callback) => {
    try {
        // ... 전처리 ...
        try {
            await writePromise;
            callback({ cmd, timeStamp });
        } catch (error) {
            callback(undefined, error.message);  // 바깥과 동일
        }
    } catch (error) {
        callback(undefined, error.message);      // 안쪽과 동일
    }
};
```

## 에러 메시지 작성 원칙

에러 메시지는 **일반인도 이해할 수 있는 사용자 친화적 표현**으로 작성한다. 내부 기술 용어(태그, 레지스터, 인스턴스 등)를 피하고, **무엇이 어떤 상태인지** 사람이 읽을 수 있는 문장으로 쓴다.

```
// ✅ Good — 사용자 친화적
throw new Error('창고 제어 값을 확인할 수 없습니다.');
throw new Error('AGV 제어 상태를 읽을 수 없습니다.');
throw new Error('충전기 제어 명령을 확인할 수 없습니다.');

// ❌ Bad — 기술 용어, 내부 구현 노출
throw new Error('warehouse.control 태그 없음');
throw new Error('getTag returned undefined');
throw new Error('agv.control is null');
```

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

### ESModule 문법 사용

`require()` / `module.exports` 대신 `import` / `export`를 사용한다. tsc가 CommonJS로 컴파일하므로 런타임 호환성에 문제없다.

```
// ✅ Good
import { Logger } from '../util/logger';
import { CommHandler } from '../driver/common/types';

// ❌ Bad
const Logger = require('../util/logger');
import Logger = require('../util/logger');
module.exports = Door;
export = Door;
```

### named export 사용 (default export 금지)

`export default`를 사용하지 않는다. 항상 **named export** (`export { }` 또는 `export class/function/const`)를 사용한다.

- import 시 이름이 강제되어 오타를 컴파일 타임에 잡을 수 있다
- IDE 자동완성/리팩터링이 정확하게 동작한다
- 한 파일에서 여러 개 export할 때 일관적이다

```
// ✅ Good — named export
export class Door extends ThingExt<DoorTags> { }
export { Door };
export { CommHandler, CommResponse };

// ✅ Good — import 시 이름 강제
import { Door } from '../equipment/door';
import { CommHandler } from '../driver/common/types';

// ❌ Bad — default export
export default Door;
export default class Door { }

// ❌ Bad — import 시 아무 이름 가능 (오타/혼란)
import Door from '../equipment/door';
import Foo from '../equipment/door';     // 이것도 됨
```

### import * 금지

`import * as X from '...'`를 사용하지 않는다. 필요한 것만 named import한다. 모듈 전체가 필요한 경우는 모듈 구조를 재설계한다.

```
// ✅ Good
import { UDP as FEnetUDP, TCP as FEnetTCP } from './fenet';

// ❌ Bad
import * as FEnet from './fenet';
```

### 타입은 항상 안전하고 정확한 쪽으로

타입 관련 선택이 필요할 때는 항상 **더 안전하고 더 정확한 쪽**을 택한다. 편의를 위해 타입 안전성을 포기하지 않는다.

- **`as const` 유지**: 불변 상수 데이터(PLC 맵, 설정값 등)에는 `as const`를 사용한다. `readonly` 호환 문제가 생기면 `as const`를 제거하지 않고 **받는 쪽 인터페이스에서 `readonly`를 수용**하도록 수정한다. 내부에서 배열을 변형하지 않는다면 파라미터 타입을 `readonly T[]`로 선언한다.
- **`readonly` 전파**: 변형하지 않는 배열/객체 파라미터는 `readonly`로 선언하여 불변성을 타입 시스템으로 보장한다.
- **타입 좁히기 우선**: 캐스팅(`as`)보다 타입 가드, 제네릭, 인터페이스 설계를 우선한다.
- **구체적 타입 정의 원칙**: `Record<string, unknown>`, `object`, `any` 등 느슨한 타입 대신 **구체적 인터페이스를 정의**하는 것이 정석이다. 공통 필드는 베이스 인터페이스로, 개별 필드는 extends로 확장한다. 느슨한 타입을 사용해야 할 경우 사용자에게 근거와 함께 승인받는다.

### 동일 카테고리는 동일 수준으로 통일

같은 역할/카테고리에 속하는 모듈들은 **타입 정의 수준, 패턴, 구조를 통일**한다. 한 모듈만 다른 방식으로 하지 않는다.

- **타입 정의 수준**: 동일 카테고리의 모듈이 `Record<string, unknown>`을 쓰면 전부 그렇게 하고, 구체 인터페이스를 쓰면 전부 구체적으로 한다. 한 모듈만 구체적이고 나머지가 느슨하면 안 된다. 수준을 올리려면 전부 함께 올린다.
- **네이밍 패턴**: 인터페이스명(`XxxConfig`, `XxxOptions`, `XxxTags`), 변수명, 메서드명이 같은 카테고리 내에서 일관되어야 한다.
- **클래스 구조**: 같은 베이스 클래스를 상속하는 모듈들은 생성자 패턴, 초기화 흐름, dispose 패턴이 동일해야 한다.
- **적용 범위**: equipment 장비 클래스, controller 컨트롤러, driver 드라이버 등 동일 디렉터리/역할의 모듈이 대상이다.

변경 시 한 모듈만 바꾸면 불일치가 생길 수 있으므로, **같은 카테고리 전체에 영향을 주는 변경인지 확인**하고 필요하면 전부 함께 수정한다.

```
// ✅ Good — 전체 장비가 동일 수준
// Door, Charger, PSD, Crane 모두 config: Record<string, unknown>
interface DoorConfig { options: { driver: string; config: Record<string, unknown> } }
interface CraneOptions { driver: string; config: Record<string, unknown> }

// ✅ Good — 전체를 구체적으로 올린 경우
interface DoorDriverConfig { host: string; port: number; ... }
interface CraneDriverConfig { host: string; port: number; ... }

// ❌ Bad — Crane만 구체적, 나머지는 느슨
interface DoorConfig { options: { config: Record<string, unknown> } }
interface CraneOptions { config: CraneConfig }  // 혼자만 구체적
```

```
// ✅ Good — as const 유지, 받는 쪽에서 readonly 수용
const MAP = { model: [...] } as const;

addWriteBlock = (block: { model: readonly WriteModel[] }): void => {
    block.model.forEach(item => { ... });  // 순회만 — readonly OK
};

// ❌ Bad — 호환 안 된다고 as const 제거
const MAP = { model: [...] };  // 실수로 MAP.model.push(...) 해도 안 잡힘

// ❌ Bad — 호환 안 된다고 캐스팅으로 우회
this.addWriteBlock(MAP as unknown as WriteBlockConfig);
```

### 타입 캐스팅 최소화

**`as unknown as` (이중 캐스팅) 금지.** 타입이 맞지 않으면 인터페이스/제네릭으로 타입 설계를 수정한다.

`as Type` (단일 캐스팅)은 외부 라이브러리 경계, JSON 파싱 등 불가피한 경우에만 허용하고, 비즈니스 로직에서는 사용하지 않는다.

```
// ✅ Good — 인터페이스로 해결
class FEnet implements CommHandler { ... }
const driver = driverFactory.get('fenet');  // CommHandler 타입 반환

// ✅ Good — 제네릭으로 해결
const closed = door.getTag('stat.closed');  // 자동 추론

// ❌ Bad — 이중 캐스팅
driver.ref as unknown as CommHandler

// ❌ Bad — 비즈니스 로직에서 단일 캐스팅
const closed = door.getTag('stat.closed') as number;
```

### 제네릭 클래스 활용

공통 베이스 클래스는 **제네릭으로 설계**하여 하위 클래스에서 구체 타입을 지정한다. 호출 측에서 매번 타입을 지정하지 않아도 되도록 한다.

```
// ✅ Good — 클래스 제네릭 + FlattenKeys로 dot notation 지원
class Thing<TTags extends object> {
    getTag(): TTags | undefined;
    getTag<K extends FlattenKeys<TTags>>(tagName: K): DeepValue<TTags, K> | undefined;
}

class Door extends ThingExt<DoorTags> { }

interface DoorTags {
    stat: { closed: number; opened: number; loopSensor: number };
    cmd: { enable: number; open: number; close: number };
}

// 사용: 타입 자동 추론, 오타 컴파일 타임 검출
const closed = door.getTag('stat.closed');   // number — 자동 추론
const tags = door.getTag();                   // DoorTags — 자동 추론
door.getTag('stat.closd');                    // ← 컴파일 에러! 오타 검출

// ❌ Bad — 메서드 제네릭 (매번 타입 지정)
const closed = door.getTag<number>('stat.closed');
```

### 공통 인터페이스 정의

여러 클래스가 동일한 메서드를 가지면 **공통 인터페이스를 정의하고 implements** 한다. 팩토리/컨테이너에서 반환할 때 캐스팅이 불필요해진다.

```
// ✅ Good — 인터페이스 implements
interface CommHandler {
    write(...): void;
    read(...): void;
    isConnected(): boolean;
    close(): void;
}

class FEnet extends FrameBuilder implements CommHandler { ... }
class Modbus implements CommHandler { ... }

// 팩토리에서 캐스팅 없이 반환
get(name: string): { id: string; ref: CommHandler } | undefined

// ❌ Bad — 인터페이스 없이 캐스팅
get(name: string): { id: string; ref: Record<string, unknown> }
// 사용 시: driver.ref as unknown as CommHandler
```

### any / unknown 사용 원칙

`any`와 `unknown`은 모두 **구체적 타입을 찾는 노력을 먼저** 한 뒤에만 고려한다. 실제 데이터 흐름을 추적하여 정확한 타입을 정의할 수 있다면 반드시 그렇게 한다.

**`any` — 금지.** 어떤 경우에도 사용하지 않는다.

**`unknown` — 외부 경계에서만 허용, 사용 전 사용자 확인 필수.** `unknown`을 사용해야 할 것 같은 상황이 오면:
1. 먼저 실제 호출/데이터 흐름을 추적하여 구체적 타입을 찾는다
2. 구체적 타입이 정말 불가능한 경우에만 사용자에게 근거와 함께 확인받는다
3. 승인 없이 `unknown`을 작성하지 않는다

외부 경계란 하드웨어에서 읽은 raw 데이터, WebSocket 수신 메시지, JSON.parse 결과 등 런타임에 타입을 보장할 수 없는 지점을 말한다. 내부 코드 간 전달(함수 파라미터, 반환값, 콜백 등)에는 반드시 구체적 타입을 사용한다.

```
// ✅ Good — 실제 호출 흐름을 추적하여 정확한 타입 정의
// cb(eventName, error) 로 호출되므로 정확한 시그니처 사용
on = (eventName: string, conditions: ..., cb?: (topic: string, error?: Error) => void): void => {

// ✅ Good — 외부 경계에서만 unknown 허용
ws.onmessage = (event: MessageEvent) => {
    const data: unknown = JSON.parse(event.data);
    if (isStatusBatch(data)) { /* 타입이 좁혀짐 */ }
};

// ❌ Bad — 추적하면 구체 타입을 알 수 있는데 unknown/any 사용
on = (eventName: string, conditions: ..., cb?: (...args: unknown[]) => void): void => {
on = (eventName: string, conditions: ..., cb?: (...args: any[]) => void): void => {
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

## 중복 로직 금지

동일하거나 거의 동일한 로직이 **2곳 이상**에서 반복되면, 별도의 메서드/함수로 추출하여 재사용한다. 코드를 작성하거나 수정할 때 기존 코드베이스에 같은 패턴이 이미 존재하는지 확인하고, 있으면 해당 메서드를 호출한다.

```
// ✅ Good — 공통 로직을 메서드로 추출
resolveTaskDoneCallback = (args) => {
    if (args && args.length > 0) {
        const lastArg = args[args.length - 1];

        if (typeof lastArg === 'function' && lastArg.name === '_taskDone') {
            lastArg();
        }
    }
};

// 호출부 A
this.resolveTaskDoneCallback(option?.args);

// 호출부 B
this.resolveTaskDoneCallback(task.request?.args);

// ❌ Bad — 같은 로직을 여러 곳에 인라인으로 반복
// 호출부 A
const args = option?.args;
if (args && args.length > 0) {
    const lastArg = args[args.length - 1];
    if (typeof lastArg === 'function' && lastArg.name === '_taskDone') {
        lastArg();
    }
}

// 호출부 B (거의 동일한 코드 반복)
const args = task.request?.args;
if (args && args.length > 0) {
    const lastArg = args[args.length - 1];
    if (typeof lastArg === 'function' && lastArg.name === '_taskDone') {
        lastArg();
    }
}
```
