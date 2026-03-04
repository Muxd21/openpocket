#!/data/data/com.termux/files/usr/bin/bash
# Configure environment variables in ~/.bashrc
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'
log_ok() { echo -e "${GREEN}[OK]${NC}   $1"; }

BASHRC="$HOME/.bashrc"
MARKER_START="# >>> OpenClaw Pocket Server >>>"
MARKER_END="# <<< OpenClaw Pocket Server <<<"

# Remove existing block if present
if grep -q "$MARKER_START" "$BASHRC" 2>/dev/null; then
  sed -i "/$MARKER_START/,/$MARKER_END/d" "$BASHRC"
  log_ok "Removed old environment block"
fi

PATCH_DIR="$HOME/.openclaw-android/patches"

cat >> "$BASHRC" << EOF

$MARKER_START
# Temp directories
export TMPDIR="\$PREFIX/tmp"
export TMP="\$TMPDIR"
export TEMP="\$TMPDIR"

# Node.js compatibility patches
export NODE_OPTIONS="-r $PATCH_DIR/bionic-compat.js"

# Bypass systemd checks
export CONTAINER=1

# C/C++ compatibility (renameat2, RENAME_NOREPLACE)
export CXXFLAGS="-include $PATCH_DIR/termux-compat.h"
export CFLAGS="-include $PATCH_DIR/termux-compat.h"
export CMAKE_CXX_FLAGS="-include $PATCH_DIR/termux-compat.h"
export CMAKE_C_FLAGS="-include $PATCH_DIR/termux-compat.h"

# node-gyp OS detection override
export GYP_DEFINES="OS=linux android_ndk_path=''"

# Fix: Skip OpenClaw's broken --disable-warning respawn on Node v24+
export OPENCLAW_NODE_OPTIONS_READY=1

# glib/vips headers for sharp builds
export CPATH="\$PREFIX/include/glib-2.0:\$PREFIX/lib/glib-2.0/include:\$CPATH"
$MARKER_END
EOF

log_ok "Environment variables configured in ~/.bashrc"

# Create temp directory
mkdir -p "$PREFIX/tmp/openclaw" 2>/dev/null || true
mkdir -p "$HOME/.openclaw-android/patches" 2>/dev/null || true
mkdir -p "$HOME/.openclaw" 2>/dev/null || true

log_ok "Directories created"
