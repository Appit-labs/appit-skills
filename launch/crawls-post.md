# Post 2 — the measured problem (r/ExperiencedDevs / Hacker News / dev.to)

**Title:** 16,315 `cd && grep` calls: what an agent actually wastes re-learning your repo

---

I keep session transcripts of every coding-agent run I do. Then I counted, over ~2 months of work
across 56 repos:

| Pattern | Count |
| --- | --- |
| `cd <repo> && grep/sed -rn …` — rediscovering where things are | **16,315** |
| `PGPASSWORD=… psql -h … -U … -d … -c "…"` — retyped connection strings | **1,115** |
| hand-written `ssh -o BatchMode=yes -o ConnectTimeout=… 'bash -lc …'` | **825** |

None of that is the work. All of it is paid in context tokens, in every session, forever, because
nothing carries the answer forward.

What actually fixed each one, as three small MIT skills:

- **repo-runbook** — reads the manifests once, writes a 20-line runbook (install, run, test, lint,
  migrate, services, env keys, CI) into `AGENTS.md` between markers, and has a `check` mode that
  reports drift. Later sessions read twelve lines instead of grepping.
- **pg-inspect** — one read-only command per question (`overview`, `tables`, `schema`, `q`, `explain`,
  `audit`, `locks`, …34 of them). Statements are refused before connecting unless they are a single
  SELECT, and the session runs with `default_transaction_read_only=on`, so the write path does not
  exist even if the model tries.
- **remote-exec** — aliased hosts, hard timeouts, BatchMode, and a `probe` that returns uptime, disks
  over 70%, memory, containers, GPU and listening ports in one call. A dead host costs your timeout,
  not your session.

Collection: github.com/Appit-labs/appit-skills — twelve MIT skills, `npx skills add Appit-labs/appit-skills`
installs all of them. Each repo states its own token cost, because that is the objection
worth answering up front.

The general lesson, if you take only one thing: **your agent's biggest cost is not thinking, it is
re-derivation.** Write the answers down where the next session reads them at startup.
