const fs = require('fs');
const os = require('os');
const path = require('path');
const readline = require('readline');
const { execFileSync, spawn } = require('child_process');
const manifest = require('./.codex-plugin/plugin.json');
const marketplace = require('./marketplace.json');
const { hooks } = require('./hooks/hooks.json');

async function main() {
  const pluginId = `${manifest.name}@${marketplace.name}`;
  const installed = JSON.parse(execFileSync('codex', ['plugin', 'list', '--marketplace', marketplace.name, '--json'], { encoding: 'utf8' }));
  if (installed.installed.some((plugin) => plugin.pluginId === pluginId)) {
    execFileSync('codex', ['plugin', 'remove', pluginId], { stdio: 'inherit' });
  }
  const plugin = JSON.parse(execFileSync('codex', ['plugin', 'add', pluginId, '--json'], { encoding: 'utf8' }));

  for (const [target, source] of [
    ['.agents/skills', 'skills'],
    ['.codex/hooks.json', 'hooks/hooks.json'],
  ]) {
    const targetPath = path.join(os.homedir(), target);
    if (fs.lstatSync(targetPath, { throwIfNoEntry: false })?.isSymbolicLink() && fs.realpathSync(targetPath) === path.join(__dirname, source)) {
      fs.unlinkSync(targetPath);
    }
  }

  const server = spawn('codex', ['app-server', '--stdio', '--strict-config'], { stdio: ['pipe', 'pipe', 'inherit'] });
  const lines = readline.createInterface({ input: server.stdout });
  const iterator = lines[Symbol.asyncIterator]();
  let nextId = 0;
  const timeout = setTimeout(() => server.kill(), 30000);

  async function request(method, params) {
    const id = ++nextId;
    server.stdin.write(JSON.stringify({ id, method, params }) + '\n');
    for (;;) {
      const { value, done } = await iterator.next();
      if (done) throw new Error(`Codex app-server closed during ${method}`);
      const response = JSON.parse(value);
      if (response.id !== id) continue;
      if (response.error) throw new Error(JSON.stringify(response.error));
      return response.result;
    }
  }

  try {
    await request('initialize', {
      clientInfo: { name: 'dotfiles_bootstrap', version: '1' },
      capabilities: { experimentalApi: true },
    });
    server.stdin.write('{"method":"initialized"}\n');
    const response = await request('hooks/list', { cwds: [os.homedir()] });
    const entry = response.data[0];
    if (entry.errors.length) throw new Error(JSON.stringify(entry.errors));
    const pluginHooks = entry.hooks.filter((hook) => hook.pluginId === pluginId);
    const expectedCount = hooks.PreToolUse.reduce((count, group) => count + group.hooks.length, 0);
    if (pluginHooks.length !== expectedCount) throw new Error(`Expected ${expectedCount} hooks for ${pluginId}, found ${pluginHooks.length}`);
    for (const hook of pluginHooks) {
      if (hook.sourcePath !== path.join(plugin.installedPath, 'hooks/hooks.json')) {
        throw new Error(`Unexpected hook source: ${hook.sourcePath}`);
      }
    }

    await request('config/batchWrite', {
      edits: pluginHooks.map((hook) => ({
        keyPath: `hooks.state.${JSON.stringify(hook.key)}`,
        value: { trusted_hash: hook.currentHash, enabled: true },
        mergeStrategy: 'replace',
      })),
    });
    const verified = await request('hooks/list', { cwds: [os.homedir()] });
    const trusted = verified.data[0].hooks.filter((hook) => hook.pluginId === pluginId);
    if (trusted.length !== expectedCount || trusted.some((hook) => !hook.enabled || hook.trustStatus !== 'trusted')) {
      throw new Error(`Hook trust verification failed for ${pluginId}`);
    }
    console.log(`Refreshed ${pluginId}; ${trusted.length} hooks enabled and trusted.`);
  } finally {
    clearTimeout(timeout);
    lines.close();
    server.kill();
  }
}

main().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});
