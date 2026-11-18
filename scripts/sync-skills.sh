#!/usr/bin/env bash
# Copy each published skill into ./skills for the npm package (appit-skills).
# Single source of truth stays in the per-skill repositories.
set -euo pipefail
cd "$(dirname "$0")/.."
ORG="${ORG:-ibrahimbdr}"
rm -rf skills && mkdir -p skills
for repo in live-qa trello-tickets repo-runbook pg-inspect remote-exec cloud-browser ci-triage open-design blender-pipeline; do
  tmp=$(mktemp -d)
  git clone --depth 1 --quiet "git@github.com:$ORG/$repo.git" "$tmp/$repo"
  cp -r "$tmp/$repo/skills/$repo" "skills/$repo"
  rm -rf "$tmp"
done
ls -1 skills
