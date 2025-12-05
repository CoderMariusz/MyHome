# Story 1.3: Supabase Client Integration

Status: ready-for-dev

## Story

As a **developer**,
I want **to integrate Supabase client libraries with Next.js**,
so that **the application can authenticate users and query the database**.

## Acceptance Criteria

1. **AC1: Server-Side Client Configured**
   - Given the Next.js project with Supabase dependencies
   - When examining lib/supabase/server.ts
   - Then it should:
     - Use @supabase/ssr for server-side operations
     - Handle cookies properly for session management
     - Export createClient function for Server Components and Actions

2. **AC2: Browser Client Configured**
   - Given the Supabase setup
   - When examining lib/supabase/client.ts
   - Then it should:
     - Use @supabase/ssr for browser operations
     - Export createClient function for Client Components
     - Use environment variables for URL and key

3. **AC3: Middleware for Session Refresh**
   - Given the authentication flow
   - When examining middleware.ts
   - Then it should:
     - Refresh expired sessions automatically
     - Handle cookie operations
     - Match appropriate routes (exclude static files)

4. **AC4: Environment Variables Configured**
   - Given the project configuration
   - When examining .env.local
   - Then the following should be set:
     - NEXT_PUBLIC_SUPABASE_URL
     - NEXT_PUBLIC_SUPABASE_ANON_KEY
     - NEXT_PUBLIC_SITE_URL

5. **AC5: TypeScript Types Generated**
   - Given the database schema
   - When types are generated
   - Then lib/database.types.ts should contain typed definitions for all tables

## Tasks / Subtasks

- [ ] **Task 1: Install Supabase Dependencies** (AC: 1, 2)
  - [ ] Run `npm install @supabase/supabase-js @supabase/ssr`
  - [ ] Verify packages in package.json

- [ ] **Task 2: Create Server Client** (AC: 1)
  - [ ] Create lib/supabase/server.ts
  - [ ] Import createServerClient from @supabase/ssr
  - [ ] Implement cookie handling with next/headers
  - [ ] Export createClient function
  - [ ] Add proper TypeScript types

- [ ] **Task 3: Create Browser Client** (AC: 2)
  - [ ] Create lib/supabase/client.ts
  - [ ] Import createBrowserClient from @supabase/ssr
  - [ ] Export createClient function
  - [ ] Use environment variables

- [ ] **Task 4: Create Auth Middleware** (AC: 3)
  - [ ] Create middleware.ts in project root
  - [ ] Implement session refresh logic
  - [ ] Configure route matcher (exclude static files, images)
  - [ ] Handle cookie get/set/remove operations

- [ ] **Task 5: Configure Environment Variables** (AC: 4)
  - [ ] Create .env.local with local Supabase credentials
  - [ ] Create .env.example as template (without secrets)
  - [ ] Add .env.local to .gitignore
  - [ ] Document variables in README

- [ ] **Task 6: Generate TypeScript Types** (AC: 5)
  - [ ] Run `supabase gen types typescript --local > lib/database.types.ts`
  - [ ] Add type generation script to package.json
  - [ ] Import types in Supabase clients

- [ ] **Task 7: Create Utility Functions** (AC: 1, 2)
  - [ ] Create lib/utils.ts with cn() for Tailwind class merging
  - [ ] Install clsx and tailwind-merge dependencies

## Dev Notes

### Architecture Reference

**Server Client Implementation** [Source: docs/architecture.md#Authentication-Flow]:

```typescript
// lib/supabase/server.ts
import { createServerClient, type CookieOptions } from '@supabase/ssr';
import { cookies } from 'next/headers';

export function createClient() {
  const cookieStore = cookies();

  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        get(name: string) {
          return cookieStore.get(name)?.value;
        },
        set(name: string, value: string, options: CookieOptions) {
          cookieStore.set({ name, value, ...options });
        },
        remove(name: string, options: CookieOptions) {
          cookieStore.delete({ name, ...options });
        },
      },
    }
  );
}
```

**Browser Client Implementation:**

```typescript
// lib/supabase/client.ts
import { createBrowserClient } from '@supabase/ssr';

export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  );
}
```

**Middleware Implementation:**

```typescript
// middleware.ts
import { createServerClient, type CookieOptions } from '@supabase/ssr';
import { NextResponse, type NextRequest } from 'next/server';

export async function middleware(request: NextRequest) {
  let response = NextResponse.next({
    request: { headers: request.headers },
  });

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        get(name: string) {
          return request.cookies.get(name)?.value;
        },
        set(name: string, value: string, options: CookieOptions) {
          request.cookies.set({ name, value, ...options });
          response = NextResponse.next({
            request: { headers: request.headers },
          });
          response.cookies.set({ name, value, ...options });
        },
        remove(name: string, options: CookieOptions) {
          request.cookies.set({ name, value: '', ...options });
          response = NextResponse.next({
            request: { headers: request.headers },
          });
          response.cookies.set({ name, value: '', ...options });
        },
      },
    }
  );

  // Refresh session if expired
  await supabase.auth.getUser();

  return response;
}

export const config = {
  matcher: [
    '/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)',
  ],
};
```

### Environment Variables

```bash
# .env.local (for local development)
NEXT_PUBLIC_SUPABASE_URL=http://localhost:54321
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJxxx...local
NEXT_PUBLIC_SITE_URL=http://localhost:3000
```

### Project Structure Notes

```
lib/
├── supabase/
│   ├── server.ts        # Server-side client
│   └── client.ts        # Browser client
├── database.types.ts    # Generated types
└── utils.ts             # Utility functions
middleware.ts            # Auth middleware (root)
```

### Security Considerations

- JWT tokens stored in HttpOnly cookies (XSS protection)
- Server client uses cookies() from next/headers
- Middleware refreshes tokens before expiry
- Environment variables never committed to Git

### Testing Notes

- Test server client in Server Component
- Test browser client in Client Component
- Verify middleware refreshes sessions
- Check types work with database queries

### Prerequisites

- Story 1.1 completed (project initialized)
- Story 1.2 completed (Supabase project with schema)

### References

- [Source: docs/architecture.md#Authentication-Flow] - Complete auth setup
- [Source: docs/architecture.md#Supabase-Auth-Next.js-SSR] - Client configuration
- [Source: docs/prd.md#NFR-S3] - JWT in HttpOnly cookies requirement

## Dev Agent Record

### Context Reference

<!-- Path(s) to story context XML will be added here by context workflow -->

### Agent Model Used

<!-- Will be filled by dev agent -->

### Debug Log References

<!-- Will be filled during implementation -->

### Completion Notes List

<!-- Will be filled after implementation -->

### File List

<!-- Will be filled after implementation with NEW/MODIFIED/DELETED files -->

---

## Change Log

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-11-19 | SM Agent | Initial story draft created |
