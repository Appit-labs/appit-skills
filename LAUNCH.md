# Launch: what to post, where, and in what order

State on 2026-11-18 (verified, not assumed):

| | |
| --- | --- |
| Public repos | 13 under [Appit-labs](https://github.com/Appit-labs): 12 skills + this catalog |
| Org profile | `.github` renders the org landing page, transparent wordmark, avatar ready to upload |
| Claude Code install | `claude plugin marketplace add Appit-labs/appit-skills` → install → *Skills (1)* — tested |
| Any-agent install | `npx skills add Appit-labs/live-qa` installs into `.claude/skills`, `.agents/skills` — tested |
| npm package | `npm pack` builds a 4.2 MB tarball with **all 12 skills**; `publish.sh --dry-run` green until auth |
| Blocked on you | `npm login` (publish), org avatar upload (no API), paid Claude plan (Anthropic directory) |

## Remaining steps, in order

### 1. npm publish — one command, unlocks the gallery

```bash
cd work/appit-skills
bash scripts/publish.sh          # preflight: auth, keyword, marketplace validation, 12 skills in the tarball
```

That puts all twelve in **[pi.dev/packages](https://pi.dev/packages)**, which indexes npm by the
`pi-package` keyword. It is the only channel with a public download counter, so it is also the
only honest way to answer "how many people use this".

Trim first if 4.2 MB feels heavy: drop `assets` from `package.json#files` and the demos stop
shipping with the npm package (they still show on GitHub).

### 2. Get past the two-star floor

[SkillsMP](https://skillsmp.com/) auto-crawls public repos but filters out anything under 2 stars,
and `skills.sh` indexes a repo the first time someone runs `npx skills add`. So: ask three people
who use agents to install one skill, and the crawlers pick you up. No submission forms exist for
either.

### 3. Publish the post people will actually read

Not "12 skills". One finding:

> **Your Cloudflare Turnstile may never be issuing a token — here is the one-liner that tells you**

`JSON.stringify({widgets: document.querySelectorAll('.cf-turnstile').length, token: (document.querySelector('input[name="cf-turnstile-response"]')||{}).value?.length ?? null})`

`widgets: 1, token: 0` after 15 seconds means the widget is not issuing tokens, so no user can
submit that form — and the fix is in the sitekey/action binding, not the browser. That is a real
finding, reproduced on a live site, with a one-line check anyone can run. It is the post that
earns stars; the repo is what people find afterwards.

Week 3 post, for engineers: **"16,315 `cd && grep` calls: what an agent wastes re-learning your repo"**
— the measured origin of `repo-runbook`, `pg-inspect` and `remote-exec`.

### 4. Listings that need a human

| Where | Requirement | Effort |
| --- | --- | --- |
| [Anthropic plugin directory](https://claude.ai/directory/manage) | paid Claude plan; README ≥ 40 words and a licence (both already there) | 20 min |
| [awesome-claude-skills](https://github.com/ComposioHQ/awesome-claude-skills) | one README line, one PR — 1,600 open PRs, and they now ask for social proof, so file after the first post | 10 min |
| Org avatar | `Appit-labs/.github/profile/assets/appit-avatar.png` → Settings → Profile | 1 min |

### 5. What to do *not* do

- Do not post twelve repos in one go. Nine-at-once reads as spam; one sharp finding reads as expertise.
- Do not claim numbers you have not run. Every figure in these READMEs came from a session log or a
  test in the repo.
- Do not add a skill without a demo. Three of twelve still have no GIF (`code-scan`, `release`,
  `hermes-setup` — built after the demo pass); they will convert worse until they have one.

## The one thing that decides whether this works

Answer the first twenty comments on whatever you post. Stars come from that thread, not from the
post. Everything above is just getting people into the thread.
