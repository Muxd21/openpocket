#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
#  OpenClaw Pocket Server — Master Installer
#  By Muxd21
#  All-in-one: deps → patches → openclaw → ssh → tmux → boot
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

export PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
export HOME="${HOME:-/data/data/com.termux/files/home}"
export PATH="$PREFIX/bin:$PATH"
export TMPDIR="$PREFIX/tmp"

SSH_PASSWORD="1234"
TMUX_SESSION="OpenClaw"

log_ok()   { echo -e "${GREEN}[OK]${NC}   $1"; }
log_fail() { echo -e "${RED}[FAIL]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_info() { echo -e "${CYAN}[INFO]${NC} $1"; }

step() {
    echo ""
    echo -e "${CYAN}───${NC} ${BOLD}[$1] $2${NC} ${CYAN}───${NC}"
}

TOTAL_STEPS=10
FAILED=0

# Show banner
MAGENTA='\033[0;35m'
echo ""
echo -e "${MAGENTA}${BOLD}"
echo "  ┌───────────────────────────────────────────────────┐"
echo "  │        🛰️  OPENPOCKET AI SERVER INSTALLER         │"
echo "  │        Native. Professional. 24/7 Server.         │"
echo "  └───────────────────────────────────────────────────┘"
echo -e "${NC}"
echo -e "  ${CYAN}By ${BOLD}Muxd21${NC}"
echo -e "  ${YELLOW}github.com/Muxd21/openpocket${NC}"
echo ""

# --- Step Section ---
#  STEP 1: Environment Check
# --- Step Section ---
step "1/$TOTAL_STEPS" "Environment Check"
bash "$SCRIPT_DIR/scripts/check-env.sh" || { log_fail "Environment check failed"; exit 1; }

# --- Step Section ---
#  STEP 2: Install Dependencies
# --- Step Section ---
step "2/$TOTAL_STEPS" "Installing Dependencies"
bash "$SCRIPT_DIR/scripts/install-deps.sh" || { log_fail "Dependency install failed"; exit 1; }

# --- Step Section ---
#  STEP 3: Setup Environment Variables
# --- Step Section ---
step "3/$TOTAL_STEPS" "Configuring Environment"
bash "$SCRIPT_DIR/scripts/setup-env.sh" || { log_fail "Environment setup failed"; exit 1; }

# Manually load the critical vars for the rest of the install process
# to avoid potential set -u / set -e crashes from sourcing a user's full .bashrc
export TMPDIR="$PREFIX/tmp"
export NODE_OPTIONS="-r $HOME/.openclaw-android/patches/bionic-compat.js"
export OPENCLAW_NODE_OPTIONS_READY=1
export CONTAINER=1
export CXXFLAGS="-include $HOME/.openclaw-android/patches/termux-compat.h"
export CFLAGS="-include $HOME/.openclaw-android/patches/termux-compat.h"
export CMAKE_CXX_FLAGS="-include $HOME/.openclaw-android/patches/termux-compat.h"
export CMAKE_C_FLAGS="-include $HOME/.openclaw-android/patches/termux-compat.h"
export GYP_DEFINES="OS=linux android_ndk_path=''"
export CPATH="$PREFIX/include/glib-2.0:$PREFIX/lib/glib-2.0/include:${CPATH:-}"
export OPENCLAW_GATEWAY_HOST="0.0.0.0"
export OPENCLAW_GATEWAY_PORT="18789"

# --- Step Section ---
#  STEP 4: Install OpenClaw + Apply Patches
# --- Step Section ---
step "4/$TOTAL_STEPS" "Installing OpenClaw"

# Copy patches first (needed during npm install for native builds)
log_info "Preparing patches..."
PATCH_DEST="$HOME/.openclaw-android/patches"
mkdir -p "$PATCH_DEST"
cp "$SCRIPT_DIR/patches/bionic-compat.js" "$PATCH_DEST/"
cp "$SCRIPT_DIR/patches/termux-compat.h"  "$PATCH_DEST/"

# Update spawn.h (crucial for native builds like koffi)
cp "$SCRIPT_DIR/patches/spawn.h" "$PREFIX/include/spawn.h"
log_ok "spawn.h updated"

# Environment variables already exported in Step 3.
# No need to source ~/.bashrc which can be unstable.

log_info "Installing OpenClaw (this may take 5-15 minutes)..."
npm install -g openclaw@latest || log_warn "OpenClaw install process returned non-zero. Attempting to continue..."

if command -v openclaw &>/dev/null; then
  log_ok "OpenClaw version: $(openclaw --version 2>/dev/null || echo 'unknown')"
else
  log_fail "OpenClaw binary not found after install"
  # Don't exit here, mission control might still work
fi

# Apply patches
log_info "Applying patches..."
bash "$SCRIPT_DIR/patches/apply-patches.sh"

# --- Step Section ---
#  STEP 4.5: Install Mission Control
# --- Step Section ---
step "4.5/$TOTAL_STEPS" "Installing Mission Control"
log_info "Installing pnpm..."
if npm install -g pnpm; then
  log_ok "pnpm installed"
else
  log_warn "pnpm install had issues, continuing anyway..."
fi

log_info "Cloning and setup Mission Control..."
if [ ! -d "$HOME/mission-control" ]; then
  if git clone https://github.com/builderz-labs/mission-control.git "$HOME/mission-control"; then
    log_ok "Mission Control cloned"
  else
    log_warn "Mission Control cloning failed"
  fi
fi

if [ -d "$HOME/mission-control" ]; then
  cd "$HOME/mission-control"
  log_info "Running pnpm install for Mission Control..."
  pnpm install || log_warn "pnpm install returned non-zero"
  
  # Force binding to 0.0.0.0 in .env for Tailscale
  if [ ! -f ".env" ]; then
    cp .env.example .env 2>/dev/null || true
  fi
  
  # Ensure HOST and PORT are set correctly in .env
  # We use python to safely handle multi-platform newline/quote issues
  python3 -c "
import os
path = '.env'
lines = []
if os.path.exists(path):
    with open(path, 'r') as f:
        lines = f.readlines()
new_lines = []
found_host = False
found_port = False
for line in lines:
    if line.startswith('HOST='):
        new_lines.append('HOST=0.0.0.0\n')
        found_host = True
    elif line.startswith('PORT='):
        new_lines.append('PORT=3000\n')
        found_port = True
    else:
        new_lines.append(line)
if not found_host: new_lines.append('HOST=0.0.0.0\n')
if not found_port: new_lines.append('PORT=3000\n')
with open(path, 'w') as f:
    f.writelines(new_lines)
" || true
  
  cd - >/dev/null
fi

# --- Step Section ---
#  STEP 5: Build Sharp (Image Processing)
# --- Step Section ---
step "5/$TOTAL_STEPS" "Building sharp (Image Processing)"

# Fix: create ar → llvm-ar symlink if missing
if [ ! -f "$PREFIX/bin/ar" ] && [ -f "$PREFIX/bin/llvm-ar" ]; then
  ln -sf "$PREFIX/bin/llvm-ar" "$PREFIX/bin/ar"
  log_ok "Created ar → llvm-ar symlink"
fi

# Install sharp build deps
pkg install -y libvips binutils 2>/dev/null || true
npm install -g node-gyp 2>/dev/null || true

OPENCLAW_DIR="$PREFIX/lib/node_modules/openclaw"
if [ -d "$OPENCLAW_DIR/node_modules/sharp" ]; then
  log_info "Rebuilding sharp (this may take several minutes)..."
  if npm rebuild sharp --prefix "$OPENCLAW_DIR" 2>/dev/null; then
    log_ok "sharp built successfully — image processing enabled"
  else
    log_warn "sharp build failed (non-critical). Image processing unavailable."
    log_warn "You can retry later: npm rebuild sharp --prefix $OPENCLAW_DIR"
  fi
else
  log_warn "sharp module not found, skipping"
fi

# --- Step Section ---
#  STEP 6: Setup SSH Server
# --- Step Section ---
step "6/$TOTAL_STEPS" "Setting Up SSH Server"
bash "$SCRIPT_DIR/scripts/setup-ssh.sh" "$SSH_PASSWORD" || { log_warn "SSH setup had issues"; }

# --- Step Section ---
#  STEP 7: Setup Termux:Boot Auto-Start
# --- Step Section ---
step "7/$TOTAL_STEPS" "Configuring Auto-Start (Termux:Boot)"
bash "$SCRIPT_DIR/scripts/setup-boot.sh" || { log_warn "Boot script setup had issues"; }

# --- Step Section ---
#  STEP 8: Verification
# --- Step Section ---
step "8/$TOTAL_STEPS" "Verifying Installation"
bash "$SCRIPT_DIR/tests/verify-install.sh" || true

# --- Step Section ---
#  DONE — Installation Summary
# --- Step Section ---
echo ""
echo -e "${BOLD}----------------------------------------${NC}"
echo -e "${GREEN}${BOLD}  🦞 INSTALLATION COMPLETE!${NC}"
echo -e "${BOLD}----------------------------------------${NC}"
echo ""
echo -e "  OpenClaw version : ${CYAN}$(openclaw --version 2>/dev/null || echo 'unknown')${NC}"
echo -e "  Node.js version  : ${CYAN}$(node -v 2>/dev/null)${NC}"
echo -e "  npm version      : ${CYAN}$(npm -v 2>/dev/null)${NC}"
echo ""
echo -e "  ${BOLD}SSH Access:${NC}"
echo -e "  Port     : ${CYAN}8022${NC}"
echo -e "  Password : ${CYAN}${SSH_PASSWORD}${NC} (change with: ${YELLOW}passwd${NC})"
echo -e "  Connect  : ${CYAN}ssh -p 8022 \$(whoami)@<phone-ip>${NC}"
echo ""

# --- Step Section ---
#  STEP 9: OpenClaw Onboarding (Interactive)
# --- Step Section ---
echo -e "${BOLD}----------------------------------------${NC}"
echo -e "${BOLD}  [9] OpenClaw Onboarding${NC}"
echo -e "${BOLD}----------------------------------------${NC}"
echo ""
echo -e "  ${YELLOW}Configure your AI provider, channels, and skills.${NC}"
echo -e "  ${CYAN}Follow the prompts below — this takes ~2 minutes.${NC}"
echo ""

# Run onboard interactively — user configures their setup
openclaw onboard || true

# Fix: Ensure gateway.mode is set to local and binds to 0.0.0.0 for Tailscale
log_info "Configuring OpenClaw (Latest Schema)..."
openclaw doctor --fix 2>/dev/null || true # Auto-migrate if possible

python3 -c "
import json, os, secrets
config_path = os.path.expanduser('~/.openclaw/openclaw.json')
if os.path.exists(config_path):
    with open(config_path, 'r') as f:
        try:
            config = json.load(f)
        except:
            config = {}
    
    # Force Gateway Config (Latest v2026 Schema)
    gateway = config.setdefault('gateway', {})
    gateway['mode'] = 'local'
    
    # Auth Config (OpenClaw v2026 requires gateway.auth.token)
    auth = gateway.setdefault('auth', {})
    if 'token' not in auth or not auth['token']:
        # Migrate old token if it exists
        old_token = gateway.pop('token', None)
        auth['token'] = old_token or ('op_' + secrets.token_hex(16))
    
    # IMPORTANT: Remove 'listen', 'host', 'port' from JSON to prevent "Unrecognized key" errors.
    # We now set these via OPENCLAW_GATEWAY_HOST/PORT environment variables instead.
    gateway.pop('listen', None)
    gateway.pop('host', None)
    gateway.pop('port', None)
    gateway.pop('token', None)
    
    with open(config_path, 'w') as f:
        json.dump(config, f, indent=2)
    
    print(f'TOKEN_FOUND:{auth['token']}')
" > "$TMPDIR/oc_token_info" || true

GATEWAY_TOKEN=$(grep 'TOKEN_FOUND:' "$TMPDIR/oc_token_info" | cut -d: -f2)
log_ok "Gateway (0.0.0.0) configured with token: ${GATEWAY_TOKEN:-generated}"

log_ok "Onboarding and configuration complete!"

# --- Step Section ---
#  STEP 10: Launching AI Command Center
# --- Step Section ---
step "10/10" "Launching AI Command Center"

# Create a clean unified tmux session
tmux kill-session -t OpenClaw 2>/dev/null || true
# Start Gateway with explicit environment variables
tmux new-session -d -s OpenClaw "export OPENCLAW_GATEWAY_HOST=0.0.0.0 && export OPENCLAW_GATEWAY_PORT=18789 && source ~/.bashrc && openclaw gateway"
sleep 5
# Start Mission Control with explicit token and binding
tmux new-window -t OpenClaw -n "mission-control" "cd \$HOME/mission-control && export HOST=0.0.0.0 && export PORT=3000 && export OPENCLAW_GATEWAY_TOKEN=$GATEWAY_TOKEN && pnpm start"

log_ok "AI Server (Engine + Dashboard) is now running natively."

# ──────────────────────────────────────────────
#  ALL DONE — WELCOME TO GREATNESS 💥
# ──────────────────────────────────────────────
USER_NAME=$(whoami)
IP=$(ip -4 addr show wlan0 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1 || echo "<phone-ip>")

echo -e "\n${BOLD}${MAGENTA}  🛰️  OPENPOCKET AI SERVER IS ONLINE${NC}"
echo -e "  ${CYAN}Engine: OpenClaw | Dashboard: Mission Control${NC}\n"

echo -e "  ${BOLD}1. ACCESS DASHBOARD${NC}"
echo -e "     URL:   ${GREEN}http://${IP}:3000${NC}"
echo -e "     Token: ${YELLOW}${GATEWAY_TOKEN:-See config}${NC}"

echo -e "\n  ${BOLD}2. MANAGE SERVER${NC}"
echo -e "     Logs:  ${YELLOW}tmux attach -t OpenClaw${NC} (Ctrl+B, N to switch)"
echo -e "     Chat:  ${YELLOW}openclaw tui${NC}"

echo -e "\n  ${BOLD}3. REMOTE ACCESS (SSH)${NC}"
echo -e "     Cmd:   ${CYAN}ssh -p 8022 ${USER_NAME}@${IP}${NC}"
echo -e "     Pass:  ${CYAN}${SSH_PASSWORD}${NC}\n"

echo -e "  ${DIM}Docs: https://muxd21.github.io/openpocket${NC}"
echo -e "  ${BOLD}${MAGENTA}Built for Muxd21${NC}\n"
