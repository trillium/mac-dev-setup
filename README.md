# Mac Dev Setup

Copy-paste setup for a fresh Mac: Claude Code + GitHub CLI + iOS build tools + Laravel Herd + firstmate.

Open **Terminal** (press `⌘ + Space`, type `Terminal`, hit Enter). Run each command below in order.

> **In a hurry?** One command installs Homebrew + all the brew-based tools automatically, then tells you the few manual steps left (GitHub login, Xcode, Herd):
> ```bash
> curl -fsSL https://raw.githubusercontent.com/trillium/mac-dev-setup/main/setup.sh | bash
> ```
> Prefer to do it by hand / understand each piece? Follow the steps below instead.

---

## 1. Claude Code

```bash
curl -fsSL https://claude.ai/install.sh | bash
source ~/.zshrc
claude --version   # should print a version
claude             # first run signs you in via browser; quit with Ctrl-C
```

## 2. Homebrew (package manager)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## 3. GitHub CLI + tmux

```bash
brew install gh tmux
gh auth login        # choose HTTPS, then "Login with a web browser"
```

## 4. Xcode (iOS development)

```bash
xcode-select --install
```

> `xcode-select --install` installs **only the Command Line Tools** (git, clang, make) — NOT the full Xcode IDE. For building iOS apps you need full Xcode too. Two ways to get it (details + reliability ranking in [Appendix A](#appendix-a--installing-full-xcode-from-the-cli)):

**Easiest:** install **Xcode** from the App Store (search "Xcode", ~7 GB), then run the post-install below.

**CLI (scriptable):**
```bash
brew install xcodesorg/made/xcodes aria2   # aria2 = faster parallel downloads
xcodes install --latest                     # prompts for your Apple ID
```

**Post-install (required either way):**
```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license accept
xcodebuild -runFirstLaunch
```

## 5. Laravel Herd (PHP dev environment)

```bash
brew install --cask herd
```

Then open **Herd** once from Applications so it can finish setup (needs admin permission for its background service).

## 6. firstmate (agent crew)

```bash
git clone https://github.com/kunchenguid/firstmate && cd firstmate
claude
```

Inside firstmate, its `AGENTS.md` takes over and offers to install anything still missing.

## 7. The `yolo` shortcut

A shell function that launches Claude Code with permission prompts skipped (auto-approves tool calls) and a Sonnet fallback. Add it once and use `yolo` instead of `claude`.

```bash
cat >> ~/.zshrc <<'YOLO'

yolo () {
	unset CLAUDECODE CLAUDE_CODE_ENTRYPOINT
	claude --dangerously-skip-permissions --fallback-model sonnet "$@"
}
YOLO
source ~/.zshrc
```

Then just run:

```bash
yolo
```

> ⚠️ `--dangerously-skip-permissions` means the agent runs commands without asking. Only use it in a directory/project you trust.

---

## Part 3 · Recommended extras

All verified against current Homebrew formulae. Grab the **must-haves** at minimum.

### Runtimes (do these early — Claude Code & tooling need them)

```bash
brew install oven-sh/bun/bun     # Bun runtime (note the tap path; bare `brew install bun` won't work)
brew install node                # Node — Claude Code & many CLIs still expect it on PATH
```

### Search & JSON tools (agents lean on these for codebase navigation) — must-have

```bash
brew install ripgrep fd jq
```

### Terminal, shell & editor

```bash
brew install --cask iterm2                 # solid default terminal (or --cask ghostty for a modern GPU-native one)
brew install --cask wezterm                # GPU-accelerated, Lua-configurable terminal — another solid alternative to iTerm2
brew install starship                      # language-aware prompt (git/PHP/Swift context)
brew install --cask visual-studio-code     # editor for the PHP/Laravel side + reading agent diffs
```

### Git ergonomics

```bash
brew install git-delta                     # syntax-highlighted diffs (binary is `delta`; set core.pager=delta)
git config --global init.defaultBranch main
git config --global user.name  "Your Name"
git config --global user.email "you@example.com"
```

### iOS tooling

```bash
brew install xcbeautify                     # clean, readable xcodebuild output — must-have for CLI/agent builds
brew install swiftlint                      # Swift style/lint gate
brew install xcodegen                       # generate .xcodeproj from YAML (kills project-file merge conflicts)
brew install ios-deploy                     # install/debug apps on a physical iPhone from the CLI
brew install fastlane                       # automate builds/signing/TestFlight (add when shipping to the store)
```

### PHP / Laravel

```bash
composer global require laravel/installer   # `laravel new` scaffolder — Composer comes bundled WITH Herd
```

> **Don't double-install:** Herd already ships `php`, `composer`, `laravel`, `node`, `npm`, and `nvm`. Don't `brew install composer` or add a second global Laravel installer — it'll shadow Herd's and cause confusion.

### Optional

```bash
brew install --cask 1password-cli           # inject API keys/secrets into shells without hardcoding
brew install ollama                         # run local LLMs for offline agent experiments
brew install cocoapods                      # only if a project uses Pods (SwiftPM has mostly replaced it)
```

---

## Or: let the agent do it

Paste this into Claude Code and it'll run the whole thing:

> Please set up this Mac as a development environment. Do each step, verify it worked before moving on, and stop and tell me if anything needs my input (password, browser login, GUI install): (1) Install Homebrew if not present. (2) `brew install gh tmux`. (3) `gh auth login` — walk me through the browser sign-in. (4) `xcode-select --install`. (5) Check for full Xcode; if missing, tell me to install it from the App Store, then run `sudo xcodebuild -license accept && xcodebuild -runFirstLaunch`. (6) `brew install --cask herd`, then tell me to open Herd once. (7) Clone https://github.com/kunchenguid/firstmate and cd into it. Confirm versions at the end (`gh --version`, `tmux -V`, `xcodebuild -version`, `php --version`, `herd --version`) and report anything that failed.

---

## Verify everything

```bash
gh --version && tmux -V && xcodebuild -version && php --version && herd --version
```

---

## Appendix A · Installing full Xcode from the CLI

`xcode-select --install` installs **only** the Command Line Tools (~few hundred MB). Full Xcode is a separate ~7 GB download (~40 GB on disk). Ranked by reliability:

**1. `xcodes` — recommended (scriptable, version-pinnable, resumable):**
```bash
brew install xcodesorg/made/xcodes aria2   # aria2 → 3-5x faster downloads
xcodes list                                 # see all versions
xcodes install --latest                     # or: xcodes install 16.2
xcodes select 16.2                           # switch active version
```
Prompts for your Apple ID and saves it to Keychain. For CI, set `XCODES_USERNAME` / `XCODES_PASSWORD`.

**2. `mas` — Mac App Store CLI (only installs latest, needs prior GUI sign-in):**
```bash
brew install mas
sudo mas install 497799835                   # 497799835 = Xcode's App Store ID
```
Note: mas 4.0+ requires `sudo`; you must already be signed into the App Store app.

**3. App Store GUI** — most foolproof for a one-off, but not scriptable.

Always finish with the post-install trio (`xcode-select -s`, `xcodebuild -license accept`, `xcodebuild -runFirstLaunch`).

## Appendix B · CLI tools for iOS development

| Tool | For | Example |
|------|-----|---------|
| `xcodebuild` | Build/test/archive from CLI | `xcodebuild -scheme MyApp -destination 'platform=iOS Simulator,name=iPhone 16' build` |
| `xcrun` | Run tools in the active toolchain | `xcrun --find clang` |
| `xcrun simctl` | Control iOS simulators | `xcrun simctl boot "iPhone 16" && xcrun simctl install booted MyApp.app` |
| `xcode-select` | Switch active Xcode/toolchain | `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer` |
| `swift` / `swiftc` | Swift REPL / compile | `swiftc main.swift -o main` |
| `xcbeautify` | Prettify xcodebuild output | `xcodebuild ... \| xcbeautify` |
| `xcodegen` | Generate .xcodeproj from YAML | `xcodegen generate` |
| `ios-deploy` | Install/debug on a real device | `ios-deploy --bundle MyApp.app --debug` |
| `fastlane` | Automate build/sign/deploy | `fastlane beta` |
| `swiftlint` | Lint Swift style | `swiftlint lint` |
| `swiftformat` | Auto-format Swift | `swiftformat .` |
| `cocoapods` | Dependency manager (if project uses Pods) | `pod install` |

Install the brew-based ones from Part 3. For CocoaPods prefer `brew install cocoapods` over `gem install` to avoid Ruby version conflicts. For fastlane use the **formula** (`brew install fastlane`), not the old cask.
