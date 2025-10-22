# Ultimate Arch Updater (Fish Shell)

A single-command, secure, and fully automated Arch Linux updater written for the Fish shell.  
It handles official repositories, AUR packages, and Flatpaks, performs safety audits on PKGBUILDs, cleans orphans and caches, and produces a concise system summary.

---

## Features

- **AUR safety scanner:** Inspects PKGBUILDs for dangerous commands before updating.
- **Automatic retries:** Recovers gracefully from failed fetches.
- **Optional DNS refresh:** Integrates with `onedns` for Cloudflare DNS setup.
- **Comprehensive updates:** Handles pacman, AUR, and Flatpak in one sequence.
- **System cleanup:** Removes orphaned packages and clears caches.
- **Final report:** Summarizes explicit, AUR, and Flatpak package counts.

---

## Requirements

| Component | Purpose | Required |
|------------|----------|----------|
| Fish Shell | To execute the function | ✅ |
| pacman | Core package manager | ✅ |
| yay or paru | AUR helper | ✅ (one of them) |
| onedns | Optional secure DNS setup | Optional |
| flatpak | Optional app updates | Optional |
| pacman-contrib (paccache) | Cache cleanup | Optional |

---

## Installation

1. Clone the repository
   ```bash
   git clone https://github.com/karanveers969/ultimate-arch-updater.git
   cd ultimate-arch-updater
   ```

2. Install into Fish
   ```bash
   mkdir -p ~/.config/fish/functions
   cp update.fish ~/.config/fish/functions/update.fish
   ```

3. Run
   ```bash
   update
   ```

---

## Execution Flow

1. Connects to Cloudflare DNS (if `onedns` is installed)
2. Scans all installed AUR packages for suspicious PKGBUILD patterns
3. Updates official Arch repositories
4. Updates AUR packages only if no critical issues are found
5. Updates Flatpak applications
6. Removes orphaned packages
7. Cleans pacman/yay/paru caches
8. Prints a concise system summary

---

## Example Output

```
Connecting to Cloudflare DNS via onedns...
✅ Connected to Cloudflare DNS.

Checking AUR package safety...
✅ All AUR packages passed safety checks.

Updating official packages...
...
System fully updated, cleaned, and optimized.
```

---

## License

MIT License — see [LICENSE](LICENSE) for details.

---

## Author

https://github.com/karanveers969
