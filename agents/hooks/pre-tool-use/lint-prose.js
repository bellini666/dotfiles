#!/usr/bin/env node
// Lint Prose - PreToolUse hook for Edit/Write/MultiEdit/Bash.
// Denies edits whose comments, and git/gh/glab messages whose bodies, contain AI-writing tells.
// Rules live in skills/humanizer/scripts/prose-lint.js. Set PROSE_LINT=off to skip for a session.

const fs = require('fs');
const path = require('path');
const { lint, format } = require(path.resolve(__dirname, '../../skills/humanizer/scripts/prose-lint.js'));

const LOG_DIR = path.join(process.env.HOME, '.claude', 'hooks-logs');
const PROSE_FILES = /\.(md|mdx|rst|txt|adoc)$/i;
// These files list the banned words on purpose.
const SKIP_PATHS = /\/(AGENTS|CLAUDE)\.md$|\/humanizer\/|lint-prose\.js$/;
const MESSAGE_COMMANDS = /\b(git\s+commit|gh\s+(?:pr|issue)\s+(?:create|edit|comment|review)|glab\s+(?:mr|issue)\s+(?:create|update|note|comment))\b/;
const PR_CREATE = /\b(gh\s+pr\s+create|glab\s+mr\s+create)\b/;
const FOOTER = 'Co-Authored-By: 🤖 Claude [Claude Code](https://claude.com/claude-code), reviewed by the author';

function log(data) {
  try {
    if (!fs.existsSync(LOG_DIR)) fs.mkdirSync(LOG_DIR, { recursive: true });
    const file = path.join(LOG_DIR, `${new Date().toISOString().slice(0, 10)}.jsonl`);
    fs.appendFileSync(file, JSON.stringify({ ts: new Date().toISOString(), ...data }) + '\n');
  } catch {}
}

function messageText(cmd, cwd) {
  const parts = [];
  for (const m of cmd.matchAll(/<<-?\s*['"]?(\w+)['"]?\n([\s\S]*?)\n\s*\1\b/g)) parts.push(m[2]);
  for (const m of cmd.matchAll(/(?:^|\s)(?:-m|--message|-b|--body|-t|--title|-d|--description)(?:=|\s+)(?:"((?:[^"\\]|\\.)*)"|'([^']*)')/g)) parts.push(m[1] ?? m[2]);
  for (const m of cmd.matchAll(/(?:^|\s)(?:-F|--body-file|--description-file|--file)(?:=|\s+)(\S+)/g)) {
    try { parts.push(fs.readFileSync(path.resolve(cwd || '.', m[1].replace(/^["']|["']$/g, '')), 'utf8')); } catch {}
  }
  return parts.join('\n');
}

function check({ tool_name, tool_input, cwd }) {
  if (tool_name === 'Bash') {
    const cmd = tool_input?.command || '';
    if (!MESSAGE_COMMANDS.test(cmd)) return [];
    const text = messageText(cmd, cwd);
    const findings = lint(text, /\bgit\s+commit\b/.test(cmd) ? 'commit' : 'prose');
    if (PR_CREATE.test(cmd) && text && !text.includes(FOOTER)) findings.push({ line: 0, rule: 'pr-footer', match: `body must end with: ${FOOTER}` });
    const seen = new Set();
    return findings.filter((f) => !seen.has(f.rule + f.match) && seen.add(f.rule + f.match));
  }

  const file = tool_input?.file_path || '';
  if (SKIP_PATHS.test(file)) return [];
  const texts = [tool_input?.new_string, tool_input?.content, ...(tool_input?.edits || []).map((e) => e.new_string)].filter(Boolean);
  if (!texts.length) return [];
  return lint(texts.join('\n'), PROSE_FILES.test(file) ? 'prose' : 'comment');
}

async function main() {
  let input = '';
  for await (const chunk of process.stdin) input += chunk;
  if (process.env.PROSE_LINT === 'off') return console.log('{}');

  try {
    const data = JSON.parse(input);
    const findings = check(data);
    if (!findings.length) return console.log('{}');

    log({ level: 'BLOCKED', id: 'prose-lint', tool: data.tool_name, findings, session_id: data.session_id, cwd: data.cwd });
    console.log(JSON.stringify({
      hookSpecificOutput: {
        hookEventName: 'PreToolUse',
        permissionDecision: 'deny',
        permissionDecisionReason: `prose lint rejected this text. Rewrite the flagged parts (describe current state, plain words, no em dashes) and retry:\n${format(findings.slice(0, 8))}`,
      },
    }));
  } catch (e) {
    log({ level: 'ERROR', id: 'prose-lint', error: e.message });
    console.log('{}');
  }
}

if (require.main === module) {
  main();
} else {
  module.exports = { check, messageText };
}
