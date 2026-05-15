#!/usr/bin/env node
/**
 * Continuous Learning - Stop Hook
 *
 * Cross-platform (Windows, macOS, Linux). Runs at session end.
 * When the session has enough messages, outputs a {reason} JSON to stdout
 * which causes Claude to do one extra "learning turn" to extract patterns.
 *
 * Anti-loop: exits immediately when stop_hook_active is true (we're already
 * in the re-run triggered by this hook — don't fire again).
 */

'use strict';

const path = require('path');
const fs = require('fs');
const { getLearnedSkillsDir, ensureDir, readFile, countInFile, log } = require('../lib/utils');

const MAX_STDIN = 1024 * 1024;
let stdinData = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', chunk => {
  if (stdinData.length < MAX_STDIN) stdinData += chunk.substring(0, MAX_STDIN - stdinData.length);
});
process.stdin.on('end', () => {
  main().catch(err => {
    log(`[ContinuousLearning] Error: ${err.message}`);
    process.exit(0);
  });
});

async function main() {
  let input = {};
  try {
    input = JSON.parse(stdinData);
  } catch {
    // malformed input — fail open, allow stop
    process.exit(0);
  }

  // Anti-loop guard: stop_hook_active = true means we're already in the learning re-run
  if (input.stop_hook_active) process.exit(0);

  const transcriptPath = input.transcript_path || process.env.CLAUDE_TRANSCRIPT_PATH;
  if (!transcriptPath || !fs.existsSync(transcriptPath)) process.exit(0);

  const scriptDir = __dirname;
  const configFile = path.join(scriptDir, '..', 'continuous-learning', 'config.json');

  let minSessionLength = 10;
  let learnedSkillsPath = getLearnedSkillsDir();

  const configContent = readFile(configFile);
  if (configContent) {
    try {
      const config = JSON.parse(configContent);
      minSessionLength = config.min_session_length ?? 10;
      if (config.learned_skills_path) {
        learnedSkillsPath = config.learned_skills_path.replace(/^~/, require('os').homedir());
      }
    } catch (err) {
      log(`[ContinuousLearning] Config parse failed: ${err.message}`);
    }
  }

  try { ensureDir(learnedSkillsPath); } catch { /* Claude will create it during the learning turn */ }

  const messageCount = countInFile(transcriptPath, /"type"\s*:\s*"user"/g);

  if (messageCount < minSessionLength) {
    log(`[ContinuousLearning] Session too short (${messageCount} messages), skipping`);
    process.exit(0);
  }

  log(`[ContinuousLearning] ${messageCount} messages — triggering learning extraction`);

  // Output {reason} to stdout: Claude re-runs and does the extraction turn
  const reason = [
    `This session had ${messageCount} user messages.`,
    `Review it and extract reusable patterns — techniques, corrections, debugging approaches, workflow insights.`,
    `For each significant pattern, write a markdown skill file to ${learnedSkillsPath}/<slug>.md`,
    `with YAML frontmatter: name, description, trigger.`,
    `Be selective: skip one-time fixes, prefer patterns that will recur.`,
  ].join(' ');

  process.stdout.write(JSON.stringify({ reason }) + '\n');
  process.exit(0);
}
