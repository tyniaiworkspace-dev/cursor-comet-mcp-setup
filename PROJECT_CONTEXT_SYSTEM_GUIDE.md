# Project Context Management System - Complete Guide

> **Your Improved Prompt**: "I want to create a context management system for my projects that maintains project memory across sessions using markdown files that automatically update as the project progresses, allowing AI to quickly restore context when needed, working as a reusable template across all my projects, and integrating with Cursor's features (skills, rules, @-mentions)."

---

## 🎯 What This System Does

**Problem Solved**: Context loss when:
- The 200k token window resets
- Switching between projects  
- Taking breaks and returning later
- Onboarding team members
- AI needs project history

**Solution**: Persistent markdown files that:
- ✅ Automatically update as you work
- ✅ Restore full context in minutes
- ✅ Work across all your projects
- ✅ Integrate natively with Cursor
- ✅ Require minimal maintenance

---

## 📁 System Components

### 1. Context Files (`.cursor/context/`)

Six markdown files that track everything:

| File | What It Tracks | Updates |
|------|---------------|---------|
| **PROJECT_OVERVIEW.md** | What, why, current state | When project changes phase |
| **ARCHITECTURE.md** | Tech stack, structure | When architecture changes |
| **PROGRESS.md** | Timeline, completed work | Weekly, after milestones |
| **DECISIONS.md** | Key decisions, rationale | When decisions are made |
| **TODO.md** | Current tasks, priorities | After task completion |
| **CONVENTIONS.md** | Coding standards, patterns | When patterns established |

### 2. Project-Memory Skill (`.cursor/skills/project-memory/`)

Intelligent assistant that:
- Knows when to suggest context updates
- Helps restore context when you return
- Maintains file consistency
- Suggests specific edits (not vague)

### 3. Context-Management Rule (`.cursor/rules/`)

Automatic behavior:
- Reminds about context at key moments
- Encourages @-mention usage
- Enforces documentation quality

---

## 🚀 Quick Start

### Step 1: Copy Template to Your Project

```powershell
# Navigate to your project
cd "C:\path\to\your\project"

# Run setup script
& "c:\Users\admin\Perplexity mcp\project-context-template\setup-project-memory.ps1"
```

**What this does**:
- Creates `.cursor/context/` with 6 template files
- Adds `project-memory` skill
- Adds `context-management` rule
- Everything activates automatically!

### Step 2: Initialize Your Project Context

Open your project in Cursor and ask:
```
"Help me fill in the project overview and architecture files"
```

The AI will interview you and populate:
- PROJECT_OVERVIEW.md with project basics
- ARCHITECTURE.md with your tech stack
- TODO.md with initial tasks

### Step 3: Start Working Normally

That's it! The system now:
- Suggests updates after significant work
- Helps restore context when you return
- Keeps documentation current
- Works automatically in the background

---

## 💡 How to Use

### Restoring Context

**After a break:**
```
You: "Catch me up on this project"

AI: *Reads all context files*
"This is [ProjectName], a [description]. 
Last week you completed [features].
Currently working on [current tasks].
Next up: [priorities]."
```

**For specific areas:**
```
You: "Remind me how authentication works"

AI: *Reads ARCHITECTURE.md auth section*
"Auth uses JWT tokens stored in httpOnly cookies..."
```

**For decision history:**
```
You: "Why did we choose PostgreSQL?"

AI: *Reads DECISIONS.md*
"From Jan 15 decision: PostgreSQL was chosen because..."
```

### Using @-Mentions for Context

Include context files in your prompts:

```
@.cursor/context/ARCHITECTURE.md How should I structure the new payment feature?
```

```
@.cursor/context/TODO.md What should I prioritize today?
```

```
@.cursor/context/DECISIONS.md @.cursor/context/ARCHITECTURE.md 
Should we add Redis caching?
```

### Automatic Context Updates

**The AI suggests updates automatically:**

```
You: "I just finished the user authentication feature"

AI: "Great! I suggest updating:

PROGRESS.md:
### User Authentication - Feb 9, 2026
- Implemented JWT-based auth
- Added login/logout endpoints
- Password reset functionality

TODO.md:
- [x] Implement login endpoint
- [x] Add JWT validation
- [ ] Add OAuth (next sprint)

Would you like me to make these updates?"
```

**You just respond:**
```
You: "Yes"  or  "Yes, but also update ARCHITECTURE.md with the auth flow"
```

---

## 📋 Typical Workflow

### Starting Your Day

```
1. You: "What should I work on today?"
2. AI: *Reads TODO.md* 
   "Top priorities: [list from TODO.md]"
3. You work on tasks...
```

### Completing Work

```
1. You: "I finished implementing the payment integration"
2. AI: "Let me update the context files..."
   *Suggests specific updates to PROGRESS.md, TODO.md, ARCHITECTURE.md*
3. You: "Looks good, update them"
4. AI: *Makes the updates*
```

### Making Decisions

```
1. You: "We need to choose between Redis and Memcached for caching"
2. *Discussion happens*
3. AI: "Since you decided on Redis, I'll update DECISIONS.md with the rationale"
4. *DECISIONS.md gets updated with full context*
```

### End of Sprint

```
1. You: "We're done with this sprint"
2. AI: "Let me update the sprint summary..."
   *Suggests updates to PROGRESS.md, TODO.md, PROJECT_OVERVIEW.md*
3. *Archives completed work, sets up next sprint*
```

### Returning After Break

```
1. You: "I haven't worked on this in 3 weeks, what's happening?"
2. AI: *Reads all context files*
   *Provides comprehensive summary*
3. You're back up to speed in 2 minutes!
```

---

## 🎯 Best Practices

### Do Update For:
- ✅ Completed features
- ✅ Architectural changes
- ✅ Important decisions
- ✅ Sprint/milestone completion
- ✅ Significant bug fixes
- ✅ New patterns established

### Don't Update For:
- ❌ Minor bug fixes
- ❌ Routine maintenance
- ❌ Trivial changes
- ❌ Work in progress (wait until done)

### Keep Files Manageable:
- Under 500 lines each
- Archive old content in collapsible sections
- Use consistent date formats (YYYY-MM-DD)
- Cross-reference between files
- Be specific, not vague

### Update Frequency:
- **TODO.md**: After every task completion
- **PROGRESS.md**: Weekly or after milestones
- **ARCHITECTURE.md**: When structure changes
- **DECISIONS.md**: When decisions are made
- **PROJECT_OVERVIEW.md**: At phase transitions
- **CONVENTIONS.md**: When patterns are established

---

## 🔄 Template Reusability

### For Every New Project:

**Method 1: PowerShell Script**
```powershell
cd "C:\path\to\new\project"
& "c:\Users\admin\Perplexity mcp\project-context-template\setup-project-memory.ps1"
```

**Method 2: Manual Copy**
```powershell
# Copy the .cursor directory
Copy-Item -Path "c:\Users\admin\Perplexity mcp\project-context-template\.cursor" -Destination "C:\path\to\new\project\.cursor" -Recurse
```

**Then customize**:
- Fill in PROJECT_OVERVIEW.md
- Update ARCHITECTURE.md with your stack
- Add initial tasks to TODO.md
- Everything else updates automatically as you work!

---

## 💼 Team Collaboration

### Onboarding New Members:

New team member:
```
"Catch me up on this project"
```

AI reads context files and provides:
- Project overview and goals
- Architecture and tech stack
- Recent progress and current state
- Current priorities and tasks
- Key decisions and rationale

**Result**: Onboarded in minutes, not days!

### Shared Context:

Since context files are in `.cursor/`:
- ✅ Commit to git (recommended)
- ✅ Team has shared understanding
- ✅ No knowledge silos
- ✅ Consistent documentation

---

## 🎓 Advanced Usage

### Custom Sections

Add project-specific sections to any file:

**In ARCHITECTURE.md**:
```markdown
## Deployment Pipeline
[Your custom deployment info]

## Monitoring & Logging
[Your custom monitoring setup]
```

**In CONVENTIONS.md**:
```markdown
## Team-Specific Patterns
[Your team's special conventions]
```

### Additional Files

Add more context files if needed:
- `TESTING.md` - Testing strategies
- `DEPLOYMENT.md` - Deployment procedures
- `SECURITY.md` - Security considerations
- `API.md` - API documentation

Just put them in `.cursor/context/` and reference them!

### Integration with Other Tools

**With GitHub Actions**:
```yaml
# Auto-update PROGRESS.md on merge
- name: Update Progress
  run: echo "- Merged PR #${{ github.event.number }}" >> .cursor/context/PROGRESS.md
```

**With Commit Hooks**:
```bash
# Remind to update context on significant commits
#!/bin/bash
echo "Don't forget to update .cursor/context/ files!"
```

---

## 🔧 Troubleshooting

### AI Not Suggesting Updates

**Check**:
1. Is `.cursor/skills/project-memory/` present?
2. Is `.cursor/rules/context-management.md` present?
3. Try explicitly asking: "Update the project context"

### Context Files Too Large

**Solution**:
- Archive old content in `<details>` tags
- Move history to separate archive files
- Keep main content focused on current

**Example**:
```markdown
## Archive

<details>
<summary>Older progress (click to expand)</summary>

### Q1 2026
- Old accomplishment 1
- Old accomplishment 2

</details>
```

### Updates Not Happening

**Check**:
- Are you completing significant work?
- Minor changes don't trigger updates (by design)
- Manually request: "Update PROGRESS.md with what I just did"

---

## 📊 System Comparison

### Without Context System:
- ❌ Context lost after 200k tokens
- ❌ Repeating information every session
- ❌ No history of decisions
- ❌ Hard to onboard new members
- ❌ Knowledge in people's heads

### With Context System:
- ✅ Context persists forever
- ✅ Quick restoration in minutes
- ✅ Full decision history
- ✅ Easy team onboarding
- ✅ Knowledge in files

---

## 🎯 Real-World Example

**Day 1: Project Start**
```
You: "Starting a new e-commerce project"
AI: "Let's set up the context files..."
*Fills in PROJECT_OVERVIEW.md, ARCHITECTURE.md, TODO.md*
```

**Week 1: Building Features**
```
You: *Complete user auth*
AI: "Update PROGRESS.md?"
You: "Yes"
*Context updated*
```

**Week 2: Architecture Decision**
```
You: "Should we use PostgreSQL or MongoDB?"
*Discussion*
AI: "I'll document this decision in DECISIONS.md"
*Rationale preserved*
```

**Week 4: Taking Break**
```
You: *2 weeks away*
```

**Week 6: Returning**
```
You: "Catch me up"
AI: *Reads all context*
"You were building the checkout flow.
Last commit: Payment integration complete.
Next: Order management system.
Known issue: Stripe webhook retry logic needed."
```

**Back to full speed in 2 minutes!**

---

## 📚 Reference

### Template Location
```
c:\Users\admin\Perplexity mcp\project-context-template\
├── .cursor\
│   ├── context\          # 6 template files
│   ├── skills\           # project-memory skill
│   └── rules\            # context-management rule
└── setup-project-memory.ps1
```

### Key Files Reference

| File | Primary Use | Update Trigger |
|------|-------------|----------------|
| PROJECT_OVERVIEW.md | "What is this?" | Phase changes |
| ARCHITECTURE.md | "How is it built?" | Structure changes |
| PROGRESS.md | "What's been done?" | Feature completion |
| DECISIONS.md | "Why did we do this?" | Decisions made |
| TODO.md | "What's next?" | Task completion |
| CONVENTIONS.md | "How do we code?" | Pattern establishment |

---

## 🎊 Summary

### You Now Have:

✅ **Persistent Project Memory**
- Never lose context across sessions
- Restore full understanding in minutes
- Knowledge survives beyond 200k tokens

✅ **Automatic Maintenance**
- AI suggests updates at natural points
- No manual effort required
- Always stays current

✅ **Reusable Template**
- One-command setup for new projects
- Consistent across all your work
- Team-ready from day one

✅ **Cursor-Native Integration**
- Works with @-mentions
- Skills for intelligence
- Rules for automation

### Key Principle:

**"Set it up once, benefits forever.  
Context management that's effortless, not a burden."**

---

## 🚀 Next Steps

1. **Try It Now**:
   ```powershell
   cd "your-project-path"
   & "c:\Users\admin\Perplexity mcp\project-context-template\setup-project-memory.ps1"
   ```

2. **Fill Initial Context**:
   - Ask AI to help complete PROJECT_OVERVIEW.md
   - Update ARCHITECTURE.md with your stack
   - Add tasks to TODO.md

3. **Start Working**:
   - Work normally
   - Accept update suggestions
   - Use @-mentions when helpful

4. **Experience the Magic**:
   - Take a break
   - Come back
   - Ask "Catch me up"
   - Be amazed!

---

**Created**: February 9, 2026
**System Version**: 1.0
**Status**: ✅ READY TO USE
**Location**: `c:\Users\admin\Perplexity mcp\project-context-template\`

**Your context will never be lost again!** 🎉
