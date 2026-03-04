#!/data/data/com.termux/files/usr/bin/bash
# Apply all patches to OpenClaw installation
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
log_ok()   { echo -e "${GREEN}[OK]${NC}   $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_info() { echo -e "${CYAN}[INFO]${NC} $1"; }

PATCH_DEST="$HOME/.openclaw-android/patches"
mkdir -p "$PATCH_DEST"

# 1. Copy compatibility patches
cp "$SCRIPT_DIR/bionic-compat.js"  "$PATCH_DEST/" 2>/dev/null && log_ok "bionic-compat.js installed" || log_warn "bionic-compat.js copy failed"
cp "$SCRIPT_DIR/termux-compat.h"   "$PATCH_DEST/" 2>/dev/null && log_ok "termux-compat.h installed"  || log_warn "termux-compat.h copy failed"

# 2. Install spawn.h if missing
if [ ! -f "$PREFIX/include/spawn.h" ]; then
  cp "$SCRIPT_DIR/spawn.h" "$PREFIX/include/spawn.h" 2>/dev/null && log_ok "spawn.h installed" || log_warn "spawn.h copy failed"
else
  log_ok "spawn.h already exists"
fi

# 3. Install systemctl stub
cp "$SCRIPT_DIR/systemctl" "$PREFIX/bin/systemctl" 2>/dev/null || true
chmod +x "$PREFIX/bin/systemctl" 2>/dev/null || true
log_ok "systemctl stub installed"

# 4. Fix: create ar → llvm-ar symlink (fixes sharp/node-gyp builds)
if [ ! -f "$PREFIX/bin/ar" ] && [ -f "$PREFIX/bin/llvm-ar" ]; then
  ln -sf "$PREFIX/bin/llvm-ar" "$PREFIX/bin/ar"
  log_ok "Created ar → llvm-ar symlink (fixes node-gyp builds)"
elif [ -f "$PREFIX/bin/ar" ]; then
  log_ok "ar binary already exists"
fi

# 5. Patch hardcoded paths
log_info "Patching hardcoded paths..."
bash "$SCRIPT_DIR/patch-paths.sh" 2>/dev/null || log_warn "Path patching had issues"

log_ok "All patches applied"
