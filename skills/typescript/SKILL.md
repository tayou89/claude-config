---
name: typescript
description: TypeScript 코드 작성, 전환, 수정 시 적용할 규칙. .ts 파일을 생성하거나 편집할 때 자동으로 참조한다.
user-invocable: false
---

# TypeScript 규칙

TypeScript 코드를 작성하거나 수정할 때 아래 규칙을 따른다.

## 빌드 및 경고 품질 기준

- `npx tsc --noEmit` 에러 **0개**를 유지한다
- IDE 경고(ESLint, TypeScript 힌트) **0개**를 목표로 한다. 경고가 발생하면 코드 수정 또는 ESLint 규칙 조정으로 해결한다
- ESLint의 JS 기본 규칙(`no-unused-vars`, `no-use-before-define`, `no-shadow`)은 TypeScript에서 오탐이 발생하므로 **off**하고, `@typescript-eslint/` 대응 규칙을 사용한다

## 소스와 빌드 산출물

`.ts` 파일과 대응하는 `.js` 파일이 함께 존재하면, `.js`는 빌드 산출물이다. **반드시 `.ts` 파일을 수정하고 빌드(`tsc`)하여 `.js`를 생성**한다. `.js`를 직접 수정하지 않는다. 수정 전에 대응하는 `.ts` 파일이 존재하는지 항상 확인한다.

- `.ts` 파일 수정 시 반드시 `tsc` 빌드 후 산출물(`.js`, `.js.map`, `tsconfig.tsbuildinfo`)을 함께 커밋한다
- `.ts` 소스 파일과 그 빌드 산출물(`.js`, `.js.map`)은 **반드시 같은 커밋**에 포함한다. 소스와 빌드를 별도 커밋으로 분리하지 않는다
- `tsconfig.tsbuildinfo`도 함께 커밋한다 (incremental build 캐시, 다른 개발자의 빌드 시간 단축)

## ESModule 문법 사용

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

## named export 사용 (default export 금지)

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

## import * 금지

`import * as X from '...'`를 사용하지 않는다. 필요한 것만 named import한다. 모듈 전체가 필요한 경우는 모듈 구조를 재설계한다.

```
// ✅ Good
import { UDP as FEnetUDP, TCP as FEnetTCP } from './fenet';

// ❌ Bad
import * as FEnet from './fenet';
```

## 타입은 항상 안전하고 정확한 쪽으로

타입 관련 선택이 필요할 때는 항상 **더 안전하고 더 정확한 쪽**을 택한다. 편의를 위해 타입 안전성을 포기하지 않는다.

- **`as const` 유지**: 불변 상수 데이터(PLC 맵, 설정값 등)에는 `as const`를 사용한다. `readonly` 호환 문제가 생기면 `as const`를 제거하지 않고 **받는 쪽 인터페이스에서 `readonly`를 수용**하도록 수정한다. 내부에서 배열을 변형하지 않는다면 파라미터 타입을 `readonly T[]`로 선언한다.
- **`readonly` 전파**: 변형하지 않는 배열/객체 파라미터는 `readonly`로 선언하여 불변성을 타입 시스템으로 보장한다.
- **타입 좁히기 우선**: 캐스팅(`as`)보다 타입 가드, 제네릭, 인터페이스 설계를 우선한다.
- **구체적 타입 정의 원칙**: `Record<string, unknown>`, `object`, `any` 등 느슨한 타입 대신 **구체적 인터페이스를 정의**하는 것이 정석이다. 공통 필드는 베이스 인터페이스로, 개별 필드는 extends로 확장한다. 느슨한 타입을 사용해야 할 경우 사용자에게 근거와 함께 승인받는다.

## 동일 카테고리는 동일 수준으로 통일

같은 역할/카테고리에 속하는 모듈들은 **타입 정의 수준, 패턴, 구조를 통일**한다. 한 모듈만 다른 방식으로 하지 않는다.

- **타입 정의 수준**: 동일 카테고리의 모듈이 `Record<string, unknown>`을 쓰면 전부 그렇게 하고, 구체 인터페이스를 쓰면 전부 구체적으로 한다. 한 모듈만 구체적이고 나머지가 느슨하면 안 된다. 수준을 올리려면 전부 함께 올린다.
- **네이밍 패턴**: 인터페이스명(`XxxConfig`, `XxxOptions`, `XxxTags`), 변수명, 메서드명이 같은 카테고리 내에서 일관되어야 한다.
- **클래스 구조**: 같은 베이스 클래스를 상속하는 모듈들은 생성자 패턴, 초기화 흐름, dispose 패턴이 동일해야 한다.
- **적용 범위**: equipment 장비 클래스, controller 컨트롤러, driver 드라이버 등 동일 디렉터리/역할의 모듈이 대상이다.

변경 시 한 모듈만 바꾸면 불일치가 생길 수 있으므로, **같은 카테고리 전체에 영향을 주는 변경인지 확인**하고 필요하면 전부 함께 수정한다.

```
// ✅ Good — 전체 장비가 동일 수준
interface DoorConfig { options: { driver: string; config: Record<string, unknown> } }
interface CraneOptions { driver: string; config: Record<string, unknown> }

// ✅ Good — as const 유지, 받는 쪽에서 readonly 수용
const MAP = { model: [...] } as const;

addWriteBlock = (block: { model: readonly WriteModel[] }): void => {
    block.model.forEach(item => { ... });
};

// ❌ Bad — Crane만 구체적, 나머지는 느슨
interface DoorConfig { options: { config: Record<string, unknown> } }
interface CraneOptions { config: CraneConfig }
```

## 타입 캐스팅 최소화

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

## 코드 줄 길이

한 줄은 **120자 이내**로 작성한다. 초과하면 줄바꿈하여 가독성을 유지한다.

```
// ✅ Good — 120자 이내로 줄바꿈
write = (
    addr: string,
    values: Data,
    type: string,
    options?: MemoryModelOptions,
): Promise<CommResponse | undefined> => {

// ❌ Bad — 한 줄에 모두 작성
write = (addr: string, values: Data, type: string, options?: MemoryModelOptions): Promise<CommResponse | undefined> => {
```

## 제네릭 활용 원칙

TypeScript 전환 또는 코드 작성 시, 베이스 클래스/공통 모듈이 **하위 클래스/사용처마다 다른 데이터 구조**를 다루면 제네릭으로 설계한다. `Record<string, unknown>`, `any`, 타입 캐스팅으로 우회하지 않고 제네릭으로 해결한다.

제네릭이 필요한 대표 패턴:

- **베이스 클래스**: 하위 클래스가 각각 다른 타입의 데이터를 저장/반환하는 경우 → 베이스에 제네릭 파라미터 추가
- **팩토리/컨테이너**: 여러 타입의 객체를 관리하는 경우 → 반환 타입에 제네릭 적용
- **콜백/이벤트 핸들러**: 인자가 사용처마다 다른 경우 → 콜백 타입을 제네릭으로
- **공통 유틸리티**: 입력 타입에 따라 출력 타입이 결정되는 경우 → 제네릭 함수로

전환 작업 시 기존 코드에서 `any`, `Record<string, unknown>`, 타입 캐스팅, duck typing으로 처리된 곳을 발견하면 **제네릭으로 교체할 수 있는지 먼저 검토**한다.

## 제네릭 클래스 활용

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

## 공통 인터페이스 정의

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

## any / unknown 사용 원칙

`any`와 `unknown`은 모두 **구체적 타입을 찾는 노력을 먼저** 한 뒤에만 고려한다. 실제 데이터 흐름을 추적하여 정확한 타입을 정의할 수 있다면 반드시 그렇게 한다.

**`any` — 금지.** 어떤 경우에도 사용하지 않는다.

**`unknown` — 외부 경계에서만 허용, 사용 전 사용자 확인 필수.** `unknown`을 사용해야 할 것 같은 상황이 오면:
1. 먼저 실제 호출/데이터 흐름을 추적하여 구체적 타입을 찾는다
2. 구체적 타입이 정말 불가능한 경우에만 사용자에게 근거와 함께 확인받는다
3. 승인 없이 `unknown`을 작성하지 않는다

외부 경계란 하드웨어에서 읽은 raw 데이터, WebSocket 수신 메시지, JSON.parse 결과 등 런타임에 타입을 보장할 수 없는 지점을 말한다. 내부 코드 간 전달(함수 파라미터, 반환값, 콜백 등)에는 반드시 구체적 타입을 사용한다.

```
// ✅ Good — 실제 호출 흐름을 추적하여 정확한 타입 정의
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

## 타입 억제 주석 금지

`@ts-expect-error`, `@ts-ignore`, `eslint-disable` 주석을 사용하지 않는다. 타입 에러가 발생하면 **타입을 올바르게 수정**하여 해결한다. 주석으로 에러를 숨기는 것은 근본 원인을 방치하는 것이다.

```
// ❌ Bad — 주석으로 에러 숨김
// @ts-expect-error 타입 불일치
await this.work.alloc(plateNo, workplaceId, this.workMode);

// ❌ Bad
// eslint-disable-next-line @typescript-eslint/no-unsafe-function-type
type StepFunction = Function;

// ✅ Good — 타입을 올바르게 수정
type StepFunction = (option: StepOption) => Promise<void>;
```

## `Function` 타입 금지

`Function` 타입을 사용하지 않는다. **구체적인 함수 시그니처**를 정의한다.

```
// ✅ Good
type TaskCallback = (result: boolean) => void;
interface StepOption {
    func: TaskCallback;
}

// ❌ Bad
interface StepOption {
    func: Function;
}
```

## interface vs type

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

## 긴 타입 시그니처 분리

인라인 타입(함수 타입, 객체 타입, 유니온 타입 등)이 길어지면 **`type` 별칭 또는 `interface`로 분리**한다. 파라미터, 반환 타입, 프로퍼티 등에 인라인으로 긴 타입이 들어가면 가독성이 떨어진다.

```
// ✅ Good — 콜백 타입을 별칭으로 분리
type EventHandler = (topic: string, error?: Error) => void;

interface ChargerObject {
    on(name: string, condition: string, handler: EventHandler): void;
}

// ✅ Good — 인라인 객체 타입을 interface로 분리
interface TagResponse {
    uptime: number;
    data: Record<string, unknown>;
}

parseTags = (responses: TagResponse | TagResponse[]): void => {

// ❌ Bad — 인라인 함수 타입이 너무 길어 가독성 저하
interface ChargerObject {
    on(name: string, condition: string, handler: (topic: string, error?: Error) => void): void;
}

// ❌ Bad — 인라인 객체 타입이 파라미터에 직접 들어감
parseTags = (
    responses: { uptime: number; data: Record<string, unknown> }
        | { uptime: number; data: Record<string, unknown> }[],
): void => {
```

## enum vs const object

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

## 함수 스타일

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

## null vs undefined

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

## 타입 파일 위치

타입 정의는 **해당 모듈 가까이에 co-locate**한다. 모듈 디렉터리 하위에 `types/` 폴더를 만들고 `{모듈명}.types.ts` 형식으로 배치한다.

- **모듈 공유 타입**: 해당 모듈의 `types/` 폴더에 정의. 예: `server/types/operation-server.types.ts`, `equipment/types/charger.types.ts`
- **여러 모듈에서 공유하는 공통 타입**: `define/types.ts` 등 공통 정의 파일
- **해당 파일에서만 사용하는 내부 타입**: 파일 상단에 인라인 정의

```
// ✅ Good — 모듈 co-location
// server/types/operation-server.types.ts
export interface ChargeData { ... }
export interface WorkData { ... }

// ✅ Good — 공통 도메인 타입
// define/types.ts
export interface BatterySlot { ... }

// ✅ Good — 내부 전용: 인라인
// controller/work.ts
interface AllocLock {
    [workplaceId: number]: boolean;
}
class Work { ... }
```

## 반환 타입 명시

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
