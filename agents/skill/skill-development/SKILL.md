---
name: skill-development
description: This skill should be used when the user wants to "create a skill", "add a skill", "write a new skill", "create a skill for opencode", "create a skill for claude", "improve skill description", "organize skill content", or needs guidance on skill structure, progressive disclosure, or skill development best practices for OpenCode or Claude Code.
---

# Skill Development

This skill provides guidance for creating effective skills for OpenCode and Claude Code.

## Skill Locations

Skills can be stored in different locations depending on scope and which tool will use them.

### Shared Skills (OpenCode + Claude Code)

For skills that work with both OpenCode and Claude Code, store them in the shared dotfiles location:

```
~/.dotfiles/agents/skill/<skill-name>/SKILL.md
```

This directory is symlinked to both:

- `~/.config/opencode/skill/` (OpenCode)
- `~/.claude/plugins/personal-config/skills/` (Claude Code)

### Project-Local Skills

For project-specific skills, create them in the project directory:

| Tool     | Location                          |
| -------- | --------------------------------- |
| OpenCode | `.opencode/skill/<name>/SKILL.md` |
| Claude   | `.claude/skills/<name>/SKILL.md`  |

### Global Skills (Tool-Specific)

For global skills specific to one tool:

| Tool     | Location                                   | Notes                   |
| -------- | ------------------------------------------ | ----------------------- |
| OpenCode | `~/.config/opencode/skill/<name>/SKILL.md` | Global for all projects |
| Claude   | `~/.claude/skills/<name>/SKILL.md`         | Personal skills         |

**Note:** Claude also auto-discovers skills from nested `.claude/skills/` directories in subdirectories (e.g., `packages/frontend/.claude/skills/`).

## About Skills

Skills are modular, self-contained packages that extend agent capabilities with specialized knowledge, workflows, and tools. They transform a general-purpose agent into a specialized one equipped with procedural knowledge.

### What Skills Provide

1. Specialized workflows - Multi-step procedures for specific domains
2. Tool integrations - Instructions for working with specific file formats or APIs
3. Domain expertise - Company-specific knowledge, schemas, business logic
4. Bundled resources - Scripts, references, and assets for complex and repetitive tasks

### Anatomy of a Skill

Every skill consists of a required SKILL.md file and optional bundled resources:

```
skill-name/
├── SKILL.md (required)
│   ├── YAML frontmatter metadata (required)
│   │   ├── name: (required)
│   │   └── description: (required)
│   └── Markdown instructions (required)
└── Bundled Resources (optional)
    ├── scripts/          - Executable code (Python/Bash/etc.)
    ├── references/       - Documentation loaded into context as needed
    └── assets/           - Files used in output (templates, icons, etc.)
```

### SKILL.md (required)

**Metadata Quality:** The `name` and `description` in YAML frontmatter determine when the skill triggers. Be specific about what the skill does and when to use it. Use third-person (e.g. "This skill should be used when..." instead of "Use this skill when...").

### Bundled Resources (optional)

**Scripts (`scripts/`):** Executable code for tasks requiring deterministic reliability or repeatedly rewritten code. Token efficient, may be executed without loading into context.

**References (`references/`):** Documentation loaded as needed. Keeps SKILL.md lean. Use for schemas, API docs, domain knowledge, policies, detailed workflow guides.

**Assets (`assets/`):** Files used in output (templates, images, icons, boilerplate code). Separates output resources from documentation.

### Progressive Disclosure

Skills use a three-level loading system:

1. **Metadata (name + description)** - Always in context (~100 words)
2. **SKILL.md body** - When skill triggers (keep under 500 lines)
3. **Bundled resources** - As needed (unlimited)

**Key principle:** Only add context the agent doesn't already have. Challenge each piece: "Does the agent really need this explanation?"

## Skill Creation Process

To create a skill, follow the "Skill Creation Process" in order, skipping steps only if there is a clear reason why they are not applicable.

### Step 1: Understanding the Skill with Concrete Examples

Skip this step only when the skill's usage patterns are already clearly understood. It remains valuable even when working with an existing skill.

To create an effective skill, clearly understand concrete examples of how the skill will be used. This understanding can come from either direct user examples or generated examples that are validated with user feedback.

For example, when building an image-editor skill, relevant questions include:

- "What functionality should the image-editor skill support? Editing, rotating, anything else?"
- "Can you give some examples of how this skill would be used?"
- "I can imagine users asking for things like 'Remove the red-eye from this image' or 'Rotate this image'. Are there other ways you imagine this skill being used?"
- "What would a user say that should trigger this skill?"

To avoid overwhelming users, avoid asking too many questions in a single message. Start with the most important questions and follow up as needed for better effectiveness.

Conclude this step when there is a clear sense of the functionality the skill should support.

### Step 2: Planning the Reusable Skill Contents

To turn concrete examples into an effective skill, analyze each example by:

1. Considering how to execute on the example from scratch
2. Identifying what scripts, references, and assets would be helpful when executing these workflows repeatedly

Example: When building a `pdf-editor` skill to handle queries like "Help me rotate this PDF," the analysis shows:

1. Rotating a PDF requires re-writing the same code each time
2. A `scripts/rotate_pdf.py` script would be helpful to store in the skill

Example: When designing a `frontend-webapp-builder` skill for queries like "Build me a todo app" or "Build me a dashboard to track my steps," the analysis shows:

1. Writing a frontend webapp requires the same boilerplate HTML/React each time
2. An `assets/hello-world/` template containing the boilerplate HTML/React project files would be helpful to store in the skill

Example: When building a `big-query` skill to handle queries like "How many users have logged in today?" the analysis shows:

1. Querying BigQuery requires re-discovering the table schemas and relationships each time
2. A `references/schema.md` file documenting the table schemas would be helpful to store in the skill

**For Claude Code plugins:** When building a hooks skill, the analysis shows:

1. Developers repeatedly need to validate hooks.json and test hook scripts
2. `scripts/validate-hook-schema.sh` and `scripts/test-hook.sh` utilities would be helpful
3. `references/patterns.md` for detailed hook patterns to avoid bloating SKILL.md

To establish the skill's contents, analyze each concrete example to create a list of the reusable resources to include: scripts, references, and assets.

### Step 3: Create Skill Structure

Create the skill directory based on desired scope:

```bash
# Shared skill (works with both OpenCode and Claude Code)
mkdir -p ~/.dotfiles/agents/skill/skill-name/{references,scripts}
touch ~/.dotfiles/agents/skill/skill-name/SKILL.md

# Project-local skill (OpenCode)
mkdir -p .opencode/skill/skill-name/{references,scripts}
touch .opencode/skill/skill-name/SKILL.md

# Project-local skill (Claude Code)
mkdir -p .claude/skills/skill-name/{references,scripts}
touch .claude/skills/skill-name/SKILL.md
```

Create only the directories actually needed (references/, scripts/, assets/).

### Step 4: Edit the Skill

Focus on information beneficial and non-obvious to the agent. Consider procedural knowledge, domain-specific details, or reusable assets.

#### Start with Reusable Skill Contents

Implement `scripts/`, `references/`, and `assets/` files first. This may require user input (e.g., brand assets, documentation). Delete unused directories.

#### Update SKILL.md

**Writing Style:** Use imperative/infinitive form, not second person.

**Description (Frontmatter):** Third-person with specific trigger phrases:

```yaml
---
name: skill-name
description: This skill should be used when the user asks to "specific phrase 1", "specific phrase 2". Be concrete and specific.
---
```

**Good:** `description: This skill should be used when the user asks to "create a hook", "validate tool use", or mentions hook events.`

**Bad:** `description: Use this skill when working with hooks.` (wrong person, vague)

**Body content:** Answer these questions:

1. What is the purpose of the skill?
2. When should it be used? (reflected in description)
3. How should the agent use it? Reference all bundled resources.

**Keep SKILL.md lean:** Target under 500 lines. Move detailed content to references/.

### Step 5: Validate and Test

1. Check frontmatter has `name` (matching directory) and `description`
2. Verify description uses third-person with trigger phrases
3. Confirm body uses imperative form
4. Ensure SKILL.md is lean (<500 lines)
5. Verify all referenced files exist
6. Test skill triggers on expected queries

### Step 6: Iterate

Use the skill on real tasks, notice inefficiencies, and improve. Common improvements:

- Strengthen trigger phrases
- Move long sections to references/
- Add missing scripts or examples
- Clarify ambiguous instructions

## Tool-Specific Considerations

### Directory Naming Differences

| Tool     | Directory Name |
| -------- | -------------- |
| OpenCode | `skill/`       |
| Claude   | `skills/`      |

### Name Validation (Both Tools)

Both tools enforce similar naming rules:

- **Length**: 1-64 characters
- **Characters**: Lowercase alphanumeric with single hyphen separators
- **No leading/trailing hyphens**: Cannot start or end with `-`
- **No consecutive hyphens**: Cannot contain `--`
- **Must match directory**: The `name` field must match the containing directory name

Regex pattern: `^[a-z0-9]+(-[a-z0-9]+)*$`

**Valid names:** `git-release`, `pdf-editor`, `myskill`, `api-v2-client`
**Invalid names:** `Git-Release`, `my_skill`, `-skill`, `skill-`, `my--skill`

### Frontmatter Fields

**Required (both tools):**

- `name` - Must match directory name
- `description` - 1-1024 characters

**Optional (OpenCode):**

- `license`
- `compatibility`
- `metadata` - String-to-string map

**Note:** OpenCode ignores unknown frontmatter fields. Avoid `version` field for compatibility.

### OpenCode Permissions

Control skill access in `opencode.json`:

```json
{
  "permission": {
    "skill": {
      "pr-review": "allow",
      "internal-*": "deny",
      "*": "allow"
    }
  }
}
```

Permission values: `allow` (immediate), `deny` (hidden), `ask` (prompt user).

### Testing Skills

**OpenCode:**

```bash
opencode  # Skills auto-discovered from skill/ directories
```

**Claude Code:**

```bash
claude --plugin-dir ~/.claude/plugins/personal-config
# Or use the wrapper function that auto-loads personal-config
claude
```

### Troubleshooting

If a skill doesn't appear:

1. Verify `SKILL.md` is spelled in all caps
2. Check frontmatter includes both `name` and `description`
3. Ensure `name` matches the directory name exactly
4. Ensure skill names are unique across all locations
5. Check permissions (OpenCode)—skills with `deny` are hidden

## Skill Example

A minimal shared skill at `~/.dotfiles/agents/skill/git-release/SKILL.md`:

```yaml
---
name: git-release
description: This skill should be used when the user asks to "create a release", "draft release notes", "prepare a tagged release", or needs help with versioning and changelogs.
---

## Purpose

Draft release notes from merged PRs, propose version bumps, and provide copy-pasteable `gh release create` commands.

## Workflow

1. Identify commits since last tag
2. Categorize changes (features, fixes, breaking changes)
3. Generate changelog entries
4. Suggest version bump based on semver
5. Output `gh release create` command
```

This skill works with both OpenCode and Claude Code via the shared dotfiles symlink.

## Progressive Disclosure in Practice

### What Goes in SKILL.md

**Include (always loaded when skill triggers):**

- Core concepts and overview
- Essential procedures and workflows
- Quick reference tables
- Pointers to references/examples/scripts
- Most common use cases

**Keep under 500 lines for optimal performance**

### What Goes in references/

**Move to references/ (loaded as needed):**

- Detailed patterns and advanced techniques
- Comprehensive API documentation
- Migration guides
- Edge cases and troubleshooting
- Extensive examples and walkthroughs

**Each reference file can be large (2,000-5,000+ words)**

### What Goes in examples/

**Working code examples:**

- Complete, runnable scripts
- Configuration files
- Template files
- Real-world usage examples

**Users can copy and adapt these directly**

### What Goes in scripts/

**Utility scripts:**

- Validation tools
- Testing helpers
- Parsing utilities
- Automation scripts

**Should be executable and documented**

## Writing Style

- **Description:** Use third-person ("This skill should be used when...")
- **Body:** Use imperative/infinitive form (verb-first instructions)
- **Avoid:** Second person ("You should...", "You need to...")

## Validation Checklist

- [ ] `name` matches directory name
- [ ] `description` uses third person with specific trigger phrases
- [ ] Body uses imperative form, <500 lines
- [ ] Referenced files exist
- [ ] Skill triggers on expected queries

For detailed writing style examples and common mistakes, see `references/skill-creator-original.md`.

## Quick Reference

### Skill Structures

**Minimal:** `skill-name/SKILL.md` - Simple knowledge, no complex resources

**Standard (Recommended):**

```
skill-name/
├── SKILL.md
└── references/
    └── detailed-guide.md
```

**Complete:**

```
skill-name/
├── SKILL.md
├── references/
│   └── patterns.md
└── scripts/
    └── validate.sh
```

### Location Quick Reference

| Scope           | Path                                       |
| --------------- | ------------------------------------------ |
| Shared (both)   | `~/.dotfiles/agents/skill/<name>/SKILL.md` |
| OpenCode local  | `.opencode/skill/<name>/SKILL.md`          |
| Claude local    | `.claude/skills/<name>/SKILL.md`           |
| OpenCode global | `~/.config/opencode/skill/<name>/SKILL.md` |
| Claude personal | `~/.claude/skills/<name>/SKILL.md`         |

## Additional Resources

- **`references/skill-creator-original.md`** - Full skill-creator methodology, writing style examples, common mistakes

## Implementation Workflow Summary

1. **Determine scope**: Shared (both tools), project-local, or global
2. **Understand use cases**: Identify concrete examples of skill usage
3. **Plan resources**: Determine what scripts/references needed
4. **Create structure**: Use appropriate path from Quick Reference
5. **Write SKILL.md**:
   - Frontmatter with third-person description and trigger phrases
   - Lean body (<500 lines) in imperative form
   - Reference supporting files
6. **Add resources**: Create references/, scripts/ as needed
7. **Validate**: Check description, writing style, organization
8. **Test**: Verify skill loads on expected triggers in both tools
9. **Iterate**: Improve based on usage

Focus on strong trigger descriptions, progressive disclosure, and imperative writing style for effective skills that load when needed and provide targeted guidance.
