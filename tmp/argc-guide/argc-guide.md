---
name: arch-system-guide
description: Manages and improves the user's Arch Linux system over time by crawling the live system, pulling signals from the broader Linux community (forums, GitHub dotfiles, Arch wiki, Reddit, blogs), and surfacing exactly 5 actionable improvement ideas per session. Use this skill whenever the user mentions their Arch system, wants to audit or improve their Linux setup, asks about system config, packages, services, dotfiles, or says anything like "let's do a system session", "check my arch setup", "what can I improve", or "continue the system audit". Also trigger when the user shares system output like `pacman -Q`, `systemctl`, `journalctl`, or similar.
---

# Arch System Guide

A living, session-based skill for incrementally auditing and improving an Arch Linux system by combining live system inspection with community intelligence.

## Core Loop (Every Session)

1. **Check state file** — load `~/.arch-guide/state.json` to see coverage history and backlog
2. **Pick an area** — rotate through uncovered or stale areas (see Areas below)
3. **Crawl the system** — run relevant commands for the chosen area
4. **Pull community signals** — web search + Arch wiki + GitHub dotfiles + forums for that area
5. **Cross-reference user's docs** — check GitHub repos and local docs if accessible
6. **Surface exactly 5 ideas** — specific, actionable, ranked by impact
7. **Update state file** — log this session's area, timestamp, and any ideas accepted/deferred

---

## System Areas (rotate through these)

Track which have been visited in state.json. Prefer unvisited or long-unvisited areas.

| Area              | Key Commands                                                                 |
| ----------------- | ---------------------------------------------------------------------------- |
| Packages          | `pacman -Qdt` (orphans), `pacman -Qe` (explicit), `pacman -Qs`               |
| Services          | `systemctl list-units --failed`, `systemctl list-unit-files --state=enabled` |
| Boot & kernel     | `bootctl status`, `mkinitcpio -L`, `uname -r`, `journalctl -b -p err`        |
| Security          | `ss -tulnp`, `systemctl status firewalld/ufw`, `sudo -l`, file perms         |
| Performance       | `systemd-analyze blame`, `free -h`, `df -h`, `iotop`, `htop` snapshot        |
| Dotfiles & config | `ls ~/.config`, diff against community dotfiles patterns                     |
| AUR & updates     | `yay -Qua` or `paru`, news.archlinux.org, recent breaking changes            |
| Storage & fs      | `df -h`, `lsblk`, `btrfs` subvolumes if applicable, TRIM status              |
| Network           | resolv.conf, DNS, NetworkManager vs systemd-networkd, firewall rules         |
| Logs & monitoring | `journalctl --disk-usage`, log rotation, any monitoring tools                |

---

## Community Signal Sources

For each session, pull from at least 2–3 of these:

- **Arch wiki** — use MCP if available, otherwise web search `site:wiki.archlinux.org <area>`
- **r/archlinux** — search for recent threads on the area (last 6–12 months)
- **GitHub dotfiles** — search `dotfiles arch <area>` or `awesome-<area>` lists; look for patterns across popular repos
- **Arch forums** — `site:bbs.archlinux.org <area>`
- **Linux blogs/Power users** — search `arch linux <area> tips <year>` to find what experienced users recommend
- **Other distro communities** — NixOS, Gentoo, and Void users often have transferable ideas

The goal is to understand what the broader Linux community considers best practice for this area, then check whether the user's system reflects it.

---

## The 5 Ideas Format

Each session ends with exactly 5 ideas. Format them like this:

```
## Session: <Area> — <Date>

### Idea 1: <Short title>
**What**: One sentence on what to do
**Why**: Why the community recommends this / what problem it solves
**Source**: Where you found this (wiki, repo, forum thread)
**Commands / steps**:
  <specific commands or config snippet>
**Effort**: low / medium / high
**Impact**: low / medium / high

[repeat for 2–5]
```

Mix effort levels — don't give the user 5 high-effort ideas in one session. Aim for at least 1–2 quick wins.

---

## State File: `~/.arch-guide/state.json`

Create if missing. Update after every session.

```json
{
  "last_updated": "2025-01-01",
  "sessions": [
    {
      "date": "2025-01-01",
      "area": "packages",
      "ideas_surfaced": 5,
      "ideas_accepted": ["Remove orphans", "Switch to paru"],
      "ideas_deferred": ["Audit AUR packages"]
    }
  ],
  "area_last_visited": {
    "packages": "2025-01-01",
    "services": null,
    "boot": null
  },
  "system_profile": {
    "distro": "Arch Linux",
    "kernel": null,
    "de_wm": null,
    "aur_helper": null,
    "init": "systemd",
    "notes": []
  },
  "backlog": []
}
```

Fill in `system_profile` fields as you discover them. This becomes a living record of the system.

---

## System Profile Doc

Also maintain `~/.arch-guide/profile.md` — a human-readable, growing document that captures what's installed, how things are configured, and notable choices. Update it each session with what you discover. This is the "documentation of what is" part of the skill.

---

## Session Opener

When starting a session, briefly tell the user:

- Which area you're covering today (and why — e.g., "haven't visited this one yet")
- What you're about to inspect
- Estimated number of commands you'll run

Then run the commands, do the research, and present the 5 ideas. Keep the research visible but summarized — don't dump raw output unless the user asks.

---

## User Docs Integration

If the user has GitHub repos or local docs, check them:

- Look for existing dotfiles, install scripts, notes
- Note conflicts or redundancies with community best practices
- Reference them when relevant in ideas ("you already do X in your dotfiles, but community recommends Y instead")

Ask the user at first session for their GitHub handle and any relevant repo names. Store in state.json.

---

## First Session Bootstrap

If state.json doesn't exist:

1. Create `~/.arch-guide/` directory
2. Ask the user 3 quick questions: GitHub handle, AUR helper (yay/paru/etc), DE or WM
3. Run a broad system snapshot: `uname -r`, `pacman -Q | wc -l`, `systemctl list-units --failed`
4. Pick the area with the most obvious quick wins for session 1 (usually packages or services)
5. Proceed with the normal loop
