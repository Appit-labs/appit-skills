# Appit skills

Practical agent skills for real engineering work — browser QA, tickets, databases, remote boxes,
CI triage, Blender. One marketplace, nine skills, no runtime dependencies.

Every skill is plain `SKILL.md` plus (where useful) a single stdlib script, so it works in any agent
that reads the open Agent Skills format: **pi, Claude Code, Codex, Cursor, Gemini CLI, Copilot, Goose**.

## Install

**Claude Code** — the whole collection as a marketplace:

```bash
claude plugin marketplace add appit-labs/appit-skills
claude plugin install live-qa@appit-skills
```

**pi** — one package, nine skills:

```bash
pi install npm:@appit-labs/skills
```

**Codex / Cursor / anything else** — clone and copy the skill you want:

```bash
git clone git@github.com:appit-labs/live-qa.git
cp -r live-qa/skills/live-qa ~/.codex/skills/          # or ~/.claude/skills/, or .cursor/skills/
```

## The skills

| Skill | What it does | Needs |
| --- | --- | --- |
| [live-qa](https://github.com/appit-labs/live-qa) | Live QA in a real browser: numbered screenshot per step, pass/fail table, console/network/a11y evidence, plus verified Turnstile/auth procedures | an `agent_browser`-style browser tool |
| [ci-triage](https://github.com/appit-labs/ci-triage) | "CI is red" → failing step + the extracted error, GitHub Actions and GitLab | `gh` and/or `glab` |
| [pg-inspect](https://github.com/appit-labs/pg-inspect) | Read-only Postgres inspection that is safe against production | `psql` |
| [repo-runbook](https://github.com/appit-labs/repo-runbook) | Writes the install/test/migrate runbook into `AGENTS.md` so sessions stop re-grepping for it | Python 3.9+ |
| [remote-exec](https://github.com/appit-labs/remote-exec) | SSH that cannot hang: aliased hosts, hard timeouts, one-call host probe | `ssh` + key auth |
| [trello-tickets](https://github.com/appit-labs/trello-tickets) | Seven ticket types with sections, checklist, labels, cover — read and create | Trello API key |
| [cloud-browser](https://github.com/appit-labs/cloud-browser) | Hosted/stealth browser sessions **and** the sweep that stops them billing | provider key |
| [open-design](https://github.com/appit-labs/open-design) | OpenDesign monorepo: pinned pnpm, `tools-dev` lifecycle, QA, pre-PR checks | Node 24 + pnpm 10.33.2 |
| [blender-pipeline](https://github.com/appit-labs/blender-pipeline) | Blockout → shade → light → export via MCP, eight playbooks behind one router | Blender + MCP add-on |

## Why these

- **Measured, not guessed.** Each skill came out of real work: 16k grep-crawls became `repo-runbook`,
  1,115 retyped `psql` lines became `pg-inspect`. The numbers are in each repo.
- **Token-cheap by design.** Descriptions are short because every skill's description is paid on
  every session; detail lives in `references/` and is read only when needed.
- **Security-scanned.** Each repo carries a SkillSpector baseline and a `SECURITY.md` that lists every
  accepted finding and why. Nothing here shells out with `shell=True`, bundles a credential, or picks
  a network destination at runtime.
- **Verified end to end.** Scripts ship `--self-test`; the commands were run against real targets
  (a live Postgres, a staging server, a failing CI run, Blender through MCP).

## License

MIT. `blender-pipeline` bundles the Blender Skills playbooks by
[arjun988](https://github.com/arjun988/blender-skills) (MIT) — see its `NOTICE`.
