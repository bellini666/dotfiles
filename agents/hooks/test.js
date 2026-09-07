const assert = require('assert');
const path = require('path');
const { spawnSync } = require('child_process');
const { hooks } = require('./hooks.json');

const cases = [
  ['block-dangerous-commands', 'Bash', { command: 'git reset --hard' }, true],
  ['block-dangerous-commands', 'Bash', { command: 'git status --short' }, false],
  ['protect-secrets', 'Read', { file_path: '.env' }, true],
  ['protect-secrets', 'Edit', { file_path: '.env', new_string: 'VALUE=test' }, true],
  ['protect-secrets', 'Write', { file_path: '.env.example', content: 'VALUE=' }, false],
  ['protect-secrets', 'Grep', { glob: '*.pem' }, true],
  ['protect-secrets', 'Bash', { command: 'cat .env' }, true],
  ['protect-secrets', 'Bash', { command: 'git status --short' }, false],
  ['lint-prose', 'Write', { file_path: 'README.md', content: 'Leverage the robust API.' }, true],
  ['lint-prose', 'Edit', { file_path: 'app.py', new_string: '# now uses the API.' }, true],
  ['lint-prose', 'MultiEdit', { file_path: 'README.md', edits: [{ new_string: 'Leverage the robust API.' }] }, true],
  ['lint-prose', 'Write', { file_path: 'README.md', content: 'Run the tests.' }, false],
];

for (const operation of ['Add', 'Update', 'Delete']) {
  cases.push(['protect-secrets', 'apply_patch', {
    command: `*** Begin Patch\n*** ${operation} File: .env\n${operation === 'Delete' ? '' : operation === 'Update' ? '@@\n+VALUE=test\n' : '+VALUE=test\n'}*** End Patch`,
  }, true]);
}

for (const [source, target, blocked] of [
  ['app.py', '.env', true],
  ['.env', 'app.py', true],
  ['app.py', 'src/app.py', false],
]) {
  cases.push(['protect-secrets', 'apply_patch', {
    command: `*** Begin Patch\n*** Update File: ${source}\n*** Move to: ${target}\n@@\n-value = 1\n+value = 2\n*** End Patch`,
  }, blocked]);
}

for (const [file, content, blocked] of [
  ['README.md', 'Leverage the robust API.', true],
  ['app.py', '# now uses the API.', true],
  ['app.py', 'message = "Leverage the robust API."', false],
  ['README.md', 'Run the tests.', false],
  ['/project/AGENTS.md', 'Leverage the robust API.', false],
  ['/project/skills/humanizer/SKILL.md', 'Leverage the robust API.', false],
]) {
  cases.push(['lint-prose', 'apply_patch', {
    command: `*** Begin Patch\n*** Add File: ${file}\n+${content}\n*** End Patch`,
  }, blocked]);
}

cases.push(
  ['protect-secrets', 'apply_patch', {
    command: '*** Begin Patch\n*** Add File: .env.example\n+VALUE=\n*** End Patch',
  }, false],
  ['protect-secrets', 'apply_patch', {
    command: '*** Begin Patch\n*** Add File: app.py\n+value = 1\n*** Delete File: .env\n*** End Patch',
  }, true],
  ['lint-prose', 'apply_patch', {
    command: '*** Begin Patch\n*** Update File: README.md\n@@\n-Leverage the robust API.\n+Call the API.\n*** End Patch',
  }, false],
  ['lint-prose', 'apply_patch', {
    command: '*** Begin Patch\n*** Add File: app.py\n+value = 1\n*** Add File: README.md\n+Leverage the robust API.\n*** End Patch',
  }, true],
  ['lint-prose', 'apply_patch', {
    command: '*** Begin Patch\n*** Update File: notes.txt\n*** Move to: README.md\n@@\n+Leverage the robust API.\n*** End Patch',
  }, true],
);

for (const footer of [
  'Co-Authored-By: 🤖 Claude [Claude Code](https://claude.com/claude-code), reviewed by the author',
  'Co-Authored-By: 🤖 GPT-6 Astra [Codex](https://openai.com/codex/), reviewed by the author',
]) {
  cases.push(['lint-prose', 'Bash', {
    command: `gh pr create --title 'Fix parsing' --body 'Handle empty input.\n\n${footer}'`,
  }, false]);
  cases.push(['lint-prose', 'Bash', {
    command: `gh pr create --body 'Handle empty input.\n\n${footer}' --title 'Fix parsing'`,
  }, false]);
}

cases.push(['lint-prose', 'Bash', {
  command: "gh pr create --title 'Fix parsing' --body 'Handle empty input.'",
}, true]);

let failures = 0;
for (const [hook, tool_name, tool_input, blocked] of cases) {
  const group = hooks.PreToolUse.find((group) => group.hooks.some((handler) => handler.command.includes(`/${hook}.js`)));
  assert.ok(group && new RegExp(group.matcher).test(tool_name), `${hook} must match ${tool_name}`);
  const handler = group.hooks.find((handler) => handler.command.includes(`/${hook}.js`));
  const result = spawnSync('sh', ['-c', handler.command], {
    env: { ...process.env, CLAUDE_PLUGIN_ROOT: path.resolve(__dirname, '..') },
    input: JSON.stringify({ hook_event_name: 'PreToolUse', tool_name, tool_input, cwd: __dirname }),
    encoding: 'utf8',
  });
  try {
    assert.strictEqual(result.status, 0, result.stderr);
    const output = JSON.parse(result.stdout);
    assert.strictEqual(output.hookSpecificOutput?.permissionDecision === 'deny', blocked);
  } catch (error) {
    failures++;
    console.error(`${hook} ${tool_name} ${JSON.stringify(tool_input)}: ${error.message}`);
  }
}

console.log(`${cases.length - failures}/${cases.length} hook cases passed`);
process.exitCode = failures ? 1 : 0;
