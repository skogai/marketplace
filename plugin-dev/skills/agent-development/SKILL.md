---
name: agent-development
description: This skill should be used when the user asks to "create an agent", "add an agent", "write a subagent", "agent frontmatter", "when to use description", "agent examples", "agent tools", "agent colors", "autonomous agent", or needs guidance on agent structure, system prompts, triggering conditions, or agent development best practices for Claude Code plugins.
---

# Agent Development for Claude Code Plugins

## Overview

Agents are autonomous subprocesses that handle complex, multi-step tasks independently. Understanding agent structure, triggering conditions, and system prompt design enables creating powerful autonomous capabilities.

**Key concepts:**

- Agents are FOR autonomous work, commands are FOR user-initiated actions
- Markdown file format with YAML frontmatter
- Triggering is decided from the `description` field alone, at registration time — the body isn't read until after that decision
- System prompt (the markdown body) defines agent behavior once invoked
- Model and color customization

## Agent File Structure

### Complete Format

```markdown
---
name: agent-identifier
description: Expert [role] specializing in [domain]. Proactively [does X] when [condition]. Use when [trigger scenario 1], [trigger scenario 2], or [trigger scenario 3].
model: inherit
color: blue
tools: Read, Write, Grep
---

You are [agent role description]...

**Your Core Responsibilities:**

1. [Responsibility 1]
2. [Responsibility 2]

**Analysis Process:**
[Step-by-step workflow]

**Output Format:**
[What to return]
```

## Frontmatter Fields

### name (required)

Agent identifier used for namespacing and invocation.

**Format:** lowercase, numbers, hyphens only
**Length:** 3-50 characters
**Pattern:** Must start and end with alphanumeric

**Good examples:**

- `code-reviewer`
- `test-generator`
- `api-docs-writer`
- `security-analyzer`

**Bad examples:**

- `helper` (too generic)
- `-agent-` (starts/ends with hyphen)
- `my_agent` (underscores not allowed)
- `ag` (too short, < 3 chars)

### description (required)

Defines when Claude should trigger this agent. **This is the most critical field** — the delegation decision is made from the `description` field's content itself (plus current context) at the moment the agent is registered, before the agent body/system prompt is ever loaded. Any triggering detail that lives only in the body is invisible to that decision, so don't put it there.

**Format:** a single, dense, self-contained paragraph — this is what every official example uses. No XML `<example>`/`<commentary>` blocks, and no pointer to a body section ("see below," "see When to invoke," etc.) — those patterns either aren't documented or actively undermine delegation by deferring detail past the point where it's needed.

Official example style:

```
Expert code review specialist. Proactively reviews code for quality, security, and maintainability. Use immediately after writing or modifying code.
```

**Must include, written out directly in the paragraph:**

1. What the agent is / does (short expert-persona framing)
2. Concrete trigger conditions — specific scenarios and phrasings, not vague categories
3. "Use proactively" / "immediately after X" language if the agent should self-trigger without an explicit user request

**Best practices:**

- Name 2-4 trigger scenarios directly in the description, in plain prose
- Cover both proactive (assistant invokes itself) and reactive (user requests) triggering
- Cover different phrasings of the same intent
- Be specific about when NOT to use the agent
- Keep it one coherent paragraph rather than a bulleted list or nested examples

### model (optional)

Which model the agent should use. Only `name` and `description` are required by the official spec; `model` defaults to inheriting the parent's model if omitted.

**Options:**

- `inherit` - Use same model as parent (recommended)
- `sonnet` - Claude Sonnet (balanced)
- `opus` - Claude Opus (most capable, expensive)
- `haiku` - Claude Haiku (fast, cheap)

**Recommendation:** Use `inherit` unless agent needs specific model capabilities.

### color (optional)

Visual identifier for the agent in the task list and transcript.

**Options:** `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, `cyan` (the full documented enum — `magenta` is not a valid value)

**Guidelines:**

- Choose distinct colors for different agents in same plugin
- Use consistent colors for similar agent types
- Blue/cyan: Analysis, review
- Green: Success-oriented tasks
- Yellow: Caution, validation
- Red: Critical, security
- Purple: Creative, transformation

**Caveat for plugin-shipped agents:** the plugin manifest reference documents `name`, `description`, `model`, `effort`, `maxTurns`, `tools`, `disallowedTools`, `skills`, `memory`, `background`, and `isolation` as the supported frontmatter fields for agents shipped inside a plugin's `agents/` directory — `color` is not listed there. It may be silently ignored on plugin agents even though it works for project/user-level agents in `.claude/agents/`. Don't rely on it to functionally distinguish plugin agents.

### tools (optional)

Restrict agent to specific tools.

**Format:** Comma-separated list of tool names — this is what every official documentation example uses for file-based agent frontmatter:

```yaml
tools: Read, Write, Grep, Bash
```

A bracketed YAML array (`tools: ["Read", "Write"]`) is only demonstrated in the docs for the `--agents` **CLI JSON flag**, a different serialization context — not for markdown file frontmatter. Don't assume the array form works here; it isn't documented for this context.

**Default:** If omitted, agent has access to all tools

**Best practice:** Limit tools to minimum needed (principle of least privilege)

**Common tool sets:**

- Read-only analysis: `Read, Grep, Glob`
- Code generation: `Read, Write, Grep`
- Testing: `Read, Bash, Grep`
- Full access: Omit the field

## System Prompt Design

The markdown body becomes the agent's system prompt. Write in second person, addressing the agent directly.

### Structure

**Standard template:**

```markdown
You are [role] specializing in [domain].

**Your Core Responsibilities:**

1. [Primary responsibility]
2. [Secondary responsibility]
3. [Additional responsibilities...]

**Analysis Process:**

1. [Step one]
2. [Step two]
3. [Step three]
   [...]

**Quality Standards:**

- [Standard 1]
- [Standard 2]

**Output Format:**
Provide results in this format:

- [What to include]
- [How to structure]

**Edge Cases:**
Handle these situations:

- [Edge case 1]: [How to handle]
- [Edge case 2]: [How to handle]
```

### Best Practices

✅ **DO:**

- Write in second person ("You are...", "You will...")
- Be specific about responsibilities
- Provide step-by-step process
- Define output format
- Include quality standards
- Address edge cases
- Keep under 10,000 characters

❌ **DON'T:**

- Write in first person ("I am...", "I will...")
- Be vague or generic
- Omit process steps
- Leave output format undefined
- Skip quality guidance
- Ignore error cases
- Rely on the body to carry triggering information — that belongs in `description`

## Creating Agents

### Method 1: AI-Assisted Generation

Use this prompt pattern:

```
Create an agent configuration based on this request: "[YOUR DESCRIPTION]"

Requirements:
1. Extract core intent and responsibilities
2. Design expert persona for the domain
3. Create comprehensive system prompt with:
   - Clear behavioral boundaries
   - Specific methodologies
   - Edge case handling
   - Output format
4. Create identifier (lowercase, hyphens, 3-50 chars)
5. Write a single self-contained description paragraph with triggering conditions spelled out concretely — this drives the delegation decision, so put all trigger detail here, not in the body

Return JSON with:
{
  "identifier": "agent-name",
  "whenToUse": "Expert [role]... Use when [scenario 1], [scenario 2]...",
  "systemPrompt": "You are..."
}
```

Then convert to agent file format with frontmatter.

See `examples/agent-creation-prompt.md` for complete template.

### Method 2: Manual Creation

1. Choose agent identifier (3-50 chars, lowercase, hyphens)
2. Write a single self-contained description paragraph with concrete trigger scenarios
3. Select model (usually `inherit`)
4. Choose color for visual identification
5. Define tools (if restricting access)
6. Write system prompt with structure above
7. Save as `agents/agent-name.md`

## Validation Rules

### Identifier Validation

```
✅ Valid: code-reviewer, test-gen, api-analyzer-v2
❌ Invalid: ag (too short), -start (starts with hyphen), my_agent (underscore)
```

**Rules:**

- 3-50 characters
- Lowercase letters, numbers, hyphens only
- Must start and end with alphanumeric
- No underscores, spaces, or special characters

### Description Validation

**Length:** 10-5,000 characters
**Must include:** Concrete triggering conditions written directly in the paragraph
**Best:** 200-1,000 characters, one dense paragraph naming 2-4 trigger scenarios

### System Prompt Validation

**Length:** 20-10,000 characters
**Best:** 500-3,000 characters
**Structure:** Clear responsibilities, process, output format

## Agent Organization

### Plugin Agents Directory

```
plugin-name/
└── agents/
    ├── analyzer.md
    ├── reviewer.md
    └── generator.md
```

All `.md` files in `agents/` are auto-discovered.

### Namespacing

Agents are namespaced automatically:

- Single plugin: `agent-name`
- With subdirectories: `plugin:subdir:agent-name`

## Testing Agents

### Test Triggering

Create test scenarios to verify agent triggers correctly:

1. Write agent with a specific, concrete description
2. Use similar phrasing to the description's trigger scenarios in test
3. Check Claude loads the agent
4. Verify agent provides expected functionality

### Test System Prompt

Ensure system prompt is complete:

1. Give agent typical task
2. Check it follows process steps
3. Verify output format is correct
4. Test edge cases mentioned in prompt
5. Confirm quality standards are met

## Quick Reference

### Minimal Agent

```markdown
---
name: simple-agent
description: Expert [role] that [does X]. Use when [trigger 1] or [trigger 2].
model: inherit
color: blue
---

You are an agent that [does X].

Process:

1. [Step 1]
2. [Step 2]

Output: [What to provide]
```

### Frontmatter Fields Summary

| Field       | Required | Format                                        | Example                            |
| ----------- | -------- | ---------------------------------------------- | ----------------------------------- |
| name        | Yes      | lowercase-hyphens                              | code-reviewer                       |
| description | Yes      | Single self-contained prose paragraph          | Expert code reviewer. Use when...   |
| model       | No       | inherit/sonnet/opus/haiku                      | inherit                             |
| color       | No       | red/blue/green/yellow/purple/orange/pink/cyan  | blue                                |
| tools       | No       | Comma-separated tool names                     | Read, Grep                          |

### Best Practices

**DO:**

- ✅ Name 2-4 trigger scenarios directly in the description, spelled out concretely, in one paragraph
- ✅ Write specific triggering conditions
- ✅ Use `inherit` for model unless specific need
- ✅ Choose appropriate tools (least privilege)
- ✅ Write clear, structured system prompts
- ✅ Test agent triggering thoroughly

**DON'T:**

- ❌ Use generic descriptions without trigger scenarios
- ❌ Omit triggering conditions
- ❌ Use `<example>`/`<commentary>` XML blocks in the description — not documented, not needed
- ❌ Point the description at a body section for triggering detail — the body isn't read until after the delegation decision
- ❌ Give all agents same color
- ❌ Grant unnecessary tool access
- ❌ Write vague system prompts
- ❌ Skip testing

## Additional Resources

### Reference Files

For detailed guidance, consult:

- **`references/system-prompt-design.md`** - Complete system prompt patterns
- **`references/triggering-examples.md`** - Example formats and best practices
- **`references/agent-creation-system-prompt.md`** - The exact prompt from Claude Code

### Example Files

Working examples in `examples/`:

- **`agent-creation-prompt.md`** - AI-assisted agent generation template
- **`complete-agent-examples.md`** - Full agent examples for different use cases

### Utility Scripts

Development tools in `scripts/`:

- **`validate-agent.sh`** - Validate agent file structure
- **`test-agent-trigger.sh`** - Test if agent triggers correctly

## Implementation Workflow

To create an agent for a plugin:

1. Define agent purpose and triggering conditions
2. Choose creation method (AI-assisted or manual)
3. Create `agents/agent-name.md` file
4. Write frontmatter with all required fields
5. Write system prompt following best practices
6. Spell out 2-4 trigger scenarios concretely in one self-contained description paragraph
7. Validate with `scripts/validate-agent.sh`
8. Test triggering with real scenarios
9. Document agent in plugin README

Focus on clear triggering conditions and comprehensive system prompts for autonomous operation.
