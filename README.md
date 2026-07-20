# ClaudeUsageTray

A native macOS menu-bar app that tracks [Claude Code](https://claude.com/claude-code) token usage across all of your Claude accounts, live.

[![Platform](https://img.shields.io/badge/platform-macOS%2014%2B-blue.svg)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/swift-5.9-orange.svg)](https://swift.org)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

## Features

- **Live token tracking** — incrementally tails every transcript in `~/.claude/projects/**/*.jsonl` and updates usage as you work (rescans every 10s).
- **Automatic account detection** — watches `oauthAccount` in `~/.claude.json`; the moment you `/login` to a different account, usage is attributed to it. Every account gets its own card.
- **Claude-style windows** — a rolling 5-hour session window and a 7-day weekly window per account, each with a live "resets in" countdown.
- **Per-account limits** — set your own 5-hour and weekly token ceilings per account. Gauges turn orange at 60% and red at 85%.
- **Metric choice** — compares against `input + output + cache_creation` by default (cache reads are cheaper against real limits); toggle per account to count everything.

## Requirements

- macOS 14 (Sonoma) or later
- [Swift toolchain](https://swift.org/download/) (bundled with Xcode or the Command Line Tools)

## Install

```bash
git clone https://github.com/hunterh37/ClaudeUsageTray.git
cd ClaudeUsageTray
./install.sh
```

This builds with SwiftPM, installs `/Applications/ClaudeUsageTray.app` (menu-bar only, no Dock icon), ad-hoc signs it, adds a LaunchAgent so it starts at login, and launches it. Re-run `./install.sh` to update.

## Uninstall

```bash
pkill -x ClaudeUsageTray
rm -rf /Applications/ClaudeUsageTray.app \
       ~/Library/LaunchAgents/io.medvr.claudeusagetray.plist \
       ~/Library/Application\ Support/ClaudeUsageTray
```

## Data & privacy

All state is stored locally at `~/Library/Application Support/ClaudeUsageTray/state.json` (accounts, switch timeline, usage buckets, and file cursors). Nothing is sent anywhere. Delete the file to reset.

## Notes & limitations

- Usage before first launch is attributed to whichever account was logged in at first launch — transcripts don't record which account made each request, so attribution is exact only from install time onward.
- Anthropic doesn't publish exact per-plan token limits; set the limit values on each card to match what you observe for your plan.

## Contributing

Contributions are welcome! Please open an issue to discuss significant changes, and see [CONTRIBUTING.md](CONTRIBUTING.md) for the workflow.

## License

Released under the [MIT License](LICENSE).

---

<p align="center">
  <a href="https://dicyaninlabs.com">
    <img src="assets/dicyanin-labs-logo.png" alt="Dicyanin Labs" width="360">
  </a>
  <br>
  <sub>Proudly maintained by <a href="https://dicyaninlabs.com">DicyaninLabs</a></sub>
</p>
