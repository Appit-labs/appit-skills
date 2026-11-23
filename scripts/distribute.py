#!/usr/bin/env python3
"""Keep the collection discoverable, without asking anyone for a favour.

    python3 scripts/distribute.py smoke     # does `npx skills add` still install all twelve?
    python3 scripts/distribute.py index     # put this source into the skills.sh index
    python3 scripts/distribute.py radar     # where do we rank for the queries people actually type?
    python3 scripts/distribute.py all

Why three commands and not one:

  * `smoke` is the funnel. The first version of this repo shipped no SKILL.md, so the
    install command the README advertised returned "No valid skills found" to every
    reader. Nothing else matters if this fails.
  * `index` is the entry. skills.sh search is an Algolia index fed by install
    telemetry — not a GitHub crawl. An install from a machine you own is how the
    registry learns a source exists; the org was absent from search for that reason.
  * `radar` is the scoreboard. It records the queries your users type and who currently
    owns them, so "are we getting anywhere" is a table, not a feeling.

Nothing here inflates a number: one install, from this machine, is the same event a
user produces. The radar is read-only.
"""
from __future__ import annotations

import json
import shutil
import subprocess
import sys
import tempfile
import urllib.parse
import urllib.request
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCE = "Appit-labs/appit-skills"
API = "https://skills.sh/api/search"
OUT = ROOT / "distribution" / "radar.md"

# The query a user actually types, per skill. Keep these in the user's words, not ours.
QUERIES = {
    "live-qa": "browser qa",
    "ci-triage": "ci failed",
    "pg-inspect": "postgres inspect",
    "repo-runbook": "runbook",
    "remote-exec": "ssh",
    "trello-tickets": "trello",
    "cloud-browser": "cloud browser",
    "open-design": "open-design",
    "blender-pipeline": "blender",
    "code-scan": "dead code",
    "release": "changelog",
    "hermes-setup": "hermes agent",
}


def search(query: str, owner: str | None = None) -> list[dict]:
    url = f"{API}?q={urllib.parse.quote(query)}"
    if owner:
        url += f"&owner={urllib.parse.quote(owner)}"
    req = urllib.request.Request(url, headers={"User-Agent": "appit-skills-radar"})
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            return json.loads(r.read()).get("skills", [])
    except Exception as e:  # network flake must not fail the whole run
        print(f"  ! {query}: {e}", file=sys.stderr)
        return []


def cmd_smoke() -> int:
    """Install the catalog the way a stranger would, and count what lands."""
    tmp = Path(tempfile.mkdtemp(prefix="appit-smoke-"))
    try:
        subprocess.run(["npx", "-y", "skills", "add", SOURCE, "-y"], cwd=tmp,
                       capture_output=True, text=True, timeout=600)
        found = sorted(p.parent.name for p in tmp.rglob("SKILL.md"))
        print(f"smoke: {len(found)} skills installed {found}")
        if len(found) < 12:
            print("FAIL: `npx skills add` no longer installs the collection", file=sys.stderr)
            return 1
        return 0
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def cmd_index() -> int:
    """Install globally once, so this source is registered in the skills.sh index."""
    r = subprocess.run(["npx", "-y", "skills", "add", SOURCE, "-g", "-y"],
                       capture_output=True, text=True, timeout=600)
    ok = "Installed" in r.stdout + r.stderr
    print("index: install sent" if ok else "index: install failed — see output below")
    if not ok:
        print(r.stdout[-800:], r.stderr[-800:], file=sys.stderr)
    return 0 if ok else 1


def cmd_radar() -> int:
    rows, mine = [], 0
    for skill, query in QUERIES.items():
        hits = search(query)
        ours = [h for h in hits if h.get("source") == SOURCE]
        own = hits.index(ours[0]) + 1 if ours else 0
        mine += 1 if ours else 0
        top = ", ".join(f"{h['source']} ({h.get('installs', 0):,})" for h in hits[:3]) or "—"
        rows.append((skill, query, own, sum(h.get("installs", 0) for h in ours), top))
        print(f"  {skill:<18} q={query:<18} rank={own or '-':<3} top: {top}")

    OUT.parent.mkdir(exist_ok=True)
    now = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
    lines = [f"# Distribution radar — {now}", "",
             f"Indexed for `{SOURCE}` on {mine}/{len(QUERIES)} tracked queries.",
             "Ranking is by installs, so this table moves only when people install.", "",
             "| skill | query | our rank | our installs | top three for that query |",
             "| --- | --- | --- | --- | --- |"]
    for skill, query, own, installs, top in rows:
        lines.append(f"| `{skill}` | {query} | {own or '—'} | {installs} | {top} |")
    previous = OUT.read_text().splitlines() if OUT.exists() else []
    before = [l for l in previous if l.startswith("| `")]
    after = lines[-len(rows):]
    changed = before and before != after
    OUT.write_text("\n".join(lines) + "\n")
    print(f"radar: {OUT.relative_to(ROOT)} written ({mine}/{len(QUERIES)} indexed)")
    if changed:
        print("radar: CHANGED since the last run")
    return 0  # not indexed yet is a fact to report, not a failure to block on


def main(argv: list[str]) -> int:
    cmd = argv[1] if len(argv) > 1 else "all"
    if cmd in ("smoke", "all"):
        rc = cmd_smoke()
        if rc:
            return rc
    if cmd in ("index", "all"):
        cmd_index()
    if cmd in ("radar", "all"):
        return cmd_radar()
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
