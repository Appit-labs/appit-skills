#!/usr/bin/env bash
# Migrate the nine skill repos + the central marketplace into the appit-labs org.
#
#   scripts/migrate-to-org.sh                 # dry run: prints every step, changes nothing
#   scripts/migrate-to-org.sh --yes           # transfer, repoint, push, set topics
#   scripts/migrate-to-org.sh --yes --public  # ... and make the repos public (see warnings)
#
# Prerequisites:
#   1. The org exists: https://github.com/organizations/new  ->  Free  ->  appit-labs
#   2. You are an owner of it, and this token can act on the org:
#        gh auth refresh -h github.com -s admin:org
#   3. Local clones of the skills live in $SRC (default: $HOME/work/skills-ship)
set -euo pipefail

ORG="${ORG:-appit-labs}"
SRC="${SRC:-$HOME/work/skills-ship}"
CENTRAL="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS=(live-qa ci-triage pg-inspect repo-runbook remote-exec trello-tickets cloud-browser open-design blender-pipeline)

APPLY=0
PUBLIC=0
for arg in "$@"; do
  case "$arg" in
    --yes) APPLY=1 ;;
    --public) PUBLIC=1 ;;
    *) echo "unknown flag: $arg" >&2; exit 2 ;;
  esac
done

run() {
  if [ "$APPLY" = 1 ]; then "$@"; else echo "    would run: $*"; fi
}

echo "org:      $ORG"
echo "central:  $CENTRAL"
echo "clones:   $SRC"
echo

echo "== 1. preflight"
if ! gh api "/orgs/$ORG" --jq .login >/dev/null 2>&1; then
  cat >&2 <<EOF
The organisation '$ORG' does not exist yet, so nothing can be transferred.

Create it (web UI is the only route, there is no API for it):
  https://github.com/organizations/new   ->   Free   ->   name: $ORG

Then grant this CLI org rights and re-run:
  gh auth refresh -h github.com -s admin:org
  scripts/migrate-to-org.sh --yes
EOF
  exit 1
fi
echo "    org exists: $(gh api "/orgs/$ORG" --jq .login)"

for r in "${SKILLS[@]}"; do
  [ -d "$SRC/$r/.git" ] || { echo "    missing clone: $SRC/$r" >&2; exit 1; }
done
echo "    all nine clones present"

echo "== 2. transfer repositories (history, stars, issues and redirects are preserved)"
for r in "${SKILLS[@]}"; do
  echo "  $r"
  run gh api -X POST "repos/Appit-labs/$r/transfer" -f "new_owner=$ORG"
done

echo "== 3. repoint local clones, docs and manifests to $ORG"
for r in "${SKILLS[@]}"; do
  d="$SRC/$r"
  if [ "$APPLY" = 1 ]; then
    git -C "$d" remote set-url origin "git@github.com:$ORG/$r.git"
    python3 - "$d" "$ORG" <<'PY'
import json, sys
from pathlib import Path
d, org = Path(sys.argv[1]), sys.argv[2]
for name in ('README.md', 'SECURITY.md', 'NOTICE'):
    p = d / name
    if p.exists():
        p.write_text(p.read_text().replace('Appit-labs/', f'{org}/'))
pkg = d / 'package.json'
if pkg.exists():
    data = json.loads(pkg.read_text())
    data.setdefault('repository', {})['url'] = f'https://github.com/{org}/{d.name}.git'
    pkg.write_text(json.dumps(data, indent=2) + "\n")
plug = d / '.claude-plugin' / 'plugin.json'
if plug.exists():
    data = json.loads(plug.read_text())
    data['homepage'] = f'https://github.com/{org}/{d.name}'
    data.get('author', {})['url'] = f'https://github.com/{org}'
    plug.write_text(json.dumps(data, indent=2) + "\n")
PY
    git -C "$d" add -A
    git -C "$d" -c user.name="Ibrahim M. Badr" -c user.email="ibrabadr01@gmail.com" \
      commit -qm "chore: move to $ORG" || echo "    (nothing to commit)"
    git -C "$d" push -q origin main
  else
    echo "    would repoint and push $r"
  fi
done

echo "== 4. topics (how directory crawlers match you)"
declare -A TOPICS=(
  [live-qa]="agent-skill,agent-skills,claude-code-plugin,codex,qa,browser-testing,e2e,turnstile"
  [ci-triage]="agent-skill,ci,github-actions,gitlab-ci,devops,logs"
  [pg-inspect]="agent-skill,postgres,database,sql,explain,read-only"
  [repo-runbook]="agent-skill,agents-md,onboarding,monorepo,dx"
  [remote-exec]="agent-skill,ssh,devops,remote,provisioning"
  [trello-tickets]="agent-skill,trello,kanban,project-management,api"
  [cloud-browser]="agent-skill,browser,cloud,stealth,agent-browser"
  [open-design]="agent-skill,open-design,monorepo,pnpm,design-system"
  [blender-pipeline]="agent-skill,blender,3d,mcp,modeling,export"
)
for r in "${SKILLS[@]}"; do
  run gh repo edit "$ORG/$r" --add-topic "${TOPICS[$r]}"
done

echo "== 5. central marketplace repo"
run gh repo create "$ORG/appit-skills" --private --source="$CENTRAL" --remote=origin --push \
  --description "Agent skills marketplace: browser QA, CI triage, Postgres, tickets, Blender"
run gh repo edit "$ORG/appit-skills" --add-topic agent-skills,claude-code-plugin,codex,pi-package,marketplace

if [ "$PUBLIC" = 1 ]; then
  echo "== 6. visibility: public (this exposes full git history)"
  for r in "${SKILLS[@]}" appit-skills; do
    run gh repo edit "$ORG/$r" --visibility public --accept-visibility-change-consequences
  done
else
  echo "== 6. visibility: unchanged (re-run with --yes --public once the history scan is clean)"
fi

cat <<EOF

Next, outside this script:
  npm org create $ORG                      # free for public packages
  cd "$CENTRAL" && npm publish --access public
  # indexers: skillsmp.com (needs >=2 stars), skills.sh (needs one 'npx skills add'),
  # pi.dev/packages (needs the npm publish above)
EOF
