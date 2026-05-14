#!/usr/bin/env bats

PLUGIN_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
}

@test "hooks manifest only references plugin-local scripts that exist" {
    run node - "$PLUGIN_ROOT" <<'NODE'
const fs = require('fs');
const path = require('path');

const pluginRoot = process.argv[2];
const manifest = JSON.parse(fs.readFileSync(path.join(pluginRoot, 'hooks/hooks.json'), 'utf8'));
const references = new Set();

function visit(value) {
  if (Array.isArray(value)) {
    value.forEach(visit);
    return;
  }
  if (!value || typeof value !== 'object') {
    return;
  }
  if (typeof value.command === 'string') {
    for (const match of value.command.matchAll(/\bscripts\/(?:hooks|lib)\/[^\s"']+/g)) {
      references.add(match[0]);
    }
  }
  Object.values(value).forEach(visit);
}

visit(manifest);

const missing = [...references]
  .sort()
  .filter((relativePath) => !fs.existsSync(path.join(pluginRoot, relativePath)));

for (const relativePath of missing) {
  console.log(relativePath);
}

process.exit(missing.length === 0 ? 0 : 1);
NODE

    assert_success
    assert_output ""
}

@test "manifest hook scripts have their local require dependencies present" {
    run node - "$PLUGIN_ROOT" <<'NODE'
const fs = require('fs');
const path = require('path');
const Module = require('module');

const pluginRoot = process.argv[2];
const manifest = JSON.parse(fs.readFileSync(path.join(pluginRoot, 'hooks/hooks.json'), 'utf8'));
const entries = new Set();
const visited = new Set();
const missing = new Set();

function visitManifest(value) {
  if (Array.isArray(value)) {
    value.forEach(visitManifest);
    return;
  }
  if (!value || typeof value !== 'object') {
    return;
  }
  if (typeof value.command === 'string') {
    for (const match of value.command.matchAll(/\bscripts\/hooks\/[^\s"']+\.js/g)) {
      entries.add(path.join(pluginRoot, match[0]));
    }
  }
  Object.values(value).forEach(visitManifest);
}

function walkRequires(file) {
  if (visited.has(file)) {
    return;
  }
  visited.add(file);

  const source = fs.readFileSync(file, 'utf8');
  for (const match of source.matchAll(/require\(['"](\.{1,2}\/[^'"]+)['"]\)/g)) {
    const request = match[1];
    const resolver = Module.createRequire(file);
    let resolved;
    try {
      resolved = resolver.resolve(request);
    } catch {
      missing.add(`${path.relative(pluginRoot, file)} -> ${request}`);
      continue;
    }
    if (resolved.startsWith(pluginRoot) && resolved.endsWith('.js')) {
      walkRequires(resolved);
    }
  }
}

visitManifest(manifest);

for (const file of entries) {
  if (!fs.existsSync(file)) {
    missing.add(path.relative(pluginRoot, file));
    continue;
  }
  walkRequires(file);
}

for (const item of [...missing].sort()) {
  console.log(item);
}

process.exit(missing.size === 0 ? 0 : 1);
NODE

    assert_success
    assert_output ""
}
