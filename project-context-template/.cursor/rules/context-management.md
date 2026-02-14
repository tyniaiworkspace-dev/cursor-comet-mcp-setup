# Context Management Rule

## Project Memory System

This project uses a context management system in `.cursor/context/` to maintain knowledge across sessions.

## Key Context Files

- **PROJECT_OVERVIEW.md** - Project basics and current state
- **ARCHITECTURE.md** - Technical structure and decisions  
- **PROGRESS.md** - Timeline of completed work
- **DECISIONS.md** - Important decisions and rationale
- **TODO.md** - Current tasks and priorities
- **CONVENTIONS.md** - Project-specific standards

## Automatic Behaviors

### When User Asks for Context
If user asks "what's the current state?", "catch me up", or similar:
- Read relevant `.cursor/context/` files
- Provide concise summary
- Highlight current priorities

### After Significant Work
When features complete, architecture changes, or decisions are made:
- Suggest specific context file updates
- Provide exact content to add/change
- Ask for approval before updating

### Before Major Changes
When user is about to make architectural changes:
- Recommend reviewing `ARCHITECTURE.md` and `DECISIONS.md`
- Suggest using @-mentions to include context

## Usage Patterns

### For Quick Context
Encourage: `@.cursor/context/TODO.md what should I work on?`

### For Architecture Review
Encourage: `@.cursor/context/ARCHITECTURE.md @.cursor/context/DECISIONS.md` before changes

### For Progress Summary
Encourage: `@.cursor/context/PROGRESS.md summarize recent work`

## Update Frequency

- **TODO.md**: Update frequently (after task completion)
- **PROGRESS.md**: Update weekly or after milestones  
- **ARCHITECTURE.md**: Update when structure changes
- **DECISIONS.md**: Update when significant decisions made
- **PROJECT_OVERVIEW.md**: Update at phase transitions
- **CONVENTIONS.md**: Update when patterns established

## Keep Files Concise

- Each file should stay under 500 lines
- Archive old content in collapsible sections
- Use consistent formatting and dates
- Cross-reference between files

## Do NOT Update For

- Minor bug fixes
- Routine maintenance  
- Trivial changes
- Work still in progress

## Integration with project-memory Skill

The `project-memory` skill handles context management automatically. This rule ensures:
- Context files are suggested at appropriate times
- @-mentions are encouraged for context inclusion
- Files stay current and actionable

## Key Principle

**Make context management natural and effortless, not a burden.**
