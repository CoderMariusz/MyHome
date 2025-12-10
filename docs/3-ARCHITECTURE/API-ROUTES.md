# HomeOS - API Routes & Server Actions

**Wersja:** 1.1
**Data:** 2025-12-09
**Architecture Ref:** @docs/3-ARCHITECTURE/ARCHITECTURE.md
**Database Ref:** @docs/3-ARCHITECTURE/DATABASE-SCHEMA.md

---

## 1. Architecture Overview

HomeOS uzywa **Server Actions** jako glowny sposob komunikacji z backendem (zamiast tradycyjnych API routes). API Routes sa uzywane tylko dla:
- OAuth callback
- Push notifications subscription
- Webhooks (przyszlosc)

```
+------------------+     +------------------+     +------------------+
|   Client         |     |  Server Actions  |     |   Supabase       |
|   Component      |---->|  (Next.js 15)    |---->|   (RLS)          |
+------------------+     +------------------+     +------------------+
        |
        | [tylko dla OAuth, Push]
        v
+------------------+
|   API Routes     |
|   /api/*         |
+------------------+
```

---

## 2. Server Actions

### 2.1 Authentication Actions

**File:** `lib/actions/auth.ts`

```typescript
'use server';

import { createServerClient } from '@/lib/supabase/server';
import { redirect } from 'next/navigation';
import { z } from 'zod';

// ============================================
// REGISTER (Email + Password)
// ============================================
const registerSchema = z.object({
  email: z.string().email('Nieprawidlowy email'),
  password: z.string().min(8, 'Haslo musi miec min. 8 znakow'),
  confirmPassword: z.string(),
}).refine((data) => data.password === data.confirmPassword, {
  message: 'Hasla nie sa identyczne',
  path: ['confirmPassword'],
});

export async function register(formData: FormData) {
  const supabase = createServerClient();

  const validatedFields = registerSchema.safeParse({
    email: formData.get('email'),
    password: formData.get('password'),
    confirmPassword: formData.get('confirmPassword'),
  });

  if (!validatedFields.success) {
    return {
      error: validatedFields.error.flatten().fieldErrors,
    };
  }

  const { email, password } = validatedFields.data;

  const { error } = await supabase.auth.signUp({
    email,
    password,
    options: {
      emailRedirectTo: `${process.env.NEXT_PUBLIC_SITE_URL}/auth/callback`,
    },
  });

  if (error) {
    return { error: { email: [error.message] } };
  }

  return { success: true, message: 'Sprawdz email, aby potwierdzic konto' };
}

// ============================================
// LOGIN (Email + Password)
// ============================================
const loginSchema = z.object({
  email: z.string().email('Nieprawidlowy email'),
  password: z.string().min(1, 'Haslo jest wymagane'),
});

export async function login(formData: FormData) {
  const supabase = createServerClient();

  const validatedFields = loginSchema.safeParse({
    email: formData.get('email'),
    password: formData.get('password'),
  });

  if (!validatedFields.success) {
    return {
      error: validatedFields.error.flatten().fieldErrors,
    };
  }

  const { email, password } = validatedFields.data;

  const { error } = await supabase.auth.signInWithPassword({
    email,
    password,
  });

  if (error) {
    return { error: { email: [error.message] } };
  }

  redirect('/dashboard');
}

// ============================================
// LOGIN WITH GOOGLE
// ============================================
export async function loginWithGoogle() {
  const supabase = createServerClient();

  const { data, error } = await supabase.auth.signInWithOAuth({
    provider: 'google',
    options: {
      redirectTo: `${process.env.NEXT_PUBLIC_SITE_URL}/auth/callback`,
    },
  });

  if (error) {
    return { error: error.message };
  }

  redirect(data.url);
}

// ============================================
// LOGOUT
// ============================================
export async function logout() {
  const supabase = createServerClient();
  await supabase.auth.signOut();
  redirect('/login');
}

// ============================================
// GET CURRENT USER
// UWAGA: Uzywamy getUser() zamiast getSession() - bezpieczniejsze
// ============================================
export async function getCurrentUser() {
  const supabase = createServerClient();
  const { data: { user } } = await supabase.auth.getUser();
  return user;
}
```

---

### 2.2 Home (Household) Actions

**File:** `lib/actions/home.ts`

```typescript
'use server';

import { createServerClient } from '@/lib/supabase/server';
import { revalidatePath } from 'next/cache';
import { redirect } from 'next/navigation';
import { z } from 'zod';

// ============================================
// CREATE HOME
// ============================================
const createHomeSchema = z.object({
  name: z.string().min(1, 'Nazwa jest wymagana').max(50, 'Max 50 znakow'),
});

export async function createHome(formData: FormData) {
  const supabase = createServerClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return { error: 'Nie jestes zalogowany' };
  }

  // Check if user already has a home
  const { data: existingMember } = await supabase
    .from('home_members')
    .select('id')
    .eq('user_id', user.id)
    .single();

  if (existingMember) {
    return { error: 'Nalezysz juz do gospodarstwa' };
  }

  const validatedFields = createHomeSchema.safeParse({
    name: formData.get('name'),
  });

  if (!validatedFields.success) {
    return { error: validatedFields.error.flatten().fieldErrors };
  }

  const { name } = validatedFields.data;

  // Create home
  const { data: home, error: homeError } = await supabase
    .from('homes')
    .insert({ name, created_by: user.id })
    .select()
    .single();

  if (homeError) {
    return { error: homeError.message };
  }

  // Add user as admin
  const { error: memberError } = await supabase
    .from('home_members')
    .insert({
      user_id: user.id,
      home_id: home.id,
      role: 'admin',
    });

  if (memberError) {
    // Rollback home creation
    await supabase.from('homes').delete().eq('id', home.id);
    return { error: memberError.message };
  }

  // Create default user settings
  await supabase
    .from('user_settings')
    .insert({ user_id: user.id });

  // Create first invite automatically
  await supabase.rpc('create_invite_with_code', {
    p_home_id: home.id,
    p_created_by: user.id,
  });

  revalidatePath('/dashboard');
  redirect('/dashboard');
}

// ============================================
// JOIN HOME BY CODE
// Uzywa tabeli home_invites (jedyne zrodlo prawdy)
// ============================================
const joinHomeSchema = z.object({
  inviteCode: z.string().length(6, 'Kod musi miec 6 znakow'),
});

export async function joinHomeByCode(formData: FormData) {
  const supabase = createServerClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return { error: 'Nie jestes zalogowany' };
  }

  // Check if user already has a home
  const { data: existingMember } = await supabase
    .from('home_members')
    .select('id')
    .eq('user_id', user.id)
    .single();

  if (existingMember) {
    return { error: 'Nalezysz juz do gospodarstwa' };
  }

  const validatedFields = joinHomeSchema.safeParse({
    inviteCode: formData.get('inviteCode'),
  });

  if (!validatedFields.success) {
    return { error: validatedFields.error.flatten().fieldErrors };
  }

  const { inviteCode } = validatedFields.data;

  // Validate and use invite using DB function
  const { data: inviteResult, error: inviteError } = await supabase
    .rpc('validate_and_use_invite', {
      p_invite_code: inviteCode.toUpperCase(),
      p_user_id: user.id,
    });

  if (inviteError || !inviteResult || inviteResult.length === 0) {
    return { error: 'Nieprawidlowy lub wygasly kod zaproszenia' };
  }

  const { home_id, intended_role } = inviteResult[0];

  // Add user as member with intended role
  const { error: memberError } = await supabase
    .from('home_members')
    .insert({
      user_id: user.id,
      home_id: home_id,
      role: intended_role,
    });

  if (memberError) {
    return { error: memberError.message };
  }

  // Create default user settings
  await supabase
    .from('user_settings')
    .insert({ user_id: user.id });

  revalidatePath('/dashboard');
  redirect('/dashboard');
}

// ============================================
// GET HOME
// ============================================
export async function getHome() {
  const supabase = createServerClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) return null;

  const { data: member } = await supabase
    .from('home_members')
    .select('home_id, role, homes(*)')
    .eq('user_id', user.id)
    .single();

  if (!member) return null;

  return {
    home: member.homes,
    role: member.role,
  };
}

// ============================================
// GET HOME MEMBERS
// ============================================
export async function getHomeMembers() {
  const supabase = createServerClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) return [];

  const { data: currentMember } = await supabase
    .from('home_members')
    .select('home_id')
    .eq('user_id', user.id)
    .single();

  if (!currentMember) return [];

  const { data: members } = await supabase
    .from('home_members')
    .select(`
      id,
      user_id,
      role,
      display_name,
      avatar_url,
      joined_at
    `)
    .eq('home_id', currentMember.home_id)
    .order('joined_at', { ascending: true });

  return members || [];
}

// ============================================
// UPDATE MEMBER ROLE
// ============================================
export async function updateMemberRole(memberId: string, newRole: 'member' | 'child') {
  const supabase = createServerClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return { error: 'Nie jestes zalogowany' };
  }

  // Check if current user is admin
  const { data: currentMember } = await supabase
    .from('home_members')
    .select('home_id, role')
    .eq('user_id', user.id)
    .single();

  if (!currentMember || currentMember.role !== 'admin') {
    return { error: 'Tylko admin moze zmieniac role' };
  }

  // Update member role
  const { error } = await supabase
    .from('home_members')
    .update({ role: newRole })
    .eq('id', memberId)
    .eq('home_id', currentMember.home_id);

  if (error) {
    return { error: error.message };
  }

  revalidatePath('/settings');
  return { success: true };
}

// ============================================
// REMOVE MEMBER
// ============================================
export async function removeMember(memberId: string) {
  const supabase = createServerClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return { error: 'Nie jestes zalogowany' };
  }

  // Check if current user is admin
  const { data: currentMember } = await supabase
    .from('home_members')
    .select('home_id, role')
    .eq('user_id', user.id)
    .single();

  if (!currentMember || currentMember.role !== 'admin') {
    return { error: 'Tylko admin moze usuwac czlonkow' };
  }

  // Remove member
  const { error } = await supabase
    .from('home_members')
    .delete()
    .eq('id', memberId)
    .eq('home_id', currentMember.home_id)
    .neq('user_id', user.id); // Can't remove self

  if (error) {
    return { error: error.message };
  }

  revalidatePath('/settings');
  return { success: true };
}

// ============================================
// CREATE NEW INVITE
// Tworzy nowe zaproszenie w tabeli home_invites
// ============================================
export async function createInvite(intendedRole: 'member' | 'child' = 'member') {
  const supabase = createServerClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return { error: 'Nie jestes zalogowany' };
  }

  // Check if current user is admin or member
  const { data: currentMember } = await supabase
    .from('home_members')
    .select('home_id, role')
    .eq('user_id', user.id)
    .single();

  if (!currentMember || currentMember.role === 'child') {
    return { error: 'Nie masz uprawnien do tworzenia zaproszen' };
  }

  // Create new invite using DB function
  const { data, error } = await supabase.rpc('create_invite_with_code', {
    p_home_id: currentMember.home_id,
    p_created_by: user.id,
    p_intended_role: intendedRole,
  });

  if (error) {
    return { error: error.message };
  }

  revalidatePath('/invite');
  return { success: true, invite: data[0] };
}

// ============================================
// GET ACTIVE INVITES
// ============================================
export async function getActiveInvites() {
  const supabase = createServerClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) return [];

  const { data: currentMember } = await supabase
    .from('home_members')
    .select('home_id')
    .eq('user_id', user.id)
    .single();

  if (!currentMember) return [];

  const { data: invites } = await supabase
    .from('home_invites')
    .select('*')
    .eq('home_id', currentMember.home_id)
    .is('used_at', null)
    .gt('expires_at', new Date().toISOString())
    .order('created_at', { ascending: false });

  return invites || [];
}

// ============================================
// REGENERATE INVITE CODE (Create new invite)
// ============================================
export async function regenerateInviteCode(intendedRole: 'member' | 'child' = 'member') {
  const supabase = createServerClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return { error: 'Nie jestes zalogowany' };
  }

  // Check if current user is admin
  const { data: currentMember } = await supabase
    .from('home_members')
    .select('home_id, role')
    .eq('user_id', user.id)
    .single();

  if (!currentMember || currentMember.role !== 'admin') {
    return { error: 'Tylko admin moze regenerowac kod' };
  }

  // Create new invite
  const { data, error } = await supabase.rpc('create_invite_with_code', {
    p_home_id: currentMember.home_id,
    p_created_by: user.id,
    p_intended_role: intendedRole,
  });

  if (error) {
    return { error: error.message };
  }

  revalidatePath('/invite');
  return { success: true, inviteCode: data[0].invite_code };
}
```

---

### 2.3 Shopping List Actions

**File:** `lib/actions/shopping.ts`

```typescript
'use server';

import { createServerClient } from '@/lib/supabase/server';
import { revalidatePath } from 'next/cache';
import { z } from 'zod';

// ============================================
// GET SHOPPING LISTS
// Poprawna skladnia Supabase dla nested relations
// ============================================
export async function getShoppingLists() {
  const supabase = createServerClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) return [];

  const { data: member } = await supabase
    .from('home_members')
    .select('home_id')
    .eq('user_id', user.id)
    .single();

  if (!member) return [];

  // Poprawna skladnia: items:shopping_list_items(count)
  const { data: lists } = await supabase
    .from('shopping_lists')
    .select(`
      *,
      items:shopping_list_items(count)
    `)
    .eq('home_id', member.home_id)
    .eq('is_archived', false)
    .order('created_at', { ascending: false });

  return lists || [];
}

// ============================================
// GET SHOPPING LIST WITH ITEMS
// ============================================
export async function getShoppingListWithItems(listId: string) {
  const supabase = createServerClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) return null;

  // Poprawna skladnia dla nested relations
  const { data: list } = await supabase
    .from('shopping_lists')
    .select(`
      *,
      items:shopping_list_items(
        *,
        category:categories(*)
      )
    `)
    .eq('id', listId)
    .single();

  return list;
}

// ============================================
// GET SHOPPING LIST ITEMS
// ============================================
export async function getShoppingListItems(listId: string) {
  const supabase = createServerClient();

  const { data: items } = await supabase
    .from('shopping_list_items')
    .select(`
      *,
      category:categories(*)
    `)
    .eq('list_id', listId)
    .order('is_purchased', { ascending: true })
    .order('sort_order', { ascending: true });

  return items || [];
}

// ============================================
// CREATE SHOPPING LIST
// ============================================
const createListSchema = z.object({
  name: z.string().min(1, 'Nazwa jest wymagana').max(100, 'Max 100 znakow'),
});

export async function createShoppingList(formData: FormData) {
  const supabase = createServerClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return { error: 'Nie jestes zalogowany' };
  }

  const { data: member } = await supabase
    .from('home_members')
    .select('home_id, role')
    .eq('user_id', user.id)
    .single();

  if (!member || member.role === 'child') {
    return { error: 'Nie masz uprawnien' };
  }

  const validatedFields = createListSchema.safeParse({
    name: formData.get('name'),
  });

  if (!validatedFields.success) {
    return { error: validatedFields.error.flatten().fieldErrors };
  }

  const { name } = validatedFields.data;

  const { data: list, error } = await supabase
    .from('shopping_lists')
    .insert({
      name,
      home_id: member.home_id,
      created_by: user.id,
    })
    .select()
    .single();

  if (error) {
    return { error: error.message };
  }

  revalidatePath('/shopping');
  return { success: true, list };
}

// ============================================
// DELETE SHOPPING LIST
// ============================================
export async function deleteShoppingList(listId: string) {
  const supabase = createServerClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return { error: 'Nie jestes zalogowany' };
  }

  const { data: member } = await supabase
    .from('home_members')
    .select('home_id, role')
    .eq('user_id', user.id)
    .single();

  if (!member || member.role === 'child') {
    return { error: 'Nie masz uprawnien' };
  }

  // Verify list belongs to home
  const { data: list } = await supabase
    .from('shopping_lists')
    .select('id')
    .eq('id', listId)
    .eq('home_id', member.home_id)
    .single();

  if (!list) {
    return { error: 'Lista nie istnieje' };
  }

  const { error } = await supabase
    .from('shopping_lists')
    .delete()
    .eq('id', listId);

  if (error) {
    return { error: error.message };
  }

  revalidatePath('/shopping');
  return { success: true };
}

// ============================================
// ARCHIVE SHOPPING LIST
// ============================================
export async function archiveShoppingList(listId: string) {
  const supabase = createServerClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return { error: 'Nie jestes zalogowany' };
  }

  const { data: member } = await supabase
    .from('home_members')
    .select('home_id, role')
    .eq('user_id', user.id)
    .single();

  if (!member || member.role === 'child') {
    return { error: 'Nie masz uprawnien' };
  }

  const { error } = await supabase
    .from('shopping_lists')
    .update({ is_archived: true })
    .eq('id', listId)
    .eq('home_id', member.home_id);

  if (error) {
    return { error: error.message };
  }

  revalidatePath('/shopping');
  return { success: true };
}

// ============================================
// UNARCHIVE SHOPPING LIST
// ============================================
export async function unarchiveShoppingList(listId: string) {
  const supabase = createServerClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return { error: 'Nie jestes zalogowany' };
  }

  const { error } = await supabase
    .from('shopping_lists')
    .update({ is_archived: false })
    .eq('id', listId);

  if (error) {
    return { error: error.message };
  }

  revalidatePath('/shopping');
  return { success: true };
}

// ============================================
// ADD SHOPPING ITEM
// ============================================
const addItemSchema = z.object({
  name: z.string().min(1, 'Nazwa jest wymagana').max(200, 'Max 200 znakow'),
  quantity: z.string().max(20).optional(),
  unit: z.string().max(20).optional(),
  categoryId: z.string().uuid().optional(),
  assignedTo: z.string().uuid().optional(),
});

export async function addShoppingItem(listId: string, formData: FormData) {
  const supabase = createServerClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return { error: 'Nie jestes zalogowany' };
  }

  const { data: member } = await supabase
    .from('home_members')
    .select('home_id, role')
    .eq('user_id', user.id)
    .single();

  if (!member) {
    return { error: 'Nie masz uprawnien' };
  }

  // Check list belongs to home
  const { data: list } = await supabase
    .from('shopping_lists')
    .select('id, home_id')
    .eq('id', listId)
    .eq('home_id', member.home_id)
    .single();

  if (!list) {
    return { error: 'Lista nie istnieje' };
  }

  const validatedFields = addItemSchema.safeParse({
    name: formData.get('name'),
    quantity: formData.get('quantity') || undefined,
    unit: formData.get('unit') || undefined,
    categoryId: formData.get('categoryId') || undefined,
    assignedTo: formData.get('assignedTo') || undefined,
  });

  if (!validatedFields.success) {
    return { error: validatedFields.error.flatten().fieldErrors };
  }

  const { name, quantity, unit, categoryId, assignedTo } = validatedFields.data;

  // Get max sort_order
  const { data: maxOrder } = await supabase
    .from('shopping_list_items')
    .select('sort_order')
    .eq('list_id', listId)
    .order('sort_order', { ascending: false })
    .limit(1)
    .single();

  const newSortOrder = (maxOrder?.sort_order || 0) + 1;

  const { data: item, error } = await supabase
    .from('shopping_list_items')
    .insert({
      list_id: listId,
      home_id: member.home_id,
      name,
      quantity,
      unit,
      category_id: categoryId,
      assigned_to: assignedTo,
      sort_order: newSortOrder,
      created_by: user.id,
    })
    .select()
    .single();

  if (error) {
    return { error: error.message };
  }

  revalidatePath(`/shopping/${listId}`);
  return { success: true, item };
}

// ============================================
// TOGGLE ITEM PURCHASED
// ============================================
export async function toggleItemPurchased(itemId: string) {
  const supabase = createServerClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return { error: 'Nie jestes zalogowany' };
  }

  // Get current state
  const { data: item } = await supabase
    .from('shopping_list_items')
    .select('is_purchased, list_id')
    .eq('id', itemId)
    .single();

  if (!item) {
    return { error: 'Produkt nie istnieje' };
  }

  const newValue = !item.is_purchased;

  const { error } = await supabase
    .from('shopping_list_items')
    .update({
      is_purchased: newValue,
      purchased_by: newValue ? user.id : null,
      purchased_at: newValue ? new Date().toISOString() : null,
    })
    .eq('id', itemId);

  if (error) {
    return { error: error.message };
  }

  revalidatePath(`/shopping/${item.list_id}`);
  return { success: true, is_purchased: newValue };
}

// ============================================
// UPDATE ITEM SORT ORDER
// ============================================
export async function updateItemSortOrder(
  items: Array<{ id: string; sort_order: number }>
) {
  const supabase = createServerClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return { error: 'Nie jestes zalogowany' };
  }

  // Update each item's sort_order
  const updates = items.map(({ id, sort_order }) =>
    supabase
      .from('shopping_list_items')
      .update({ sort_order })
      .eq('id', id)
  );

  const results = await Promise.all(updates);
  const errors = results.filter(r => r.error);

  if (errors.length > 0) {
    return { error: 'Nie udalo sie zaktualizowac kolejnosci' };
  }

  return { success: true };
}

// ============================================
// DELETE SHOPPING ITEM
// ============================================
export async function deleteShoppingItem(itemId: string) {
  const supabase = createServerClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return { error: 'Nie jestes zalogowany' };
  }

  const { data: member } = await supabase
    .from('home_members')
    .select('home_id, role')
    .eq('user_id', user.id)
    .single();

  if (!member || member.role === 'child') {
    return { error: 'Nie masz uprawnien' };
  }

  // Get list_id for revalidation
  const { data: item } = await supabase
    .from('shopping_list_items')
    .select('list_id')
    .eq('id', itemId)
    .single();

  if (!item) {
    return { error: 'Produkt nie istnieje' };
  }

  const { error } = await supabase
    .from('shopping_list_items')
    .delete()
    .eq('id', itemId);

  if (error) {
    return { error: error.message };
  }

  revalidatePath(`/shopping/${item.list_id}`);
  return { success: true };
}

// ============================================
// DELETE PURCHASED ITEMS
// ============================================
export async function deletePurchasedItems(listId: string) {
  const supabase = createServerClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return { error: 'Nie jestes zalogowany' };
  }

  const { data: member } = await supabase
    .from('home_members')
    .select('home_id, role')
    .eq('user_id', user.id)
    .single();

  if (!member || member.role === 'child') {
    return { error: 'Nie masz uprawnien' };
  }

  const { error } = await supabase
    .from('shopping_list_items')
    .delete()
    .eq('list_id', listId)
    .eq('is_purchased', true);

  if (error) {
    return { error: error.message };
  }

  revalidatePath(`/shopping/${listId}`);
  return { success: true };
}

// ============================================
// GET CATEGORIES
// ============================================
export async function getCategories() {
  const supabase = createServerClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) return [];

  const { data: member } = await supabase
    .from('home_members')
    .select('home_id')
    .eq('user_id', user.id)
    .single();

  const { data: categories } = await supabase
    .from('categories')
    .select('*')
    .or(`is_default.eq.true,home_id.eq.${member?.home_id}`)
    .order('sort_order', { ascending: true });

  return categories || [];
}
```

---

### 2.4 Tasks Actions

**File:** `lib/actions/tasks.ts`

```typescript
'use server';

import { createServerClient } from '@/lib/supabase/server';
import { revalidatePath } from 'next/cache';
import { z } from 'zod';

// ============================================
// GET TASKS
// ============================================
export async function getTasks() {
  const supabase = createServerClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) return [];

  const { data: member } = await supabase
    .from('home_members')
    .select('home_id')
    .eq('user_id', user.id)
    .single();

  if (!member) return [];

  const { data: tasks } = await supabase
    .from('tasks')
    .select('*')
    .eq('home_id', member.home_id)
    .order('is_completed', { ascending: true })
    .order('created_at', { ascending: false });

  return tasks || [];
}

// ============================================
// CREATE TASK
// ============================================
const createTaskSchema = z.object({
  title: z.string().min(1, 'Tytul jest wymagany').max(200, 'Max 200 znakow'),
  description: z.string().max(1000).optional(),
  assignedTo: z.string().uuid().optional(),
  dueDate: z.string().optional(),
});

export async function createTask(formData: FormData) {
  const supabase = createServerClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return { error: 'Nie jestes zalogowany' };
  }

  const { data: member } = await supabase
    .from('home_members')
    .select('home_id, role')
    .eq('user_id', user.id)
    .single();

  if (!member || member.role === 'child') {
    return { error: 'Nie masz uprawnien' };
  }

  const validatedFields = createTaskSchema.safeParse({
    title: formData.get('title'),
    description: formData.get('description') || undefined,
    assignedTo: formData.get('assignedTo') || undefined,
    dueDate: formData.get('dueDate') || undefined,
  });

  if (!validatedFields.success) {
    return { error: validatedFields.error.flatten().fieldErrors };
  }

  const { title, description, assignedTo, dueDate } = validatedFields.data;

  const { data: task, error } = await supabase
    .from('tasks')
    .insert({
      home_id: member.home_id,
      title,
      description,
      assigned_to: assignedTo,
      due_date: dueDate,
      created_by: user.id,
    })
    .select()
    .single();

  if (error) {
    return { error: error.message };
  }

  revalidatePath('/tasks');
  return { success: true, task };
}

// ============================================
// TOGGLE TASK COMPLETED
// ============================================
export async function toggleTaskCompleted(taskId: string) {
  const supabase = createServerClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return { error: 'Nie jestes zalogowany' };
  }

  // Get current state
  const { data: task } = await supabase
    .from('tasks')
    .select('is_completed')
    .eq('id', taskId)
    .single();

  if (!task) {
    return { error: 'Zadanie nie istnieje' };
  }

  const newValue = !task.is_completed;

  const { error } = await supabase
    .from('tasks')
    .update({
      is_completed: newValue,
      completed_by: newValue ? user.id : null,
      completed_at: newValue ? new Date().toISOString() : null,
    })
    .eq('id', taskId);

  if (error) {
    return { error: error.message };
  }

  revalidatePath('/tasks');
  return { success: true, is_completed: newValue };
}

// ============================================
// DELETE TASK
// ============================================
export async function deleteTask(taskId: string) {
  const supabase = createServerClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return { error: 'Nie jestes zalogowany' };
  }

  const { data: member } = await supabase
    .from('home_members')
    .select('home_id, role')
    .eq('user_id', user.id)
    .single();

  if (!member || member.role === 'child') {
    return { error: 'Nie masz uprawnien' };
  }

  const { error } = await supabase
    .from('tasks')
    .delete()
    .eq('id', taskId);

  if (error) {
    return { error: error.message };
  }

  revalidatePath('/tasks');
  return { success: true };
}
```

---

### 2.5 Settings Actions

**File:** `lib/actions/settings.ts`

```typescript
'use server';

import { createServerClient } from '@/lib/supabase/server';
import { revalidatePath } from 'next/cache';
import { z } from 'zod';

// ============================================
// GET USER SETTINGS
// ============================================
export async function getUserSettings() {
  const supabase = createServerClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) return null;

  const { data: settings } = await supabase
    .from('user_settings')
    .select('*')
    .eq('user_id', user.id)
    .single();

  return settings;
}

// ============================================
// UPDATE USER SETTINGS
// ============================================
const updateSettingsSchema = z.object({
  theme: z.enum(['light', 'dark', 'system']).optional(),
  language: z.enum(['pl', 'en']).optional(),
  notifications_enabled: z.boolean().optional(),
  notification_new_item: z.boolean().optional(),
  notification_assigned: z.boolean().optional(),
});

export async function updateUserSettings(formData: FormData) {
  const supabase = createServerClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return { error: 'Nie jestes zalogowany' };
  }

  const validatedFields = updateSettingsSchema.safeParse({
    theme: formData.get('theme') || undefined,
    language: formData.get('language') || undefined,
    notifications_enabled: formData.get('notifications_enabled') === 'true',
    notification_new_item: formData.get('notification_new_item') === 'true',
    notification_assigned: formData.get('notification_assigned') === 'true',
  });

  if (!validatedFields.success) {
    return { error: validatedFields.error.flatten().fieldErrors };
  }

  const updates = validatedFields.data;

  const { error } = await supabase
    .from('user_settings')
    .upsert({
      user_id: user.id,
      ...updates,
    });

  if (error) {
    return { error: error.message };
  }

  revalidatePath('/settings');
  return { success: true };
}

// ============================================
// UPDATE PROFILE
// ============================================
const updateProfileSchema = z.object({
  displayName: z.string().max(30).optional(),
});

export async function updateProfile(formData: FormData) {
  const supabase = createServerClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return { error: 'Nie jestes zalogowany' };
  }

  const validatedFields = updateProfileSchema.safeParse({
    displayName: formData.get('displayName') || undefined,
  });

  if (!validatedFields.success) {
    return { error: validatedFields.error.flatten().fieldErrors };
  }

  const { displayName } = validatedFields.data;

  const { error } = await supabase
    .from('home_members')
    .update({ display_name: displayName })
    .eq('user_id', user.id);

  if (error) {
    return { error: error.message };
  }

  revalidatePath('/settings');
  return { success: true };
}
```

---

### 2.6 Notifications Actions

**File:** `lib/actions/notifications.ts`

```typescript
'use server';

import { createServerClient } from '@/lib/supabase/server';

// ============================================
// SUBSCRIBE TO PUSH
// ============================================
export async function subscribeToPush(subscription: {
  endpoint: string;
  p256dh: string;
  auth: string;
}) {
  const supabase = createServerClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return { error: 'Nie jestes zalogowany' };
  }

  const { error } = await supabase
    .from('push_subscriptions')
    .upsert({
      user_id: user.id,
      endpoint: subscription.endpoint,
      p256dh: subscription.p256dh,
      auth: subscription.auth,
      platform: 'web',
    }, {
      onConflict: 'user_id,endpoint',
    });

  if (error) {
    return { error: error.message };
  }

  return { success: true };
}

// ============================================
// UNSUBSCRIBE FROM PUSH
// ============================================
export async function unsubscribeFromPush(endpoint: string) {
  const supabase = createServerClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return { error: 'Nie jestes zalogowany' };
  }

  const { error } = await supabase
    .from('push_subscriptions')
    .delete()
    .eq('user_id', user.id)
    .eq('endpoint', endpoint);

  if (error) {
    return { error: error.message };
  }

  return { success: true };
}

// ============================================
// SEND NOTIFICATION TO HOME (Internal)
// ============================================
export async function sendNotificationToHome(
  homeId: string,
  title: string,
  body: string,
  excludeUserId?: string
) {
  const supabase = createServerClient();

  // Get all members of the home
  const { data: members } = await supabase
    .from('home_members')
    .select('user_id')
    .eq('home_id', homeId);

  if (!members || members.length === 0) return;

  const userIds = members
    .map(m => m.user_id)
    .filter(id => id !== excludeUserId);

  // Get push subscriptions
  const { data: subscriptions } = await supabase
    .from('push_subscriptions')
    .select('*')
    .in('user_id', userIds);

  if (!subscriptions || subscriptions.length === 0) return;

  // Send notifications (implement with web-push library)
  // This would be called from an Edge Function or API route
  // For now, we just return the subscription data
  return { subscriptions, title, body };
}
```

---

## 3. API Routes

### 3.1 OAuth Callback

**File:** `app/api/auth/callback/route.ts`

```typescript
import { createServerClient } from '@supabase/ssr';
import { cookies } from 'next/headers';
import { NextRequest, NextResponse } from 'next/server';

export async function GET(request: NextRequest) {
  const { searchParams, origin } = new URL(request.url);
  const code = searchParams.get('code');
  const next = searchParams.get('next') ?? '/dashboard';

  if (code) {
    const cookieStore = cookies();
    const supabase = createServerClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
      {
        cookies: {
          get(name: string) {
            return cookieStore.get(name)?.value;
          },
          set(name: string, value: string, options) {
            cookieStore.set({ name, value, ...options });
          },
          remove(name: string, options) {
            cookieStore.delete({ name, ...options });
          },
        },
      }
    );

    const { error } = await supabase.auth.exchangeCodeForSession(code);

    if (!error) {
      // Check if user has a home - UWAGA: getUser() zamiast getSession()
      const { data: { user } } = await supabase.auth.getUser();

      if (user) {
        const { data: member } = await supabase
          .from('home_members')
          .select('id')
          .eq('user_id', user.id)
          .single();

        // Redirect to setup if no home
        if (!member) {
          return NextResponse.redirect(`${origin}/setup`);
        }
      }

      return NextResponse.redirect(`${origin}${next}`);
    }
  }

  // Return to login on error
  return NextResponse.redirect(`${origin}/login?error=auth_failed`);
}
```

### 3.2 Push Subscribe Webhook

**File:** `app/api/push/subscribe/route.ts`

```typescript
import { createServerClient } from '@/lib/supabase/server';
import { NextRequest, NextResponse } from 'next/server';

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { endpoint, keys } = body;

    if (!endpoint || !keys?.p256dh || !keys?.auth) {
      return NextResponse.json(
        { error: 'Invalid subscription data' },
        { status: 400 }
      );
    }

    const supabase = createServerClient();
    const { data: { user } } = await supabase.auth.getUser();

    if (!user) {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 401 }
      );
    }

    const { error } = await supabase
      .from('push_subscriptions')
      .upsert({
        user_id: user.id,
        endpoint,
        p256dh: keys.p256dh,
        auth: keys.auth,
        platform: 'web',
      }, {
        onConflict: 'user_id,endpoint',
      });

    if (error) {
      return NextResponse.json(
        { error: error.message },
        { status: 500 }
      );
    }

    return NextResponse.json({ success: true });
  } catch (error) {
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

export async function DELETE(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const endpoint = searchParams.get('endpoint');

    if (!endpoint) {
      return NextResponse.json(
        { error: 'Endpoint is required' },
        { status: 400 }
      );
    }

    const supabase = createServerClient();
    const { data: { user } } = await supabase.auth.getUser();

    if (!user) {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 401 }
      );
    }

    const { error } = await supabase
      .from('push_subscriptions')
      .delete()
      .eq('user_id', user.id)
      .eq('endpoint', endpoint);

    if (error) {
      return NextResponse.json(
        { error: error.message },
        { status: 500 }
      );
    }

    return NextResponse.json({ success: true });
  } catch (error) {
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
```

---

## 4. Actions Summary Table

| Action | File | Auth | Role | Revalidates |
|--------|------|------|------|-------------|
| `register` | auth.ts | No | - | - |
| `login` | auth.ts | No | - | redirect |
| `loginWithGoogle` | auth.ts | No | - | redirect |
| `logout` | auth.ts | Yes | Any | redirect |
| `getCurrentUser` | auth.ts | Yes | Any | - |
| `createHome` | home.ts | Yes | No home | /dashboard |
| `joinHomeByCode` | home.ts | Yes | No home | /dashboard |
| `getHome` | home.ts | Yes | Any | - |
| `getHomeMembers` | home.ts | Yes | Any | - |
| `updateMemberRole` | home.ts | Yes | Admin | /settings |
| `removeMember` | home.ts | Yes | Admin | /settings |
| `createInvite` | home.ts | Yes | Admin/Member | /invite |
| `getActiveInvites` | home.ts | Yes | Any | - |
| `regenerateInviteCode` | home.ts | Yes | Admin | /invite |
| `getShoppingLists` | shopping.ts | Yes | Any | - |
| `getShoppingListWithItems` | shopping.ts | Yes | Any | - |
| `getShoppingListItems` | shopping.ts | Yes | Any | - |
| `createShoppingList` | shopping.ts | Yes | Admin/Member | /shopping |
| `deleteShoppingList` | shopping.ts | Yes | Admin/Member | /shopping |
| `archiveShoppingList` | shopping.ts | Yes | Admin/Member | /shopping |
| `unarchiveShoppingList` | shopping.ts | Yes | Admin/Member | /shopping |
| `addShoppingItem` | shopping.ts | Yes | Admin/Member | /shopping/[id] |
| `toggleItemPurchased` | shopping.ts | Yes | Any | /shopping/[id] |
| `updateItemSortOrder` | shopping.ts | Yes | Any | - |
| `deleteShoppingItem` | shopping.ts | Yes | Admin/Member | /shopping/[id] |
| `deletePurchasedItems` | shopping.ts | Yes | Admin/Member | /shopping/[id] |
| `getCategories` | shopping.ts | Yes | Any | - |
| `getTasks` | tasks.ts | Yes | Any | - |
| `createTask` | tasks.ts | Yes | Admin/Member | /tasks |
| `toggleTaskCompleted` | tasks.ts | Yes | Any | /tasks |
| `deleteTask` | tasks.ts | Yes | Admin/Member | /tasks |
| `getUserSettings` | settings.ts | Yes | Any | - |
| `updateUserSettings` | settings.ts | Yes | Any | /settings |
| `updateProfile` | settings.ts | Yes | Any | /settings |
| `subscribeToPush` | notifications.ts | Yes | Any | - |
| `unsubscribeFromPush` | notifications.ts | Yes | Any | - |

---

## 5. Error Handling Pattern

```typescript
// lib/actions/utils.ts
export type ActionResult<T = void> =
  | { success: true; data?: T }
  | { success: false; error: string | Record<string, string[]> };

export function handleActionError(error: unknown): ActionResult {
  if (error instanceof z.ZodError) {
    return {
      success: false,
      error: error.flatten().fieldErrors,
    };
  }

  if (error instanceof Error) {
    return {
      success: false,
      error: error.message,
    };
  }

  return {
    success: false,
    error: 'Wystapil nieoczekiwany blad',
  };
}
```

---

## 6. Client-Side Usage

```typescript
// Example: Adding item with optimistic update
'use client';

import { useTransition, useOptimistic } from 'react';
import { addShoppingItem } from '@/lib/actions/shopping';

export function AddItemForm({ listId }: { listId: string }) {
  const [isPending, startTransition] = useTransition();

  async function handleSubmit(formData: FormData) {
    startTransition(async () => {
      const result = await addShoppingItem(listId, formData);
      if (result.error) {
        toast.error(typeof result.error === 'string'
          ? result.error
          : 'Blad walidacji'
        );
      }
    });
  }

  return (
    <form action={handleSubmit}>
      <input name="name" placeholder="Nazwa produktu" required />
      <button type="submit" disabled={isPending}>
        {isPending ? 'Dodawanie...' : 'Dodaj'}
      </button>
    </form>
  );
}
```

---

**Document Version:** 1.1
**Last Updated:** 2025-12-09
**Author:** Architect Agent
**Changes:**
- Poprawiono skladnie Supabase (items:shopping_list_items)
- Dodano deleteShoppingList()
- Dodano archiveShoppingList()
- Dodano regenerateInviteCode()
- Dodano createInvite(), getActiveInvites()
- Zamieniono getSession() na getUser() wszedzie
- Zaktualizowano joinHomeByCode() do uzycia home_invites
