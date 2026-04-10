---
name: typescript
description: TypeScript rules applied when writing, converting, or modifying .ts files. Automatically referenced when creating or editing TypeScript code.
user-invocable: false
---

# TypeScript Rules

Apply these rules when writing or modifying TypeScript code.

## Build Quality

- Maintain `npx tsc --noEmit` with **0 errors**
- Run `eslint` on changed `.ts` files before commit — **0 errors** required. Warnings from original JS code patterns are acceptable.
- Target **0 IDE warnings** (ESLint, TS hints). Fix via code changes or ESLint rule adjustments.
- Disable JS-native ESLint rules (`no-unused-vars`, `no-use-before-define`, `no-shadow`) that false-positive in TS. Use `@typescript-eslint/` equivalents.

## Build Procedure

Before running `tsc` build (output generation):
1. **Style check**: verify code-style compliance (all rules, not a subset)
2. **`npx tsc --noEmit`**: confirm 0 type errors
3. **`eslint`**: confirm 0 errors on changed `.ts` files
4. **User approval**: show code, get confirmation
5. **`npx tsc` build**: generate .js/.js.map only after approval

**Never run `npx tsc` (output build) without user approval.**

## Source and Build Artifacts

When `.ts` and corresponding `.js` coexist, `.js` is a build artifact. **Always edit `.ts` and build with `tsc`** — never edit `.js` directly. Check for corresponding `.ts` before modifying any `.js`.

- After `.ts` changes, build and commit `.js`, `.js.map`, `tsconfig.tsbuildinfo` together.
- `.ts` source and its `.js`/`.js.map` output MUST be in the **same commit**.

## ESModule Syntax

Use `import`/`export` instead of `require()`/`module.exports`. tsc compiles to CommonJS so runtime compatibility is preserved.

**require format in TS files**: When `require()` is needed (module with JS consumers), use `import X = require(...)` form only. Never mix `const X = require(...)` with import statements.

**Module with no JS consumers** → `import X from '...'` or `import { X } from '...'`
**Module with JS consumers** → `import X = require('...')`
**Type only** → `import type { X } from '...'`

**Named import for partial values**: With `esModuleInterop: true`, `export =` modules support named imports. Destructure at import time, don't create intermediate variables.

```ts
// Good
import { WRITE_BLOCK, READ_BLOCK } from './crane-map';

// Bad — intermediate variable
import craneMapModule = require('./crane-map');
const { WRITE_BLOCK, READ_BLOCK } = craneMapModule;
```

Exceptions for `import X = require(...)` + destructure: `export = X` modules (tsc 2497 error), when full module reference is needed (`typeof module.FIELD`), single-value exports (Logger, ThingExt, drivers).

## Named Export (No Default Export)

Always use named exports. Never `export default`. Enforces import name consistency, IDE refactoring accuracy, and multi-export consistency.

## No import * (CJS Namespace Exception)

Don't use `import * as X`. Use named imports. **Exception**: CJS modules where `module.exports = { a: {...}, b: {...} }` makes the module itself a namespace (e.g. `jsmodbus`).

## Type Safety

- **`as const`**: Use for immutable constant data (PLC maps, configs). If `readonly` compatibility issues arise, adjust the **receiving interface** to accept `readonly`, don't remove `as const`.
- **`readonly` propagation**: Declare non-mutated array/object params as `readonly`.
- **Type narrowing first**: Prefer type guards, generics, and interface design over `as` casts.
- **Specific types**: Define concrete interfaces instead of `Record<string, unknown>`, `object`, `any`. Use base interface + extends for shared/individual fields. Get approval with justification if loose types are unavoidable.

## Access Modifiers and Naming

- **`public`**: Omit keyword (TS default)
- **`protected`**: Explicit. For subclass-accessed members.
- **`private`**: Explicit. For class-internal members.

Internal-only members MUST be `private` or `protected`.

**`_` prefix**: Applied to `private` and `protected` members (properties and methods). Not applied to `public` members.

**Class member order**: properties (public → protected → private) → constructor → methods (public → protected → private).

## Uniform Category Conventions

Same-category modules (equipment, controllers, drivers) must share the **same level of type definition, naming patterns, and class structure**. Don't make one module specific while others are loose. When upgrading type precision, upgrade all in the category together.

## Typed Event/Callback Systems

Design event bus/emitter/callback systems with **typed patterns**. Define payload types per event in EventMap so callback params are never `unknown`/`any`.

```ts
interface EventMap {
    'user:login': (userId: string, timestamp: number) => void;
    'data:received': (payload: DataPayload) => void;
}
```

Get approval if `unknown`/`any` callback params are unavoidable.

## Minimize Type Casting

**`as unknown as` (double cast) forbidden.** Fix type design with interfaces/generics.

**`as Type` (single cast)** — depends on data source:

- **Allowed** for internal structured data: hardware comm data parsed by same-codebase drivers, fixed-structure event payloads (open-protocol, ROS), narrowing already-typed function returns. Define interface and cast with `as InterfaceName`.
- **Require type guard or Zod** for untrusted external data: REST API responses, user input, external WebSocket messages, parsed JSON files. **Get user approval before writing new type guards** — don't over-engineer for internal hardware data.

**`undefined!` exception**: Allowed only in `dispose()` for forcing GC reference release.

**Local variable to eliminate `as`**: After type guard, if `as` is still needed (e.g. array index access), assign to local variable first — TS narrows it automatically.

## Code Line Length

Max **120 characters** per line. When breaking multi-item imports/exports across lines, put **one item per line**.

## Generics

When a base class/common module handles **different data structures per subclass/consumer**, use generics. Don't use `Record<string, unknown>`, `any`, or casts. Review existing `any`/`Record<string, unknown>`/casts during conversion for generic replacement.

**Generic classes**: Design common base with generics so subclasses specify concrete types. Callers shouldn't need to specify types manually each time.

## Common Interfaces

When multiple classes share the same methods, define a common interface with `implements`. Eliminates casts in factories/containers.

## any / unknown Rules

**`any` — Forbidden.** No exceptions.

**`unknown` — External boundaries only, requires user approval.** Before using `unknown`:
1. Trace actual call/data flow to find concrete type
2. Only if truly impossible, explain with justification and get approval
3. Never write `unknown` without approval

External boundaries: hardware raw data, WebSocket messages, JSON.parse results. Internal code (function params, return values, callbacks) must use concrete types.

## `Record<string, unknown>` Minimization

It's a variant of `unknown`. Before using, check: (1) trace actual fields, (2) define interface if known, (3) use recursive types for nested structures, (4) for library options, define known fields + `[key: string]: unknown` for extensibility.

**Allowed**: external API metadata, undocumented library options, generic constraints (`TTags extends Record<string, unknown>`).

## External Library `.d.ts` Declarations

For libraries without `@types/`: methods accepting/returning "anything" should use `unknown`, not `Record<string, unknown>`. The latter forces downstream code to add `[key: string]: unknown` index signatures, causing type pollution.

## Root Cause for Type Errors

Never add `[key: string]: unknown` or `as` casts to **dodge** type errors. When errors cascade (A fix → B error → B fix → C error), find the **cascade start point** and fix that declaration. Multiple places needing index signatures/casts = signal that root cause is elsewhere.

## No Type Suppression Comments

Never use `@ts-expect-error`, `@ts-ignore`, `eslint-disable`. Fix the actual type error.

## No `Function` Type

Define concrete function signatures instead.

## interface vs type

**Object shapes → `interface`**. Unions/intersections/utility types → **`type`**.

## Extract Long Inline Types

When inline types (function types, object types, unions) in parameters/returns/properties get long, extract to `type` alias or `interface`.

## No Repeated Inline Object Types

When the same object shape (or a subset of it) appears in 2+ places — parameters, return types, `as` casts, destructuring annotations — extract it to a named `interface`.

- Owner: the class/module that produces or stores the data (provider principle)
- Consumers import the interface, never redefine the shape inline
- Violation signal: inline `as { field: Type }` cast, or identical field sets in separate type annotations

## No enum — Use const Object

Use `as const` objects with derived types instead of TypeScript `enum`.

```ts
const DEVICE = { AGV: 'agv', CHARGER: 'charger' } as const;
type DeviceType = (typeof DEVICE)[keyof typeof DEVICE];
```

## Function Style

- **Class methods**: arrow functions (`=`) for safe `this` binding
- **Module-level utilities**: function declarations

## null vs undefined

Default to **`undefined`** (compatible with optional params `param?: Type`). Use `null` only for explicit "intentionally empty" (e.g. API response with no data).

## Type File Location

Co-locate types near their module: `types/` folder with `{module}.types.ts`.
- Module-shared types → module's `types/` folder
- Cross-module shared types → `define/types.ts`
- File-internal types → inline at file top

## Conditional Types for Input Shape Detection

Type utilities handling multiple input shapes should use conditional types for automatic detection with a single entry point (like Zod's `z.infer<>`, `Awaited<T>`, `ReturnType<T>`).

## Explicit Return Types

Always specify function/method return types. Don't rely on inference.
