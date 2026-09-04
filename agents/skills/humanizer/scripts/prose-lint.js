#!/usr/bin/env node
// Prose lint shared by the humanizer skill and the lint-prose PreToolUse hook.
// Usage: node prose-lint.js [--mode comment|prose|commit] [file]   (reads stdin without a file)
// Modes: comment = only comment lines and docstrings; prose = every line; commit = prose minus old-behavior rules.

const fs = require('fs');

const RULES = [
  { id: 'em-dash', modes: ['comment', 'prose', 'commit'], regex: /—|\s–\s/g },
  { id: 'curly-quotes', modes: ['prose', 'commit'], regex: /[“”‘’]/g },
  {
    id: 'old-behavior',
    modes: ['comment', 'prose'],
    regex: /\b(previously|no longer|used to (?:be|have|do|use|call|return|rely)|now (?:uses|calls|returns|does|handles|supports|relies)|renamed from|moved from|instead of the (?:old|previous)|before this (?:change|pr|mr|commit)|this (?:change|pr|mr|commit)|the old (?:behaviou?r|implementation|approach|way))\b/gi,
  },
  {
    id: 'what-was-not-done',
    modes: ['prose'],
    regex: /\b(unchanged|untouched|preserved|retained|we did(?:n't| not)|left as[- ]is|does not (?:change|touch|affect)|no (?:behaviou?r(?:al)?|functional) changes?|(?:is|are|remains?|stays?) the same)\b/gi,
  },
  {
    id: 'fancy-register',
    modes: ['prose', 'commit'],
    regex: /\b(quietly|load-bearing|delve|leverages?|leveraging|seamless(?:ly)?|robust(?:ly|ness)?|comprehensive(?:ly)?|it(?:'s| is) worth noting|notably|importantly|crucial(?:ly)?|pivotal|streamlines?|streamlining)\b/gi,
  },
  {
    id: 'not-x-but-y',
    modes: ['prose', 'commit'],
    regex: /\bnot (?:just|only|merely) \w+[^.\n]{0,60}\bbut\b|\bit'?s not \w+[^.\n]{0,40}, it'?s\b/gi,
  },
  {
    id: 'chatbot',
    modes: ['prose', 'commit'],
    regex: /\b(great question|great catch|i hope this helps|let me know if|you'?re absolutely right|happy to help)\b/gi,
  },
];

const COMMENT_PREFIX = /^\s*(#(?!!)|\/\/|\/\*+|\*|--|<!--|;)\s?(.*)$/;
const TRAILING_COMMENT = /\s(?:#(?!!)|\/\/)\s(.*)$/;
const TRIPLE_QUOTE = /"""|'''/g;

function commentText(line, inDocstring) {
  if (inDocstring) return line;
  const full = line.match(COMMENT_PREFIX);
  if (full) return full[2];
  const trailing = line.match(TRAILING_COMMENT);
  return trailing ? trailing[1] : null;
}

function lint(text, mode = 'prose') {
  const rules = RULES.filter((r) => r.modes.includes(mode));
  const findings = [];
  let inDocstring = false;

  text.split('\n').forEach((line, i) => {
    let subject = line;
    if (mode === 'comment') {
      subject = commentText(line, inDocstring);
      if ((line.match(TRIPLE_QUOTE) || []).length % 2 === 1) inDocstring = !inDocstring;
      if (subject === null) return;
    }
    for (const rule of rules) {
      for (const m of subject.matchAll(rule.regex)) {
        findings.push({ line: i + 1, rule: rule.id, match: m[0].trim() });
      }
    }
  });

  return findings;
}

function format(findings) {
  return findings.map((f) => `line ${f.line} [${f.rule}]: "${f.match}"`).join('\n');
}

if (require.main === module) {
  const args = process.argv.slice(2);
  const modeIdx = args.indexOf('--mode');
  const mode = modeIdx === -1 ? 'prose' : args[modeIdx + 1];
  const file = args.filter((a, i) => a !== '--mode' && i !== modeIdx + 1)[0];
  const text = fs.readFileSync(file || 0, 'utf8');
  const findings = lint(text, mode);
  if (findings.length) {
    console.log(format(findings));
    process.exit(1);
  }
} else {
  module.exports = { RULES, lint, format };
}
