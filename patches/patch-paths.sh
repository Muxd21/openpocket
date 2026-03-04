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

PATCHED=0

# Patch /tmp → $PREFIX/tmp
find "$OPENCLAW_DIR" -name "*.js" -o -name "*.mjs" | while read -r file; do
  if grep -q '"/tmp"' "$file" 2>/dev/null || grep -q "'/tmp'" "$file" 2>/dev/null; then
    sed -i "s|\"\/tmp\"|\"$PREFIX/tmp\"|g" "$file"
    sed -i "s|'\/tmp'|'$PREFIX/tmp'|g" "$file"
    PATCHED=$((PATCHED + 1))
  fi
done

# Patch /bin/sh → $PREFIX/bin/sh
find "$OPENCLAW_DIR" -name "*.js" -o -name "*.mjs" | while read -r file; do
  if grep -q '"/bin/sh"' "$file" 2>/dev/null; then
    sed -i "s|\"\/bin\/sh\"|\"$PREFIX/bin/sh\"|g" "$file"
  fi
done

# Patch /bin/bash → $PREFIX/bin/bash
find "$OPENCLAW_DIR" -name "*.js" -o -name "*.mjs" | while read -r file; do
  if grep -q '"/bin/bash"' "$file" 2>/dev/null; then
    sed -i "s|\"\/bin\/bash\"|\"$PREFIX/bin/bash\"|g" "$file"
  fi
done

# Patch /usr/bin/env → $PREFIX/bin/env
find "$OPENCLAW_DIR" -name "*.js" -o -name "*.mjs" | while read -r file; do
  if grep -q '"/usr/bin/env"' "$file" 2>/dev/null; then
    sed -i "s|\"\/usr\/bin\/env\"|\"$PREFIX/bin/env\"|g" "$file"
  fi
done

log_ok "Path patches applied"
