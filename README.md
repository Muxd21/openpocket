<div align="center">

# ⚡ OpenClaw Pocket Server

**Your old phone → a 24/7 AI powerhouse. One command. No Linux distro. No bloat.**

[![Android](https://img.shields.io/badge/Android-7.0%2B-34A853?style=for-the-badge&logo=android&logoColor=white)](#-prerequisites)
[![Termux](https://img.shields.io/badge/Termux-F--Droid-FF6B00?style=for-the-badge)](#-prerequisites)
[![One Command](https://img.shields.io/badge/Setup-One%20Command-blue?style=for-the-badge)](#-quick-start)
[![MIT](https://img.shields.io/github/license/Muxd21/openpocket?style=for-the-badge)](LICENSE)
[![Stars](https://img.shields.io/github/stars/Muxd21/openpocket?style=for-the-badge&color=gold)](https://github.com/Muxd21/openpocket/stargazers)

[Quick Start](#-quick-start) · [Full Guide](#-full-setup-guide) · [Troubleshooting](#-common-issues) · [What's Under the Hood](#-how-it-works)

</div>

---

## 💡 The Idea

That old phone collecting dust in your drawer? It's a **quad-core Linux machine** with WiFi, a battery backup, and zero electricity cost. Why waste it?

**OpenClaw Pocket Server** turns it into a full AI agent server — running [OpenClaw](https://openclaw.ai) natively on Termux without installing any Linux distribution. Just paste one command and walk away.

**What makes this different from running Linux on Termux?**

Most guides tell you to install proot-distro (Debian/Ubuntu) — that's **1-2GB of overhead**, slower performance, and 20+ minutes of setup. This project skips all that. It uses a minimal glibc linker to run Node.js binaries directly, no emulation, no virtual filesystem.

| | 🐢 proot-distro way | ⚡ Pocket Server |
|:--|:---------------------|:-----------------|
| **Storage** | 1–2 GB (full Linux) | ~200 MB |
| **Setup time** | 20–30 min | 3–10 min |
| **Performance** | Slower (proot overhead) | Native speed |
| **Complexity** | Install distro → configure → install Node → fix paths… | **One command** |

> **TL;DR:** 10x smaller, 10x faster setup, zero bloat.

## 🚀 Quick Start

**Step 1:** Install [Termux from F-Droid](https://f-droid.org/en/packages/com.termux/) (NOT Play Store — it's discontinued there)

**Step 2:** Open Termux and run:

```bash
pkg update -y && pkg install -y curl
```

**Step 3:** Install everything:

```bash
curl -sL https://raw.githubusercontent.com/Muxd21/openpocket/master/bootstrap.sh | bash
source ~/.bashrc
```

**Step 4:** Set up and launch:

```bash
openclaw onboard          # Configure your AI provider
tmux new -s oc            # Persistent terminal session
openclaw gateway          # Start the server
```

That's it. Your pocket server is live. 🎉

## 📋 Prerequisites

| What | Why |
|:-----|:----|
| **Android 7.0+** (10+ recommended) | Kernel compatibility |
| **~1GB free storage** | OpenClaw + dependencies |
| **WiFi connection** | Downloads + API calls |

**Required apps** (all from [F-Droid](https://f-droid.org), NOT Play Store):

| App | Purpose |
|:----|:--------|
| [Termux](https://f-droid.org/en/packages/com.termux/) | Terminal environment |
| [Termux:Boot](https://f-droid.org/en/packages/com.termux.boot/) | Auto-start on reboot |
| [Termux:API](https://f-droid.org/en/packages/com.termux.api/) | Camera, sensors, notifications |

> 📌 Open **Termux:Boot** once after install to register boot permissions.

## 📖 Full Setup Guide

### 1️⃣ Prepare Your Phone

<details>
<summary><b>Enable Developer Options</b></summary>

1. **Settings** → **About phone**
2. Tap **Build number** 7 times
3. Enter your PIN if asked
4. Done — Developer options now visible in Settings

</details>

<details>
<summary><b>Keep Screen Alive (for server use)</b></summary>

1. **Settings** → **Developer options**
2. Enable **Stay awake** (screen stays on while charging)
3. Keep charger plugged in when running the server

</details>

<details>
<summary><b>Protect Battery (important for 24/7 use)</b></summary>

Running at 100% charge 24/7 = battery swelling risk. Set a charge limit:

- **Samsung**: Settings → Battery → Battery Protection → **Maximum 80%**
- **Pixel**: Settings → Battery → Battery Protection → **ON**
- **Other brands**: Search "battery protection" or "charge limit" in settings

</details>

<details>
<summary><b>Disable Battery Optimization for Termux</b></summary>

Prevents Android from killing Termux in background:

1. **Settings** → **Battery** (or Battery and device care)
2. Find **Termux** → Set to **Not optimized** / **Unrestricted**

</details>

### 2️⃣ Install & Configure

The installer handles everything automatically:

| Step | What happens |
|:-----|:-------------|
| 📦 Dependencies | Node.js, npm, build tools, tmux, SSH, git |
| 🔧 Patches | Android compatibility (renameat2, paths, platform detection) |
| 🖼️ Sharp | Image processing module built from source |
| 🔒 SSH | Server configured on port `8022`, default password `1234` |
| 🔄 Boot | Termux:Boot auto-start script installed |
| ⚡ Wakelock | Acquired to prevent process killing |

### 3️⃣ Run the Gateway

> ⚠️ Always run the gateway **inside the Termux app** (not over SSH) — SSH disconnection would kill it.

Create a persistent tmux session:

```bash
tmux new -s oc
openclaw gateway
```

| tmux Action | Keys |
|:------------|:-----|
| Detach (keep running) | `Ctrl+B` then `D` |
| Reattach later | `tmux attach -t oc` |
| Stop gateway | `Ctrl+C` |

### 4️⃣ Access From Your PC

Find your phone's IP:
```bash
ifconfig | grep -A1 wlan0 | grep inet
```

Set up SSH tunnel from your PC:
```bash
ssh -N -L 18789:127.0.0.1:18789 -p 8022 <phone-ip>
```

Open dashboard: `http://localhost:18789/`

> Run `openclaw dashboard` on the phone for the full URL with auth token.

## 🛡️ Android 12+ — Kill Phantom Process Killer

Android 12+ aggressively kills background processes (you'll see `[Process completed (signal 9)]`). Fix it once, works forever:

```bash
# Already installed by the setup script
adb pair localhost:<PAIRING_PORT> <CODE>     # From Wireless Debugging settings
adb connect localhost:<CONNECTION_PORT>
adb shell "settings put global settings_enable_monitor_phantom_procs false"
```

📘 [Step-by-step guide with details →](docs/disable-phantom-process-killer.md)

## 🔐 SSH Access

Default: port `8022`, password `1234`

```bash
# From your PC
ssh -p 8022 <phone-ip>
```

**Change password** (do this first!):
```bash
passwd
```

**Use SSH keys** (recommended):
```bash
# On your PC
ssh-keygen -t ed25519 -f ~/.ssh/pocket_server -N ""
ssh-copy-id -i ~/.ssh/pocket_server.pub -p 8022 <phone-ip>
ssh -i ~/.ssh/pocket_server -p 8022 <phone-ip>
```

📘 [Full SSH guide →](docs/termux-ssh-guide.md)

## 🔄 Updates

```bash
openclaw update
```

Or re-run the installer for a full refresh (patches + dependencies):

```bash
curl -sL https://raw.githubusercontent.com/Muxd21/openpocket/master/bootstrap.sh | bash
source ~/.bashrc
```

## 🗑️ Uninstall

```bash
npm uninstall -g openclaw
rm -rf ~/.openclaw ~/.openclaw-android ~/openpocket
# Clean up env vars from ~/.bashrc manually
```

## ⚙️ How It Works

The installer bridges the gap between Termux (Bionic libc) and standard Linux (glibc) — so tools like Node.js and OpenClaw run without modification:

| Problem | Solution |
|:--------|:---------|
| No glibc on Android | Installs glibc-runner (linker only, ~50MB) |
| Node.js needs glibc | Wraps official Node.js binary with `ld.so` loader |
| `/tmp`, `/bin/sh` missing | Path conversion to Termux equivalents |
| No systemd | Stub service manager |
| `renameat2()` missing | Compatibility header patch |
| `ar` not found (sharp build) | `llvm-ar` symlink |
| `sharp` prebuilt fails | Builds from source with Termux headers |

## ⚡ Performance Notes

**CLI commands** (like `openclaw status`) feel slower than on a PC — that's normal. Phone storage + Android security layers add overhead on cold reads.

**The gateway itself runs at full speed** once loaded. AI responses come from cloud APIs (OpenAI, Gemini, Anthropic) — identical performance to a desktop setup.

## 🤖 Local LLM (Experimental)

OpenClaw supports local inference via [node-llama-cpp](https://github.com/withcatai/node-llama-cpp). The prebuilt `linux-arm64` binary loads under glibc-runner.

**Reality check:**

| Factor | Limitation |
|:-------|:-----------|
| **RAM** | 7B Q4 model needs ~4GB free — shared with Android |
| **Storage** | Model files: 4GB–70GB+ |
| **Speed** | CPU-only, no GPU offload on Android |
| **Verdict** | Fun for experiments (TinyLlama 1.1B works). For real use → cloud APIs |

## 📁 Project Structure

```
openpocket/
├── bootstrap.sh              # One-liner entry point
├── install.sh                # Master installer
├── scripts/
│   ├── check-env.sh          # Pre-flight checks
│   ├── install-deps.sh       # Termux packages
│   ├── setup-env.sh          # Environment config
│   ├── setup-ssh.sh          # SSH server setup
│   ├── setup-tmux.sh         # tmux session info
│   └── setup-boot.sh         # Auto-start on reboot
├── patches/
│   ├── termux-compat.h       # renameat2 + RENAME_NOREPLACE
│   ├── bionic-compat.js      # Platform + OS patches
│   ├── spawn.h               # POSIX spawn stub
│   ├── patch-paths.sh        # /tmp → $PREFIX/tmp
│   ├── apply-patches.sh      # Patch orchestrator
│   └── systemctl             # systemctl stub
├── tests/
│   └── verify-install.sh     # Post-install health check
├── docs/
│   ├── disable-phantom-process-killer.md
│   ├── termux-ssh-guide.md
│   ├── ssh-guide.md
│   ├── troubleshooting.md
│   └── images/
└── LICENSE
```

## 🔧 Common Issues

<details>
<summary><b>❌ <code>"--disable-warning=ExperimentalWarning"</code> path error</b></summary>

Node v24+ conflict with `NODE_OPTIONS`. The installer sets `OPENCLAW_NODE_OPTIONS_READY=1` automatically. If it reappears:

```bash
echo 'export OPENCLAW_NODE_OPTIONS_READY=1' >> ~/.bashrc && source ~/.bashrc
```
</details>

<details>
<summary><b>❌ <code>make: ar: No such file or directory</code></b></summary>

Termux ships `llvm-ar` but not `ar`. Fix:
```bash
ln -sf $PREFIX/bin/llvm-ar $PREFIX/bin/ar
npm rebuild sharp --prefix $PREFIX/lib/node_modules/openclaw
```
</details>

<details>
<summary><b>❌ <code>renameat2 / RENAME_NOREPLACE undeclared</code></b></summary>

Android Bionic doesn't expose `renameat2()`. Already patched by installer. For manual rebuilds:
```bash
export CXXFLAGS="-include $HOME/.openclaw-android/patches/termux-compat.h"
```
</details>

<details>
<summary><b>❌ Gateway crashes with <code>signal 9</code></b></summary>

Android Phantom Process Killer. [Disable it →](#️-android-12--kill-phantom-process-killer)
</details>

<details>
<summary><b>❌ SSH connection refused</b></summary>

```bash
sshd    # Start SSH server in Termux
```
If password doesn't work, reset it: `passwd`
</details>

<details>
<summary><b>❌ <code>WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED</code></b></summary>

Phone's SSH key changed. On your PC:
```bash
ssh-keygen -R "[<phone-ip>]:8022"
```
</details>

📘 [Full troubleshooting guide →](docs/troubleshooting.md)

## 🎁 Bonus: AI CLI Tools on Termux

The glibc patches unlock more than just OpenClaw. These tools also run natively:

| Tool | Command |
|:-----|:--------|
| [Gemini CLI](https://github.com/google-gemini/gemini-cli) | `npm i -g @google/gemini-cli` |
| [Claude Code](https://github.com/anthropics/claude-code) | `npm i -g @anthropic-ai/claude-code` |
| [Qwen CLI](https://github.com/QwenLM/qwen-code) | `npm i -g @qwen-code/qwen-code@latest` |
| [Codex CLI](https://github.com/openai/codex) | `npm i -g @openai/codex` |

## 🙏 Credits

- [OpenClaw](https://openclaw.ai) — The AI agent framework
- Built with ⚡ by **Jarvis (RTX⚡🦞)** for [**Muxd21**](https://github.com/Muxd21)

## 📄 License

[MIT](LICENSE) — do whatever you want with it.
