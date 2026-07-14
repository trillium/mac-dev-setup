#!/usr/bin/env bash
#
# One-shot Mac dev setup. Run with:
#   curl -fsSL https://raw.githubusercontent.com/trillium/mac-dev-setup/main/setup.sh | bash
#
# Installs the non-interactive pieces (Homebrew + CLI tools + casks). The steps
# that need a human — GitHub login, Apple ID for Xcode — are printed as
# reminders at the end rather than half-automated.

set -uo pipefail

info()  { printf '\n\033[1;34m==>\033[0m %s\n' "$1"; }
ok()    { printf '\033[1;32m  ok\033[0m %s\n' "$1"; }
warn()  { printf '\033[1;33m  !!\033[0m %s\n' "$1"; }

# ── Homebrew ─────────────────────────────────────────────────────────────────
if ! command -v brew >/dev/null 2>&1; then
  info "Installing Homebrew (may prompt for your Mac password)"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add brew to PATH for this session (Apple Silicon path)
  [ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
  [ -x /usr/local/bin/brew ]    && eval "$(/usr/local/bin/brew shellenv)"
else
  ok "Homebrew already installed"
fi

# ── Command Line Tools (git, clang) ──────────────────────────────────────────
if ! xcode-select -p >/dev/null 2>&1; then
  info "Triggering Xcode Command Line Tools install (accept the popup)"
  xcode-select --install || true
else
  ok "Command Line Tools present"
fi

# ── Formulae ─────────────────────────────────────────────────────────────────
FORMULAE=(
  gh tmux                       # GitHub CLI + terminal multiplexer (firstmate needs both)
  node                          # Node runtime (Claude Code & many CLIs expect it)
  ripgrep fd jq                 # fast search / find / JSON — agents lean on these (jq also parses herdr's JSON)
  herdr                         # agent-native terminal multiplexer (runs alongside Claude Code & firstmate)
  starship git-delta            # prompt + pretty git diffs
  xcbeautify swiftlint xcodegen ios-deploy fastlane   # iOS tooling
)
info "Installing formulae: ${FORMULAE[*]}"
brew install "${FORMULAE[@]}"

# Bun (needs the tap path)
info "Installing Bun"
brew install oven-sh/bun/bun

# ── Casks ────────────────────────────────────────────────────────────────────
CASKS=(
  iterm2                        # terminal
  # wezterm                     # alternative to iterm2 — GPU-accelerated, Lua-configurable; uncomment to use instead
  visual-studio-code            # editor
)
info "Installing casks: ${CASKS[*]}"
brew install --cask "${CASKS[@]}"

# ── firstmate ────────────────────────────────────────────────────────────────
if [ ! -d "$HOME/firstmate" ]; then
  info "Cloning firstmate into ~/firstmate"
  git clone https://github.com/kunchenguid/firstmate "$HOME/firstmate" || warn "clone failed (need gh auth first?)"
else
  ok "~/firstmate already exists"
fi

# ── yolo shell function ──────────────────────────────────────────────────────
if ! grep -q 'yolo ()' "$HOME/.zshrc" 2>/dev/null; then
  info "Adding the 'yolo' shortcut to ~/.zshrc"
  cat >> "$HOME/.zshrc" <<'YOLO'

yolo () {
	unset CLAUDECODE CLAUDE_CODE_ENTRYPOINT
	claude --dangerously-skip-permissions --fallback-model sonnet "$@"
}
YOLO
else
  ok "'yolo' already in ~/.zshrc"
fi

# ── Manual follow-ups ────────────────────────────────────────────────────────
cat <<'NEXT'

────────────────────────────────────────────────────────────
✅ Automated install done. A few things still need YOU:
────────────────────────────────────────────────────────────
1. Claude Code:   curl -fsSL https://claude.ai/install.sh | bash   (then run `claude` to sign in)
2. GitHub login:  gh auth login        (HTTPS → login with web browser)
3. Full Xcode:    install "Xcode" from the App Store (~7GB), open it once, then:
                    sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
                    sudo xcodebuild -license accept && xcodebuild -runFirstLaunch
4. Reload shell:  source ~/.zshrc      (activates `yolo`)

Then:  cd ~/firstmate && claude
────────────────────────────────────────────────────────────
NEXT
