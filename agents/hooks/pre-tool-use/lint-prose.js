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
// Plans, scratchpads and memory are working notes, never posted.
const SKIP_PATHS = /\/(AGENTS|CLAUDE)\.md$|\/humanizer\/|lint-prose\.js$|\/\.claude\/(?:plans|memory)\/|\/claude-\d+\/.*\/scratchpad\/|\/\.claude\/projects\/[^/]+\/memory\//;
// core:create-mr posts through the API because core's safety hook denies `glab mr create`.
const MR_API_WRITE = /glab\s+api\b(?=[^\n]*\b(?:POST|PUT)\b|[^\n]*\s(?:-f|-F|--field|--raw-field)[\s=])(?=[^\n]*merge_requests)/i;
const MR_API_BODY = /merge_requests(?:\/\d+)?["']?(?:\s|$)/;
const MR_API_CREATE = /merge_requests["']?(?:\s|$)/;
const MR_API_PUT = /\bPUT\b/i;
const MESSAGE_COMMANDS = /\b(git\s+commit|gh\s+(?:pr|issue)\s+(?:create|edit|comment|review)|glab\s+(?:mr|issue)\s+(?:create|update|note|comment))\b/;
const PR_CREATE = /\b(gh\s+pr\s+create|glab\s+mr\s+create)\b/;
const PR_BODY = /\b(gh\s+pr\s+(?:create|edit)|glab\s+mr\s+(?:create|update))\b/;
const TEST_EVIDENCE = /\b(test plan|tests? pass(?:ed|es|ing)? locally|ruff (?:is )?clean|mypy (?:is )?clean)\b/i;
const COMMIT_SEGMENT = /\bgit\s+commit\b(?:[^&;|"']|"(?:[^"\\]|\\.)*"|'[^']*')*/g;
const OPT_OUT = /(?:^|[;&|\n]\s*)PROSE_LINT=off\s+(?:git\s+commit|gh\s|glab\s)/;
const FOOTER = /Co-Authored-By: 🤖 [^\n]+ \[(?:Claude Code|Codex)\]\(https:\/\/(?:claude\.com\/claude-code|openai\.com\/codex\/?)\), reviewed by the author/;

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
  for (const m of cmd.matchAll(/(?:-f|--field|--raw-field)[\s=]+(?:"(?:title|description)=((?!\$\()(?:[^"\\]|\\.)*)"|'(?:title|description)=([^']*)')/g)) parts.push(m[1] ?? m[2]);
  for (const m of cmd.matchAll(/(?:title|description)=(?:\$\(cat\s+["']?|@)([^"')\s]+)/g)) {
    const variable = m[1].match(/^\$\{?(\w+)\}?$/);
    const assigned = variable && cmd.match(new RegExp(`(?:^|[\\s;&])${variable[1]}=["']?([^"'\\s;&$]+)`));
    if (variable && !assigned) continue;
    try { parts.push(fs.readFileSync(path.resolve(cwd || '.', assigned ? assigned[1] : m[1]), 'utf8')); } catch {}
  }
  for (const m of cmd.matchAll(/printf\s+'%s'\s+"((?:[^"\\]|\\.)*)"\s*>/g)) parts.push(m[1]);
  return parts.join('\n');
}

function check({ tool_name, tool_input, cwd }) {
  if (tool_name === 'Bash') {
    const cmd = (tool_input?.command || '').replace(/\\\r?\n\s*/g, ' ');
    const mrWrite = MR_API_WRITE.test(cmd);
    if (OPT_OUT.test(cmd) || !(MESSAGE_COMMANDS.test(cmd) || mrWrite)) return [];
    const text = messageText(cmd, cwd);
    const prText = messageText(cmd.replace(COMMIT_SEGMENT, ''), cwd);
    const findings = lint(text, /\bgit\s+commit\b/.test(cmd) ? 'commit' : 'prose');
    if ((PR_CREATE.test(cmd) || (mrWrite && MR_API_CREATE.test(cmd) && !MR_API_PUT.test(cmd))) && prText && !FOOTER.test(prText)) findings.push({ line: 0, rule: 'pr-footer', match: 'body must end with the model and client attribution from AGENTS.md' });
    const evidence = (PR_BODY.test(cmd) || (mrWrite && MR_API_BODY.test(cmd))) && prText.match(TEST_EVIDENCE);
    if (evidence) findings.push({ line: 0, rule: 'test-evidence', match: evidence[0] });
    if (mrWrite && !text && /(?:title|description)=/.test(cmd)) findings.push({ line: 0, rule: 'unreadable-body', match: 'write the body in a heredoc in this command so it can be checked' });
    const seen = new Set();
    return findings.filter((f) => !seen.has(f.rule + f.match) && seen.add(f.rule + f.match));
  }

  let edits = [{
    file: tool_input?.file_path || '',
    texts: [tool_input?.new_string, tool_input?.content, ...(tool_input?.edits || []).map((e) => e.new_string)].filter(Boolean),
  }];
  if (tool_name === 'apply_patch') {
    edits = [];
    for (const line of (tool_input?.command || '').split('\n')) {
      const header = line.match(/^\*\*\* (?:Add|Update|Delete) File: (.+)$/);
      if (header) edits.push({ file: header[1].trim(), texts: [] });
      else if (line.startsWith('*** Move to: ') && edits.length) edits[edits.length - 1].file = line.slice('*** Move to: '.length).trim();
      else if (line.startsWith('+') && edits.length) edits[edits.length - 1].texts.push(line.slice(1));
    }
  }

  return edits.flatMap(({ file, texts }) => {
    if (SKIP_PATHS.test(path.resolve(cwd || '.', file))) return [];
    return lint(texts.join('\n'), PROSE_FILES.test(file) ? 'prose' : 'comment');
  });
}

async function main() {
  let input = '';
  for await (const chunk of process.stdin) input += chunk;
  if (process.env.PROSE_LINT === 'off') return console.log('{}');

  try {
    const data = JSON.parse(input);
    const findings = check(data);
    if (!findings.length) return console.log('{}');

    log({ level: 'BLOCKED', id: 'prose-lint', tool: data.tool_name, file: data.tool_input?.file_path, findings, session_id: data.session_id, cwd: data.cwd });
    console.log(JSON.stringify({
      hookSpecificOutput: {
        hookEventName: 'PreToolUse',
        permissionDecision: 'deny',
        permissionDecisionReason: `prose lint rejected this text. Rewrite the flagged parts (describe current state, plain words, no em dashes) and retry. Only if the user asked to skip this check, prefix the command with PROSE_LINT=off.\n${format(findings.slice(0, 8))}`,
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
