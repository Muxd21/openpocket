#!/data/data/com.termux/files/usr/bin/bash
# Install required Termux packages
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
log_ok()   { echo -e "${GREEN}[OK]${NC}   $1"; }
log_fail() { echo -e "${RED}[FAIL]${NC} $1"; }
log_info() { echo -e "${CYAN}[INFO]${NC} $1"; }

log_info "Updating package repositories..."
pkg update -y 2>/dev/null || { echo "Retrying..."; yes | pkg update; }
pkg upgrade -y 2>/dev/null || true

PACKAGES=(
  nodejs-lts    # Node.js LTS runtime (>= 22) + npm
  git           # Git (some npm packages need it)
  python        # Python (node-gyp build scripts)
  make          # Build automation (node-gyp)
  cmake         # Cross-platform builds (koffi, argon2)
  clang         # C/C++ compiler
  tmux          # Terminal multiplexer (persistent sessions)
  openssh       # SSH server for remote access
  curl          # HTTP client
  wget          # File downloader
)

log_info "Installing ${#PACKAGES[@]} packages..."
for pkg_name in "${PACKAGES[@]}"; do
  if dpkg -s "$pkg_name" &>/dev/null; then
    log_ok "$pkg_name (already installed)"
  else
    if pkg install -y "$pkg_name" 2>/dev/null; then
      log_ok "$pkg_name installed"
    else
      log_fail "$pkg_name failed to install"
    fi
  fi
done

# Install PyYAML (needed for .skill packaging)
if pip install pyyaml 2>/dev/null; then
  log_ok "PyYAML installed"
else
  log_fail "PyYAML install failed (non-critical)"
fi

# Verify Node.js
if command -v node &>/dev/null; then
  NODE_VER=$(node -v | tr -d 'v')
  MAJOR=$(echo "$NODE_VER" | cut -d. -f1)
  if [ "${MAJOR:-0}" -ge 22 ]; then
    log_ok "Node.js v${NODE_VER} verified (>= 22)"
  else
    log_fail "Node.js v${NODE_VER} is too old. Need >= 22."
    exit 1
  fi
else
  log_fail "Node.js not found after installation"
  exit 1
fi

# Verify npm
if command -v npm &>/dev/null; then
  log_ok "npm $(npm -v) verified"
else
  log_fail "npm not found"
  exit 1
fi

# Acquire wakelock
if command -v termux-wake-lock &>/dev/null; then
  termux-wake-lock 2>/dev/null || true
  log_ok "Wakelock acquired (prevents sleep)"
fi

echo ""
log_ok "All dependencies installed successfully"
