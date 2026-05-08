# skogai marketplace

Personal Claude Code plugin marketplace — git tools, workflow automation, and dev utilities.

## Install

```bash
claude plugin marketplace add git@github.com:skogai/marketplace.git
```

Or via HTTPS:

```bash
claude plugin marketplace add https://github.com/skogai/marketplace.git
```

## Browse and install plugins

```bash
/plugin list @skogai
```

Install a specific plugin:

```bash
claude plugin install skogai-worktrunk@skogai
```

## Plugins

| Plugin | Description |
|--------|-------------|
| [skogai-worktrunk](https://github.com/skogai/worktrunk) | Worktrunk (`wt`) CLI guidance — git worktree management, hooks, and config |

## Development

See [CLAUDE.md](CLAUDE.md) for how to add plugins, validate, and test locally.
