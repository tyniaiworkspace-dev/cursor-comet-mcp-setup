# Project Context Management System - Design Document

## Problem Statement

**Challenge**: Long-running projects lose context when:
- Context window resets after 200k tokens
- Switching between projects
- Taking breaks and returning later
- Onboarding new team members
- AI needs to understand project history

**Goal**: Create a persistent, auto-updating documentation system that:
- Maintains project memory across sessions
- Automatically updates as work progresses
- Enables quick context restoration
- Works as a reusable template
- Integrates with Cursor features

---

## Proposed Solution

### Three-Layer System:

#### Layer 1: Context Files (`.cursor/context/`)
Markdown files that track project state:
- `PROJECT_OVERVIEW.md` - What, why, current state
- `ARCHITECTURE.md` - Technical structure and decisions
- `PROGRESS.md` - Timeline and completed work
- `DECISIONS.md` - Key decisions and rationale
- `TODO.md` - Current tasks and next steps
- `CONVENTIONS.md` - Project-specific patterns

#### Layer 2: Cursor Skill (`.cursor/skills/project-memory/`)
Intelligent agent that:
- Knows when to update context files
- Maintains consistency across files
- Suggests updates after significant work
- Helps restore context when asked

#### Layer 3: Cursor Rule (`.cursor/rules/context-management.md`)
Automatic behavior that:
- Reminds to update context at key moments
- Encourages @-mentioning context files
- Enforces documentation standards

---

## File Structure

```
project-root/
├── .cursor/
│   ├── context/              # Project memory files
│   │   ├── PROJECT_OVERVIEW.md
│   │   ├── ARCHITECTURE.md
│   │   ├── PROGRESS.md
│   │   ├── DECISIONS.md
│   │   ├── TODO.md
│   │   └── CONVENTIONS.md
│   │
│   ├── skills/               # Project-specific skills
│   │   └── project-memory/
│   │       └── SKILL.md
│   │
│   └── rules/                # Project rules
│       └── context-management.md
│
└── [project files...]
```

---

## Usage Workflow

### Initial Setup (Once per project):
1. Copy template files to `.cursor/context/`
2. Fill in initial project overview
3. Skill and rule activate automatically

### During Development:
1. Work normally on your project
2. AI automatically suggests context updates after:
   - Major features completed
   - Architecture decisions made
   - Significant refactoring
   - Sprint/milestone completion
3. Use `@.cursor/context/PROGRESS.md` to review progress
4. Use `@.cursor/context/ARCHITECTURE.md` when making changes

### Context Restoration:
When returning to project after break:
```
User: "Catch me up on this project"
AI: Reads `.cursor/context/` files and provides summary
```

---

## Key Features

### 1. Automatic Update Triggers
Skill detects when to update:
- After completing tasks
- After making architectural changes
- After implementing new features
- After fixing significant bugs
- At user request

### 2. Smart Summarization
- Keeps files concise (under 500 lines each)
- Archives old content when needed
- Progressive detail levels

### 3. Cross-File Consistency
- Ensures dates match across files
- Links related information
- Maintains unified terminology

### 4. Quick Restoration
- Single command to get caught up
- Targeted @-mentions for specific context
- Chronological progress tracking

---

## Benefits

✅ **Never lose context** - Persistent across sessions
✅ **Quick onboarding** - New team members read context files
✅ **Better decisions** - Easy to review why choices were made
✅ **Audit trail** - Clear history of what was done when
✅ **Reusable** - Copy template to any project
✅ **Low overhead** - Updates happen naturally during work
✅ **Cursor-native** - Uses @-mentions, skills, rules

---

## Implementation Plan

1. **Create context file templates** with clear structure
2. **Build project-memory skill** for intelligent updates
3. **Write context-management rule** for automatic behavior
4. **Create project setup script** for easy template copying
5. **Document usage patterns** and best practices

---

## Example Usage Scenarios

### Scenario 1: Starting Work Session
```
User: "What should I work on today?"
AI: Reads @.cursor/context/TODO.md
    Provides prioritized list with context
```

### Scenario 2: Making Architecture Decision
```
User: "Should we use Redis or in-memory cache?"
AI: After decision is made, suggests:
    "Update DECISIONS.md with this caching choice"
```

### Scenario 3: Completing Feature
```
User: "I just finished the user authentication"
AI: Automatically suggests:
    "Update PROGRESS.md with completion date"
    "Update TODO.md to mark task complete"
    "Consider updating ARCHITECTURE.md with auth flow"
```

### Scenario 4: Context Loss
```
User: "I haven't worked on this in 3 weeks, catch me up"
AI: Reads all context files
    Provides: Last work done, current state, next steps
```

---

## Success Metrics

- ✅ Can restore full context in under 2 minutes
- ✅ Files stay under 500 lines (readable)
- ✅ Updates happen naturally during work
- ✅ Team members can onboard from files alone
- ✅ No redundant information across files

---

**Next Step**: Implement this system with working templates and skills!
