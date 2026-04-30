#!/usr/bin/env bash
# claude-commit.sh — wrapper enforcing git-commit skill checklist.
#
# Usage:
#   claude-commit.sh [--amend] "<message>" <file1> [<file2> ...]
#
# Validates message format (subject prefix/length, body line length/count,
# bullet count, no internal terms), runs amend check, stages exact files,
# verifies no extras, prints verification table, then commits with
# CLAUDE_SKILL_GIT_COMMIT=1 marker. Subprocess git commit does NOT trigger
# Claude's PreToolUse hook (hooks fire at tool boundary only), so the
# checklist becomes the single enforced path.
#
# Exit codes:
#   0  success (commit created)
#   1  git error
#   2  message validation failure
#   3  staging mismatch
#   4  usage error

set -euo pipefail

AMEND=""
if [[ "${1:-}" == "--amend" ]]; then
    AMEND="--amend"
    shift
fi

if [[ $# -lt 2 ]]; then
    cat >&2 <<'EOF'
Usage: claude-commit.sh [--amend] "<message>" <file1> [<file2> ...]

Example:
  claude-commit.sh "$(cat <<MSG
Refactor: drop loose index signature from request boundary types

- bullet 1
- bullet 2
- bullet 3
MSG
  )" driver/common/types.ts driver/fenet/framebuilder.ts
EOF
    exit 4
fi

MSG="$1"
shift
FILES=("$@")

MSG_FILE=$(mktemp -t claude-commit-msg.XXXXXX)
trap 'rm -f "$MSG_FILE"' EXIT
printf '%s\n' "$MSG" > "$MSG_FILE"

echo "===================="
echo " claude-commit.sh"
echo "===================="

SUBJECT=$(sed -n '1p' "$MSG_FILE")
SUBJ_LEN=${#SUBJECT}

if (( SUBJ_LEN == 0 )); then
    echo "FAIL: empty subject" >&2
    exit 2
fi
if (( SUBJ_LEN > 72 )); then
    echo "FAIL: subject ${SUBJ_LEN} chars > 72" >&2
    echo "  subject: $SUBJECT" >&2
    exit 2
fi
if ! echo "$SUBJECT" | grep -qE '^(Feat|Fix|Refactor|Chore|Merge): '; then
    echo "FAIL: subject must start with Feat:|Fix:|Refactor:|Chore:|Merge:" >&2
    echo "  got: $SUBJECT" >&2
    exit 2
fi

SECOND=$(sed -n '2p' "$MSG_FILE")
if [[ -n "$SECOND" ]]; then
    echo "FAIL: line 2 must be blank" >&2
    exit 2
fi

BODY_MAX_LEN=$(awk 'NR>2 { if (length > max) max = length } END { print max+0 }' "$MSG_FILE")
if (( BODY_MAX_LEN > 72 )); then
    echo "FAIL: body line max ${BODY_MAX_LEN} chars > 72" >&2
    awk 'NR>2 && length > 72 { print NR": "length" chars: "$0 }' "$MSG_FILE" >&2
    exit 2
fi

BODY_LINES=$(awk 'NR>2 && NF>0' "$MSG_FILE" | wc -l)
if (( BODY_LINES < 1 )); then
    echo "FAIL: empty body" >&2
    exit 2
fi
if (( BODY_LINES > 8 )); then
    echo "FAIL: body has ${BODY_LINES} non-blank lines, max 8" >&2
    exit 2
fi

BULLET_COUNT=$(grep -c '^- ' "$MSG_FILE" || true)
if (( BULLET_COUNT < 3 )); then
    echo "FAIL: only ${BULLET_COUNT} bullets, need 3-5" >&2
    exit 2
fi
if (( BULLET_COUNT > 5 )); then
    echo "FAIL: ${BULLET_COUNT} bullets, max 5" >&2
    exit 2
fi

if grep -qiE '\b(step|phase|pattern)\s+[0-9]+\b' "$MSG_FILE"; then
    echo "FAIL: internal terms (Step N / Phase N / Pattern N) detected" >&2
    grep -niE '\b(step|phase|pattern)\s+[0-9]+\b' "$MSG_FILE" >&2
    exit 2
fi

echo
echo "=== Recent commits ==="
git log --oneline -3
echo

echo "=== Staging files ==="
for f in "${FILES[@]}"; do
    if [[ ! -e "$f" ]]; then
        echo "WARN: file not found in working tree: $f" >&2
    fi
    git add -- "$f"
    echo "  + $f"
done
echo

echo "=== Staged changes ==="
git diff --cached --stat
echo

EXPECTED=$(printf '%s\n' "${FILES[@]}" | sort -u)
ACTUAL=$(git diff --cached --name-only | sort -u)
EXTRA=$(comm -13 <(echo "$EXPECTED") <(echo "$ACTUAL") || true)

if [[ -n "$EXTRA" ]]; then
    echo "FAIL: files staged but not in argv:" >&2
    echo "$EXTRA" >&2
    echo >&2
    echo "Resolve: git restore --staged <unwanted-files>" >&2
    exit 3
fi

echo "=== Verification ==="
printf '| %-30s | %s\n' "Item" "Status"
printf '| %-30s | %s\n' "------------------------------" "--------"
printf '| %-30s | %s\n' "Type prefix" "✓"
printf '| %-30s | %s\n' "Subject ≤72 chars" "✓ (${SUBJ_LEN})"
printf '| %-30s | %s\n' "Body line max ≤72" "✓ (${BODY_MAX_LEN})"
printf '| %-30s | %s\n' "Body lines 1-8" "✓ (${BODY_LINES})"
printf '| %-30s | %s\n' "Bullets 3-5" "✓ (${BULLET_COUNT})"
printf '| %-30s | %s\n' "No internal terms" "✓"
printf '| %-30s | %s\n' "Stage matches argv" "✓"
echo

echo "=== Committing ==="
if [[ -n "$AMEND" ]]; then
    CLAUDE_SKILL_GIT_COMMIT=1 git commit --amend -F "$MSG_FILE"
else
    CLAUDE_SKILL_GIT_COMMIT=1 git commit -F "$MSG_FILE"
fi

echo
echo "=== Done ==="
git log --oneline -1
