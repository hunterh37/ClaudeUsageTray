# ClaudeUsageTray

Native macOS menu-bar app that tracks Claude Code token usage across **all your Claude accounts**, live.

## What it does

- **Live token tracking** — tails every transcript in `~/.claude/projects/**/*.jsonl` incrementally (file cursors, dedup by message+request id) and increments usage as you work. Rescans every 10 s.
- **Automatic account detection** — watches `oauthAccount` in `~/.claude.json`. The moment you `/login` to a different account, a switch event is recorded and all subsequent usage is attributed to the new account. Every account ever seen gets its own card.
- **Claude-style windows per account**:
  - **5-hour window** — anchored at your first message after the previous window expired, just like Claude's real session limits, with a "resets in Xh Ym" countdown.
  - **Weekly window** — 7-day anchored window with countdown.
- **Per-account limits** — each account can have its own 5-hour and weekly token limits (in millions of tokens, editable via the slider icon on each card). Gauges go orange at 60 %, red at 85 %.
- **Metric choice** — limits compare against `input + output + cache_creation` by default (cache reads are far cheaper against real limits); toggle per account to count everything. The in/out/cached breakdown is always shown.
- Menu-bar title shows the current account and its 5-hour usage (% if a limit is set, raw tokens otherwise).

## Install / update

```bash
./install.sh
```

Builds with SwiftPM, installs `/Applications/ClaudeUsageTray.app` (menu-bar only, no Dock icon), ad-hoc signs it, adds a LaunchAgent so it starts at login, and launches it.

## Data

State lives at `~/Library/Application Support/ClaudeUsageTray/state.json`
(accounts, switch timeline, 5-minute usage buckets for the last 9 days, file cursors).
Delete it to reset; history will re-scan and attribute to the currently logged-in account.

## Notes / limits

- Usage that happened **before first launch** is attributed to the account logged in at first launch (transcripts don't record which account made each request — attribution is only exact from install time onward).
- Anthropic doesn't publish exact token limits per plan; set the limit numbers on each card to whatever you observe your plan's ceilings to be.
- Uninstall: `pkill -x ClaudeUsageTray; rm -rf /Applications/ClaudeUsageTray.app ~/Library/LaunchAgents/io.medvr.claudeusagetray.plist`
