#!/data/data/com.termux/files/usr/bin/bash
# Pre-flight environment check
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
log_ok()   { echo -e "${GREEN}[OK]${NC}   $1"; }
log_fail() { echo -e "${RED}[FAIL]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_info() { echo -e "${CYAN}[INFO]${NC} $1"; }

PASS=0
FAIL=0

# Check Termux
if [ -n "${PREFIX:-}" ] && [[ "$PREFIX" == */com.termux/* ]]; then
  log_ok "Running in Termux"
  ((PASS++)) || true
else
  log_fail "Not running in Termux. This script requires Termux."
  exit 1
fi

# Check architecture
ARCH=$(uname -m)
case "$ARCH" in
  aarch64|arm64) log_ok "Architecture: $ARCH (optimal)"; ((PASS++)) || true ;;
  armv7l|armv8l) log_warn "Architecture: $ARCH (supported, aarch64 recommended)"; ((PASS++)) || true ;;
  x86_64)        log_warn "Architecture: $ARCH (emulator detected)"; ((PASS++)) || true ;;
  *)             log_fail "Architecture: $ARCH (unsupported)"; ((FAIL++)) || true ;;
esac

# Check disk space (need ~500MB)
AVAIL_KB=$((df "$PREFIX" 2>/dev/null || echo "") | awk 'NR==2{print $4}')
if [ "${AVAIL_KB:-0}" -gt 512000 ]; then
  AVAIL_MB=$((AVAIL_KB / 1024))
  log_ok "Disk space: ${AVAIL_MB}MB available"
  ((PASS++)) || true
else
  log_fail "Insufficient disk space. Need at least 500MB free."
  ((FAIL++)) || true
fi

# Check Android version
ANDROID_VER=$(getprop ro.build.version.release 2>/dev/null || echo "unknown")
log_info "Android version: $ANDROID_VER"

# Check existing installations
if command -v openclaw &>/dev/null; then
  log_info "Existing OpenClaw detected: $(openclaw --version 2>/dev/null || echo 'unknown')"
  log_info "This will be a reinstall/upgrade"
fi

if command -v node &>/dev/null; then
  NODE_VER=$(node -v 2>/dev/null | tr -d 'v')
  MAJOR=$(echo "$NODE_VER" | cut -d. -f1)
  if [ "${MAJOR:-0}" -ge 22 ]; then
    log_ok "Node.js $NODE_VER already installed"
  else
    log_warn "Node.js $NODE_VER found but version 22+ required (will be upgraded)"
  fi
fi

echo ""
if [ "$FAIL" -gt 0 ]; then
  log_fail "Environment check: $FAIL issue(s) found"
  exit 1
else
  log_ok "Environment check passed ($PASS checks)"
fi
