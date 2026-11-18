# Move the nine skill repos into the Appit organisation

Checked 2026-11-18.

> **Current state:** the org does not exist yet, so the repos are **public under `Appit-labs`** and
> the catalog points there — everything in `LAUNCH.md` works today. When you create `appit-labs`,
> run `scripts/migrate-to-org.sh --yes` and it transfers the repos, rewrites every `Appit-labs/`
> reference (README, `plugin.json`, `package.json`, marketplace sources) and pushes.

| Question | Answer |
| --- | --- |
| Can an organisation be created for free? | **Yes.** GitHub Free for organizations costs $0: unlimited public and private repos, unlimited collaborators, 500 MB Actions storage, and **$12 of included compute usage per month** (Actions on private repos draws on that credit; Actions on public repos is free). |
| Is the name `Appit` available? | **No.** `github.com/appit` is taken by a **user account**, and users + orgs share one namespace, so `Appit` cannot be registered as an org. Free alternatives, all verified available: **`appit-labs`**, `appit-hq`, `appit-labs`, `appitdev`. This repo assumes `appit-labs`. |
| Does transferring keep history? | Yes: commits, issues, PRs, stars, watchers, forks and releases move with the repo. GitHub leaves a permanent redirect from the old URL. **Not transferred:** Actions secrets (re-add them), and personal forks of the repo are unlinked. |
| What does it cost to move? | Nothing, and it is reversible (`gh api -X POST repos/Appit-labs/<repo>/transfer -f new_owner=Appit-labs`). |

## Do it in one command

Everything below is automated in `scripts/migrate-to-org.sh` (dry run by default):

```bash
# after creating the org and running `gh auth refresh -h github.com -s admin:org`
scripts/migrate-to-org.sh            # prints the plan, changes nothing
scripts/migrate-to-org.sh --yes      # transfer, repoint, push, set topics
scripts/migrate-to-org.sh --yes --public   # ... and flip visibility (history becomes public)
```

## 1. Create the organisation (web UI, 1 minute)

<https://github.com/organizations/new> → **Free** → name `appit-labs` → contact email → create.
There is no API for creating an organisation; the web form is the only route.

Then, if you want the skills to be adoptable at all:

```bash
# from a machine authenticated as the org owner
gh auth refresh -h github.com -s admin:org
```

## 2. Push the central marketplace repo

```bash
gh repo create Appit-labs/appit-skills --public --source=. \
  --remote=origin --push \
  --description "Agent skills marketplace: browser QA, tickets, databases, CI triage, Blender"
```

Validate the catalog before anyone else does (this is the same check users hit):

```bash
claude plugin validate .claude-plugin/marketplace.json --strict
```

## 3. Transfer the nine repos

```bash
for r in live-qa ci-triage pg-inspect repo-runbook remote-exec trello-tickets \
         cloud-browser open-design blender-pipeline; do
  gh api -X POST "repos/Appit-labs/$r/transfer" -f new_owner=appit-labs
done
```

Re-point your local clones afterwards (`git remote set-url origin git@github.com:Appit-labs/<repo>.git`);
old URLs keep redirecting, so nothing breaks immediately.

## 4. Make them discoverable

**Nothing on this page matters while the repos are private.** Every crawler (skills.sh, SkillsMP,
the pi gallery, awesome lists) indexes public repositories only, and SkillsMP additionally filters
repos under 2 stars. Going public is the single biggest lever, and it needs your deliberate go-ahead:
code, history and any secret ever committed become public at that moment.

```bash
# run a secret scan over the full history first — this must come back empty
# (gitleaks if you have it: `gitleaks detect --source <mirror> -v`)
for r in live-qa ci-triage pg-inspect repo-runbook remote-exec trello-tickets cloud-browser open-design blender-pipeline; do
  git clone -q --mirror "git@github.com:Appit-labs/$r.git" "/tmp/scan-$r" 2>/dev/null
  hits=$(git -C "/tmp/scan-$r" log -p --all 2>/dev/null \
    | grep -acE '(bu_|sk-|ghp_|AKIA|xox[baprs]-)[A-Za-z0-9_\-]{12,}|-----BEGIN [A-Z ]*PRIVATE KEY')
  echo "$r: $hits suspicious match(es) in history"
done

# then, per repo
gh repo edit Appit-labs/live-qa --visibility public --accept-visibility-change-consequences

# topics are how directory crawlers match you
gh repo edit Appit-labs/live-qa \
  --add-topic agent-skill,agent-skills,claude-code-plugin,claude-skills,codex,pi-package,browser-testing,qa
```

Suggested topics per skill:

| Repo | Topics |
| --- | --- |
| live-qa | `agent-skill,claude-code-plugin,codex,qa,browser-testing,playwright,e2e,turnstile` |
| ci-triage | `agent-skill,ci,github-actions,gitlab-ci,devops,logs` |
| pg-inspect | `agent-skill,postgres,database,sql,read-only,explain` |
| repo-runbook | `agent-skill,agents-md,onboarding,monorepo,dx` |
| remote-exec | `agent-skill,ssh,devops,remote,provisioning` |
| trello-tickets | `agent-skill,trello,kanban,project-management,api` |
| cloud-browser | `agent-skill,browser,cloud,stealth,agent-browser` |
| open-design | `agent-skill,open-design,monorepo,pnpm,design-system` |
| blender-pipeline | `agent-skill,blender,3d,mcp,modeling,export` |

## 5. Publish to the registries that actually send traffic

| Registry | Route | Gate |
| --- | --- | --- |
| **npm → pi.dev/packages** | `npm org create appit-labs` (free for public packages), then `npm publish --access public` in `appit-skills/` with its `prepack` sync | `pi-package` keyword; the pi gallery indexes npm only, so git installs never appear |
| **skills.sh** | no submission — indexed the first time anyone runs `npx skills add Appit-labs/live-qa` | public repo + valid `SKILL.md` |
| **SkillsMP** | no submission — auto-crawls public GitHub | public repo, **≥ 2 stars**, quality filter |
| **Claude Code marketplace** | self-hosted via this repo (`.claude-plugin/marketplace.json`) | none |
| **Anthropic plugin directory** | submit at <https://claude.ai/directory/manage> from the repo | **paid Claude plan**, README ≥ 40 words, a license, and their security scan |
| **awesome-claude-skills** (ComposioHQ) | fork + one README entry + PR | 1,600+ open PRs; the list now asks for "social proof", so submit after you have stars |
| **Codex / Cursor** | no marketplace; README copy instructions | none |
