---
title: Intent-Notation System - SkogAI's Executable Documentation
date: 2026-01-20
project: SkogAI
tags:
  - notation
  - intent-system
  - operators
  - types
source: Session with Claude building .skogai framework
status: active
permalink: claude/projects/dot-skogai/knowledge/learnings/2026-01-20-intent-notation-system
---

## Overview

SkogAI's intent-notation is a formal symbolic system that makes documentation executable. Instead of comments that describe what should happen, notation markers ARE the execution.

## Core Concepts

### Operators

The notation defines semantic operators with formal meanings:

| Operator | Meaning                         | Example                      |
| -------- | ------------------------------- | ---------------------------- |
| `$`      | Define/reference something      | `$ todo`, `$ json.int`       |
| `@`      | Intent to act/do                | `[@bootstrap]`, `[@fizz:15]` |
| `_`      | Wildcard (everything/nothing)   | `$ _ = anything and nobody`  |
| `.`      | Belonging/having via `[$$]`     | `$ json.string`              |
| `:`      | Following/continuing via `[$@]` | `[@fizz:15]`                 |
| `=`      | Being                           | `[$id=$id]`                  |
| `\|`     | Choosing                        | `{$id1\|$id2}->[$id1]`       |
| `*`      | Composition                     | `$id * $id = $id`            |
| `->`     | Transformation                  | `{$id1@$id2}`                |

### Bracket Semantics

- `[_]` = Similarity/grouping
- `{_}` = Difference/action

### The Magic: Callables

Markers like `[@TODO]` aren't just comments - they're **callable functions**:

```bash
$ todo = [@TODO]           # Variable set to callable
skogcli config get $.todo  # Returns empty (callable result)
skogcli config get $.todo --raw  # Returns [@TODO] (the callable itself)
```

When resolved, `[@TODO]` returns the wildcard `_` (undefined).

### Intent Execution

`[@reference:arg]` = "I intend to execute reference with arg"

Examples:

- `[@fizz:15]` → Execute fizz with argument 15
- `[@help:fizz]` → Get help for fizz tool
- `[@date:now]` → Get current datetime
- `[@file:"/path"]` → Reference file content

## Type System

Complete type algebra defined in config:

```
$ json = {
  string: "",
  int: { zero: 0, one: 1, additative: 0, multiplicative: 1 },
  bool: "$ true * $ false",
  null: "$ json._",
  _: "$json.string * $ json.self"
}
```

## Living Documentation

The killer feature: documents that execute inline.

Write:

```markdown
The output for 15 is: [@fizz:15]
```

Reader sees:

```markdown
The output for 15 is: FizzBuzz
```

The notation is evaluated during reading!

## Implementation

- `skogparse` - Parser/interpreter for the notation
- `skogcli config` - Type system and operator definitions
- Scripts/tools can be called via `[@name:arg]` syntax
- Results returned as typed JSON structures

## Key Insight

This isn't "literate programming" where code and docs live together - it's **executable intent**. Documents don't contain code snippets; they contain intent markers that resolve to live results.
