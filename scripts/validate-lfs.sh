#!/usr/bin/env bash
set -euo pipefail

: "${LFS:?LFS is not set}"

fail() { echo "ERROR: $*" >&2; exit 1; }
ok()   { echo "OK: $*"; }

echo "== Adimux OS LFS smoke validation =="
echo "LFS=$LFS"

# Basic dirs
for d in bin sbin lib lib64 usr usr/bin usr/sbin usr/lib usr/lib64 var; do
  [[ -e "$LFS/$d" ]] || fail "Missing $LFS/$d"
done
ok "base directory layout exists"

# Expected symlinks (LFS style)
[[ -L "$LFS/bin"   ]] || fail "$LFS/bin is not a symlink"
[[ -L "$LFS/sbin"  ]] || fail "$LFS/sbin is not a symlink"
[[ -L "$LFS/lib"   ]] || fail "$LFS/lib is not a symlink"
[[ -L "$LFS/lib64" ]] || fail "$LFS/lib64 is not a symlink"
ok "LFS /bin,/sbin,/lib,/lib64 symlinks exist"

# Dynamic loader presence (x86_64)
if [[ -e "$LFS/lib64/ld-linux-x86-64.so.2" ]]; then
  ok "dynamic loader present at /lib64/ld-linux-x86-64.so.2"
elif [[ -e "$LFS/usr/lib64/ld-linux-x86-64.so.2" ]]; then
  ok "dynamic loader present at /usr/lib64/ld-linux-x86-64.so.2"
else
  fail "dynamic loader ld-linux-x86-64.so.2 not found (glibc likely missing/broken)"
fi

# Core binaries we expect after recovery (env from coreutils, bash from bash)
if [[ -x "$LFS/usr/bin/env" ]]; then ok "/usr/bin/env present"; else echo "WARN: /usr/bin/env missing (coreutils not installed correctly yet)"; fi
if [[ -x "$LFS/usr/bin/bash" || -x "$LFS/bin/bash" ]]; then ok "bash present"; else echo "WARN: bash missing"; fi

echo "== Validation complete =="
