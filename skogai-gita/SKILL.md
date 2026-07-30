---
name: skogai-gita
description: Multi-repo git management with the gita CLI. Use when checking status across multiple repositories, fetching/pulling all repos at once, running git commands across repo groups, or when the user mentions gita, repo groups, or wants a bird's-eye view of their git repositories. Also use when working with repos in ~/claude/ or ~/.local/src/ and you need to understand what's there or operate on them in bulk.
---

<what_is_this>

gita manages multiple git repos from any working directory. two core capabilities:

1. **dashboard** — see status of all repos (or a group) side by side
2. **delegation** — run git commands against specific repos without cd-ing

all repos live in `~/.local/src/`. symlinks in `~/claude/` point there. gita tracks 18 repos total.

</what_is_this>

<groups>

groups scope operations. current setup:

| group | repos | notes |
|-------|-------|-------|
| `src` | all 17 repos in `~/.local/src/` | aichat, argc, argc-completions, claude-memory, cli, docs, dot-skogai, episodic-memory, everything-claude-code, get-shit-done, gita, gptme-contrib, marketplace, nelson, skogterm, small-hours, worktrunk |
| `develop` | skogix/claude | the `~/claude/` workspace repo |

context is currently set to `src` (stored in `~/.config/gita/src.context`).

`skogix/claude` is the auto-prefixed name for `~/claude/` — gita prefixes with the parent dir to avoid collision with any repo named `claude`.

</groups>

<commands>

## status and overview

```bash
gita ll                    # all repos (or context group)
gita ll src                # just ~/.local/src/ repos
gita st                    # short status
```

`ll` output shows: repo name, branch, dirty indicators, last commit, age, path, tracking branch.

dirty indicators: `*` unstaged, `+` staged, `$` stashed, `?` untracked, `↑` ahead, `↓` behind.

## targeted git commands

```bash
gita super <repo> <git-command>
gita super claude-memory pull
gita super nelson log --oneline -5
```

## bulk operations

```bash
gita fetch                   # fetch all (or context group)
gita fetch src               # fetch src group
gita pull src                # pull all src repos
```

## shell commands

```bash
gita shell <repo> <shell-command>
gita shell docs "ls -la"
```

## context (default group)

```bash
gita context src             # set default — all commands scope to this
gita context none            # clear context
```

## repo management

```bash
gita ls                      # list all repo names
gita ls <repo>               # show repo path
gita add /path/to/repo       # register
gita rm <repo>               # unregister
gita group ls                # list groups
gita group add -n <name> <repo1> <repo2> ...
gita group rm <name>
gita rename <old> <new>
```

group names cannot collide with repo names.

## freeze and restore

```bash
gita freeze                           # capture full state (URLs, paths, branches)
gita freeze > freeze.csv              # save to file
gita clone -f freeze.csv -p           # restore from freeze
```

`-p` (preserve-path) is required to clone into original paths. without it, repos clone into cwd.

</commands>

<workflows>

**morning check** — fetch and see what's dirty or behind:

```bash
gita fetch && gita ll
```

**find uncommitted work** — look for `*`, `+`, `?` indicators:

```bash
gita ll
```

**add a new project repo:**

```bash
gita add ~/.local/src/new-repo
gita group add -n src <all-existing-src-repos> new-repo
```

</workflows>

<config>

config at `~/.config/gita/` — version-controlled copy at `skills/gita/config/`:

| file | purpose |
|------|---------|
| `repos.csv` | registered repos (path, name, flags) |
| `groups.csv` | group definitions |
| `info.csv` | display column config |
| `src.context` | current context setting |
| `freeze.csv` | full state snapshot for backup/restore |

the `skills/gita/config/` directory is the version-controlled source. sync to `~/.config/gita/` as needed.

</config>
