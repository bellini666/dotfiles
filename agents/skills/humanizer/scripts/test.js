const assert = require('assert');
const { lint } = require('./prose-lint.js');

const ids = (text, mode) => lint(text, mode).map((f) => f.rule);

assert.deepStrictEqual(ids('# now uses the new client\nx = 1\n', 'comment'), ['old-behavior']);
assert.deepStrictEqual(ids('x = 1  # previously 2\n', 'comment'), ['old-behavior']);
assert.deepStrictEqual(ids('def f():\n    """Parse the date.\n\n    Previously raised on None.\n    """\n', 'comment'), ['old-behavior']);
assert.deepStrictEqual(ids('#!/usr/bin/env node\nconst previously = 1;\n', 'comment'), []);
assert.deepStrictEqual(ids('# this value is used to fetch the token\n', 'comment'), []);
assert.deepStrictEqual(ids('# insertion order is preserved by dict\n', 'comment'), []);
assert.deepStrictEqual(ids('This quietly fixes the bug — no behavior changes.\n', 'prose'), ['em-dash', 'what-was-not-done', 'fancy-register']);
assert.deepStrictEqual(ids("It's not just a fix, it's a redesign. Great question!\n", 'prose'), ['not-x-but-y', 'chatbot']);
assert.deepStrictEqual(ids('Previously this crashed on None input.\n', 'commit'), []);
assert.deepStrictEqual(ids('Leverage the robust API.\n', 'commit'), ['fancy-register', 'fancy-register']);
assert.deepStrictEqual(ids('Bumped dependencies.\n\n- celery 5.5.1 -> 5.5.2\n', 'prose'), []);

assert.deepStrictEqual(ids('GitLab support is out of scope; see #88.\n', 'prose'), []);
assert.deepStrictEqual(ids('- Retry logic is the same\n', 'prose'), ['what-was-not-done']);

assert.deepStrictEqual(ids('This does not mean X. It means Y.\n', 'prose'), ['not-x-but-y']);
assert.deepStrictEqual(ids('Keyed by `(model, pk)` rather than by instance.\n', 'prose'), []);
assert.deepStrictEqual(ids("That doesn't mean it failed. It means it retried.\n", 'prose'), ['not-x-but-y']);
assert.deepStrictEqual(ids('This does not mean the same thing in Postgres as it means in MySQL.\n', 'prose'), []);
assert.deepStrictEqual(ids('Retries hide outages. Let that sink in.\n', 'commit'), ['closer']);
for (const closer of ['That distinction matters.', "That's the real win.", 'That is the real win.', 'Let that sink in.', 'Read that again.']) {
  assert.deepStrictEqual(ids(`${closer}\n`, 'prose'), ['closer']);
}
for (const text of ['The worker must read that again from disk.', 'That distinction matters for pg_dump.', 'Let that sink in the background.']) {
  assert.deepStrictEqual(ids(`${text}\n`, 'prose'), []);
}
assert.deepStrictEqual(ids('Do you want me to take this over, or will you push the fix?\n', 'prose'), []);
assert.deepStrictEqual(ids("The bot replied 'Would you like me to retry?' instead of retrying.\n", 'prose'), []);
console.log('ok');
