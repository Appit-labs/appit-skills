#!/usr/bin/env bash
# Publish the catalog to npm (and therefore into the pi package gallery).
#
#   scripts/publish.sh            # preflight, then publish
#   scripts/publish.sh --dry-run  # everything except the upload
#
# Preflight is the point: a broken pack still "publishes", and a published version
# cannot be taken back — only deprecated.
set -euo pipefail
cd "$(dirname "$0")/.."
DRY=""
[ "${1:-}" = "--dry-run" ] && DRY="--dry-run"
# 2FA is enabled on the publishing account (auth-and-writes), so npm asks for a one-time
# password. Pass it as $NPM_OTP and it goes to npm as --otp; an automation token
# ($NPM_TOKEN) bypasses the prompt entirely and is the right choice for repeat releases.
OTP_ARG=""
[ -n "${NPM_OTP:-}" ] && OTP_ARG="--otp=$NPM_OTP"

say() { printf '%s\n' "$*"; }
fail() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

say "== preflight"
NPMRC=""
cleanup() { [ -n "$NPMRC" ] && rm -f "$NPMRC"; }
trap cleanup EXIT

# A dedicated npm config wins over the login session in ~/.npmrc: it can hold an
# automation token (no OTP prompt) without touching the account's interactive session.
APPNPMRC="${APPNPMRC:-$HOME/.config/appit/npmrc}"
if [ -z "${NPM_TOKEN:-}" ] && [ -f "$APPNPMRC" ]; then
  MODE=$(stat -c '%a' "$APPNPMRC" 2>/dev/null || stat -f '%Lp' "$APPNPMRC")
  [ "$MODE" = "600" ] || fail "$APPNPMRC is mode $MODE — chmod 600 it (it holds a credential)"
  export NPM_CONFIG_USERCONFIG="$APPNPMRC"
  say "  auth:       $APPNPMRC (automation token, mode 600)"
fi
if [ -n "${NPM_TOKEN:-}" ]; then
  # Token path: no browser, no bot check. Written 0600 and deleted on exit.
  NPMRC=$(mktemp)
  chmod 600 "$NPMRC"
  printf '//registry.npmjs.org/:_authToken=%s\n' "$NPM_TOKEN" > "$NPMRC"
  export NPM_CONFIG_USERCONFIG="$NPMRC"
  say "  auth:       \$NPM_TOKEN (temporary config, deleted on exit)"
else
  npm whoami >/dev/null 2>&1 || fail "not logged in. Either:
  - npm login --auth-type=legacy     (no browser; asks user/password/OTP)
  - export NPM_OTP=<6-digit code from the authenticator>   (2FA is auth-and-writes)
  - or export NPM_TOKEN=<automation token>                 (bypasses the OTP prompt)"
fi
say "  npm user:   $(npm whoami 2>/dev/null || echo '(token)')"
node -e 'const p=require("./package.json"); if(!p.name||!p.version) process.exit(1); console.log("  package:    "+p.name+"@"+p.version)'
node -e 'const p=require("./package.json"); if(!(p.keywords||[]).includes("pi-package")) process.exit(1); console.log("  gallery:    pi-package keyword present")'
[ -f .claude-plugin/marketplace.json ] || fail "marketplace.json missing"
claude plugin validate .claude-plugin/marketplace.json --strict >/dev/null 2>&1 \
  && say "  marketplace: validates" || fail "marketplace.json does not validate"

say "== pack"
TARBALL=$(npm pack --silent | tail -1)
COUNT=$(tar -tzf "$TARBALL" | grep -c '/SKILL.md$')
say "  $TARBALL  ($(du -h "$TARBALL" | cut -f1), $COUNT skills)"
[ "$COUNT" -ge 12 ] || fail "only $COUNT skills in the tarball — run scripts/sync-skills.sh"
say "  skills:     $(tar -tzf "$TARBALL" | grep '/SKILL.md$' | sed 's|package/skills/||;s|/SKILL.md||' | sort | tr '\n' ' ')"

say "== publish"
if [ -n "$DRY" ]; then
  npm publish --access public $OTP_ARG --dry-run
  say "dry run: nothing uploaded"
else
  npm publish --access public $OTP_ARG
  say "published — the pi gallery indexes npm by the 'pi-package' keyword within minutes"
  say "next: git tag v$(node -p 'require("./package.json").version') && git push --tags"
fi
