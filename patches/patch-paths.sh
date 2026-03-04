#!/data/data/com.termux/files/usr/bin/bash
# Patch hardcoded Linux paths in OpenClaw to Termux equivalents
set -euo pipefail

GREEN='\033[0;32m'; CYAN='\033[0;36m'; NC='\033[0m'
log_ok() { echo -e "${GREEN}[OK]${NC}   $1"; }
log_info() { echo -e "${CYAN}[INFO]${NC} $1"; }

OPENCLAW_DIR="$PREFIX/lib/node_modules/openclaw"

if [ ! -d "$OPENCLAW_DIR" ]; then
  echo "OpenClaw directory not found: $OPENCLAW_DIR"
  exit 1
fi

# Efficiently patch /tmp, /bin/sh, /bin/bash, and /usr/bin/env to Termux equivalents
log_info "Scanning and patching OpenClaw files..."

# Use a single find/xargs/sed pass for speed and reliability
find "$OPENCLAW_DIR" -type f \( -name "*.js" -o -name "*.mjs" -o -name "*.json" \) -print0 | xargs -0 sed -i \
  -e "s|\"/tmp\"|\"$PREFIX/tmp\"|g" \
  -e "s|'/tmp'|'$PREFIX/tmp'|g" \
  -e "s|\"/bin/sh\"|\"$PREFIX/bin/sh\"|g" \
  -e "s|\"/bin/bash\"|\"$PREFIX/bin/bash\"|g" \
  -e "s|\"/usr/bin/env\"|\"$PREFIX/bin/env\"|g" 2>/dev/null || true

log_ok "Path patches applied"
