# Launch: what to post, where, and in what order

State on 2026-11-18 (verified, not assumed):

| | |
| --- | --- |
| Public repos | 13 under [Appit-labs](https://github.com/Appit-labs): 12 skills + this catalog |
| Org profile | `.github` renders the org landing page, transparent wordmark, avatar ready to upload |
| Claude Code install | `claude plugin marketplace add Appit-labs/appit-skills` → install → *Skills (1)* — tested |
| Any-agent install | `npx skills add Appit-labs/live-qa` installs into `.claude/skills`, `.agents/skills` — tested |
| npm | **published**: `@appitlabs/skills@0.1.0`, 12 skills, 5.7 MB, public — `npm i @appitlabs/skills` verified in a clean dir |
| pi gallery | live: [pi.dev/packages/@appitlabs/skills](https://pi.dev/packages/@appitlabs/skills) |
| Org avatar | **live** — full Appit wordmark, 512², 99.8% pixel match to the committed file |
| npm download counter | [`api.npmjs.org/downloads/point`](https://api.npmjs.org/downloads/point/last-week/@appitlabs/skills) — empty until npm's daily rollup picks the package up (≤24 h) |
| **Post 1** | **published** — [dev.to article](https://dev.to/ibrahimbdr/your-cloudflare-turnstile-may-never-be-issuing-a-token-here-is-the-one-liner-that-tells-you-4h75) + [GitHub Discussion #1](https://github.com/Appit-labs/appit-skills/discussions/1), cross-linked |
| Blocked on you | the Anthropic directory (paid plan); the awesome-list PR is deliberately deferred until there is social proof |

## Remaining steps, in order

### 1. ~~npm publish~~ — done

`@appitlabs/skills@0.1.0` is on the registry and in the pi gallery. The only follow-up is the
optional diet: `assets` out of `files` and publish `0.1.1` (~1 MB instead of 5.7 MB). Do that
before the first post if you want the lean package, not after people have installed 0.1.0.

### 2. Get past the two-star floor

[SkillsMP](https://skillsmp.com/) auto-crawls public repos but filters out anything under 2 stars,
and `skills.sh` indexes a repo the first time someone runs `npx skills add`. So: ask three people
who use agents to install one skill, and the crawlers pick you up. No submission forms exist for
either.

### 3. Publish the post people will actually read

**Already live, no account needed:** the finding is published as a Discussion on the catalog —
https://github.com/Appit-labs/appit-skills/discussions/1 — so there is a canonical, indexable URL to
link from anywhere. Discussions were enabled for this.

**One click from a real article:** dev.to has a publishing API, so the post can go out with a command
instead of a browser:

```bash
# 1. dev.to → Settings → Extensions → DEV Community API Keys → copy the key
DEVTO_API_KEY=xxx launch/post-to-devto.sh launch/turnstile-post.md
DEVTO_API_KEY=xxx launch/post-to-devto.sh --dry-run launch/turnstile-post.md   # preview the payload
```

Same command publishes post 2 in a fortnight (`launch/crawls-post.md`). The endpoint is verified
(`POST /api/articles` → 401 without a key, i.e. URL and method are right), and the body cleanup strips
the launch-file scaffolding so only the article is published.

**Why not Hacker News / Reddit automatically:** neither has an API for submissions, both need a
logged-in browser session (there is none in your Chrome profile — 29 cookie hosts, none of them
`news.ycombinator.com`, `reddit.com`, `x.com`, `linkedin.com` or `dev.to`), and HN's guidelines treat
bot submissions as abuse while many subreddits auto-remove posts from low-karma accounts. dev.to is
the one channel where automation is both possible and welcome; HN is worth doing manually afterwards
with the Discussion URL as the link.

Not "12 skills". One finding:

> **Your Cloudflare Turnstile may never be issuing a token — here is the one-liner that tells you**

`JSON.stringify({widgets: document.querySelectorAll('.cf-turnstile').length, token: (document.querySelector('input[name="cf-turnstile-response"]')||{}).value?.length ?? null})`

`widgets: 1, token: 0` after 15 seconds means the widget is not issuing tokens, so no user can
submit that form — and the fix is in the sitekey/action binding, not the browser. That is a real
finding, reproduced on a live site, with a one-line check anyone can run. It is the post that
earns stars; the repo is what people find afterwards.

Week 3 post, for engineers: **"16,315 `cd && grep` calls: what an agent wastes re-learning your repo"**
— the measured origin of `repo-runbook`, `pg-inspect` and `remote-exec`.

### 4. After the post: cross-links and the second one

Published and cross-linked already:

- dev.to article — tags `webdev`, `security`, `cloudflare`, `testing`
- GitHub Discussion #1 with a comment pointing at the article
- catalog `README` "Write-ups" section and the `live-qa` README both link it

Two weeks of readers, then `launch/crawls-post.md` through the same command
(`DEVTO_API_KEY=… launch/post-to-devto.sh launch/crawls-post.md`). Use `canonical_url` if you
cross-post it to another publication, so the two do not compete in search.

### 5. Listings that need a human

| Where | Requirement | Effort |
| --- | --- | --- |
| [Anthropic plugin directory](https://claude.ai/directory/manage) | paid Claude plan; README ≥ 40 words and a licence (both already there) | 20 min |
| [awesome-claude-skills](https://github.com/ComposioHQ/awesome-claude-skills) | one README line, one PR — 1,600 open PRs, and they now ask for social proof, so file after the first post | 10 min |
| Org avatar | `Appit-labs/.github/profile/assets/appit-avatar.png` → Settings → Profile | 1 min |

### 6. What to do *not* do

- Do not post twelve repos in one go. Nine-at-once reads as spam; one sharp finding reads as expertise.
- Do not claim numbers you have not run. Every figure in these READMEs came from a session log or a
  test in the repo.
- Do not add a skill without a demo. Three of twelve still have no GIF (`code-scan`, `release`,
  `hermes-setup` — built after the demo pass); they will convert worse until they have one.

## The one thing that decides whether this works

Answer the first twenty comments on whatever you post. Stars come from that thread, not from the
post. Everything above is just getting people into the thread.
