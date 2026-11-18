# Security review — appit-skills (catalog)

This repository holds **no skill code**. It is the catalog: `.claude-plugin/marketplace.json` points
at the twelve skill repositories, plus the npm packaging scripts.

## What ships in the npm package (`@appitlabs/skills`)

- `skills/<name>/SKILL.md` and their `scripts/`, `references/`, `assets/` — copied from the
  individual repositories by `scripts/sync-skills.sh` at `prepack` time.
- `demos/<name>.json` + `tools/make_demo.py` — the captured transcripts and the renderer that
  produced each hero GIF.
- `assets/appit-logo.png` — the wordmark.

Each skill's own security review lives in its repository (`SECURITY.md` there), scanned with
SkillSpector against a committed baseline: 0/100, 0 open findings, with every accepted finding
listed and justified.

## This repository's own scripts

| Script | What it does | Risk |
| --- | --- | --- |
| `scripts/sync-skills.sh` | shallow-clones the skill repos, copies each `skills/<name>` in | network read from `github.com`, writes only inside `skills/` |
| `scripts/publish.sh` | preflight, `npm pack`, `npm publish --access public` | writes a temporary `.npmrc` (`0600`) only when `$NPM_TOKEN` is used, and deletes it on exit |
| `scripts/migrate-to-org.sh` | transfers repos and rewrites org references | dry run unless `--yes` |
| `scripts/make_demo.py` | renders GIFs from captured transcripts | reads `demos/*.json`, writes `skills/*/assets/demo.gif` |

No `shell=True` with interpolated input, no credential written to a tracked path, no network
destination chosen by the model.

## Publishing checklist (before `npm publish`)

1. `npm whoami` reports the account that owns the `appitlabs` org.
2. `claude plugin validate .claude-plugin/marketplace.json --strict` passes.
3. `npm pack` contains **12** `SKILL.md` files.
4. `SECURITY.md` of every skill it bundles is still 0/100 with 0 open findings.
