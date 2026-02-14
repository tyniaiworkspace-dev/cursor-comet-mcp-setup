---
name: project-memory
description: Maintains project context files in .cursor/context/ to preserve knowledge across sessions. Automatically suggests updates after significant work, helps restore context when returning to project, and ensures documentation stays current. Use when completing features, making decisions, or when user asks to catch up on project status.
---

# Project Memory Management

This skill maintains persistent project context through structured markdown files, ensuring knowledge is never lost across sessions.

## Core Responsibility

Keep `.cursor/context/` files current and help restore context efficiently.

## Context Files Overview

| File | Purpose | Update Trigger |
|------|---------|---------------|
| `PROJECT_OVERVIEW.md` | High-level what/why/status | Project changes, milestone completion |
| `ARCHITECTURE.md` | Technical structure | Architecture changes, new integrations |
| `PROGRESS.md` | Timeline and completed work | Feature completion, sprint end |
| `DECISIONS.md` | Key decisions and rationale | Architectural decisions, tool choices |
| `TODO.md` | Current tasks and next steps | Task completion, priority changes |
| `CONVENTIONS.md` | Project-specific standards | New patterns established |

## When to Suggest Updates

### Automatic Triggers

**After Feature Completion**:
```
User: "I just finished the user authentication feature"
AI: Suggests updating:
  - PROGRESS.md: Add feature completion with date
  - TODO.md: Mark authentication tasks complete
  - ARCHITECTURE.md: Document auth flow if significant
```

**After Architecture Changes**:
```
User: "I've refactored the database layer to use Prisma"
AI: Suggests updating:
  - ARCHITECTURE.md: Update data layer section
  - DECISIONS.md: Document why Prisma was chosen
  - PROGRESS.md: Note the refactor completion
```

**After Important Decisions**:
```
User: "We're going with Redis for caching instead of in-memory"
AI: Suggests updating:
  - DECISIONS.md: Add caching decision with rationale
  - ARCHITECTURE.md: Update caching section
  - TODO.md: Add Redis integration tasks if not done
```

**End of Sprint/Week**:
```
User: "We're wrapping up this sprint"
AI: Suggests:
  - PROGRESS.md: Summarize week's accomplishments
  - TODO.md: Archive completed, add next sprint items
  - PROJECT_OVERVIEW.md: Update current state
```

### User-Requested Updates

**Context Restoration**:
```
User: "Catch me up on this project" or "What's the current state?"
AI: 
  1. Reads all .cursor/context/ files
  2. Summarizes: What works, what's in progress, what's next
  3. Highlights any blockers or decisions needed
```

**Manual Update Request**:
```
User: "Update the project context" or "Update PROGRESS.md"
AI: Reviews recent work and suggests specific updates
```

## Update Process

### 1. Detect What Changed
- Review conversation history for completed work
- Identify significant changes or decisions
- Check if milestones were reached

### 2. Suggest Specific Updates
```markdown
I suggest updating the project context:

**PROGRESS.md**:
- Add: "User Authentication Feature - Completed Feb 9, 2026"
- Mark sprint goal as complete

**TODO.md**:
- [x] Implement login endpoint
- [x] Add JWT token validation
- [ ] Add password reset (move to current sprint)

**ARCHITECTURE.md**:
- Update Authentication section with JWT flow
- Document middleware structure

Would you like me to make these updates?
```

### 3. Make Updates if Approved
- Use StrReplace to update files
- Maintain consistent formatting
- Add dates for timeline clarity
- Keep files concise (under 500 lines each)

## Context Restoration Patterns

### Pattern 1: Full Project Catchup
```
User: "I haven't worked on this in 2 weeks, catch me up"

AI Process:
1. Read PROJECT_OVERVIEW.md for project basics
2. Read PROGRESS.md for recent work
3. Read TODO.md for current state
4. Read DECISIONS.md if architecture questions exist
5. Summarize:
   - "This is [project name], a [description]"
   - "Last major work: [from PROGRESS.md]"
   - "Current focus: [from TODO.md]"
   - "Next steps: [from TODO.md]"
   - "Blockers: [if any]"
```

### Pattern 2: Specific Area Catchup
```
User: "Remind me how authentication works in this project"

AI Process:
1. Read ARCHITECTURE.md authentication section
2. Read DECISIONS.md for auth-related decisions
3. Provide summary with code examples
```

### Pattern 3: Decision History
```
User: "Why did we choose PostgreSQL?"

AI Process:
1. Search DECISIONS.md for database choice
2. Provide rationale and context
3. Mention if decision has been superseded
```

## File-Specific Guidance

### PROJECT_OVERVIEW.md
**Update when**:
- Project enters new phase
- Major milestone reached
- Team composition changes
- Goals or success criteria change

**Keep current**:
- Current status (Planning/Development/Production)
- What works now vs what's planned
- Key challenges and their status

### ARCHITECTURE.md
**Update when**:
- Adding new services/integrations
- Changing data flow
- Refactoring major components
- Adding/changing external APIs
- Performance optimizations implemented

**Keep accurate**:
- Technology stack versions
- Component relationships
- Data models (as they evolve)
- API endpoints

### PROGRESS.md
**Update when**:
- Features completed
- Sprints/milestones reached
- Major bugs fixed
- Significant refactors done
- End of week/sprint

**Maintain chronology**:
- Most recent work at top
- Archive old entries in collapsible sections
- Include completion dates
- Link to related decisions

### DECISIONS.md
**Update when**:
- Choosing technologies
- Deciding architecture approaches
- Selecting libraries/tools
- Setting standards or conventions
- Making significant tradeoffs

**Document thoroughly**:
- What options were considered
- Why chosen option won
- What tradeoffs were made
- When decision might need revisiting

### TODO.md
**Update frequently**:
- Tasks completed (move to PROGRESS.md)
- New tasks identified
- Priorities changed
- Blockers discovered/resolved
- Sprint goals updated

**Keep actionable**:
- Clear task descriptions
- Owners and deadlines
- Dependencies noted
- Estimates included

### CONVENTIONS.md
**Update when**:
- Establishing new patterns
- Changing coding standards
- Adding tools or processes
- Team agreements on practices

**Keep practical**:
- Show examples (do/don't)
- Explain reasoning when non-obvious
- Link to configs (eslint, prettier)
- Update as practices evolve

## Best Practices

### Timing
- Suggest updates naturally after significant work
- Don't interrupt flow - wait for natural breaks
- Batch related updates together
- Update weekly at minimum

### Content Quality
- Be specific: "User auth completed Feb 9" not "Made progress"
- Include context: Why decisions matter
- Link related information across files
- Keep language consistent

### File Management
- Keep each file under 500 lines
- Archive old content in collapsible sections
- Use consistent date formats (YYYY-MM-DD)
- Cross-reference between files with links

### User Experience
- Always ask before making changes
- Suggest specific edits, don't be vague
- Group related updates logically
- Make it easy to accept/modify suggestions

## Integration with @-mentions

Encourage using @-mentions for context:
```
"Before we change the API, check @.cursor/context/ARCHITECTURE.md and @.cursor/context/DECISIONS.md"
```

## Avoiding Over-Documentation

**Don't update for**:
- Minor bug fixes (unless significant)
- Routine maintenance
- Trivial changes
- Work in progress (wait for completion)

**Do update for**:
- Completed features
- Architectural changes
- Important decisions
- Sprint/milestone completion
- Significant bug fixes

## Example Interactions

### Example 1: Feature Completion
```
User: "I finished implementing the payment integration with Stripe"

AI: Great! I suggest updating the project context:

**PROGRESS.md**:
Add under recent milestones:
### Payment Integration - Feb 9, 2026
- Implemented Stripe payment processing
- Added webhook handling for payment events
- Tested with test API keys

**TODO.md**:
- [x] Integrate Stripe SDK
- [x] Create payment endpoints
- [x] Add webhook handlers
- [ ] Switch to production API keys (move to current sprint)

**ARCHITECTURE.md**:
Add to External Integrations:
### Stripe Payment Processing
- Purpose: Handle payments and subscriptions
- API Docs: https://stripe.com/docs/api
- Auth: API keys in environment variables
- Webhooks: /api/webhooks/stripe endpoint

Would you like me to make these updates?
```

### Example 2: Context Restoration
```
User: "What have I been working on this week?"

AI: *Reads PROGRESS.md and TODO.md*

Based on your progress tracking:

**This week (Feb 5-9, 2026)**:
✅ Completed:
- User authentication system with JWT
- Password reset functionality
- Email verification flow

🔄 In Progress:
- Payment integration with Stripe (90% done)
- Dashboard UI refinements

📋 Next Up:
- User profile management
- Admin panel foundation

Your current sprint goal is to complete the core user features, and you're on track!
```

### Example 3: Decision Review
```
User: "Why did we choose Next.js for this project?"

AI: *Reads DECISIONS.md*

From DECISIONS.md (decision made Jan 15, 2026):

**Decision**: Next.js 15 with App Router

**Rationale**:
- Built-in SSR and SSG for SEO requirements
- Excellent TypeScript support (team preference)
- Vercel deployment simplifies CI/CD
- Large ecosystem and community
- React Server Components for performance

**Tradeoffs**:
- Higher learning curve vs vanilla React
- Vendor lock-in risk with Vercel
- More opinionated structure

This decision was made considering your team's React experience and the need for good SEO on marketing pages.
```

## Summary

This skill ensures your project's knowledge persists across sessions by:
- ✅ Maintaining up-to-date context files
- ✅ Suggesting updates at natural points
- ✅ Helping restore context quickly
- ✅ Preserving decision rationale
- ✅ Tracking progress chronologically
- ✅ Keeping documentation actionable

**Key principle**: Make updates effortless and natural, never a burden.
