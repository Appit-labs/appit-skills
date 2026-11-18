#!/usr/bin/env bash
# Publish a launch article to dev.to through their API — no browser, no bot checks.
#
#   DEVTO_API_KEY=xxx launch/post-to-devto.sh launch/turnstile-post.md
#   DEVTO_API_KEY=xxx launch/post-to-devto.sh --dry-run launch/turnstile-post.md
#
# The key is created in one click at https://dev.to/settings/extensions → "DEV Community API Keys".
set -euo pipefail

FILE=""
DRY=""
for a in "$@"; do case "$a" in --dry-run) DRY="1";; *) FILE="$a";; esac; done
[ -n "$FILE" ] && [ -f "$FILE" ] || { echo "usage: DEVTO_API_KEY=… $0 [--dry-run] <markdown-file>" >&2; exit 2; }
[ -n "${DEVTO_API_KEY:-}" ] || { echo "set DEVTO_API_KEY (dev.to → Settings → Extensions → DEV Community API Keys)" >&2; exit 2; }

# First markdown line that starts with "**Title:**" is the title; fall back to the first heading.
TITLE=$(grep -m1 '^\*\*Title:\*\*' "$FILE" | sed 's/^\*\*Title:\*\* *//' || true)
[ -n "$TITLE" ] || TITLE=$(grep -m1 '^# ' "$FILE" | sed 's/^# *//' || true)
# Drop the launch-file scaffolding: the H1 line that names the intended channels, and the
# horizontal rule right under it. What is left is the article itself.
BODY=$(grep -v '^\*\*Title:\*\*' "$FILE" \
  | awk 'NR==1 && /^# / {skip=1; next} skip && /^---$/ {skip=0; next} {print}' \
  | sed -e '/./,$!d')
[ -n "$TITLE" ] || { echo "no title found in $FILE" >&2; exit 2; }

PAYLOAD=$(TITLE="$TITLE" BODY="$BODY" python3 -c '
import json, os
print(json.dumps({"article": {
    "title": os.environ["TITLE"],
    "published": True,
    "body_markdown": os.environ["BODY"],
    "tags": ["webdev", "security", "cloudflare", "testing"],
}}))')

echo "title:  $TITLE"
echo "body:   $(printf '%s' "$BODY" | wc -l) lines, $(printf '%s' "$BODY" | wc -c) bytes"
if [ -n "$DRY" ]; then echo "dry run: nothing published"; printf '%s' "$PAYLOAD" | python3 -m json.tool | head -8; exit 0; fi

RESP=$(curl -sS -X POST https://dev.to/api/articles \
  -H "api-key: $DEVTO_API_KEY" -H "Content-Type: application/json" \
  -d "$PAYLOAD" -w '\n%{http_code}')
CODE=$(printf '%s' "$RESP" | tail -1)
BODYJSON=$(printf '%s' "$RESP" | sed '$d')
if [ "$CODE" = "201" ]; then
  printf '%s' "$BODYJSON" | python3 -c 'import json,sys; d=json.load(sys.stdin); print("published:", d.get("url"))'
else
  echo "dev.to returned HTTP $CODE" >&2; printf '%s' "$BODYJSON" | head -c 400 >&2; exit 1
fi
