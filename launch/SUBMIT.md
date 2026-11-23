# Submit — copy, paste, send

Everything here is written and ready. The only reason it is not sent is that sending it needs a
logged-in human on each platform, and that is the correct rule for all of them.

Order matters: one channel at a time, and answer the comments before opening the next one.

## 0. Before anything is sent

- [ ] `python3 scripts/distribute.py smoke` → `12 skills installed`
- [ ] `python3 scripts/distribute.py radar` → the table is honest about being 0/12 indexed
- [ ] npm is on 0.2.0 (`npm view @appitlabs/skills version`)
- [ ] `main` is green

## 1. Hacker News — the measured post, not the product

**Submit:** <https://news.ycombinator.com/submit>

| field | value |
| --- | --- |
| title | `Show HN: 16,315 cd && grep calls — what my coding agent wasted re-learning repos` |
| url | the dev.to article (or the repo README if the article is not up yet) |

Then the **first comment**, immediately, or the thread dies:

> Author here. I kept transcripts of ~2 months of agent sessions across 56 repos and counted what the
> agent did that was not the task: 16,315 `cd && grep` calls rediscovering where things live, 1,115
> retyped `psql` connection strings, 825 hand-written `ssh` invocations. All of it paid in context,
> every session.
>
> The fix in each case was to write the answer down where the next session reads it at startup: a
> 20-line runbook in `AGENTS.md`, a read-only Postgres inspector that refuses non-SELECT before it
> connects, and an SSH wrapper with hard timeouts. Three of the twelve skills; the rest are the same
> shape. MIT, one command: `npx skills add Appit-labs/appit-skills`
>
> Happy to talk about the counting method — that is the part I would want to see myself.

Do **not** submit the Turnstile post to HN as well in the same week. One story.

## 2. Reddit — three subs, three different first lines

r/ExperiencedDevs (the measurement), r/devops (the CI + SSH angle), r/ClaudeAI (the collection).
No links in the title, no "I built", no emoji; many subs auto-remove low-karma accounts, so post
where you have history first.

<details><summary>r/ExperiencedDevs</summary>

**Title:** I counted what my coding agent did that wasn't the task: 16,315 grep calls, 1,115 retyped psql commands

Body: paste the article, then — "Curious whether others see the same ratio or whether this is an
artifact of how I work. The counting script is a few hundred lines of transcript grep if anyone
wants it."

</details>

<details><summary>r/devops</summary>

**Title:** Read-only Postgres inspection from an agent: 34 commands, refuses anything that isn't a SELECT

Body: lead with the guard rail (`default_transaction_read_only=on`, `statement_timeout=15s`, refusal
before connecting), then the command list, then the repo. This sub cares about the safety property
and will test it.

</details>

<details><summary>r/ClaudeAI</summary>

**Title:** Twelve practical skills for real engineering work (MIT) — browser QA, CI triage, Postgres, SSH, runbooks

Body: the table from the README, one line each, plus `npx skills add Appit-labs/appit-skills`.
This sub installs things; keep it short and put the command above the fold.

</details>

## 3. dev.to — the second post

```bash
DEVTO_API_KEY=… launch/post-to-devto.sh launch/crawls-post.md
```

Only after the HN thread has comments: the article then has a discussion to link to, which is what
dev.to's ranking reads. Cross-post anywhere else with `canonical_url` set to the dev.to URL.

## 4. X / LinkedIn — one post, one number

> 16,315 `cd && grep` calls across 56 repos. That's what my coding agent spent re-learning where
> things live — not doing the task. Writing it into `AGENTS.md` once cut it to ~0.
>
> Twelve MIT skills that each remove one of these taxes: github.com/Appit-labs/appit-skills

Attach `assets/hero-live-qa.gif`. One link, no thread, no hashtags.

## 5. awesome-lists — after the first thread, not before

Both of these gate on social proof, so filing earlier burns the one PR they will read.

| list | where to add | line to add |
| --- | --- | --- |
| [ComposioHQ/awesome-claude-skills](https://github.com/ComposioHQ/awesome-claude-skills) | the skills table, alphabetical | `` - [Appit skills](https://github.com/Appit-labs/appit-skills) — twelve practical skills for engineering work: live browser QA, CI triage, read-only Postgres inspection, repo runbooks, hang-proof SSH, Trello tickets, cloud browsers, Blender, code scan, release, Hermes. MIT. `` |
| [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) | their issue-based submission flow | link + one sentence; they ask for a screenshot, use `assets/hero-live-qa.gif` |

## 6. What not to do

- Do not open twelve PRs, one per skill. One entry for the collection.
- Do not submit to HN twice in a month, and never on a weekend afternoon (US) — Tue–Thu 13:00–15:00 UTC.
- Do not buy installs, star rings, or `npx skills find` seeding beyond the one honest install.
  skills.sh ranks by installs; a spike followed by a flatline is visible and reads as fraud.
- Do not post the same text to three subs in ten minutes. Rewrite the first two paragraphs each time.
