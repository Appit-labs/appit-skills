# Sharing the skills with the team

Kamal asked for skills to live in `talentino-plugins`, and Seif is preparing the hosting. So the
message below does **not** announce a publication — it offers the repos, says what each one saves,
and puts the team plugin forward as the destination. People clone what they want; whoever owns the
plugin picks what goes in.

Two versions: the channel post, and a shorter reply to the direct call-out.

---

## Channel post (paste as-is)

I keep a small set of Claude Code / Codex skills for the work we all do on these repos. They're in public repos, so clone or copy whichever is useful.

**repo-runbook** — https://github.com/Appit-labs/repo-runbook
Writes the install/test/migrate runbook into `AGENTS.md` from the manifests, once, and has a `check`
mode for drift. It exists because a fresh session in one of our repos spends its first forty tool
calls grepping for the test command; this turns that into twelve lines it reads at startup.

**pg-inspect** — https://github.com/Appit-labs/pg-inspect
34 read-only Postgres commands: `overview`, `tables`, `schema`, `explain` as a plan tree with cost
bars, plus `audit`, which reports unused indexes, foreign keys with no supporting index, dead-tuple
bloat, xid age and sequence exhaustion in one prioritised list. The write path doesn't exist — the
statement is refused before connecting, and the session runs read-only, so it is safe pointed at
staging.

**ci-triage** — https://github.com/Appit-labs/ci-triage
Takes a red branch and returns the failing step plus the four lines of the log that matter, for
GitHub Actions and GitLab. It also tells you when a run failed *before any job started*, which
almost always means the workflow file, not your code — that one has saved me a lot of reading.

**live-qa** — https://github.com/Appit-labs/live-qa
A step-by-step QA pass in a real browser: numbered screenshot per step, pass/fail table, console and
failed-request evidence. It has a working auth ladder (saved session, minted token, TOTP, or a
one-click SSO hand-off), so it can test flows behind a login instead of stopping at the sign-in page.

**code-scan** — https://github.com/Appit-labs/code-scan
Runs Skylos on Python and Fallow on TS/JS and merges them into one severity scale, with a baseline so
CI only fails on findings the branch introduced. On one repo it took 3,623 raw findings down to 118
that were worth a human look.

There are others — `remote-exec` (SSH without hanging on a prompt, one-call host probe),
`release` (conventional commits → changelog → release PR/MR → tag), `cloud-browser`, `trello-tickets`
— same place if anyone wants them: https://github.com/Appit-Labs.

If we're collecting these in `talentino-plugins`, say which ones and I'll open the PR to add them
there properly — same structure as design-to-product, with the version bumped.

---

## Shorter reply, for the direct call-out

Nothing in my pocket for the plaudits, but here's the set I actually use: `repo-runbook` (writes the
runbook into AGENTS.md so sessions stop re-discovering it), `pg-inspect` (34 read-only Postgres
commands, `audit` finds dead indexes and unindexed FKs), `ci-triage` (red branch → failing step + the
four lines that matter) and `code-scan` (Skylos + Fallow, one report, baseline gate).
https://github.com/Appit-Labs — MIT, clone or copy whatever's useful, and I'll PR the ones you want
into `talentino-plugins`.

---

## Notes on tone

- **No "I published it"** and no npm/install line. The team's plan is to host them; the repos are
  just where the source lives. Anyone who wants the npm package finds it in the README.
- **Lead with what it saves**, not with features. Each paragraph ends on a concrete cost it removes.
- **Keep `hermes-setup` for the AI-team conversation**, not the general channel — it is about our
  agent's token contract, and it belongs with whoever owns that integration.
- If someone asks "when did you build these": *used on our own stack for a while, repositories
  opened up recently* — which is exactly what `CHANGELOG.md` in each repo says.
