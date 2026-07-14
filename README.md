# Mac Dev Setup

Copy-paste setup for a fresh Mac: Claude Code + GitHub CLI + iOS build tools + Laravel Herd + firstmate.

Open **Terminal** (press `⌘ + Space`, type `Terminal`, hit Enter). Run each command below in order.

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

For building/running actual iOS apps you also need the **full Xcode** — install it from the App Store (search "Xcode", ~7 GB), open it once, then:

```bash
sudo xcodebuild -license accept && xcodebuild -runFirstLaunch
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

---

## Or: let the agent do it

Paste this into Claude Code and it'll run the whole thing:

> Please set up this Mac as a development environment. Do each step, verify it worked before moving on, and stop and tell me if anything needs my input (password, browser login, GUI install): (1) Install Homebrew if not present. (2) `brew install gh tmux`. (3) `gh auth login` — walk me through the browser sign-in. (4) `xcode-select --install`. (5) Check for full Xcode; if missing, tell me to install it from the App Store, then run `sudo xcodebuild -license accept && xcodebuild -runFirstLaunch`. (6) `brew install --cask herd`, then tell me to open Herd once. (7) Clone https://github.com/kunchenguid/firstmate and cd into it. Confirm versions at the end (`gh --version`, `tmux -V`, `xcodebuild -version`, `php --version`, `herd --version`) and report anything that failed.

---

## Verify everything

```bash
gh --version && tmux -V && xcodebuild -version && php --version && herd --version
```
