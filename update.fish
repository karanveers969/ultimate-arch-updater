# ~/.config/fish/functions/update.fish
# The Ultimate Arch Linux Updater v5.4 (Confirmed & Final)
# Author: Karanveer
# License: MIT
#
function update --description "Ultimate Arch Update: pacman, AUR (w/ security scan), Flatpak, & cleanup"

    # ------------------------------------------------------------------------------
    # 📜 PRE-FLIGHT CHECK & CONFIGURATION BLOCK
    # ------------------------------------------------------------------------------
    if fish_is_root_user
        echo (set_color red)"Error: This script should not be run as root. Run it as a regular user."(set_color normal)
        return 1
    end

    # --- Trusted Packages ---
    # Add packages you have manually verified and trust completely.
    set -l CONFIG_TRUSTED_PACKAGES betterbird-bin localsend-bin octopi

    # --- DNS Check ---
    set -l CONFIG_DNS_ENABLED true

    # --- Pattern Exceptions ---
    # For whitelisting specific lines, e.g., the official rustup installer.
    set -l CONFIG_EXCEPTION_PATTERNS 'sh.rustup.rs'

    # --- Log File Location ---
    set -l CONFIG_LOGFILE "$HOME/.aur_security_scan.log"

    # ------------------------------------------------------------------------------
    # 🛠️ ARGUMENT PARSING
    # ------------------------------------------------------------------------------
    set -l options (fish_opt --short i --long interactive) (fish_opt --short q --long quiet) (fish_opt --short f --long force-aur) (fish_opt --long skip-dns) (fish_opt --short h --long help)
    if not argparse $options -- $argv; return 1; end
    if set -q _flag_help; echo "The Ultimate Arch Linux Updater v5.4 (Confirmed & Final)"; echo "Usage: update [OPTIONS]"; echo; echo "Customize behavior by editing the configuration block at the top of the script file."; echo; echo "Options:"; printf "  %-20s %s\n" "-i, --interactive" "Run in interactive mode."; printf "  %-20s %s\n" "-q, --quiet" "Suppress most informational output."; printf "  %-20s %s\n" "-f, --force-aur" "Force update of ALL AUR packages."; printf "  %-20s %s\n" "--skip-dns" "Skip the Cloudflare DNS check."; printf "  %-20s %s\n" "-h, --help" "Show this help message."; echo; return 0; end

    # ------------------------------------------------------------------------------
    # 🚀 SETUP (STABLE LINEAR ARCHITECTURE)
    # ------------------------------------------------------------------------------
    set -l TMPDIR (mktemp -d)
    trap 'rm -rf "$TMPDIR"' EXIT

    set -l SUSPICIOUS_PKGS

    function __log; if not set -q _flag_quiet; echo $argv; end; end
    function __header; set -l color_header (set_color brblue); set -l color_normal (set_color normal); echo; echo "$color_header━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$color_normal"; echo "$color_header 🧠 $argv$color_normal"; echo "$color_header━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$color_normal"; end

    # ==============================================================================
    # ▶️ EXECUTION LOGIC
    # ==============================================================================

    # ------------------------------------------------------------------------------
    # 🌐 1. DNS SETUP
    # ------------------------------------------------------------------------------
    if $CONFIG_DNS_ENABLED; and not set -q _flag_skip_dns
        __header "Ensuring Cloudflare DNS (OneDNS)"
        if not type -q onedns
            __log "🔧 OneDNS not found, installing..."; if git clone --depth 1 https://github.com/karanveers969/cloudflare-dns-switcher.git "$TMPDIR/dns" >/dev/null 2>&1; and test -f "$TMPDIR/dns/onedns.sh"; sudo install -m 755 "$TMPDIR/dns/onedns.sh" /usr/local/bin/onedns; __log "✅ OneDNS installed."; else; echo (set_color yellow)"⚠️  Failed to install OneDNS."(set_color normal); end
        end
        if type -q onedns; if printf "1\n00\n" | sudo onedns >/dev/null 2>&1; __log "✅ DNS set to Cloudflare."; else; echo (set_color yellow)"⚠️  onedns command failed."(set_color normal); end; end
    else
        __log "ℹ️  DNS check skipped."
    end

    # ------------------------------------------------------------------------------
    # 📦 2. OFFICIAL PACKAGE UPDATE (PACMAN)
    # ------------------------------------------------------------------------------
    __header "Updating Official Packages (pacman)"
    set -l pacman_args "-Syu"
    if not set -q _flag_interactive; set -a pacman_args "--noconfirm"; end
    if not sudo pacman $pacman_args; echo (set_color red)"❌ Official package upgrade failed. Aborting."(set_color normal); return 1; end

    # ------------------------------------------------------------------------------
    # 🔒 3. AUR SECURITY SCAN
    # ------------------------------------------------------------------------------
    __header "Scanning AUR Packages for Security Issues"
    echo "===== AUR Security Scan starting at "(date)" =====" > "$CONFIG_LOGFILE"
    # Hardened patterns to be more precise and reduce false positives
    set -l CRITICAL_PATTERNS 'curl\s+.*\|\s*(sh|bash)' 'wget\s+.*\|\s*(sh|bash)' 'eval\s+.*\$' '\bbash\b\s*-c' '\bsh\b\s*-c' '\$\(curl' '\$\(wget' 'nc\s+-l' 'socat' '/dev/tcp/' 'python\s+-c.*(exec|import.*os)' 'base64.*-d.*\|' 'rm\s+-rf\s+/\s' 'rm\s+-rf\s+\$HOME' '&.*\|' 'pkexec|sudo.*NOPASSWD' 'chmod.*\+s' 'chmod\s+.*777'
    set -l AUR_PACKS (pacman -Qm 2>/dev/null | awk '{print $1}')
    if test (count $AUR_PACKS) -eq 0
        __log "ℹ️  No AUR packages installed to scan."
    else
        __log "🔍 Found "(count $AUR_PACKS)" AUR package(s). Scanning..."
        for pkg in $AUR_PACKS
            if contains $pkg $CONFIG_TRUSTED_PACKAGES; __log (set_color green)"  - $pkg (whitelisted, skipped)"(set_color normal); continue; end
            set -l pkgbuild_url "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=$pkg"; set -l pkgbuild_file "$TMPDIR/$pkg.PKGBUILD"
            if not curl -fsSL --retry 2 --max-time 10 "$pkgbuild_url" -o "$pkgbuild_file" 2>/dev/null; or not test -s "$pkgbuild_file"; or not grep -q "pkgname" "$pkgbuild_file"; echo (set_color yellow)"  - $pkg (could not fetch PKGBUILD, logged)"(set_color normal); echo "FETCH_FAILED: $pkg at $pkgbuild_url" >> "$CONFIG_LOGFILE"; continue; end

            set -l files_to_scan $pkgbuild_file
            set -l install_url "https://aur.archlinux.org/cgit/aur.git/plain/$pkg.install?h=$pkg"; set -l install_file "$TMPDIR/$pkg.install"
            if curl -fsSL --max-time 10 "$install_url" -o "$install_file" 2>/dev/null; and test -s "$install_file"; and not env LC_ALL=C grep -q "<!DOCTYPE" "$install_file"; set -a files_to_scan $install_file; end

            for file in $files_to_scan
                set -l suspicious_lines (env LC_ALL=C grep -E -- (string join '|' $CRITICAL_PATTERNS) $file)
                if test (count $suspicious_lines) -gt 0
                    for line in $suspicious_lines
                        set -l is_exception false
                        for exc_pat in $CONFIG_EXCEPTION_PATTERNS
                            if string match -q -- "*$exc_pat*" "$line"; set is_exception true; break; end
                        end
                        if not $is_exception
                            set -l filename (path basename $file)
                            echo (set_color red)"🚨 CRITICAL: Suspicious pattern in '$pkg' ($filename)!"(set_color normal); echo "   Line: $line"
                            echo "CRITICAL_$(string upper $filename): $pkg matched line '$line'" >> "$CONFIG_LOGFILE"
                            if not contains $pkg $SUSPICIOUS_PKGS; set -a SUSPICIOUS_PKGS $pkg; end; break
                        end
                    end
                end
            end
        end
        if test (count $SUSPICIOUS_PKGS) -gt 0; echo; echo (set_color yellow)"⚠️  Found "(count $SUSPICIOUS_PKGS)" suspicious package(s). Review $CONFIG_LOGFILE"(set_color normal); if type -q notify-send; notify-send -u critical "AUR Security Alert" "Found "(count $SUSPICIOUS_PKGS)" suspicious package(s)."; end; else; __log "✅ All AUR packages passed security checks."; end
    end

    # ------------------------------------------------------------------------------
    # 🔧 4. AUR HELPER & UPDATES
    # ------------------------------------------------------------------------------
    if not type -q yay; and not type -q paru
        __header "Installing AUR Helper (yay)"; if not sudo pacman -S --needed --noconfirm git base-devel; echo (set_color red)"❌ Failed to install build dependencies."(set_color normal); return 1; end
        __log "   - Cloning & building yay..."; set -l yay_dir "$TMPDIR/yay"
        if git clone --depth 1 https://aur.archlinux.org/yay.git "$yay_dir" 2>/dev/null
            if fish -c "cd (string escape -- '$yay_dir'); and makepkg -si --noconfirm"; __log "✅ yay installed successfully."; else; echo (set_color red)"❌ Failed to build and install yay."(set_color normal); end
        else
             echo (set_color red)"❌ Failed to clone yay repository."(set_color normal)
        end
    end

    if type -q yay; or type -q paru
        __header "Updating AUR Packages"; set -l helper_cmd_str; if type -q yay; set helper_cmd_str "yay -Syu --devel --removemake --timeupdate"; else if type -q paru; set helper_cmd_str "paru -Syu --devel --removemake"; end
        if not set -q _flag_interactive; set -a helper_cmd_str "--noconfirm"; end
        if test (count $SUSPICIOUS_PKGS) -gt 0; and not set -q _flag_force_aur
            echo (set_color yellow)"⛔ Suspicious packages detected; they will be skipped."(set_color normal)
            for pkg in $SUSPICIOUS_PKGS; echo "   - Skipping: $pkg"; end
            set -l ignore_arg "--ignore="(string join ',' $SUSPICIOUS_PKGS); set -a helper_cmd_str $ignore_arg
        else if set -q _flag_force_aur; and test (count $SUSPICIOUS_PKGS) -gt 0
            echo (set_color brred)"⚠️  --force-aur flag set. Updating ALL packages, including suspicious ones!"(set_color normal)
        end
        fish -c "$helper_cmd_str"
    else
        __log "ℹ️  No AUR helper found, skipping AUR updates."
    end

    # ------------------------------------------------------------------------------
    # 🧊 5. FLATPAK UPDATES
    # ------------------------------------------------------------------------------
    if type -q flatpak
        __header "Updating Flatpak Applications"
        if flatpak update -y; __log "✅ Flatpaks updated."; else; echo (set_color yellow)"⚠️  Flatpak update encountered issues."(set_color normal); end
    end

    # ------------------------------------------------------------------------------
    # 🧹 6. CLEANUP
    # ------------------------------------------------------------------------------
    __header "Cleaning System"
    if set -l orphans (pacman -Qdtq 2>/dev/null); and test (count $orphans) -gt 0
        __log "🗑️  Removing "(count $orphans)" orphans..."; if sudo pacman -Rns --noconfirm $orphans >/dev/null 2>&1; __log "   - Done."; end
    else
        __log "✅ No orphans."
    end
    __log "🧹 Cleaning caches..."
    if type -q paccache; and sudo paccache -rk2 >/dev/null 2>&1; __log "   - Pacman cache cleaned."; end
    if type -q yay; and yay -Sc --noconfirm >/dev/null 2>&1; __log "   - Yay cache cleaned."; else if type -q paru; and paru -Sc --noconfirm >/dev/null 2>&1; __log "   - Paru cache cleaned."; end

    # ------------------------------------------------------------------------------
    # ✨ 7. SUMMARY
    # ------------------------------------------------------------------------------
    __header "System Update Complete"
    echo "📊 Status:"; echo "  - Explicit Packages: "(pacman -Qe 2>/dev/null | wc -l); echo "  - AUR Packages:      "(pacman -Qm 2>/dev/null | wc -l)
    if type -q flatpak; echo "  - Flatpak Apps:      "(flatpak list --app 2>/dev/null | wc -l); end; echo
    if test (count $SUSPICIOUS_PKGS) -gt 0
        echo (set_color red)"🔒 Security Alert: "(count $SUSPICIOUS_PKGS)" suspicious AUR package(s) detected."(set_color normal)
        if set -q _flag_force_aur; echo (set_color brred)"   (Forced update was performed via --force-aur)"(set_color normal)
        else; echo "   The following were SKIPPED:"; for pkg in $SUSPICIOUS_PKGS; echo (set_color yellow)"     - $pkg"(set_color normal); end; end
        echo "   Review log: $CONFIG_LOGFILE"
        if type -q notify-send; notify-send -u normal "Update Complete with Warnings" "Review security log for "(count $SUSPICIOUS_PKGS)" package(s)."; end
    else
        echo (set_color green)"🔒 Security Status: All clear."(set_color normal)
        if type -q notify-send; notify-send -u low "System Update Successful" "All packages are up-to-date."; end
    end
    echo; echo (set_color green)"done ✅"(set_color normal)

end
