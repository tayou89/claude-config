---
name: integration-testing
description: Integration/runtime test workflow. Apply when running tests against a live or simulated environment — any setup with external dependencies (servers, simulators, databases, message brokers, hardware emulators).
user-invocable: false
---

# Integration Testing Rules

Apply these rules when running integration/runtime tests against a live or simulated environment.

## 1. Verify Infrastructure First (Hard Prereq)

BEFORE starting any integration test, actively probe every external endpoint declared in the test config — `ping` the host AND TCP port-check each port. Log results visibly. If ANY endpoint is down, abort test and investigate the environment FIRST before assuming code bug. "Should be up" is not verification. When you see connection errors mid-test, return to this step before diagnosing as code.

## 2. Structured Test Execution

Organize tests bottom-up — unit-level module tests first, then controller/service tests, then end-to-end scenarios, then error/recovery, then soak tests. Track each test case with ID, status (PASS/FAIL/SKIP), and notes.

## 3. Monitor-Trigger-Verify Loop

For each test — trigger the action, capture logs immediately (process manager logs, container logs, system journal, etc.), verify (a) no runtime errors, (b) expected output, (c) expected state changes.

## 4. Fix at the Source

Runtime bugs belong to the source project, not the test harness or consumer. Fix root cause → rebuild → restart → retest. Grep for the same pattern project-wide before moving on.

**Never SKIP a test** due to harness/flow issues. On any test failure: (1) identify root cause (application code vs flow/harness/preconditions), (2) fix the source regardless of which project it lives in, (3) retest and verify PASS, (4) only then move to the next test. Consumer-specific bugs (wrong params in test harness, stale test data) are still bugs that must be fixed.

## 5. Set Up Proper Preconditions

When a test fails due to missing state (wrong initial data, wrong device position, stale records), set up the required preconditions and retest — never rationalize the failure as "simulator limitation", "expected fail", or "not a code issue" to justify skipping. Always attempt to set up required preconditions first using available tools/APIs. Only mark a test as SKIP with explicit user approval after demonstrating that precondition setup is technically impossible.

## 6. Remote Environment Diagnosis

When the system under test connects to remote services (simulators, test environments, external APIs), verify whether failures originate locally or remotely. Use SSH, network tools, or remote logs to confirm before assuming a code bug.

## 7. Don't Pivot Scope Without Approval

When the user authorizes a specific test scope (e.g. "full cycle", "end-to-end", "start to end/cancel"), do not silently fall back to weaker verification (isolated unit test, init-only smoke test, code review) on hitting blockers. Hitting a blocker during authorized work requires one of:
1. Actively fixing the blocker (SSH into the environment, orchestrate multi-API calls, modify config) and reporting progress
2. Explicitly requesting user help/approval to try an alternative approach
3. Stopping and asking how to proceed

Never declare a test "complete" or "passed" for a scope narrower than what was authorized.

## 8. Soak Test

After all manual tests pass, let the system run unattended for a defined period and verify zero errors in logs.

## 9. Clean Revert

After testing, revert all test-specific config changes (environment switches, commented-out code, dependency overrides). Never commit test-only modifications.

## 10. Preserve Logs

Never truncate log files during testing (no `pm2 flush`, `truncate`, `docker logs --tail` overwrites, etc.). Intermittent errors may not reproduce on demand, and the only evidence is in the log file. Use `grep` on the full log file directly instead of relying on tail-window commands which may miss errors past the window.
