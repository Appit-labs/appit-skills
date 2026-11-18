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

say() { printf '%s\n' "$*"; }
fail() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

say "== preflight"
NPMRC=""
cleanup() { [ -n "$NPMRC" ] && rm -f "$NPMRC"; }
trap cleanup EXIT
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
  - or create a granular token at npmjs.com and export NPM_TOKEN=…"
fi
say "  npm user:   $(npm whoami 2>/dev/null || echo '(token)')"
node -e 'const p=require("./package.json"); if(!p.name||!p.version) process.exit(1); console.log("  package:    "+p.name+"@"+p.version)'
node -e 'const p=require("./package.json"); if(!(p.keywords||[]).includes("pi-package")) process.exit(1); console.log("  gallery:    pi-package keyword present")'
[ -f .claude-plugin/marketplace.json ] || fail "marketplace.json missing"
claude plugin validate .claude-plugin/marketplace.json --strict >/dev/null 2>&1 \
  && say "  marketplace: validates" || fail "marketplace.json does not validate"

say "== pack"
npm pack --silent >/dev/null
TARBALL=$(ls -t appit-skills-*.tgz | head -1)
COUNT=$(tar -tzf "$TARBALL" | grep -c '/SKILL.md$')
say "  $TARBALL  ($(du -h "$TARBALL" | cut -f1), $COUNT skills)"
[ "$COUNT" -ge 12 ] || fail "only $COUNT skills in the tarball — run scripts/sync-skills.sh"
say "  skills:     $(tar -tzf "$TARBALL" | grep '/SKILL.md$' | sed 's|package/skills/||;s|/SKILL.md||' | sort | tr '\n' ' ')"

say "== publish"
if [ -n "$DRY" ]; then
  npm publish --access public --dry-run
  say "dry run: nothing uploaded"
else
  npm publish --access public
  say "published — the pi gallery indexes npm by the 'pi-package' keyword within minutes"
  say "next: git tag v$(node -p 'require("./package.json").version') && git push --tags"
fi
