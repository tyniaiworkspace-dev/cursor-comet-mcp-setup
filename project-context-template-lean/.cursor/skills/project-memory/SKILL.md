---
name: project-memory-lean
description: Token-optimized project context management using progressive loading. Loads AI Synopsis first, expands details only when needed. Maintains context files efficiently, suggests updates after significant work, and restores context quickly with minimal token usage. Use when catching up on projects, after completing features, or making decisions.
---

# Project Memory (Token-Optimized)

Maintain project context efficiently using progressive loading and token-aware strategies.

## Core Principle

**Load only what's needed, when it's needed.**

## Progressive Loading Strategy

### Level 1: Synopsis-Only (400 tokens)
**When**: Quick status check  
**Load**: AI Synopsis sections from all files  
**Query**: "Quick project status"

### Level 2: Standard (1,500-2,500 tokens)
**When**: Normal work (most common)  
**Load**: Synopsis + main sections, collapse `<details>`  
**Query**: "Catch me up" or "Current state?"

### Level 3: Full Context (4,000+ tokens)
**When**: Deep dive or complex question  
**Load**: Everything including optional sections  
**Query**: "Explain entire architecture" or explicit request

## File Priorities

### Always Load (Critical)
1. AI Synopsis from all files
2. Current tasks (TASKS.md or TODO.md)
3. Recent progress (last sprint from PROGRESS.md)

### Load When Relevant (Contextual)
4. Architecture (when discussing structure)
5. Decisions (when context needed)
6. Conventions (when reviewing code)

### Load On-Demand (Optional)
7. Historical progress (archived sections)
8. Full decision rationale (details tags)
9. Extended examples

## Context File Structure

### Lean Multi-File Option (6 files)
**Files**: PROJECT.md, ARCH.md, TASKS.md, PROGRESS.md, DECISIONS.md, CONVENTIONS.md  
**Tokens**: ~2,000-3,000 total  
**Best for**: Most projects

### Minimal Single-File Option (1 file)
**File**: CONTEXT.md  
**Tokens**: ~800-1,500 total  
**Best for**: Small projects, quick prototypes

## When to Update

### High Priority (Always Suggest)
- Feature completed
- Architecture changed
- Important decision made
- Sprint/milestone complete

### Medium Priority (Suggest if Significant)
- Bug fix (if major)
- Refactor (if architectural)
- New pattern established

### Low Priority (User-Initiated Only)
- Minor changes
- Routine maintenance
- Trivial updates

## Update Process (Token-Efficient)

### 1. Detect Change
Identify what changed without re-reading all files.

### 2. Targeted Update
Update only affected files, not everything.

### 3. Minimal Edit
Add 1-3 lines, not full sections.

### 4. Preserve Token Budget
Keep updates concise and factual.

**Example**:
```
Instead of:
"I completed the user authentication feature which includes
login, logout, password reset, email verification, and..."

Use:
"- ✅ User auth - Feb 9: Login, logout, password reset, email verify"
```

## Context Restoration (Optimized)

### Quick Catchup
**Query**: "Catch me up"

**Process**:
1. Read AI Synopsis from each file (~400 tokens)
2. Summarize in 3-4 sentences
3. Highlight top priorities
4. **Total time**: <1 second

### Detailed Catchup
**Query**: "Full project overview"

**Process**:
1. Read AI Synopsis (~400 tokens)
2. Read main sections, skip `<details>` (~1,500 tokens)
3. Provide comprehensive summary
4. **Total time**: ~1-2 seconds

### Targeted Query
**Query**: "How does authentication work?"

**Process**:
1. Read ARCH.md AI Synopsis (~50 tokens)
2. Read auth section from ARCH.md (~200 tokens)
3. Read related decision from DECISIONS.md if exists (~150 tokens)
4. **Total tokens**: ~400 vs 6,000+ for full context!

## AI Synopsis Structure

**Template** (always at file top):
```markdown
> **AI Synopsis**
> - [Fact 1 with key data]
> - [Fact 2 with key data]
> - [Fact 3 with key data]
> - [Critical constraint or blocker]
> - Updated: [Date]
```

**Guidelines**:
- 3-10 bullets max
- Dense factual information
- No fluff or pleasantries
- Include critical data (dates, status, blockers)
- Update this section every time file changes

## Token-Aware Suggestions

### Concise Update Format
```
"Update PROGRESS.md:
- ✅ Payment integration - Feb 9
- ✅ Stripe webhooks working

Update TASKS.md:
- [x] Integrate Stripe
- [ ] Production API keys (next)

Make these updates?"
```

### Not:
```
"I think we should update the progress tracking file to reflect 
that you've completed the payment integration feature which was
a significant milestone. This involved integrating with Stripe's
API, setting up webhook handlers..."
```

**Savings**: 70% fewer tokens in update suggestions!

## Smart File Selection

**Question analysis**:
- "What's the status?" → Load PROJECT.md Synopsis only
- "Catch me up" → Load all Synopsis + TASKS.md main
- "How does X work?" → Load ARCH.md targeted section
- "Why did we choose Y?" → Load DECISIONS.md specific decision
- "What should I do?" → Load TASKS.md only

**Result**: Load minimum necessary tokens!

## Maintenance Pattern

### Weekly Review
1. Check total token count of all files
2. Archive content if any file >1,000 tokens
3. Compress verbose sections to bullets
4. Verify AI Synopsis is current

### Monthly Optimization
1. Review token usage logs
2. Identify heavily-loaded sections
3. Compress or split large sections
4. Update based on actual query patterns

## Best Practices

**DO**:
- ✅ Use AI Synopsis in every file
- ✅ Keep main sections under 200 tokens
- ✅ Collapse optional content
- ✅ Use tables and bullets
- ✅ Load progressively
- ✅ Archive aggressively

**DON'T**:
- ❌ Load all files for simple queries
- ❌ Duplicate info across files
- ❌ Use prose when bullets suffice
- ❌ Keep all history inline
- ❌ Expand details unless requested

## Example Interaction (Optimized)

**Query**: "Catch me up on this project"

**Old Process** (Full Version):
```
1. Load all 6 files completely (~6,000 tokens)
2. Parse everything
3. Generate summary
Time: 3-5 seconds | Cost: ~$0.06
```

**New Process** (Lean Version):
```
1. Load AI Synopsis from 6 files (~400 tokens)
2. Load TASKS.md main section (~300 tokens)
3. Generate summary from ~700 tokens
Time: <1 second | Cost: ~$0.007
```

**Savings**: 88% tokens, 5x faster, 90% cheaper!

## Token Budget Guide

### File Token Targets

| File | Tokens | Max | Notes |
|------|--------|-----|-------|
| AI Synopsis (all) | 400 | 600 | Combined all files |
| CONTEXT.md (single) | 1,200 | 1,500 | If using single-file |
| PROJECT.md | 300 | 500 | Overview only |
| ARCH.md | 400 | 800 | Core structure |
| TASKS.md | 400 | 700 | Current work |
| PROGRESS.md | 300 | 600 | Recent only |
| DECISIONS.md | 300 | 600 | Active only |
| CONVENTIONS.md | 300 | 500 | Critical rules |
| **TOTAL** | **2,200** | **3,000** | Lean target |

### Query Token Budgets

| Query Type | Target Tokens | Files Loaded |
|------------|---------------|--------------|
| Quick status | <500 | Synopsis only |
| Normal catchup | 1,500-2,000 | Synopsis + main |
| Deep dive | 2,500-3,500 | All with some details |
| Full audit | 4,000-6,000 | Everything |

---

## Quick Reference

**Load minimum**: AI Synopsis (~400 tokens)  
**Load standard**: Synopsis + main sections (~1,500-2,000 tokens)  
**Load maximum**: All with details (~4,000-6,000 tokens)

**Update**: Concise bullets, not prose  
**Maintain**: Weekly compression, monthly optimization  
**Archive**: Move old content to `<details>` tags

**Goal**: <2,500 tokens for normal context restoration!

---

**Token-optimized context management that's fast, cheap, and effective!** ⚡💰🚀
