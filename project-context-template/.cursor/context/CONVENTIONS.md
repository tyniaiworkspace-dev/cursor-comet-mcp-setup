# Project Conventions & Standards

> **Last Updated**: [Date]

This file documents project-specific patterns, conventions, and coding standards. New team members should read this to understand "how we do things here."

---

## Code Style

### General Principles
- [Principle 1, e.g., "Prefer functional programming patterns"]
- [Principle 2, e.g., "Prioritize readability over cleverness"]
- [Principle 3, e.g., "Write code for humans first"]

### Formatting
- **Indentation**: [Spaces/tabs and how many]
- **Line Length**: [Maximum characters per line]
- **Quotes**: [Single/double]
- **Semicolons**: [Required/optional]
- **Trailing Commas**: [Required/optional]

**Formatter**: [Tool name and config file]

---

## Naming Conventions

### Files & Directories
```
components/      - React components (PascalCase.tsx)
utils/           - Utility functions (camelCase.ts)
types/           - TypeScript types (PascalCase.ts)
api/             - API routes (kebab-case.ts)
tests/           - Test files (*.test.ts)
```

### Variables & Functions
- **Variables**: `camelCase` - e.g., `userName`, `isActive`
- **Constants**: `UPPER_SNAKE_CASE` - e.g., `MAX_RETRY_COUNT`
- **Functions**: `camelCase` + verb - e.g., `getUserData()`, `handleClick()`
- **Booleans**: `is/has/should` prefix - e.g., `isLoading`, `hasError`
- **Private**: `_` prefix - e.g., `_internalHelper()`

### Classes & Types
- **Classes**: `PascalCase` - e.g., `UserService`, `DataManager`
- **Interfaces**: `PascalCase` + `I` prefix - e.g., `IUser`, `IApiResponse`
- **Types**: `PascalCase` - e.g., `UserData`, `ApiError`
- **Enums**: `PascalCase` - e.g., `UserRole`, `ErrorType`

### Components (React/Vue/etc.)
- **Component Files**: `PascalCase.tsx` - e.g., `UserProfile.tsx`
- **Component Names**: Match filename - e.g., `export const UserProfile`
- **Props Interface**: `[ComponentName]Props` - e.g., `UserProfileProps`
- **Event Handlers**: `handle[Action]` - e.g., `handleSubmit`, `handleClick`

---

## Project Structure Patterns

### Feature-Based Organization
```
src/
├── features/
│   ├── auth/
│   │   ├── components/
│   │   ├── hooks/
│   │   ├── utils/
│   │   ├── types/
│   │   └── index.ts
│   └── dashboard/
│       └── [same structure]
```

### Shared Code
```
src/
├── shared/
│   ├── components/    - Reusable UI components
│   ├── hooks/         - Custom React hooks
│   ├── utils/         - Pure utility functions
│   ├── types/         - Shared TypeScript types
│   └── constants/     - App-wide constants
```

---

## Code Patterns

### Error Handling
```typescript
// ✅ Good: Specific error handling
try {
  const data = await fetchUserData();
  return data;
} catch (error) {
  if (error instanceof NetworkError) {
    // Handle network errors specifically
  } else if (error instanceof ValidationError) {
    // Handle validation errors
  }
  throw error;  // Re-throw if unhandled
}

// ❌ Bad: Swallowing errors
try {
  doSomething();
} catch (error) {
  // Silent failure
}
```

### Async/Await
```typescript
// ✅ Good: Clean async/await usage
async function getUserProfile(id: string): Promise<User> {
  const user = await fetchUser(id);
  const permissions = await fetchPermissions(user.roleId);
  return { ...user, permissions };
}

// ❌ Bad: Mixing promises and async/await
async function getUserProfile(id: string) {
  return fetchUser(id).then(user => {
    return fetchPermissions(user.roleId).then(permissions => {
      return { ...user, permissions };
    });
  });
}
```

### Component Structure
```typescript
// ✅ Good: Consistent component structure
export const UserProfile: React.FC<UserProfileProps> = ({ userId }) => {
  // 1. Hooks first
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  
  // 2. Effects
  useEffect(() => {
    loadUser();
  }, [userId]);
  
  // 3. Event handlers
  const handleUpdate = () => {
    // Handler logic
  };
  
  // 4. Helper functions (or extract to utils)
  const loadUser = async () => {
    // Load logic
  };
  
  // 5. Early returns
  if (loading) return <LoadingSpinner />;
  if (!user) return <NotFound />;
  
  // 6. Render
  return (
    <div>
      {/* Component JSX */}
    </div>
  );
};
```

---

## API Conventions

### Endpoint Naming
- **Resources**: Plural nouns - `/users`, `/posts`
- **Actions**: HTTP verbs - `GET`, `POST`, `PUT`, `PATCH`, `DELETE`
- **Nesting**: Max 2 levels - `/users/{id}/posts` ✅, `/users/{id}/posts/{id}/comments` ❌

### Request/Response Format
```typescript
// Request
{
  "data": { /* payload */ },
  "meta": { /* request metadata */ }
}

// Success Response
{
  "data": { /* response data */ },
  "meta": { 
    "timestamp": "2026-02-09T10:00:00Z",
    "requestId": "abc123"
  }
}

// Error Response
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable message",
    "details": { /* additional context */ }
  },
  "meta": { "requestId": "abc123" }
}
```

---

## Testing Conventions

### Test File Structure
```typescript
describe('ComponentName', () => {
  // Setup
  beforeEach(() => {
    // Common setup
  });
  
  // Grouped tests
  describe('when condition', () => {
    it('should do expected behavior', () => {
      // Arrange
      // Act
      // Assert
    });
  });
});
```

### Test Naming
- Use descriptive names: `should return user data when ID is valid`
- Not just: `test1`, `getUserTest`

### What to Test
- ✅ Business logic
- ✅ Edge cases
- ✅ Error conditions
- ✅ User interactions
- ❌ Implementation details
- ❌ Third-party library internals

---

## Git Conventions

### Branch Naming
```
feature/short-description
bugfix/issue-number-description
hotfix/critical-issue
refactor/what-is-refactored
docs/what-is-documented
```

### Commit Messages
```
type(scope): brief description

Detailed explanation if needed

Closes #issue-number
```

**Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

**Examples**:
- `feat(auth): add password reset functionality`
- `fix(api): handle null values in user response`
- `docs(readme): update installation instructions`

---

## Documentation Standards

### Code Comments
```typescript
// ✅ Good: Explain WHY, not WHAT
// Use binary search because array is pre-sorted (performance)
const index = binarySearch(data, target);

// ❌ Bad: Stating the obvious
// Search for the target in data
const index = binarySearch(data, target);
```

### Function Documentation
```typescript
/**
 * Fetch user data with retry logic for network failures
 * 
 * @param userId - Unique user identifier
 * @param options - Optional configuration
 * @param options.retries - Max retry attempts (default: 3)
 * @param options.timeout - Request timeout in ms (default: 5000)
 * @returns User data object
 * @throws {NetworkError} When network is unavailable
 * @throws {NotFoundError} When user doesn't exist
 * 
 * @example
 * const user = await fetchUser('123', { retries: 5 });
 */
async function fetchUser(
  userId: string, 
  options?: FetchOptions
): Promise<User>
```

---

## Environment & Configuration

### Environment Variables
- All caps with underscores: `DATABASE_URL`, `API_KEY`
- Prefix by category: `DB_HOST`, `CACHE_TTL`, `MAIL_FROM`
- Document in `.env.example`
- Never commit actual values

### Configuration Files
- `config/development.ts` - Dev settings
- `config/production.ts` - Prod settings
- `config/test.ts` - Test settings
- Use type-safe configuration objects

---

## Performance Guidelines

### Do's
- ✅ Lazy load routes and large components
- ✅ Memoize expensive calculations
- ✅ Use pagination for large lists
- ✅ Optimize images and assets
- ✅ Cache API responses appropriately

### Don'ts
- ❌ Fetch data in loops
- ❌ Store large objects in state
- ❌ Use synchronous operations for I/O
- ❌ Forget to clean up effects
- ❌ Ignore bundle size

---

## Security Guidelines

### Do's
- ✅ Validate all user input
- ✅ Sanitize data before displaying
- ✅ Use parameterized queries (prevent SQL injection)
- ✅ Implement rate limiting
- ✅ Use HTTPS for all requests
- ✅ Store secrets in environment variables

### Don'ts
- ❌ Trust client-side validation alone
- ❌ Log sensitive data
- ❌ Expose internal errors to users
- ❌ Store passwords in plain text
- ❌ Use `eval()` or similar dangerous functions

---

## Review Checklist

Before submitting code for review:

### Code Quality
- [ ] Follows naming conventions
- [ ] No commented-out code
- [ ] No console.logs or debugger statements
- [ ] Error handling implemented
- [ ] Edge cases considered

### Testing
- [ ] New features have tests
- [ ] All tests pass locally
- [ ] Coverage meets minimum threshold

### Documentation
- [ ] Complex logic is commented
- [ ] README updated if needed
- [ ] API docs updated if endpoints changed

### Security
- [ ] No secrets in code
- [ ] Input validation added
- [ ] SQL injection prevented
- [ ] XSS prevented

---

## Resources

- **Style Guide**: [Link to detailed style guide]
- **API Documentation**: [Link to API docs]
- **Design System**: [Link to design system]
- **Linter Config**: `.eslintrc.js`
- **Formatter Config**: `.prettierrc`

---

**Note**: These conventions should be enforced through linting, formatting, and code reviews. Suggest updates to this file as the project evolves.
