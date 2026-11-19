# Sharing the skills with the team

Audience: **engineers** — the wording below assumes fluency (read-only transactions, JWT claims,
`storageState`, diff bases) and does not explain what a repo or a CI run is. Kamal's plugin owns
distribution, so nothing here announces a publication: the repos are the source, `talentino-plugins`
is the destination, and whoever wants a skill clones it.

All twelve, grouped. Two lines each, no marketing.

---

## Channel post (paste as-is)

Twelve of these, all MIT, all in public repos — clone or copy what's useful. Grouped roughly by what
you're doing.

**Reading the database**
- **[pg-inspect](https://github.com/Appit-labs/pg-inspect)** — 34 read-only commands against a live
  Postgres: `overview`, `tables`, `schema`, `ddl`, `fk`, `explain` (plan tree from `EXPLAIN (FORMAT
  JSON)` with cost bars), plus `audit` — unused indexes, FKs with no supporting index, dead-tuple
  bloat, `xid` age vs `freeze_max_age`, sequences near exhaustion, cache hit ratio. Single statement
  only, refused before `psql` is even invoked, session runs `default_transaction_read_only=on` with a
  15s `statement_timeout`, so pointing it at staging is fine. `--json/--csv/--md` on every command.

**Repo and release plumbing**
- **[repo-runbook](https://github.com/Appit-labs/repo-runbook)** — reads the manifests (pyproject,
  package.json, compose, alembic, CI) and writes a 20-line runbook between markers in `AGENTS.md`;
  `check` exits 1 on drift. No source crawl, ~90 ms.
- **[release](https://github.com/Appit-labs/release)** — conventional commits → SemVer
  (`!`/`BREAKING CHANGE` → major, `feat` → minor), rewrites the version in `package.json` /
  `pyproject.toml` / `VERSION` / `__version__`, prepends `CHANGELOG.md`, branches `release/vX.Y.Z`,
  opens the PR/MR via `gh`/`glab`, then tags and publishes the release. Preflight refuses a dirty
  tree, detached HEAD, or a branch behind its remote.
- **[remote-exec](https://github.com/Appit-labs/remote-exec)** — SSH with `BatchMode` +
  `ConnectTimeout` and a timeout per command, hosts in a `0600` alias file; `probe` returns uptime,
  filesystems over 70%, memory, containers, GPU and listening ports in one round trip.

**CI and code quality**
- **[ci-triage](https://github.com/Appit-labs/ci-triage)** — newest failed run → failing job and
  step → log extract with ANSI/timestamps/boilerplate stripped and ±2 lines of context. Handles
  GitLab pipelines the same way, and calls out runs with zero jobs (workflow-level failure, not a
  test failure).
- **[code-scan](https://github.com/Appit-labs/code-scan)** — Skylos (Python, `--no-upload` always) +
  Fallow (TS/JS, `-f json`) merged onto one severity scale, with a fingerprint baseline so a gate is
  adoptable on day one; `--changed` maps to `--diff-base` and `fallow audit --base`. Severity is by
  rule kind, because Skylos grades cyclomatic complexity as HIGH and that makes any gate useless.

**Browser work**
- **[live-qa](https://github.com/Appit-labs/live-qa)** — step-by-step QA in a real browser with a
  verified screenshot per step (byte-checked, not assumed), pass/fail table, console and failed
  requests. Auth ladder: saved `storageState` (0600, AES-GCM optional), backend-minted token
  injection, TOTP from a test secret, or SSO hand-off via `auth open` → `auth wait` — the last one
  completed a real Google and a real Microsoft FIDO sign-in.
- **[cloud-browser](https://github.com/Appit-labs/cloud-browser)** — hosted/stealth sessions through
  the `agent-browser` provider flags (`browseruse`, `browserbase`, `kernel`, `browserless`,
  `agentcore`), plus `stop_all.py`, which sweeps orphaned browsers by `PATCH /api/v4/browsers/{id}`
  with `{"action":"stop"}` — dry-run by default, because a crashed run otherwise keeps billing.

**Agent wiring**
- **[hermes-setup](https://github.com/Appit-labs/hermes-setup)** — the contract we use for the agent:
  HS256 token with `aud=hermes-agent`, an explicit `scope`, TTL capped at 1800s; verification
  distinguishes bad signature / expired / wrong audience / missing scope by exit code; generates the
  least-privilege SQL (`NOSUPERUSER NOINHERIT`, revoke-all-then-grant per table, defaults revoked for
  future tables, `statement_timeout` on the role); `link-check` asserts 200 valid / 401 garbage /
  401 expired — the third one is what catches a service that verifies signatures but not `exp`.

**Adjacent**
- **[trello-tickets](https://github.com/Appit-labs/trello-tickets)** — seven ticket templates as data
  (sections, checklist, labels, cover colour), `--dry-run` prints the exact payload, credentials in
  `~/.config/trello/config.json`; board/list/label resolution by name, so no board read before filing.
- **[open-design](https://github.com/Appit-labs/open-design)** — for `nexu-io/open-design`: the
  `corepack pnpm` pin, `tools-dev` as the only lifecycle entry point (there is no root `pnpm dev`),
  desktop screenshots via `tools-dev inspect`, and the `guard`/`typecheck` gates.
- **[blender-pipeline](https://github.com/Appit-labs/blender-pipeline)** — 3D only: eight Blender MCP
  playbooks behind one router, with the bridge setup (`uvx mcp-for-blender`, socket on 9876). Skip
  unless you model.

All of them: https://github.com/Appit-Labs. If we're collecting them in `talentino-plugins`, name the
ones you want and I'll PR them into that structure with the version bumped.

---

## Short version, if the channel wants one-liners

| Skill | One line |
| --- | --- |
| repo-runbook | runbook into AGENTS.md, `check` for drift |
| pg-inspect | 34 read-only Postgres commands, `audit` for index/bloat/xid |
| ci-triage | red branch → failing step + 4 log lines |
| code-scan | Skylos + Fallow, one report, baseline gate |
| live-qa | screenshot-per-step browser QA, with an auth ladder |
| remote-exec | SSH with timeouts, one-call host probe |
| release | conventional commits → changelog → PR → tag |
| trello-tickets | seven card templates, dry-run first |
| hermes-setup | agent JWT + least-privilege role + link check |
| cloud-browser | hosted browser sessions + orphan sweep |
| open-design | the pnpm/tools-dev trap, defused |
| blender-pipeline | Blender via MCP (3D only) |

---

## Notes on tone

- **No "I published it", no npm/install line** — the team is preparing the hosting; the repos are
  where the source lives. Anyone who wants the package finds it in the README.
- **Technical register**: internals, flags and failure modes instead of "this saves you time".
- **`hermes-setup` belongs in the AI thread too**, but it is listed here because it is the contract
  anyone wiring the agent will hit.
- If asked "when did you build these": *used on our stack for a while, repos opened recently* —
  which is what `CHANGELOG.md` in each repo states.
