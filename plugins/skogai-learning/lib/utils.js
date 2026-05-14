'use strict';

const fs = require('fs');
const path = require('path');
const os = require('os');

function getLearnedSkillsDir() {
  return path.join(os.homedir(), '.claude', 'skills', 'learned');
}

function ensureDir(dir) {
  fs.mkdirSync(dir, { recursive: true });
}

function readFile(filePath) {
  try {
    return fs.readFileSync(filePath, 'utf8');
  } catch {
    return null;
  }
}

function countInFile(filePath, pattern) {
  const content = readFile(filePath);
  if (!content) return 0;
  return (content.match(pattern) || []).length;
}

function log(message) {
  process.stderr.write(message + '\n');
}

module.exports = { getLearnedSkillsDir, ensureDir, readFile, countInFile, log };
