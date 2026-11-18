# Post 1 — the finding (Hacker News / r/webdev / r/ClaudeAI)

**Title:** Your Cloudflare Turnstile may never be issuing a token — here is the one-liner that tells you

---

I was writing browser-QA automation and kept hitting contact forms where:

- the Turnstile widget was in the DOM and marked rendered,
- its challenge iframe request returned HTTP 200,
- and `cf-turnstile-response` stayed empty. Forever.

That is not a bot check failing. It is no token being issued at all, which means **no real user can
submit that form either** — and nothing in the page throws.

Paste this in devtools on any page with a Turnstile widget:

```js
JSON.stringify({
  widgets: document.querySelectorAll('.cf-turnstile').length,
  token: (document.querySelector('input[name="cf-turnstile-response"]') || {}).value?.length ?? null
})
```

`widgets: 1, token: 0` after 15 seconds means you are in this state. I reproduced it on a live site
in both headless and headed Chrome, with a real (non-automated) user agent.

The two causes I found, in order of likelihood:

1. **The sitekey is not bound to that hostname** (staging key on production, or an allowed-domains
   list that does not include the apex/www variant you actually serve).
2. **The form never calls `reset()`** after a failed submit. Turnstile tokens are single-use; a retry
   without reset leaves the field empty and the backend rejects it as if you were a bot.

A related thing worth knowing if you test such forms: Cloudflare's documented **test sitekey**
`1x00000000000000000000AA` mints a token with zero interaction, so you can exercise the widget on
staging without a solver and without touching production keys. The token is only accepted end to end
if the backend verifies with the matching test secret `1x0000000000000000000000000000000AA` — that is
the part people forget, and swapping production keys to make a test pass is how you ship a hole.

If you want the whole procedure (detect → read the token → the test-key path → the line you do not
cross on sites you do not own), it is in the `live-qa` skill of the collection I published:
github.com/Appit-labs/live-qa — MIT, works in Claude Code, Codex, pi and Cursor.

Not a solver. It will not bypass anything on a site you do not own, and it says so in the skill.
