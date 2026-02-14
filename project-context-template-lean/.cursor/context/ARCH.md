# Architecture

> **AI Synopsis**
> - **Stack**: [Lang] + [Framework] + [DB] on [Platform]
> - **Pattern**: [e.g., Feature-based modules, Microservices, Monolith]
> - **Key Services**: [List 2-3 main components]
> - **External**: [Key integrations]
> - **Critical**: [Main constraint or optimization]

---

## Stack

| Layer | Tech | Version | Why |
|-------|------|---------|-----|
| **Language** | [e.g., TypeScript] | [5.3] | [Reason] |
| **Framework** | [e.g., Next.js] | [15] | [Reason] |
| **Database** | [e.g., PostgreSQL] | [16] | [Reason] |
| **Deploy** | [e.g., Vercel] | - | [Reason] |

**Key Libraries**:
- [Lib]: [Purpose]
- [Lib]: [Purpose]

---

## Structure

```
/src/
  /features/[name]/  # Feature modules
    /components/
    /hooks/
    /utils/
  /shared/           # Reusable code
  /api/              # API routes
```

---

## Key Components

**[Component 1]**:
- **What**: [Purpose]
- **Where**: [Path]
- **Deps**: [Dependencies]

**[Component 2]**:
- **What**: [Purpose]
- **Where**: [Path]

---

## Data Flow

```
Request → [A] → [B] → DB → Response
```

**Models**:
- `[Model]`: `{field: type}` - [Purpose]
- `[Model]`: `{field: type}` - [Purpose]

---

## Integrations

| Service | Purpose | Auth | Docs |
|---------|---------|------|------|
| [Name] | [Why use] | [Method] | [URL] |

---

## Critical Constraints

- [Constraint 1] - [Impact]
- [Constraint 2] - [Impact]

<details>
<summary>Optional: Environment Config</summary>

```
REQUIRED_VAR=description
OPTIONAL_VAR=description (default: value)
```

</details>
