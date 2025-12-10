# ADR-004: Server Actions zamiast API Routes

## Status
ACCEPTED

## Data
2025-12-09

## Context

Next.js 15 oferuje dwa sposoby komunikacji client-server:
1. **API Routes** (`/api/*`) - tradycyjne REST endpoints
2. **Server Actions** - funkcje serwerowe wywolywane bezposrednio z komponentow

Musimy zdecydowac, ktore podejscie wybrac dla HomeOS.

## Decision

Wybieramy **Server Actions** jako glowny sposob komunikacji:
- Wszystkie mutations (create, update, delete) przez Server Actions
- Dane inicjalne przez Server Components
- API Routes tylko dla: OAuth callback, webhooks, push subscriptions

## Alternatives Considered

| Alternatywa | Pros | Cons |
|-------------|------|------|
| **API Routes only** | REST-like, familiar | Wiecej boilerplate, CORS |
| **Server Actions only** | Mniej kodu, type-safe | Nowe, mniej familiar |
| **Hybrid** | Best of both | Dwa patterny do utrzymania |
| **tRPC** | Type-safe E2E | Dodatkowa library, learning curve |

## Consequences

### Positive
- **Mniej boilerplate** - brak route handlers, brak fetch na kliencie
- **Type safety** - TypeScript end-to-end bez generacji
- **CSRF protection** - wbudowany w Server Actions
- **Progressive enhancement** - formularze dzialaja bez JS
- **Colocation** - logika blisko UI
- **Optimistic updates** - latwa integracja z `useOptimistic`

### Negative
- **Nowe paradigm** - team musi sie nauczyc
- **Debugging** - trudniej niz REST (brak network tab dla actions)
- **Caching** - wymaga `revalidatePath`/`revalidateTag`
- **Mobile app** - native app nie moze uzywac Server Actions (API potrzebne)

### Risks
- **Przyszla native app** - mitygacja: wydzielenie business logic, API Routes jako wrapper
- **Testing** - mitygacja: testowanie funkcji bezposrednio

## Implementation Pattern

### Server Action
```typescript
// lib/actions/shopping.ts
'use server';

import { createServerClient } from '@/lib/supabase/server';
import { revalidatePath } from 'next/cache';

export async function addShoppingItem(listId: string, formData: FormData) {
  const supabase = createServerClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return { error: 'Unauthorized' };
  }

  const name = formData.get('name') as string;

  const { error } = await supabase
    .from('shopping_list_items')
    .insert({ list_id: listId, name, created_by: user.id });

  if (error) {
    return { error: error.message };
  }

  revalidatePath(`/shopping/${listId}`);
  return { success: true };
}
```

### Client Usage
```typescript
// components/AddItemForm.tsx
'use client';

import { addShoppingItem } from '@/lib/actions/shopping';
import { useTransition } from 'react';

export function AddItemForm({ listId }: { listId: string }) {
  const [isPending, startTransition] = useTransition();

  return (
    <form action={(formData) => {
      startTransition(() => addShoppingItem(listId, formData));
    }}>
      <input name="name" required />
      <button disabled={isPending}>
        {isPending ? 'Dodawanie...' : 'Dodaj'}
      </button>
    </form>
  );
}
```

### Kiedy API Route
```typescript
// app/api/auth/callback/route.ts
// - OAuth callback (wymaga redirect)

// app/api/push/subscribe/route.ts
// - Push subscription (Service Worker nie moze wywolac Server Action)

// app/api/webhooks/stripe/route.ts (przyszlosc)
// - External webhook
```

## Migration Path

Jesli potrzeba API dla native app:
```typescript
// app/api/v1/shopping/route.ts
import { addShoppingItem } from '@/lib/actions/shopping';

export async function POST(req: Request) {
  const formData = await req.formData();
  const listId = formData.get('listId') as string;
  return Response.json(await addShoppingItem(listId, formData));
}
```

## References
- [Next.js Server Actions](https://nextjs.org/docs/app/building-your-application/data-fetching/server-actions-and-mutations)
- [React 19 Actions](https://react.dev/reference/react/useTransition)
