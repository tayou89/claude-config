---
name: code-style
description: Coding style rules applied when writing or modifying code. Automatically referenced when generating or editing code.
user-invocable: false
---

# Coding Style Rules

Apply these rules when writing or modifying code. **Applies everywhere including plans, explanations, and example code.** No exceptions.

## Control Flow Braces

All control statements (`if`, `else`, `for`, `while`, `do`) MUST use braces `{}` with body on a new line. Never omit braces or write single-line bodies.

```
// Good
if (condition) {
    return value;
}

// Bad
if (condition) return value;
if (condition) { return value; }
```

## No Early Void Return / Guard Throw — Use if-else or Check Functions

Value-returning early returns (`return false`, `return 0`) are allowed. **Void returns and guard throws to exit a function are not.**

- Single condition: use if-else
- Multiple conditions: extract to a check function (see check function pattern below)

```
// Good — if-else
if (data) {
    const { cmd } = data;
    // main logic
} else {
    throw new Error('...');
}

// Bad — guard throw
if (!data) {
    throw new Error('...');
}
const { cmd } = data;
```

## Positive Conditions First

Prefer positive conditions over negated (`!`) conditions. Exception: simple conditions without else where negation is natural.

## Always Write Explicit else

When if branches return values or diverge processing, **always wrap the last branch in else**. Don't fall through past if to return.

```
// Good
if (errorCode) {
    return `Error: ${errorCode}`;
} else {
    return 'No error';
}

// Bad
if (errorCode) {
    return `Error: ${errorCode}`;
}
return 'No error';
```

## No Unnecessary `return undefined`

When return type includes `undefined`, don't write `else { return undefined; }` or `else { return; }`. Just omit the else block.

## Truthy Checks First

Use truthy checks (`if (value)`) over `!= undefined` / `!== undefined` / `!= null`. Use explicit comparison only when `0`, `''`, or `false` are valid values.

## File Top Structure: import → type → interface → const

Order file top sections with **one blank line** between sections:
1. **import / require**
2. **type aliases** (`type Foo = ...`)
3. **interface definitions** (`interface Foo { ... }`)
4. **const/let declarations**

## Import Ordering

Order imports by group, no blank lines between groups:

1. **Node.js built-ins** (`events`, `fs`, `path`, `net`, etc.)
2. **External packages** (`axios`, `lodash`, `ws`, etc.)
3. **Internal modules** (relative `./` `../` imports)
4. **Internal constants** (large destructured imports like `define/property`)
5. **`import type`** (always last)

Multiline destructured imports (4+ items) use one item per line with trailing comma.

## Imports at File Top Only

All `import`/`require` at file top. No inline `import()` or `require()` mid-code. No `import('path').Type` inline type references. If inline import is unavoidable (circular dependency), explain and get user approval.

## Type/Interface Section — No Blank Lines Between

Type and interface declarations form one section. No blank lines between them. One blank line only after the entire section ends (before const).

```ts
// Good
type FooTags = TagsFrom<typeof WRITE_BLOCK>;
interface FooOptions {
    driver: string;
}
interface BarConfig {
    host: string;
}

const DEFAULT_TIMEOUT = 3000;

// Bad — blank lines between types/interfaces
type FooTags = TagsFrom<typeof WRITE_BLOCK>;

interface FooOptions { ... }

interface BarConfig { ... }
```

## Blank Line After Variable Declarations

Consecutive `const`/`let`/`var` declarations form **one block**. No blank lines within the block. **One blank line after the block ends** — even before `return`. Applies to all blocks (function body, if, else, try, catch). Applies regardless of initializer form (simple value, object literal, multi-line callback).

```
// Good
const auth = new Auth({ username, password });
const res = await auth.request({ url });

this.setConnected(true);

// Good — blank line before return too
const state = this.getSocketState();

return !state || state === WebSocket.CLOSED;

// Bad — blank line between consecutive const
const auth = new Auth({ username, password });

const res = await auth.request({ url });
```

## Blank Line Between Method/Function Definitions

Always one blank line between class members, methods, and function definitions.

## Class Member Ordering

Order class members by access modifier, then group by type within each section:

1. **Properties** (public → protected → private)
2. **Constructor**
3. **Public methods** — type order below
4. **Protected methods** — type order below
5. **Private methods** — type order below

Within each access level, order method groups as (Angular/React/C++ convention — lifecycle first, predicates last):

1. **Lifecycle** (in order): `dispose*` → `create*` → `init*` → `start*` → `stop*` → `reset*` → `remove*` → `clear*`
   - `dispose` is the destructor counterpart to constructor — placed at the very top of each access section.
2. **Event/communication**: `on*`, `handle*`, `*EventHandler`, `send*`, `notify*`
3. **Accessors**: `get*`, `set*`
4. **Data operations**: `add*`, `update*`, `find*`, `parse*`, `make*`, `record*`, `alloc*`/`unalloc*`
5. **Misc** — methods not matching any listed prefix, grouped by their own prefix
6. **Predicates** (near bottom): `has*`, `is*`, `check*` (individual → composite)

Same-prefix methods must be adjacent. The numbered order above is the default; adjust if a file's domain makes a different grouping more natural, but never scatter same-prefix methods.

## Method Naming Convention

All method and function names MUST use camelCase. PascalCase is reserved for classes, interfaces, types, and enums only.

## Minimum Access Exposure

Prefer the most restrictive access modifier: private > protected > public. Use public only for methods called from outside the class hierarchy. Use protected for methods used by subclasses. Default to private for everything else.

**Exception**: keep public when the method belongs to the class's public contract even with no current callers — getters/setters, lifecycle API (`reset`, `start`, `stop`), interface implementations, utility class methods.

## No Unnecessary Blank Lines Inside Methods

Blank lines inside method bodies are allowed **only after variable declaration blocks**. No blank lines:
- Between execution statements
- Before/after any `}` (if/else/try/catch/for/while/forEach/callbacks)
- Before/after comments

This applies to nested blocks too.

```
// Good
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

// Bad — blank line after }
if (condition) {
    doSomething();
}

doOther();  // ← remove blank line above
```

## Remove Unnecessary async

Don't add `async` to functions that don't use `await`.

## Prefer const

Use `const` unless the variable is actually reassigned. `let` only for reassigned variables.

## Repeated Literals → Constants

String/number literals with structural meaning that appear **2+ times** should be defined as constants. Match the existing constant definition pattern (e.g. object form).

## Constant Location by Scope

- Referenced from multiple files → shared constant file (e.g. `property.js`)
- Used in one file/class only → file top or class internal

## await Over Promise Chains

Use `async/await` + `try/catch` instead of `.then().catch()`.

## Extract Long Inline Callbacks

Callbacks passed as parameters that exceed ~5 lines should be extracted to separate methods/functions.

## try-catch Scope

Default: wrap **entire function body**. Partial try-catch only when error handling differs by section. Don't nest try-catch with identical error handling. Don't mix `await` with `.catch()`.

**Handler/callback functions** (event handlers, setInterval/setTimeout, Express middleware): wrap **everything including variable declarations** in try-catch since errors can't propagate upward.

## User-Friendly Error Messages

Write error messages that non-technical people can understand. Avoid internal terms (tags, registers, instances).

```
// Good
throw new Error('Cannot verify warehouse control status.');
// Bad
throw new Error('warehouse.control tag missing');
```

## Avoid Abbreviations

Use full words in variable names, function names, and **type/interface names** unless the name becomes unreasonably long.

## check vs is Naming

| Prefix | Role | Returns | Example |
|--------|------|---------|---------|
| `check` | Precondition validation, throws on failure | `void` | `checkConnection()` |
| `is` | State query | `boolean` | `isConnected()` |

check functions validate only — they don't return values. If you need the value, call check then get separately.

## Check Function Pattern

**Individual check**: validates one condition, throws on failure, returns void.
**Composite check**: combines individual checks. Don't inline conditions in composite — call individual checks. Place at class bottom: individual → composite order.

Use in methods: common preconditions via composite, method-specific conditions by combining composite + individual. Even single-use preconditions should be extracted to check functions. Don't branch check calls with if-else in method body — use composite with parameters.

## throw Over Promise.reject

In async functions: use `throw` not `Promise.reject`. Use `await this.send()` not `return this.send()`. Never use `new Promise(async (resolve, reject) => ...)` anti-pattern.

## Minimize Comments + Explicit Naming

No comments explaining "what" code does — use clear names instead. Only allow comments explaining "why". **Section divider comments are forbidden** in all forms (text, lines, emoji, `// ===`, `// ---`, `// MARK:`, `#region`, etc.).

## String Literal Constants

Repeated or meaningful string literals should be defined as `const` constants. Don't use string literals directly in function args, event types, identifiers.

## Minimize Duplicate Code

Extract identical code into shared functions. In switch-case: if all cases produce same result, put it outside switch. If results differ, set in each case.

## Name by Purpose, Not Input Shape

Name functions/utilities by **what they produce**, not what input shape they take. Same role + different input shapes → one name, handle shapes internally (overloads, conditional types, type guards).

## No Duplicate Logic

Logic repeated in 2+ places → extract to a method. Check existing codebase for same patterns before writing new code.

## Named Alias for Complex Type Constraints

When `extends` condition in conditional types exceeds one line or same structure repeats 2+ times, extract to a named type alias.

## Resource Cleanup in Owner, Not Caller

Callback release, listener removal, schedule cancellation — place cleanup logic inside the method that owns the resource, not in callers. Otherwise other call paths may miss cleanup.

## Post-Change Verification

After completing code changes, run `npx eslint` on changed files. Report new errors and warnings to user. Changes must not increase the ESLint error/warning count compared to before the change.
