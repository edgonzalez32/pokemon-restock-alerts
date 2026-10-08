#!/bin/bash
# One Target check from this Mac (home internet, which Target doesn't block),
# shared with GitHub so the dashboard updates and GitHub stands by.
set -u
REPO="$(cd "$(dirname "$0")/.." && pwd)"
HOME_DIR="$HOME/.restock-radar"
mkdir -p "$HOME_DIR"
cd "$REPO" || exit 1

set -a; . "$HOME_DIR/env"; set +a   # NTFY_TOPIC, VAPID_PRIVATE_KEY, WEBPUSH_SUBSCRIPTIONS

git pull -q --ff-only origin main >/dev/null 2>&1 || true
if git fetch -q origin status 2>/dev/null; then
  git show origin/status:state.json > "$HOME_DIR/state.json" 2>/dev/null || true
fi

CHECKER_SOURCE=mac STATE_PATH="$HOME_DIR/state.json" STATUS_PATH="$HOME_DIR/status.json" \
  python3 checker.py || exit 1

PUB="$HOME_DIR/publish"
rm -rf "$PUB" && mkdir -p "$PUB"
cp "$HOME_DIR/state.json" "$HOME_DIR/status.json" "$PUB/"
cd "$PUB" && git init -q -b status && git add -A \
  && git -c user.name="restock-mac" -c user.email="restock-bot@users.noreply.github.com" commit -q -m "status (mac)" \
  && git push -q -f "$(git -C "$REPO" remote get-url origin)" status
