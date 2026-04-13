#!/usr/bin/env python3
import json, sys, subprocess, os, datetime

data = json.load(sys.stdin)

# Basic info
model = data.get('model', {}).get('display_name', '')
cwd = data.get('workspace', {}).get('current_dir', '') or data.get('cwd', '')
directory = os.path.basename(cwd) if cwd else ''
cost = data.get('cost', {}).get('total_cost_usd', 0) or 0
pct = int(data.get('context_window', {}).get('used_percentage', 0) or 0)
duration_ms = data.get('cost', {}).get('total_duration_ms', 0) or 0
total_in = data.get('context_window', {}).get('total_input_tokens', 0) or 0
total_out = data.get('context_window', {}).get('total_output_tokens', 0) or 0

# Cache: try multiple possible paths
cur = data.get('context_window', {}).get('current_usage', {}) or {}
cache_read = cur.get('cache_read_input_tokens', 0) or 0
cache_create = cur.get('cache_creation_input_tokens', 0) or 0

# Colors
CYAN, GREEN, YELLOW, RED, DIM, RESET = '\033[36m', '\033[32m', '\033[33m', '\033[31m', '\033[90m', '\033[0m'

# Context progress bar
bar_color = RED if pct >= 80 else YELLOW if pct >= 50 else GREEN
filled = pct * 10 // 100
bar = '█' * filled + '░' * (10 - filled)

# Duration
mins, secs = duration_ms // 60000, (duration_ms % 60000) // 1000

# Git branch + detailed status
try:
    env = os.environ.copy()
    env['PATH'] = '/usr/local/bin:/usr/bin:/bin:' + env.get('PATH', '')
    branch = subprocess.check_output(
        ['git', '-C', cwd, '--no-optional-locks', 'branch', '--show-current'],
        text=True, stderr=subprocess.DEVNULL, env=env
    ).strip()
    branch = f' | 🌿 {branch}' if branch else ''
    porcelain = subprocess.check_output(
        ['git', '-C', cwd, '--no-optional-locks', 'status', '--porcelain'],
        text=True, stderr=subprocess.DEVNULL, env=env
    ).strip()
    if porcelain and branch:
        staged = modified = untracked = 0
        for line in porcelain.splitlines():
            if len(line) >= 2:
                x, y = line[0], line[1]
                if x == '?':
                    untracked += 1
                else:
                    if x in 'MADRC':
                        staged += 1
                    if y in 'MD':
                        modified += 1
        parts = []
        if staged: parts.append(f'{GREEN}+{staged}{RESET}')
        if modified: parts.append(f'{YELLOW}~{modified}{RESET}')
        if untracked: parts.append(f'{RED}?{untracked}{RESET}')
        if parts:
            branch += ' ' + ' '.join(parts)
        else:
            branch += f' {RED}*{RESET}'
except Exception:
    branch = ''

# Rate limits
rl = data.get('rate_limits', {})
rate_parts = []
for key, label in [('five_hour', '5h'), ('seven_day', '7d')]:
    obj = rl.get(key)
    if obj:
        rpct = int(obj.get('used_percentage', 0))
        ts = obj.get('resets_at')
        rc = RED if rpct >= 80 else YELLOW if rpct >= 50 else DIM
        if ts and ts > 0:
            reset = datetime.datetime.fromtimestamp(ts).strftime('%H:%M')
            rate_parts.append(f'{rc}[{label}: {rpct}% → {reset}]{RESET}')
        else:
            rate_parts.append(f'{rc}[{label}: {rpct}%]{RESET}')
rate_str = ' '.join(rate_parts)

# Line 1: model, directory, branch + git status
print(f'{CYAN}[{model}]{RESET} 📁 {directory}{branch}')

# Line 2: context bar, tokens, cost, duration, rate limits
def fmt_tokens(n):
    if n >= 1_000_000: return f'{n/1_000_000:.1f}M'
    if n >= 1_000: return f'{n/1_000:.0f}k'
    return str(n)

cache_total = cache_read + cache_create
cache_pct = int(cache_read * 100 / cache_total) if cache_total > 0 else 0
cache_str = f' 💾{cache_pct}%' if cache_total > 0 else ''

line2 = f'{bar_color}{bar}{RESET} {pct}% | {DIM}↓{fmt_tokens(total_in)} ↑{fmt_tokens(total_out)}{cache_str}{RESET} | {YELLOW}${cost:.2f}{RESET} | ⏱️ {mins}m {secs}s'
if rate_str:
    line2 += f' | {rate_str}'
print(line2)
