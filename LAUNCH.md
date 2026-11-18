# Launch: what to post, where, and in what order

The order matters. Posting before the repos are public, before the demo exists, or before the
install command is verified wastes the one shot each community gives a project.

Current state (verified 2026-11-18):

- 9 skill repos + this marketplace are **public** under `ibrahimbdr`, with topics set.
- `claude plugin marketplace add ibrahimbdr/appit-skills` → install → skill listed: **verified**.
- `npx skills add ibrahimbdr/live-qa` → installs into `.claude/skills`, `.agents/skills`: **verified**.
- `npm pack` of this catalog builds a 488 KB tarball with all 9 skills: **verified**.
- Blocked on you: the `appit-labs` org (web UI only), npm login (`npm publish`), a paid Claude plan
  for the Anthropic directory.

## Week 1 — become indexable

1. `npm org create appit-labs` (free) → `npm publish --access public` in this directory.
   That single step lists all nine skills in the pi package gallery.
2. Ask three people who use agents to run `npx skills add ibrahimbdr/live-qa`. Each run feeds
   skills.sh's index.
3. Get past **2 stars** on `live-qa` — that is SkillsMP's crawler floor. Post the *finding*, not the
   repo (see below), and the stars follow.

## Week 2 — the post that earns attention

Do not lead with "9 new skills". Lead with a bug anyone shipping a form can check in ten seconds:

> **Title (HN / r/ClaudeAI / r/webdev):** Your Cloudflare Turnstile may never be issuing a token —
> here's the one-liner that tells you

**Body sketch**

```
While building browser-QA automation I kept hitting forms where the widget rendered, the challenge
iframe loaded with 200, and `cf-turnstile-response` stayed empty. Not a bot check failing — no token
issued at all, so the form cannot be submitted by a real user either.

Paste this in devtools on any page with a Turnstile widget:

  JSON.stringify({
    widgets: document.querySelectorAll('.cf-turnstile').length,
    token: (document.querySelector('input[name="cf-turnstile-response"]')||{}).value?.length ?? null
  })

widgets:1, token:0 after 15s in both headless and headed = your sitekey/action binding is wrong,
or the form never calls reset() after a retry (tokens are single-use).

Two more things I learned doing this, both in the repo:
- Cloudflare's documented test sitekey 1x00000000000000000000AA mints a token with zero interaction —
  so you can test your captcha gate on staging without a solver and without touching production keys.
- The token is worthless server-side unless the backend verifies with the matching test secret,
  which is the part everyone forgets.

Repo (MIT, works in Claude Code / Codex / pi / Cursor): github.com/ibrahimbdr/live-qa
```

Then the honest footnote in comments: what it does not do (no solver, no bypass on sites you do not
own, no headless fingerprint patching).

## Week 3 — the second post, for engineers

**Title:** 16,315 `cd && grep` calls: what an agent actually wastes re-learning your repo

- Claim: a 20-line runbook in `AGENTS.md` removed the biggest token sink in my own sessions.
- Show the measured numbers (16,315 crawls, 1,115 retyped `psql` commands, 825 hand-written `ssh`
  invocations) and the scripts that replaced them.
- Link `repo-runbook`, `pg-inspect`, `remote-exec` — the three that came from those numbers.

## Week 4+ — listings

| Where | What to do |
| --- | --- |
| [skillsmp.com](https://skillsmp.com/) | nothing — auto-crawls public repos with ≥2 stars |
| [skills.sh](https://skills.sh) | nothing — indexed by `npx skills add` usage (already triggered once) |
| [pi.dev/packages](https://pi.dev/packages) | the `npm publish` above is the only requirement |
| Anthropic plugin directory | `claude.ai/directory/manage` — needs a paid Claude plan; README ≥40 words and a license are already there |
| [ComposioHQ/awesome-claude-skills](https://github.com/ComposioHQ/awesome-claude-skills) | one PR, one line; they now ask for social proof, so file it after the first post |
| Codex / Cursor communities | no marketplace; post the copy-paste install block |

## Rules that decide whether this works

- **One skill per post.** Nine at once reads as spam; one sharp finding reads as expertise.
- **The demo is the pitch.** Every README that converts starts with a moving image in the first
  screenful. `live-qa`, `pg-inspect` and `repo-runbook` have one; the rest need one before promotion.
- **Never post a claim you have not run.** Every number in these READMEs came from the user's own
  session history or from a test in this repo.
- **Answer the first 20 comments.** That is where stars come from, not from the post itself.
