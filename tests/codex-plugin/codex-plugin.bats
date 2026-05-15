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

@test "codex-hooks plugin declares a valid hooks manifest with existing commands" {
    run bash -c "
        hooks_path=\$(jq -r '.hooks' '$PLUGIN_DIR/.codex-plugin/plugin.json')
        test \"\$hooks_path\" = './hooks.json'
        jq -e . '$PLUGIN_DIR/hooks.json' >/dev/null
        jq -r '.hooks[][]?.hooks[]?.command' '$PLUGIN_DIR/hooks.json' |
          while read -r command; do
            test -x '$PLUGIN_DIR/'\"\${command#./}\"
          done
    "
    assert_success
}

@test "basic codex hook command logs fixture payloads without stdout" {
    local log_file="$TEST_DIR/codex-hooks.jsonl"

    run bash -c "
        for fixture in '$PROJECT_ROOT/tests/fixtures/codex-hooks'/*.json; do
          SKOGAI_CODEX_HOOK_LOG='$log_file' '$PLUGIN_DIR/hooks/log-event.sh' < \"\$fixture\"
        done
    "
    assert_success
    assert_output_equals ""

    run bash -c "jq -s 'length' '$log_file'"
    assert_success
    assert_output_equals "8"
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
