<div align="center">

<img src="docs/images/banner.png" alt="OpenPocket Banner" width="100%">

# ⚡ OpenPocket

**Turn your old phone → a 24/7 AI powerhouse. One command. No Linux distro. No bloat.**

[![Android](https://img.shields.io/badge/Android-7.0%2B-34A853?style=for-the-badge&logo=android&logoColor=white)](#-prerequisites)
[![Termux](https://img.shields.io/badge/Termux-F--Droid-FF6B00?style=for-the-badge)](#-prerequisites)
[![One Command](https://img.shields.io/badge/Setup-One%20Command-blue?style=for-the-badge)](#-quick-start)
[![MIT](https://img.shields.io/github/license/Muxd21/openpocket?style=for-the-badge)](LICENSE)

[**Website**](https://muxd21.github.io/openpocket/) · [Quick Start](#-quick-start) · [Guide](docs/troubleshooting.md) · [Dashboard](#-mission-control)

</div>

---

## 💡 The Idea

That old phone collecting dust in your drawer? It's a **quad-core Linux machine** with WiFi, a battery backup, and zero electricity cost. 

**OpenPocket** turns it into a full AI agent server — running [OpenClaw](https://openclaw.ai) natively on Termux. We skip the overhead of `proot-distro` (Debian/Ubuntu) which usually wastes 2GB of storage. OpenPocket is **10x smaller, 10x faster**, and sets up in minutes.

| | 🐢 proot-distro way | ⚡ OpenPocket |
|:--|:---------------------|:-----------------|
| **Storage** | 1–2 GB (full Linux) | **~250 MB** |
| **Setup time** | 20–30 min | **3–8 min** |
| **Performance** | Slower (proot overhead) | **Native speed** |
| **Complexity** | 20+ commands | **One command** |

---

## 🚀 Quick Start

**Step 1:** Install [Termux from F-Droid](https://f-droid.org/en/packages/com.termux/).

**Step 2:** Open Termux and run one command:

```bash
curl -sL https://raw.githubusercontent.com/Muxd21/openpocket/master/bootstrap.sh | bash
```

**Step 3:** Setup and launch:

```bash
openclaw onboard          # Configure your AI (OpenAI, Gemini, etc.)
openclaw gateway          # Start the server
```

---

## 🎮 Mission Control

Every OpenPocket installation now comes with **[Mission Control](https://github.com/builderz-labs/mission-control)** integrated.

- **28+ Panels**: Monitor tasks, tokens, memory, and logs.
- **Real-time Dashboard**: Beautiful glassmorphism UI to manage your agents fleat.
- **Remote Access**: Connect from your PC over a secure SSH tunnel.

---

## 📋 Prerequisites

- **Android 7.0+**
- **~1GB free storage** for node modules and caches.
- **[Termux](https://f-droid.org/en/packages/com.termux/)** (F-Droid version only).

---

## 🛡️ Important: Kill Phantom Process Killer (Android 12+)

Android 12+ will kill Termux in the background by default. You **must** disable this once to keep your server running 24/7.

```bash
# Check the guide in docs
adb shell "settings put global settings_enable_monitor_phantom_procs false"
```
📘 [Full Guide to Fixing Process Killing](docs/disable-phantom-process-killer.md)

---

## ⚙️ How It Works

OpenPocket bridges the gap between Android (Bionic libc) and standard Linux (glibc).
- **glibc-runner**: Lightweight linker to run standard Linux binaries.
- **Path Patching**: Rewrites `/tmp` and `/bin/sh` to Termux paths in real-time.
- **Native Sharp**: Image processing built from source for your phone's architecture.

---

## 🙏 Credits

- [OpenClaw](https://openclaw.ai) — The AI agent framework
- [Mission Control](https://github.com/builderz-labs/mission-control) — Orchestration Dashboard
- Built with ⚡ by **Jarvis (RTX⚡🦞)** for [**Muxd21**](https://github.com/Muxd21)

## 📄 License

[MIT](LICENSE) © 2026 Muxd21
