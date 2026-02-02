---
name: skill-development
description: This skill should be used when the user wants to "create a skill", "add a skill", "write a new skill", "create a skill for opencode", "create a skill for claude", "improve skill description", "organize skill content", or needs guidance on skill structure, progressive disclosure, or skill development best practices for OpenCode or Claude Code.
---

# Skill Development

This skill provides guidance for creating effective skills for OpenCode and Claude Code.

## Skill Locations

Skills can be stored in different locations depending on scope and which tool will use them. Claude Code follows the [Agent Skills](https://agentskills.io) open standard, which works across multiple AI tools.

### Shared Skills (OpenCode + Claude Code)

For skills that work with both OpenCode and Claude Code, store them in the shared dotfiles location:

```
~/.dotfiles/agents/skill/<skill-name>/SKILL.md
```

This directory is symlinked to both:

- `~/.config/opencode/skills/` (OpenCode)
- `~/.claude/skills/` (Claude Code)

### Location Priority and Discovery

Where you store a skill determines who can use it:

| Location   | Path                                     | Applies to                     |
| :--------- | :--------------------------------------- | :----------------------------- |
| Enterprise | See managed settings                     | All users in your organization |
| Personal   | `~/.claude/skills/<skill-name>/SKILL.md` | All your projects              |
| Project    | `.claude/skills/<skill-name>/SKILL.md`   | This project only              |
| Plugin     | `<plugin>/skills/<skill-name>/SKILL.md`  | Where plugin is enabled        |

When skills share the same name across levels, higher-priority locations win: **enterprise > personal > project**. Plugin skills use a `plugin-name:skill-name` namespace, so they cannot conflict with other levels.

**Legacy support:** Files in `.claude/commands/` still work with the same frontmatter, but if a skill and a command share the same name, the skill takes precedence.

### Automatic Nested Discovery (Claude Code)

Claude Code automatically discovers skills from nested `.claude/skills/` directories when you work with files in subdirectories. For example, if editing a file in `packages/frontend/`, Claude Code also looks for skills in `packages/frontend/.claude/skills/`. This supports monorepo setups where packages have their own skills.

### OpenCode Discovery

OpenCode searches multiple locations and walks up from the current working directory to the git worktree root, loading all matching definitions along the way:

- Project-local: `.opencode/skills/<name>/SKILL.md` and `.claude/skills/<name>/SKILL.md`
- Global: `~/.config/opencode/skills/<name>/SKILL.md` and `~/.claude/skills/<name>/SKILL.md`

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
├── SKILL.md           # Main instructions (required)
│   ├── YAML frontmatter metadata (required for OpenCode and shared skills)
│   │   ├── name: (required)
│   │   └── description: (required, 1-1024 chars in OpenCode)
│   └── Markdown instructions (required)
└── Bundled Resources (optional)
    ├── scripts/       - Executable utilities and automation
    ├── references/    - Documentation loaded into context as needed
    ├── examples/      - Working code examples and complete templates
    └── assets/        - Files used in output (images, icons)
```

The `SKILL.md` contains the main instructions and is required. Other files are optional and let you build more powerful skills. Reference these files from your `SKILL.md` so Claude knows what they contain and when to load them.

### SKILL.md (required)

**Metadata Quality:** The `name` and `description` in YAML frontmatter determine when the skill triggers. Be specific about what the skill does and when to use it. Use third-person (e.g. "This skill should be used when..." instead of "Use this skill when...").

### Bundled Resources (optional)

**Scripts (`scripts/`):** Executable code for tasks requiring deterministic reliability or repeatedly rewritten code. Token efficient, may be executed without loading into context. Useful for validation tools, testing helpers, parsing utilities, and automation scripts. Should be executable and documented.

**References (`references/`):** Documentation loaded as needed. Keeps SKILL.md lean. Use for schemas, API docs, domain knowledge, policies, detailed workflow guides, comprehensive patterns, migration guides, edge cases, and troubleshooting. Each reference file can be large (2,000-5,000+ words).

**Examples (`examples/`):** Working code examples that users can copy and adapt directly. Include complete runnable scripts, configuration files, template files, and real-world usage examples.

**Assets (`assets/`):** Files used in output (templates, images, icons, boilerplate code). Separates output resources from documentation.

### Types of Skill Content

Skill files can contain any instructions, but thinking about how you want to invoke them helps guide what to include:

**Reference content** adds knowledge Claude applies to your current work. Conventions, patterns, style guides, domain knowledge. This content runs inline so Claude can use it alongside your conversation context.

```yaml
---
name: api-conventions
description: API design patterns for this codebase
---
When writing API endpoints:
  - Use RESTful naming conventions
  - Return consistent error formats
  - Include request validation
```

**Task content** gives Claude step-by-step instructions for a specific action, like deployments, commits, or code generation. These are often actions you want to invoke directly with `/skill-name` rather than letting Claude decide when to run them. Add `disable-model-invocation: true` to prevent Claude from triggering it automatically.

```yaml
---
name: deploy
description: Deploy the application to production
context: fork
disable-model-invocation: true
---

Deploy the application:
1. Run the test suite
2. Build the application
3. Push to the deployment target
```

Your `SKILL.md` can contain anything, but thinking through how you want the skill invoked (by you, by Claude, or both) and where you want it to run (inline or in a subagent) helps guide what to include.

### Progressive Disclosure

Skills use a three-level loading system:

1. **Metadata (name + description)** - In context by default. In Claude Code, `disable-model-invocation: true` keeps the description out of context until manual invocation.
2. **SKILL.md body** - When skill triggers (keep under 500 lines)
3. **Bundled resources** - As needed (unlimited)

Claude Code loads skill descriptions into context up to a character budget. If skills are missing, check `/context` and increase `SLASH_COMMAND_TOOL_CHAR_BUDGET`.

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
mkdir -p ~/.dotfiles/agents/skill/skill-name/{references,examples,scripts}
touch ~/.dotfiles/agents/skill/skill-name/SKILL.md

# Project-local skill (OpenCode)
mkdir -p .opencode/skills/skill-name/{references,examples,scripts}
touch .opencode/skills/skill-name/SKILL.md

# Project-local skill (Claude Code)
mkdir -p .claude/skills/skill-name/{references,examples,scripts}
touch .claude/skills/skill-name/SKILL.md
```

Create only the directories actually needed (references/, examples/, scripts/, assets/).

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

### Directory Naming

Both OpenCode and Claude Code use `skills/` (plural) directories.

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

**Required for shared skills (OpenCode requires these):**

- `name` - Must match directory name
- `description` - 1-1024 characters

**Optional (OpenCode):**

- `license`
- `compatibility`
- `metadata` - String-to-string map

**Optional (Claude Code):**

- `argument-hint` - Autocomplete hint for expected args (e.g., `[issue-number]` or `[filename] [format]`)
- `disable-model-invocation` - Set to `true` to prevent Claude from automatically loading this skill
- `user-invocable` - Set to `false` to hide from `/` menu (default: `true`)
- `allowed-tools` - Tools Claude can use without asking permission when this skill is active
- `model` - Model to use when this skill is active (e.g., `haiku`, `sonnet`, `opus`)
- `context` - Set to `fork` to run in a forked subagent context
- `agent` - Which subagent type to use when `context: fork` is set
- `hooks` - Hooks scoped to this skill's lifecycle

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

### OpenCode Per-Agent Overrides

Override permissions per agent in `opencode.json`:

```json
{
  "agent": {
    "plan": {
      "permission": {
        "skill": {
          "internal-*": "allow"
        }
      }
    }
  }
}
```

### Disable the Skill Tool (OpenCode)

Disable skill loading per agent in `opencode.json`:

```json
{
  "agent": {
    "plan": {
      "tools": {
        "skill": false
      }
    }
  }
}
```

### Claude Code Invocation Control

By default, both you and Claude can invoke any skill. Two frontmatter fields let you restrict this:

- `disable-model-invocation: true` - Only you can invoke the skill. Use this for workflows with side effects or that you want to control timing, like `/commit`, `/deploy`, or `/send-slack-message`. The description is not loaded into context until manual invocation.
- `user-invocable: false` - Only Claude can invoke the skill. Use this for background knowledge that isn't actionable as a command. Hidden from `/` menu but still available for automatic invocation.

How the fields affect invocation and context loading:

| Frontmatter                      | You can invoke | Claude can invoke | When loaded into context                                     |
| :------------------------------- | :------------- | :---------------- | :----------------------------------------------------------- |
| (default)                        | Yes            | Yes               | Description always in context, full skill loads when invoked |
| `disable-model-invocation: true` | Yes            | No                | Description not in context, full skill loads when you invoke |
| `user-invocable: false`          | No             | Yes               | Description always in context, full skill loads when invoked |

**Note:** In a regular session, skill descriptions are loaded into context so Claude knows what's available, but full skill content only loads when invoked. Subagents with preloaded skills work differently: the full skill content is injected at startup.

### Claude Code Permission Restrictions

By default, Claude can invoke any skill that doesn't have `disable-model-invocation: true` set. Three ways to control which skills Claude can invoke:

**1. Disable all skills** by denying the Skill tool in `/permissions`:

```
# Add to deny rules:
Skill
```

**2. Allow or deny specific skills** using permission rules:

```
# Allow only specific skills
Skill(commit)
Skill(review-pr *)

# Deny specific skills
Skill(deploy *)
```

Permission syntax: `Skill(name)` for exact match, `Skill(name *)` for prefix match with any arguments.

**3. Hide individual skills** by adding `disable-model-invocation: true` to their frontmatter. This removes the skill from Claude's context entirely.

**Note:** The `user-invocable` field only controls menu visibility, not Skill tool access. Use `disable-model-invocation: true` to block programmatic invocation.

### Claude Code Tool Restrictions

Use the `allowed-tools` field to limit which tools Claude can use when a skill is active. This creates a safe, restricted environment for specific workflows.

**Example - Read-only mode:**

```yaml
---
name: safe-reader
description: Read files without making changes
allowed-tools: Read, Grep, Glob
---
Explore the codebase and answer questions without modifying any files.
```

Skills that define `allowed-tools` grant Claude access to those tools without per-use approval when the skill is active. Your permission settings still govern baseline approval behavior for all other tools.

### Claude Code Dynamic Context

#### String Substitutions

Skills support string substitution for dynamic values in the skill content:

- `$ARGUMENTS` - All arguments passed when invoking the skill. If `$ARGUMENTS` is not present in the content, arguments are appended as `ARGUMENTS: <value>`.
- `$ARGUMENTS[N]` or `$N` - Access a specific argument by 0-based index. Example: `$0` for the first argument, `$1` for the second.
- `${CLAUDE_SESSION_ID}` - The current session ID. Useful for logging, creating session-specific files, or correlating skill output with sessions.

**Example:**

```yaml
---
name: migrate-component
description: Migrate a component from one framework to another
---
Migrate the $0 component from $1 to $2.
Preserve all existing behavior and tests.
```

Running `/migrate-component SearchBar React Vue` replaces `$0` with `SearchBar`, `$1` with `React`, and `$2` with `Vue`.

#### Dynamic Context Injection

The `!`command`` syntax runs shell commands before the skill content is sent to Claude. The command output replaces the placeholder, so Claude receives actual data, not the command itself.

**Example:**

```yaml
---
name: pr-summary
description: Summarize changes in a pull request
context: fork
agent: Explore
allowed-tools: Bash(gh *)
---

## Pull request context
- PR diff: !`gh pr diff`
- PR comments: !`gh pr view --comments`
- Changed files: !`gh pr diff --name-only`

## Your task
Summarize this pull request...
```

When this skill runs:

1. Each `!`command`` executes immediately (before Claude sees anything)
2. The output replaces the placeholder in the skill content
3. Claude receives the fully-rendered prompt with actual PR data

This is preprocessing, not something Claude executes. Claude only sees the final result.

#### Extended Thinking

To enable extended thinking (thinking mode) in a skill, include the word "ultrathink" anywhere in your skill content.

### Claude Code Subagents

Add `context: fork` to your frontmatter when you want a skill to run in isolation. The skill content becomes the prompt that drives the subagent. It won't have access to your conversation history.

**Warning:** `context: fork` only makes sense for skills with explicit instructions. If your skill contains guidelines like "use these API conventions" without a task, the subagent receives the guidelines but no actionable prompt, and returns without meaningful output.

Skills and subagents work together in two directions:

| Approach                     | System prompt                             | Task                        | Also loads                   |
| :--------------------------- | :---------------------------------------- | :-------------------------- | :--------------------------- |
| Skill with `context: fork`   | From agent type (`Explore`, `Plan`, etc.) | SKILL.md content            | CLAUDE.md                    |
| Subagent with `skills` field | Subagent's markdown body                  | Claude's delegation message | Preloaded skills + CLAUDE.md |

With `context: fork`, you write the task in your skill and pick an agent type to execute it. The `agent` field specifies which subagent configuration to use. Options include built-in agents (`Explore`, `Plan`, `general-purpose`) or any custom subagent from `.claude/agents/`. If omitted, uses `general-purpose`.

**Example: Research skill using Explore agent**

```yaml
---
name: deep-research
description: Research a topic thoroughly
context: fork
agent: Explore
---

Research $ARGUMENTS thoroughly:

1. Find relevant files using Glob and Grep
2. Read and analyze the code
3. Summarize findings with specific file references
```

When this skill runs:

1. A new isolated context is created
2. The subagent receives the skill content as its prompt
3. The `agent` field determines the execution environment (model, tools, and permissions)
4. Results are summarized and returned to your main conversation

### Testing Skills

**OpenCode:**

```bash
opencode  # Skills auto-discovered from skills/ directories
```

**Claude Code:**

```bash
claude --plugin-dir ~/.claude/plugins/personal-config
# Or use the wrapper function that auto-loads personal-config
claude
```

### Troubleshooting

**Skill not appearing:**

1. Verify `SKILL.md` is spelled in all caps
2. Check frontmatter includes both `name` and `description`
3. Ensure `name` matches the directory name exactly
4. Ensure skill names are unique across all locations
5. Check permissions (OpenCode)—skills with `deny` are hidden
6. Confirm `description` length is 1-1024 chars (OpenCode)
7. If using Claude Code, verify the description budget and character limit

**Claude Code doesn't see all skills:**

Skill descriptions are loaded into context so Claude knows what's available. If you have many skills, they may exceed the character budget (default 15,000 characters). Run `/context` to check for a warning about excluded skills.

To increase the limit, set the `SLASH_COMMAND_TOOL_CHAR_BUDGET` environment variable.

**Skill not triggering:**

If Claude doesn't use your skill when expected:

1. Check the description includes keywords users would naturally say
2. Verify the skill appears in "What skills are available?"
3. Try rephrasing your request to match the description more closely
4. Invoke it directly with `/skill-name` if the skill is user-invocable

**Skill triggers too often:**

If Claude uses your skill when you don't want it:

1. Make the description more specific
2. Add `disable-model-invocation: true` if you only want manual invocation

## Sharing Skills

Skills can be distributed at different scopes depending on your audience:

- **Project skills**: Commit `.claude/skills/` or `.opencode/skills/` to version control
- **Plugins**: Create a `skills/` directory in your plugin
- **Managed**: Deploy organization-wide through managed settings (enterprise)
- **Personal dotfiles**: Use the symlink pattern from `~/.dotfiles/agents/skill/` to both `~/.claude/skills/` and `~/.config/opencode/skills/`

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

**Working code examples that users can copy and adapt directly:**

- Complete, runnable scripts showing expected usage
- Configuration files demonstrating proper setup
- Template files with boilerplate code
- Real-world usage examples
- Sample outputs showing expected format

**Example:** A `codebase-visualizer` skill might include `examples/sample.html` showing the expected output format.

### What Goes in scripts/

**Executable utility scripts:**

- Validation tools (e.g., `validate-hook-schema.sh`)
- Testing helpers (e.g., `test-hook.sh`)
- Parsing utilities
- Automation scripts
- Visual output generators (e.g., Python scripts that generate HTML/SVG)

**Should be executable and documented.** Scripts can be in any language (Python, Bash, etc.) and can generate visual output like interactive HTML files that open in your browser for exploring data, debugging, or creating reports.

**Visual Output Pattern:** Skills can bundle and run scripts in any language, giving Claude capabilities beyond what's possible in a single prompt. One powerful pattern is generating visual output: interactive HTML files for exploring data, debugging, or creating reports. For example, a `codebase-visualizer` skill could bundle a Python script that generates an interactive tree view of your project structure with collapsible directories, file sizes, and type indicators. The script does the heavy lifting while Claude handles orchestration.

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

**With Examples:**

```
skill-name/
├── SKILL.md
├── references/
│   └── patterns.md
└── examples/
    └── sample.md
```

**Complete:**

```
skill-name/
├── SKILL.md           # Main instructions
├── references/        # Detailed reference material
│   └── patterns.md
├── examples/          # Working code examples
│   └── sample.md
└── scripts/           # Executable utilities
    └── validate.sh
```

### Location Quick Reference

| Scope           | Path                                        |
| --------------- | ------------------------------------------- |
| Shared (both)   | `~/.dotfiles/agents/skill/<name>/SKILL.md`  |
| OpenCode local  | `.opencode/skills/<name>/SKILL.md`          |
| Claude local    | `.claude/skills/<name>/SKILL.md`            |
| OpenCode global | `~/.config/opencode/skills/<name>/SKILL.md` |
| Claude personal | `~/.claude/skills/<name>/SKILL.md`          |

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
6. **Add resources**: Create references/, examples/, scripts/ as needed
7. **Validate**: Check description, writing style, organization
8. **Test**: Verify skill loads on expected triggers in both tools
9. **Iterate**: Improve based on usage

Focus on strong trigger descriptions, progressive disclosure, and imperative writing style for effective skills that load when needed and provide targeted guidance.
