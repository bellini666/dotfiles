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
console.log('ok');
