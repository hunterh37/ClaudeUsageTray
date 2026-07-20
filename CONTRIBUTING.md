# Contributing to ClaudeUsageTray

Thanks for your interest in improving ClaudeUsageTray! This project is open source and welcomes contributions of all sizes.

## Getting started

1. Fork and clone the repository.
2. Make sure you have macOS 14+ and a Swift toolchain installed.
3. Build and run locally:

   ```bash
   swift build
   swift run
   ```

   Or run `./install.sh` to install the built app into `/Applications`.

## Project layout

```
Sources/
  App.swift          # App entry point and menu-bar setup
  Models.swift       # Data models (accounts, usage buckets, state)
  UsageEngine.swift  # Transcript tailing, account detection, window logic
  Views.swift        # SwiftUI menu views and account cards
install.sh           # Build, install, sign, and register the LaunchAgent
Package.swift        # SwiftPM manifest
```

## Workflow

1. Create a branch for your change (`git checkout -b my-feature`).
2. Keep commits focused and write clear commit messages.
3. Open a pull request against `main` with a description of what changed and why.
4. For significant changes, please open an issue first to discuss the approach.

## Guidelines

- Match the existing code style and keep changes minimal and readable.
- Test your change by building and running the app before submitting.
- Be kind and constructive in reviews and discussions.

## Reporting issues

Found a bug or have a feature request? Open an issue with steps to reproduce, your macOS version, and any relevant details.
