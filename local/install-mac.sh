#!/bin/bash
# Installs the every-minute Mac checker. Run once: ./local/install-mac.sh
# Remove with: launchctl unload ~/Library/LaunchAgents/com.restockradar.check.plist
set -eu
REPO="$(cd "$(dirname "$0")/.." && pwd)"
HOME_DIR="$HOME/.restock-radar"
PLIST="$HOME/Library/LaunchAgents/com.restockradar.check.plist"
mkdir -p "$HOME_DIR" "$HOME/Library/LaunchAgents"
chmod +x "$REPO/local/run-mac.sh"

if [ ! -f "$HOME_DIR/env" ]; then
  cat > "$HOME_DIR/env" <<'ENV'
NTFY_TOPIC=
VAPID_PRIVATE_KEY=
WEBPUSH_SUBSCRIPTIONS=
ENV
  chmod 600 "$HOME_DIR/env"
  echo "Fill in $HOME_DIR/env, then run this again."
  exit 1
fi

python3 -c "import cryptography" 2>/dev/null || python3 -m pip install --user -q cryptography

cat > "$PLIST" <<PL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>com.restockradar.check</string>
  <key>ProgramArguments</key><array><string>/bin/bash</string><string>$REPO/local/run-mac.sh</string></array>
  <key>EnvironmentVariables</key><dict><key>PATH</key><string>$PATH</string></dict>
  <key>StartInterval</key><integer>60</integer>
  <key>RunAtLoad</key><true/>
  <key>StandardOutPath</key><string>$HOME_DIR/check.log</string>
  <key>StandardErrorPath</key><string>$HOME_DIR/check.log</string>
</dict>
</plist>
PL
launchctl unload "$PLIST" 2>/dev/null || true
launchctl load "$PLIST"
echo "Installed. Log: $HOME_DIR/check.log"
