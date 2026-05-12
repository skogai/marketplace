#!/usr/bin/env bats

load ../test-helper

PLUGIN_DIR="$PROJECT_ROOT/plugins/codex-hooks"
MARKETPLACE_FILE="$PROJECT_ROOT/.agents/plugins/marketplace.json"

setup() {
    setup_test_dir
    export CODEX_TEST_HOME="$TEST_DIR/home"
    mkdir -p "$CODEX_TEST_HOME"
}

teardown() {
    teardown_test_dir
}

@test "Codex marketplace points at an existing plugin payload" {
    run bash -c "
        plugin_path=\$(jq -r '.plugins[] | select(.name == \"codex-hooks\") | .source.path' '$MARKETPLACE_FILE')
        test \"\$plugin_path\" = './plugins/codex-hooks'
        test -f '$PROJECT_ROOT/'\"\$plugin_path\"'/.codex-plugin/plugin.json'
    "
    assert_success
}

@test "codex-hooks plugin manifest and marketplace entry agree on name" {
    run bash -c "
        marketplace_name=\$(jq -r '.plugins[] | select(.name == \"codex-hooks\") | .name' '$MARKETPLACE_FILE')
        plugin_name=\$(jq -r '.name' '$PLUGIN_DIR/.codex-plugin/plugin.json')
        test \"\$marketplace_name\" = \"\$plugin_name\"
    "
    assert_success
}

@test "Codex CLI can add this repo as a local marketplace" {
    skip_if_missing codex
    run env HOME="$CODEX_TEST_HOME" codex plugin marketplace add "$PROJECT_ROOT"
    assert_success
    assert_output_contains "marketplace"
    assert_output_contains "skogai"
}

@test "installed codex-hooks plugin exposes its smoke-test skill to Codex" {
    skip_if_missing codex

    env HOME="$CODEX_TEST_HOME" codex plugin marketplace add "$PROJECT_ROOT" >/dev/null

    install_dir="$CODEX_TEST_HOME/.codex/plugins/cache/skogai/codex-hooks/local"
    mkdir -p "$install_dir"
    cp -R "$PLUGIN_DIR/." "$install_dir/"

    {
        printf '\n[plugins."codex-hooks@skogai"]\n'
        printf 'enabled = true\n'
    } >> "$CODEX_TEST_HOME/.codex/config.toml"

    run env HOME="$CODEX_TEST_HOME" codex debug prompt-input "Run the Codex hooks plugin smoke test."
    assert_success
    assert_output_contains "codex-hooks:codex-hooks-smoke"
    assert_output_contains "Codex Hooks"
}
