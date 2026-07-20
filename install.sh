#!/bin/bash
# Build ClaudeUsageTray and install it to /Applications as a menu-bar app.
set -e
cd "$(dirname "$0")"
swift build -c release

APP="/Applications/ClaudeUsageTray.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
cp .build/release/ClaudeUsageTray "$APP/Contents/MacOS/"

cat > "$APP/Contents/Info.plist" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key><string>ClaudeUsageTray</string>
    <key>CFBundleIdentifier</key><string>io.medvr.claudeusagetray</string>
    <key>CFBundleName</key><string>ClaudeUsageTray</string>
    <key>CFBundleShortVersionString</key><string>1.0</string>
    <key>CFBundleVersion</key><string>1</string>
    <key>LSMinimumSystemVersion</key><string>14.0</string>
    <key>LSUIElement</key><true/>
    <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
EOF

codesign --force --deep --sign - "$APP"

# Launch at login via LaunchAgent
PLIST="$HOME/Library/LaunchAgents/io.medvr.claudeusagetray.plist"
mkdir -p "$HOME/Library/LaunchAgents"
cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key><string>io.medvr.claudeusagetray</string>
    <key>ProgramArguments</key>
    <array><string>/Applications/ClaudeUsageTray.app/Contents/MacOS/ClaudeUsageTray</string></array>
    <key>RunAtLoad</key><true/>
</dict>
</plist>
EOF

pkill -x ClaudeUsageTray 2>/dev/null || true
open "$APP"
echo "Installed $APP and launch agent. App is running in your menu bar."
