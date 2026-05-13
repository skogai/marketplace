---
title: multi-repo
type: note
permalink: skogai/skills/skogai-git/workflows/multi-repo
---

# Multi-Repo Management with gita

Manage multiple repositories as a unified ecosystem.

\<required_reading>

- skogai-worktrunk/SKILL.md (if unfamiliar with gita commands)
- references/tool-selection.md (to understand when to use gita vs wt) \</required_reading>

<process>

## 1. Add Repos to gita

```bash
# Add single repo
gita add ~/projects/my-repo

# Add multiple repos
gita add ~/projects/repo1 ~/projects/repo2

# Add all repos in directory
gita add ~/projects/*
```

## 2. Check Status

```bash
# List all repos with status
gita ll

# Detailed git status
gita st
```

Status indicators:

- `*` - Uncommitted changes
- `?` - Untracked files
- `↑` - Ahead of remote
- `↓` - Behind remote

## 3. Sync All Repos

```bash
# Fetch updates
gita fetch

# Pull all repos
gita pull

# Push all repos
gita push
```

## 4. Organize with Groups

```bash
# Create groups by project area
gita group add backend api-service db-service auth-service
gita group add frontend web-app mobile-app

# List groups
gita group ls

# Work with specific group
gita ll backend
gita pull frontend
```

## 5. Run Commands Across Repos

```bash
# Git commands
gita super git log -1 --oneline
gita super git checkout develop
gita super git stash

# Shell commands
gita shell npm install
gita shell ./setup.sh
```

## 6. Remove Repos

```bash
# Stop tracking (doesn't delete)
gita rm repo-name
```

</process>

\<common_patterns>

## Daily Sync Routine

```bash
gita fetch           # Check what's new
gita ll              # Review status
gita pull            # Pull updates
```

## Find Dirty Repos

```bash
# Repos with uncommitted changes
gita ll | grep '\*'

# Repos with untracked files
gita ll | grep '?'

# Repos ahead of remote
gita ll | grep '↑'
```

## Ecosystem-Wide Branch Switch

```bash
# Switch all repos to main
gita super git checkout main

# Switch all repos to develop
gita super git checkout develop
```

## Bulk Cleanup

```bash
# Clean all repos
gita super git clean -fd

# Prune remote branches
gita super git remote prune origin
```

## Combined with wt

```bash
# Overview with gita
gita ll

# One repo needs feature work
cd ~/projects/my-repo
wt switch --create feature/x

# Back to overview
gita ll
```

\</common_patterns>

\<success_criteria>

- All repos added to gita
- Groups organized by project area
- Status visible at a glance
- Sync operations work across all repos \</success_criteria>
