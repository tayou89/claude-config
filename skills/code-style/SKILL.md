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

## 불필요한 `return undefined` 금지

함수 반환 타입에 `undefined`가 포함될 때, `else { return undefined; }` 또는 `else { return; }`처럼 **암묵적으로 undefined를 반환하는 것과 동일한 코드를 명시적으로 작성하지 않는다**. else 블록 자체를 생략한다.

```
// ✅ Good — else 생략, 암묵적 undefined 반환
toString = (data: string | undefined): string | undefined => {
    if (data) {
        return data.toUpperCase();
    }
};

// ❌ Bad — 불필요한 else + return undefined
toString = (data: string | undefined): string | undefined => {
    if (data) {
        return data.toUpperCase();
    } else {
        return undefined;
    }
};
```

## truthy 체크 우선

`!= undefined`, `!== undefined`, `!= null` 대신 **truthy 체크(`if (value)`)를 우선 사용**한다. 단, `0`, `''`, `false` 등 falsy 값이 유효한 값인 경우에만 명시적 비교(`!== undefined`)를 사용한다.

```
// ✅ Good — truthy 체크 (0, '', false가 유효하지 않은 경우)
if (data) {
    process(data);
}

// ✅ Good — 명시적 비교 (0이 유효한 값인 경우)
if (count !== undefined) {
    setCount(count);  // count가 0이어도 유효
}

// ❌ Bad — 불필요한 명시적 비교
if (data != undefined) {
    process(data);  // data가 0이나 ''일 가능성이 없는데 명시적 비교
}
```

## 파일 상단 구조: import → 타입/인터페이스 → 상수/변수

파일 상단은 다음 순서로 구성한다. 각 섹션 사이에는 **빈 줄 하나**로 구분한다. (TypeScript 커뮤니티 일반 관행 — 상수가 타입에 의존할 수 있으므로 타입을 먼저 정의)

1. **import / require** — 모든 외부 의존성
2. **type / interface 정의** — 해당 파일에서 사용하는 타입/인터페이스
3. **상수/변수 선언** — `const`, `let` 등

```ts
// ✅ Good
import Logger = require('../util/logger');
import { EventEmitter } from 'events';

interface FooOptions {
    host: string;
    port: number;
}

const DEFAULT_TIMEOUT = 3000;
const { SOME_CONSTANT } = PROPERTY;

// ❌ Bad — 상수가 타입 정의보다 먼저 오는 경우
import Logger = require('../util/logger');
const { SOME_CONSTANT } = PROPERTY;

interface FooOptions { ... }
```

## import는 반드시 파일 상단에

모든 `import` / `require`는 **파일 최상단에 모아서 선언**한다. 코드 중간에 인라인 `import()`나 `require()`를 넣지 않는다. TypeScript의 `import('path').Type` 인라인 타입 참조도 금지한다.

인라인 import는 IDE 자동완성/리팩터링 추적이 끊기고, 코드 흐름을 이해하기 위해 파일 전체를 읽어야 하는 부담을 만든다.

불가피하게 인라인 import가 필요한 경우(순환 의존 회피 등)에는 **사용자에게 이유를 설명하고 승인받은 후** 사용한다.

```ts
// ✅ Good — 상단에 일괄 선언
import type { DriverOptions } from '../driver/common/types';
const Logger = require('../util/logger');

interface ChargerOptions {
    driver: string;
    config: DriverOptions;
}

// ❌ Bad — 인터페이스 안에 인라인 import()
interface ChargerOptions {
    driver: string;
    config: import('../driver/common/types').DriverOptions;
}

// ❌ Bad — 함수 중간에 require()
const connect = () => {
    const net = require('net');
    net.createConnection(...);
};
```

## 파일 상단 타입/인터페이스 섹션 — 빈 줄 없음

파일 상단의 `type`/`interface` 선언들은 **하나의 타입 섹션**으로 취급한다. 각 정의 사이에 빈 줄을 넣지 않는다. 타입 섹션 전체 끝에만 빈 줄 하나를 넣어 상수 섹션과 구분한다.

이 규칙은 "변수 선언 후 빈 줄" 규칙의 예외다 — 타입/인터페이스는 런타임 값이 아니므로 섹션 내 빈 줄 없이 묶는다.

```ts
// ✅ Good — 타입 섹션 내 빈 줄 없음
type FooTags = TagsFrom<typeof WRITE_BLOCK>;
interface FooOptions {
    driver: string;
    config: DriverOptions;
}
interface BarConfig {
    host: string;
    port: number;
}
type ExpectedMap = Record<string, number>;

const DEFAULT_TIMEOUT = 3000; // 타입 섹션 끝에 빈 줄 하나 후 상수

// ❌ Bad — 타입/인터페이스 사이에 빈 줄
type FooTags = TagsFrom<typeof WRITE_BLOCK>;

interface FooOptions {
    driver: string;
}

interface BarConfig {
    host: string;
}
```

## 변수 선언 후 빈 줄

**연속된** `const`/`let`/`var` 선언들은 **하나의 블록**으로 취급한다. 블록 내 개별 선언 사이에는 빈 줄을 넣지 않고, **블록 전체 끝에 빈 줄 하나**만 넣는다. `return`문 앞이라도 예외 없이 빈 줄을 넣는다. **초기화 표현식의 형태(단순 값, 객체 리터럴, 함수 호출, 콜백 포함 여러 줄 등)에 관계없이 동일하게 적용한다.** **이 규칙은 함수/메서드 본문뿐 아니라 if, else, try, catch 등 모든 블록 내부에도 동일하게 적용한다.**

```
// ✅ Good — 객체 리터럴 변수 선언 후 빈 줄
const msg = {
    reqid_s: REQ.MOVE,
    param1: targetPos
};

await this.send(msg, callback);

// ✅ Good — 콜백 포함 여러 줄 변수 선언 후 빈 줄
const socket = net.createConnection(port, host, () => {
    socket.setTimeout(0);
    client.connect(connectionListener);
});

socket.setTimeout(20000);

// ✅ Good — return 앞에도 빈 줄
const state = this.getSocketState();

return !state || state === WebSocket.CLOSED;

// ✅ Good — 연속된 const는 하나의 블록, 블록 끝에만 빈 줄
const auth = new Auth({ username, password });
const res = await auth.request({ url });

this.setConnected(true);

// ❌ Bad — 연속된 const 선언 사이에 빈 줄
const auth = new Auth({ username, password });

const res = await auth.request({ url });    ← 제거

this.setConnected(true);

// ❌ Bad — 변수 선언 후 빈 줄 없음
const state = this.getSocketState();
return !state || state === WebSocket.CLOSED;

// ❌ Bad — 여러 줄 변수 선언 후 빈 줄 없음
const socket = net.createConnection(port, host, () => {
    socket.setTimeout(0);
    client.connect(connectionListener);
});
socket.setTimeout(20000);
```

## 메서드/함수 정의 사이 빈 줄

클래스 멤버, 메서드, 함수 정의 사이에는 **반드시 빈 줄 하나**를 넣어 구분한다.

## 메서드/함수 종류별 정리

클래스 내 메서드는 **종류별로 모아서 배치**한다. 관련된 메서드끼리 그룹핑하여 가독성을 높인다. 예시 순서: 생성/소멸 → 연결 → 상태 조회 → 통신/프로토콜 → 비즈니스 로직(제어 명령) → 파라미터/컨텍스트 관리 → 유틸리티 → check 함수(개별 → 복합).

## 메서드 내 불필요한 빈 줄 금지

메서드/함수 본문 안에서 빈 줄은 **변수 선언 블록 뒤에만** 허용한다. 그 외 모든 위치에는 빈 줄을 넣지 않는다:

- 실행문과 실행문 사이
- **모든 블록의 `}` 앞뒤** — `if`/`else`/`try`/`catch`/`for`/`while`/`forEach`/콜백/arrow function 등 종류 불문
- 주석 앞뒤

이 규칙은 중첩된 블록(콜백 안의 if, try 안의 forEach 등) 내부에도 **동일하게** 적용한다.

```
// ✅ Good — 변수 선언 뒤에만 빈 줄, 실행문 사이·블록 } 뒤 빈 줄 없음
create = () => {
    const driver = drivers.get(options);

    if (driver?.ref) {
        this.setComm(driver.ref);
    }
    this.addWriteBlock(WRITE_BLOCK);
    items.forEach((item) => {
        this.addReadBlock(item);
    });
    this.init();
};

// ✅ Good — 블록 내부에서도 동일
if (request) {
    const { tid, callback, msg } = request;
    const translated = this.translate(msg);

    this.commError(translated);
    clearTimeout(tid);
}

// ❌ Bad — 블록 } 뒤 불필요한 빈 줄 (if, forEach, 콜백 모두 해당)
if (condition) {
    doSomething();
}
                  ← 제거
doOther();

items.forEach((item) => {
    process(item);
});
                  ← 제거
doNext();

// ❌ Bad — 실행문 사이 불필요한 빈 줄
this.info('시작');

this.connect();
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

특별한 이유가 없다면 try-catch는 **함수 본문 전체를 감싸는 형태**로 작성한다. 부분적 try-catch는 에러 처리가 구간별로 달라야 할 때만 사용한다. **동일한 에러 처리를 하는 try-catch를 중첩하지 않는다.** `await`과 `.catch()`를 혼용하지 않고, `async/await` 함수 내에서는 반드시 `try/catch`로 에러를 처리한다.

**핸들러/콜백 함수**(이벤트 핸들러, `setInterval`/`setTimeout` 콜백, Express 미들웨어 등)에서는 **변수 선언을 포함한 함수 본문 전체**를 try-catch로 감싼다. 이런 함수는 에러가 상위로 전파될 곳이 없어 uncaught error가 프로세스를 크래시시킬 수 있다.

```
// ✅ Good — 핸들러: 변수 선언 포함 전체 감싸기
startStatusCheck = () => {
    this.timer = setInterval(async () => {
        try {
            const status = this.collectStatus();
            const updatedAt = new Date().getTime();

            await this.updateStatus(status, updatedAt);
        } catch (error) {
            this.error('상태 업데이트 실패: ', error);
        }
    }, 3000);
};

// ❌ Bad — 핸들러: 변수 선언이 try 밖에 있어 에러 시 크래시
startStatusCheck = () => {
    this.timer = setInterval(async () => {
        const status = this.collectStatus();  // 여기서 throw되면 uncaught
        const updatedAt = new Date().getTime();

        try {
            await this.updateStatus(status, updatedAt);
        } catch (error) {
            this.error('상태 업데이트 실패: ', error);
        }
    }, 3000);
};
```

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

// ❌ Bad — await과 .catch() 혼용
updateStatus = async (data) => {
    if (data) {
        await this.opServer.updateDeviceStatus(data).catch((error) => {
            this.error('업데이트 실패: ', error);
        });
    }
};

// ✅ Good — 구간별로 다른 에러 처리가 필요한 경우의 부분 try-catch
doWork = async () => {
    try {
        await apiA();
    } catch (error) {
        this.error('A 실패, 재시도', error);
        await apiA();
    }

    try {
        await apiB();
    } catch (error) {
        this.error('B 실패, 무시하고 계속', error);
    }

    await apiC(); // 이건 실패하면 상위로 throw
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

## check vs is 네이밍 규칙

| 접두사 | 역할 | 반환값 | 예시 |
|--------|------|--------|------|
| `check` | 전제조건 검증, 실패 시 throw | `void` | `checkConnection()`, `checkHealth()` |
| `is` | 상태 조회 | `boolean` | `isConnected()`, `isHealthy()` |

- `check` 함수는 **검증만 수행**하고 값을 반환하지 않는다. 조건 불충족 시 throw한다.
- `is` 함수는 **boolean을 반환**하고 throw하지 않는다. 상태 확인 용도.
- boolean을 반환해야 하는데 `check`로 이름 지으면 안 되고, throw해야 하는데 `is`로 이름 지으면 안 된다.

```
// ✅ Good
checkHealth = async () => {
    const response = await this._axios.get('/actuator/health');

    if (response.data?.status !== 'UP') {
        throw new Error('운영서버 상태 이상: ' + response.data?.status);
    }
};

isConnected = () => {
    return this._commStatus.status == COMM_STAT.OK;
};

// ❌ Bad — check인데 boolean 반환
checkHealth = async () => {
    const response = await this._axios.get('/actuator/health');

    return response.data?.status === 'UP';
};
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
- 섹션 구분용 주석은 형식에 관계없이 **모두 금지**한다 — 텍스트, 구분선, 이모지 등 어떤 형태든 포함

  금지 예시: `// === 유틸 ===`, `// 작업`, `// AGV`, `// --- Types ---`, `// ── Class ────`, `// *** Constants ***`, `// #region`, `// MARK: -`

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

// ❌ Bad — 섹션 구분 주석 (형식 불문 전부 금지)
// === 유틸 함수 ===
// ── Class ────────────────────
// --- Types ---
// *** Constants ***
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

## 함수/유틸리티 명명: 목적 기준, 입력 형태 기준 금지

함수나 유틸리티의 이름은 **"무엇을 만드는가/하는가(목적)"** 를 나타내야 한다. 입력으로 받는 자료구조의 형태를 이름에 반영하지 않는다.

입력 형태를 이름에 넣으면:
- 자료구조가 변하거나 형태가 늘어날 때마다 이름을 새로 만들어야 한다
- 사용자가 "내 입력이 어느 형태인지" 판별해서 알맞은 함수를 골라야 한다
- 개념적으로 동일한 역할인데 이름이 달라 일관성이 깨진다

```
// ❌ Bad — 입력 형태(model 배열이냐, blocks 배열이냐)로 이름을 구분
TagsFromModel<typeof WRITE_BLOCK['model']>   // .model을 뽑아야 하는 경우
TagsFromReadBlocks<typeof READ_BLOCKS>        // 직접 전달하는 경우
// → 사용자가 매번 "지금 내 값이 어느 형태지?" 판단 필요

// ✅ Good — 목적(Tags를 만든다)만 이름에, 입력 형태 판별은 내부에서
TagsFrom<typeof WRITE_BLOCK>   // 형태를 자동 감지
TagsFrom<typeof READ_BLOCKS>   // 동일한 이름, 동일한 사용 패턴
```

**판단 기준**: 이름만 보고 "내가 이 함수에 무엇을 얻는가"가 바로 보이는가? 이름에 입력 형태(`Model`, `Array`, `Block`, `List`, `Object` 등)가 들어가 있다면 목적 기준으로 재검토한다.

**같은 역할, 다른 입력 형태** → 이름은 하나, 내부에서 형태를 처리한다 (오버로드, 조건부 타입, 타입 가드 등).

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

## 복잡한 타입 constraint는 named alias로 분리

조건부 타입(`T extends ... ? A : B`)의 `extends` 조건이 길거나 같은 구조가 반복되면, **named type alias로 먼저 추출**하고 조건부 타입 본문에서는 alias 이름만 참조한다. 이름 자체가 의도를 설명하므로 주석 없이도 각 분기의 의미가 바로 보인다.

```ts
// ❌ Bad — 인라인 constraint가 길어서 분기 의도가 묻힘
export type TagsFrom<T> =
    T extends readonly { model: readonly { name: string; type: string }[] }[]
        ? TagsFromModelArray<FlattenModels<T>>
    : T extends { model: readonly { name: string; type: string }[] }
        ? TagsFromModelArray<T['model']>
    : T extends readonly { name: string; type: string }[]
        ? TagsFromModelArray<T>
    : never;

// ✅ Good — constraint를 named alias로 분리 → 분기 의도가 한눈에 보임
type ReadBlocksArray = readonly { model: readonly { name: string; type: string }[] }[];
type BlockWithModel  = { model: readonly { name: string; type: string }[] };
type FlatModelArray  = readonly { name: string; type: string }[];

export type TagsFrom<T> =
    T extends ReadBlocksArray ? TagsFromModelArray<FlattenModels<T>>
  : T extends BlockWithModel  ? TagsFromModelArray<T['model']>
  : T extends FlatModelArray  ? TagsFromModelArray<T>
  : never;
```

**판단 기준**: `extends` 조건이 한 줄을 넘거나, 동일한 구조가 2곳 이상 반복되면 alias로 분리한다.

## 빌드 전 코드 스타일 검사

`tsc` 빌드를 실행하기 **전에** 반드시 작성한 코드가 이 스킬의 스타일 규칙을 준수하는지 확인한다. 빌드 후 산출물이 생성되면 스타일 수정 시 재빌드가 필요하므로, **스타일 문제를 빌드 전에 잡는다**.

검사 항목 (최소):
- 파일 상단 구조: import → type/interface → const 순서
- 연속 const/type/interface 사이 빈 줄 없음
- 메서드 내 불필요한 빈 줄 없음
- 접근 제한자 및 `_` 접두사
- 클래스 멤버 배치 순서 (public → protected → private)

## 리소스 정리는 호출부가 아닌 소유자에서

콜백 해제, 리스너 제거, 예약 취소 등 **리소스 정리 로직은 해당 리소스를 직접 관리하는 메서드 내부**에 둔다. 호출부에서 정리를 수행하면 다른 호출 경로에서 누락될 수 있다.

```
// ✅ Good — clearTask 내부에서 _taskDone 정리
clearTask = () => {
    this.resolveRemainingTaskDoneCallbacks();
    this._tasks = [];
    this.resetTaskCount();
};

// ❌ Bad — 호출부마다 개별적으로 정리 (다른 호출부에서 누락 위험)
// dispose에서
this.resolveRemainingTaskDoneCallbacks();
this.clearTask();

// 다른 곳에서 clearTask 호출 시 정리 누락 가능
this.clearTask();  // _taskDone 미처리
```
