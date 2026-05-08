# skogai/marketplace

Claude Code plugin marketplace. A catalog of personal plugins for git workflows, dev automation, and utilities.

## Structure

```
.claude-plugin/
  marketplace.json    ← catalog (source of truth)
plugins/              ← local plugins (hybrid: some live here, some are external)
scripts/
  validate.sh         ← validate marketplace.json and local plugin manifests
  fetch-claude-code-docs.sh  ← refresh local copy of Claude Code docs
.github/
  workflows/
    validate.yml      ← CI: runs validate.sh on changes to manifest or plugins/
docs/
  claude-code/        ← gitignored; fetch with scripts/fetch-claude-code-docs.sh
```

## Adding a plugin

### External plugin (hosted in its own repo)

Add an entry to `.claude-plugin/marketplace.json`:

```json
{
  "name": "my-plugin",
  "source": {
    "source": "github",
    "repo": "skogai/my-plugin"
  }
}
```

For a private repo via SSH:

```json
{
  "name": "my-plugin",
  "source": {
    "source": "url",
    "url": "git@github.com:skogai/my-plugin.git"
  }
}
```

### Local plugin (lives in `plugins/` of this repo)

1. Create the plugin directory:
   ```bash
   mkdir -p plugins/my-plugin/.claude-plugin
   mkdir -p plugins/my-plugin/skills/my-skill
   ```

2. Create `plugins/my-plugin/.claude-plugin/plugin.json`:
   ```json
   {
     "name": "my-plugin",
     "description": "What this plugin does",
     "version": "0.1.0"
   }
   ```

3. Add to `marketplace.json` (the `pluginRoot` is `./plugins`, so just use the folder name):
   ```json
   {
     "name": "my-plugin",
     "source": "./my-plugin"
   }
   ```

   Note: `metadata.pluginRoot = "./plugins"` means `"source": "./my-plugin"` resolves to `plugins/my-plugin/`.

## Versioning strategy

- **External plugins with no `version` field**: Claude Code uses the git commit SHA. Every push is a new version — automatic rolling updates.
- **Local plugins**: Set `"version"` in `plugin.json` and bump it on every meaningful change. Without a version, Claude Code uses the marketplace repo's commit SHA.
- **Pinning**: Add `"ref": "v1.2.3"` (and optionally `"sha": "..."`) to a source to pin.

**Rule**: Never set `version` in both `plugin.json` and the marketplace entry — `plugin.json` wins silently.

## Validation

```bash
bash scripts/validate.sh
```

Checks:
- `marketplace.json` is valid JSON
- Required fields present (`name`, `owner`, `plugins`)
- Plugin names are kebab-case
- Relative-path sources point to real directories
- Local plugin manifests (`plugin.json`) parse as valid JSON

CI runs this automatically on changes to the manifest or `plugins/`.

## Testing locally

Load a single local plugin without installing it:

```bash
claude --plugin-dir ./plugins/my-plugin
```

Add this marketplace to Claude Code for testing:

```bash
claude plugin marketplace add .
```

Install a plugin from this marketplace:

```bash
claude plugin install my-plugin@skogai
```

After editing a plugin mid-session, run `/reload-plugins` to pick up changes.

## Refreshing docs

The `docs/claude-code/` directory is gitignored. Refresh it:

```bash
cd scripts && bash fetch-claude-code-docs.sh
```
