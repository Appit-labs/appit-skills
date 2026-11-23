#!/usr/bin/env bash
# Copy each published skill into ./skills for the npm package (appit-skills).
# Single source of truth stays in the per-skill repositories.
set -euo pipefail
cd "$(dirname "$0")/.."
ORG="${ORG:-Appit-labs}"
rm -rf skills && mkdir -p skills
for repo in live-qa trello-tickets repo-runbook pg-inspect remote-exec cloud-browser ci-triage open-design blender-pipeline code-scan release hermes-setup; do
  tmp=$(mktemp -d)
  # ssh: this is a maintainer script, not a CI step — the mirror it writes is committed and
  # shipped, so publishing never clones anything.
  git clone --depth 1 --quiet "git@github.com:$ORG/$repo.git" "$tmp/$repo"
  cp -r "$tmp/$repo/skills/$repo" "skills/$repo"
  rm -rf "$tmp"
done
# Demo GIFs stay in their own repositories; the mirror is what `npx skills add` and npm
# download, so keep it lean.
find skills -path '*/assets/*.gif' -delete
ls -1 skills
