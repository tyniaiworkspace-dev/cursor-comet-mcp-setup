# Conventions

> **AI Synopsis**
> - **Style**: [Formatter name + key rules]
> - **Pattern**: [Main architectural pattern]
> - **Critical Rules**: [Top 2-3 non-negotiable standards]
> - **Linter**: [Tool + config file]

---

## Code Style

**Formatting** (enforced by [tool]):
- Indent: [spaces/tabs]
- Quotes: [single/double]
- Line length: [chars]

**Naming**:
```
files:      camelCase.ts, PascalCase.tsx
functions:  verbNoun() (getUserData)
variables:  camelCase
constants:  UPPER_SNAKE_CASE
types:      PascalCase
```

---

## Patterns

**Error Handling**:
```typescript
// ✅ Do
try {
  const data = await fetch();
  return data;
} catch (error) {
  if (error instanceof SpecificError) {
    // handle specifically
  }
  throw error;
}
```

**Component Structure** (if React/Vue):
```typescript
// 1. Hooks
// 2. Effects
// 3. Handlers
// 4. Early returns
// 5. Render
```

---

## API Conventions

- **Endpoints**: `/resources` (plural)
- **Methods**: REST verbs
- **Response**: `{ data, meta }` format

---

## Testing

**What to test**:
- ✅ Business logic
- ✅ Edge cases
- ❌ Implementation details

**Naming**: `should [do expected] when [condition]`

---

## Git

**Branches**: `feature/description`, `bugfix/issue-123`

**Commits**: `type(scope): description`
- Types: `feat`, `fix`, `docs`, `refactor`

<details>
<summary>Optional: Full standards</summary>

[Detailed conventions if needed]

</details>
