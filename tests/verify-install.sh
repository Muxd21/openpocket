#!/data/data/com.termux/files/usr/bin/bash
# Post-install verification
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

PASS=0; FAIL=0; WARN=0

check() {
  if eval "$2" &>/dev/null; then
    echo -e "${GREEN}[PASS]${NC} $1"
    ((PASS++))
  else
    echo -e "${RED}[FAIL]${NC} $1"
    ((FAIL++))
  fi
}

warn_check() {
  if eval "$2" &>/dev/null; then
    echo -e "${GREEN}[PASS]${NC} $1"
    ((PASS++))
  else
    echo -e "${YELLOW}[WARN]${NC} $1"
    ((WARN++))
  fi
}

echo ""
echo "Running post-install verification..."
echo ""

# Core
check "Node.js installed"          "command -v node"
check "Node.js >= 22"              "[ \$(node -v | tr -d v | cut -d. -f1) -ge 22 ]"
check "npm installed"              "command -v npm"
check "openclaw installed"         "command -v openclaw"
check "openclaw version"           "openclaw --version"

# Environment
check "TMPDIR set"                 "[ -n \"\${TMPDIR:-}\" ]"
check "NODE_OPTIONS set"           "[ -n \"\${NODE_OPTIONS:-}\" ]"
check "CONTAINER set"              "[ \"\${CONTAINER:-}\" = '1' ]"
check "OPENCLAW_NODE_OPTIONS_READY" "[ \"\${OPENCLAW_NODE_OPTIONS_READY:-}\" = '1' ]"

# Files
check "bionic-compat.js exists"    "[ -f ~/.openclaw-android/patches/bionic-compat.js ]"
check "termux-compat.h exists"     "[ -f ~/.openclaw-android/patches/termux-compat.h ]"
check "ar binary exists"           "command -v ar"

# Directories
check "~/.openclaw exists"         "[ -d ~/.openclaw ]"
check "~/.openclaw-android exists" "[ -d ~/.openclaw-android ]"
check "\$PREFIX/tmp exists"        "[ -d \$PREFIX/tmp ]"

# Services
warn_check "sshd running"          "pgrep -x sshd"
check ".bashrc configured"        "grep -q 'OpenClaw Pocket Server' ~/.bashrc"

# Boot
warn_check "Boot script exists"    "[ -f ~/.termux/boot/openclaw-boot.sh ]"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "  ${GREEN}PASS${NC}: $PASS  ${RED}FAIL${NC}: $FAIL  ${YELLOW}WARN${NC}: $WARN"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$FAIL" -gt 0 ]; then
  echo -e "${RED}Some checks failed. Review the output above.${NC}"
  exit 1
else
  echo -e "${GREEN}All critical checks passed!${NC}"
fi
