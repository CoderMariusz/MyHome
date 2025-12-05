# MyHome - Epic Breakdown

**Author:** Mariusz
**Date:** 2025-11-19
**Project Level:** MVP (Phase 1)
**Target Scale:** 100 power user families (3 months post-launch)

---

## Overview

This document provides the complete epic and story breakdown for MyHome, decomposing the requirements from the [PRD](./prd.md) into implementable stories. Each story is sized for a single dev agent session with detailed BDD acceptance criteria.

**Epic Summary:**

| Epic | Name | Stories | FRs Covered | User Value |
|------|------|---------|-------------|------------|
| 1 | Foundation & Project Setup | 4 | Infrastructure | Development foundation |
| 2 | User Authentication | 5 | FR1-FR6 | Users can create accounts and sign in |
| 3 | Home Management & Onboarding | 5 | FR7-FR14 | Users can create/join households |
| 4 | Shopping List Core | 6 | FR15-FR25, FR44-FR48 | Users can manage shopping lists |
| 5 | Real-time Synchronization | 4 | FR26-FR31 | Family sees instant updates |
| 6 | Offline Capability | 3 | FR39-FR43 | Users can shop without connection |
| 7 | Push Notifications | 4 | FR32-FR38 | Users get notified of activity |
| 8 | PWA & Polish | 4 | FR49-FR54 | App is installable and accessible |

**Total Stories:** 35

---

## Functional Requirements Inventory

**User Account & Access (FR1-FR6):**
- FR1: Users can create accounts using email and password
- FR2: Users can log in securely and maintain sessions
- FR3: Users can reset passwords via email verification
- FR4: Users can update account information
- FR5: Users can delete their account
- FR6: System enforces unique email addresses

**Home Management (FR7-FR14):**
- FR7: Users can create a new home
- FR8: System generates unique 6-char invite code
- FR9: Users can join home via invite code
- FR10: Users belong to exactly one home (MVP)
- FR11: Users can view home members
- FR12: Users can leave their home
- FR13: Home creators can regenerate invite code
- FR14: Users can copy invite code to clipboard

**Shopping List Core (FR15-FR25):**
- FR15: Users can add items with name
- FR16: Users can specify quantity
- FR17: Users can assign category
- FR18: System provides predefined categories
- FR19: Users can edit items
- FR20: Users can delete items
- FR21: Users can mark items as purchased
- FR22: Users can unmark purchased items
- FR23: System displays "Do Kupienia" and "Kupione" sections
- FR24: System sorts items (not purchased first)
- FR25: System maintains list per home

**Real-time Sync (FR26-FR31):**
- FR26: System syncs changes in real-time
- FR27: Added items appear within 2 seconds
- FR28: Purchase status syncs within 2 seconds
- FR29: Edits/deletes sync within 2 seconds
- FR30: System displays connection status
- FR31: System auto-reconnects and syncs

**Push Notifications (FR32-FR38):**
- FR32: System requests notification permission
- FR33: Users can enable/disable notifications
- FR34: Notification when item added
- FR35: Notification when item purchased
- FR36: Notifications include context
- FR37: Max 5 notifications per week
- FR38: Tap notification opens app

**Offline Capability (FR39-FR43):**
- FR39: Users can view list when offline
- FR40: Users can add/edit/mark when offline
- FR41: System queues and syncs changes
- FR42: System displays offline indicator
- FR43: System uses optimistic updates

**Data Security (FR44-FR48):**
- FR44: Users only view own home's list
- FR45: Users only view own home's members
- FR46: Users cannot access other homes
- FR47: Database enforces RLS
- FR48: System tracks item creator

**UI/UX (FR49-FR54):**
- FR49: App installable as PWA
- FR50: Responsive design
- FR51: Works in modern browsers
- FR52: Shopping list is home screen
- FR53: Bottom tab navigation
- FR54: Settings accessible from Dom tab

**Post-MVP (FR55-FR59):**
- FR55: Search items (Phase 2)
- FR56: Filter by category (Phase 2)
- FR57: View history (Phase 2)
- FR58: Autocomplete (Phase 2)
- FR59: Common items suggestions (Phase 2)

---

## FR Coverage Map

| Epic | Functional Requirements |
|------|------------------------|
| Epic 1 (Foundation) | Infrastructure for all FRs |
| Epic 2 (Authentication) | FR1, FR2, FR3, FR4, FR5, FR6 |
| Epic 3 (Home Management) | FR7, FR8, FR9, FR10, FR11, FR12, FR13, FR14 |
| Epic 4 (Shopping List) | FR15, FR16, FR17, FR18, FR19, FR20, FR21, FR22, FR23, FR24, FR25, FR44, FR45, FR46, FR47, FR48 |
| Epic 5 (Real-time) | FR26, FR27, FR28, FR29, FR30, FR31 |
| Epic 6 (Offline) | FR39, FR40, FR41, FR42, FR43 |
| Epic 7 (Notifications) | FR32, FR33, FR34, FR35, FR36, FR37, FR38 |
| Epic 8 (PWA & Polish) | FR49, FR50, FR51, FR52, FR53, FR54 |

---

## Epic 1: Foundation & Project Setup

**Goal:** Establish the development foundation with Next.js 15, Supabase, and deployment pipeline so that all subsequent features can be built on a solid base.

**User Value:** Enables all subsequent user-facing functionality. Required foundation for greenfield project.

### Story 1.1: Project Initialization

As a developer,
I want to initialize the Next.js 15 project with TypeScript and Tailwind,
So that I have a properly configured development environment.

**Acceptance Criteria:**

**Given** a new project directory
**When** the project is initialized
**Then** the following should be configured:
- Next.js 15 with App Router
- TypeScript 5.x with strict mode
- Tailwind CSS 3.x with custom config
- ESLint + Prettier configuration
- Git repository with .gitignore

**And** the project structure matches:
```
app/
  layout.tsx
  page.tsx
components/
lib/
public/
```

**And** `npm run dev` starts the development server on localhost:3000

**And** `npm run build` completes without errors

**Prerequisites:** None

**Technical Notes:**
- Use `npx create-next-app@latest --typescript --tailwind --app --src-dir=false`
- Configure path aliases in tsconfig.json (@/*)
- Add Inter font via next/font
- Configure Tailwind with design tokens from UX spec (--color-primary: #0288D1)

---

### Story 1.2: Supabase Project Setup

As a developer,
I want to set up Supabase project with database schema,
So that the backend infrastructure is ready for authentication and data storage.

**Acceptance Criteria:**

**Given** a Supabase project (local or cloud)
**When** the database migrations are applied
**Then** the following tables should exist:
- profiles (id, display_name, avatar_url, created_at, updated_at)
- homes (id, name, invite_code, created_by, created_at, updated_at)
- home_members (id, user_id, home_id, role, joined_at)
- shopping_list_items (id, home_id, name, quantity, category, is_purchased, created_by, created_at, updated_at)
- push_subscriptions (id, user_id, token, platform, created_at)

**And** all Row Level Security policies are enabled

**And** helper functions exist:
- generate_invite_code()
- update_updated_at_column()
- create_profile_for_user()

**And** triggers are configured:
- Auto-create profile on user signup
- Auto-add creator as admin when home created
- Update updated_at on modifications

**Prerequisites:** Story 1.1

**Technical Notes:**
- Use Supabase CLI for local development: `supabase init`, `supabase start`
- Create migrations in supabase/migrations/
- See Architecture doc section "Database Schema" for complete SQL
- Enable Realtime on shopping_list_items: `ALTER PUBLICATION supabase_realtime ADD TABLE shopping_list_items`

---

### Story 1.3: Supabase Client Integration

As a developer,
I want to integrate Supabase client libraries with Next.js,
So that the application can authenticate users and query the database.

**Acceptance Criteria:**

**Given** the Next.js project with Supabase dependencies
**When** the Supabase clients are configured
**Then** the following should work:
- Server-side client (lib/supabase/server.ts) using @supabase/ssr
- Browser client (lib/supabase/client.ts) using @supabase/ssr
- Middleware for session refresh (middleware.ts)

**And** environment variables are configured:
- NEXT_PUBLIC_SUPABASE_URL
- NEXT_PUBLIC_SUPABASE_ANON_KEY
- NEXT_PUBLIC_SITE_URL

**And** TypeScript types are generated from database schema

**Prerequisites:** Story 1.2

**Technical Notes:**
- Install: `npm install @supabase/supabase-js @supabase/ssr`
- Generate types: `supabase gen types typescript --local > lib/database.types.ts`
- Middleware matcher excludes static files
- See Architecture doc "Authentication Flow" for implementation

---

### Story 1.4: Vercel Deployment Pipeline

As a developer,
I want to configure Vercel deployment with preview and production environments,
So that the application can be deployed and tested continuously.

**Acceptance Criteria:**

**Given** the project is connected to Vercel
**When** code is pushed to main branch
**Then** automatic deployment to production should trigger

**And** when code is pushed to feature branch
**Then** preview deployment should be created with unique URL

**And** environment variables should be configured:
- Production: Supabase Cloud credentials
- Preview: Supabase staging credentials

**And** build should complete in < 2 minutes

**And** Lighthouse CI check should pass (Performance > 80)

**Prerequisites:** Story 1.3

**Technical Notes:**
- Connect GitHub repo to Vercel project
- Configure environment variables in Vercel dashboard
- Set up Supabase production project (separate from local)
- Configure custom domain later (myhome.app)

---

## Epic 2: User Authentication

**Goal:** Enable users to create accounts, sign in securely, and manage their credentials so that they can access their personal data safely.

**User Value:** Users can register, log in, and securely access their family's data.

### Story 2.1: User Registration

As a new user,
I want to create an account with email and password,
So that I can start using MyHome for my family.

**Acceptance Criteria:**

**Given** I am on the /signup page
**When** I enter a valid email and password (min 8 characters)
**Then** my account should be created in Supabase Auth
**And** a profile record should be auto-created with display_name from email
**And** I should be redirected to /onboarding

**Given** I enter an email that already exists
**When** I submit the form
**Then** I should see error "Email already registered"

**Given** I enter a password shorter than 8 characters
**When** I submit the form
**Then** I should see error "Password must be at least 8 characters"

**Prerequisites:** Story 1.3

**Technical Notes:**
- Create app/(auth)/signup/page.tsx
- Implement signUp Server Action in app/actions/auth.ts
- Use Zod for validation (see Architecture doc)
- Style according to UX spec: Login/Register wireframe
- Form fields: email, password, optional display name
- Auto-focus email field on page load

---

### Story 2.2: User Login

As a registered user,
I want to log in with my email and password,
So that I can access my family's shopping list.

**Acceptance Criteria:**

**Given** I am on the /login page
**When** I enter valid credentials
**Then** I should be authenticated via Supabase Auth
**And** JWT should be stored in HttpOnly cookie
**And** I should be redirected to / (shopping list)

**Given** I enter invalid credentials
**When** I submit the form
**Then** I should see error "Invalid email or password"

**Given** I am already logged in
**When** I visit /login
**Then** I should be redirected to /

**Prerequisites:** Story 2.1

**Technical Notes:**
- Create app/(auth)/login/page.tsx
- Implement signIn Server Action
- Session persists across browser restarts (30 day expiry)
- Add "Forgot password?" link to /reset-password
- Rate limit: 5 attempts per minute per IP (middleware)

---

### Story 2.3: Password Reset Flow

As a user who forgot my password,
I want to reset it via email verification,
So that I can regain access to my account.

**Acceptance Criteria:**

**Given** I am on the /reset-password page
**When** I enter my registered email
**Then** a password reset email should be sent
**And** I should see confirmation "Check your email for reset link"

**Given** I click the reset link in email
**When** the link is valid (not expired)
**Then** I should be taken to /reset-password/confirm
**And** I can enter a new password

**Given** I enter a new valid password
**When** I submit the form
**Then** my password should be updated
**And** all existing sessions should be invalidated
**And** I should be redirected to /login

**Prerequisites:** Story 2.2

**Technical Notes:**
- Create app/(auth)/reset-password/page.tsx and confirm/page.tsx
- Implement resetPassword Server Action
- Configure email template in Supabase Dashboard
- Reset link expires in 1 hour
- Redirects to NEXT_PUBLIC_SITE_URL/reset-password/confirm

---

### Story 2.4: User Profile Management

As a logged-in user,
I want to update my profile information,
So that my family members can identify me easily.

**Acceptance Criteria:**

**Given** I am on the /settings/profile page
**When** I update my display name
**Then** the profiles table should be updated
**And** I should see success message "Profile updated"

**Given** I upload a new avatar image
**When** the upload completes
**Then** the image should be stored in Supabase Storage
**And** avatar_url should be updated in profiles table
**And** my avatar should appear in the UI

**Given** I want to change my email
**When** I enter a new email and confirm
**Then** a verification email should be sent to the new address
**And** email updates after verification

**Prerequisites:** Story 2.2

**Technical Notes:**
- Create app/(app)/settings/profile/page.tsx
- Use Supabase Storage for avatars (public bucket)
- Avatar max size: 2MB, formats: jpg, png, webp
- Display name max length: 50 characters

---

### Story 2.5: Account Deletion

As a user,
I want to delete my account and all associated data,
So that I can exercise my right to be forgotten.

**Acceptance Criteria:**

**Given** I am on the /settings/profile page
**When** I click "Delete Account"
**Then** I should see a confirmation dialog warning this is irreversible

**Given** I confirm deletion by typing "DELETE"
**When** I submit the confirmation
**Then** my auth.users record should be deleted
**And** CASCADE deletes should remove: profile, home_members, shopping items created by me
**And** I should be logged out and redirected to /login

**Prerequisites:** Story 2.4

**Technical Notes:**
- Implement deleteAccount Server Action
- Requires password confirmation for security
- If user is last member of home, home should also be deleted
- Log deletion for audit purposes

---

## Epic 3: Home Management & Onboarding

**Goal:** Enable users to create households, invite family members, and manage their home so that families can collaborate together.

**User Value:** Users can set up their household and invite family to join.

### Story 3.1: Onboarding Flow - Create or Join Home

As a new user after registration,
I want to either create a new home or join an existing one,
So that I can start collaborating with my family.

**Acceptance Criteria:**

**Given** I am a logged-in user without a home
**When** I visit any page
**Then** I should be redirected to /onboarding

**Given** I am on /onboarding
**When** I choose "Create New Home"
**Then** I should see a form to enter home name

**Given** I enter a home name (2-50 characters)
**When** I submit the form
**Then** a home should be created with unique invite_code
**And** I should be added as admin member
**And** I should be redirected to / (shopping list)

**Given** I choose "Join Existing Home"
**When** I enter a valid 6-character invite code
**Then** I should be added as member to that home
**And** I should be redirected to /

**Prerequisites:** Story 2.1

**Technical Notes:**
- Create app/(app)/onboarding/page.tsx
- Implement createHome and joinHome Server Actions (app/actions/home.ts)
- Invite code validation: uppercase, 6 chars, alphanumeric
- Show error if code invalid or user already has a home
- UX: Two prominent buttons "Stwórz nowy dom" / "Dołącz do istniejącego"

---

### Story 3.2: View Home Members

As a home member,
I want to see all members of my household,
So that I know who I'm collaborating with.

**Acceptance Criteria:**

**Given** I am on the /settings (Dom tab)
**When** the page loads
**Then** I should see a list of all home members with:
- Display name
- Avatar
- Role (Admin/Member)
- Join date

**And** members should be sorted by join date (oldest first)

**Given** I am viewing members
**When** another user joins my home
**Then** the list should update (via page refresh or real-time)

**Prerequisites:** Story 3.1

**Technical Notes:**
- Create app/(app)/settings/page.tsx
- Query home_members joined with profiles
- RLS ensures only home members visible
- Show current user with "(You)" label
- Admin shown with badge/icon

---

### Story 3.3: Invite Code Display and Copy

As a home member,
I want to view and copy my home's invite code,
So that I can share it with family members.

**Acceptance Criteria:**

**Given** I am on the /settings page
**When** I view the invite code section
**Then** I should see the 6-character code displayed prominently

**Given** I click "Copy Code" button
**When** the action completes
**Then** the code should be copied to clipboard
**And** I should see feedback "Code copied!"
**And** the button should show checkmark for 2 seconds

**Prerequisites:** Story 3.2

**Technical Notes:**
- Use Clipboard API: navigator.clipboard.writeText()
- Style code with monospace font, large size
- Add share hint: "Share this code with family members"
- Consider share button for mobile (Web Share API)

---

### Story 3.4: Regenerate Invite Code

As a home admin,
I want to regenerate the invite code,
So that I can invalidate old codes if shared with wrong people.

**Acceptance Criteria:**

**Given** I am an admin on /settings page
**When** I click "Regenerate Code"
**Then** I should see confirmation dialog "This will invalidate the current code"

**Given** I confirm the action
**When** the regeneration completes
**Then** a new unique 6-char code should be generated
**And** the old code should no longer work
**And** I should see the new code displayed

**Given** I am a regular member (not admin)
**When** I view /settings
**Then** I should NOT see the "Regenerate Code" button

**Prerequisites:** Story 3.3

**Technical Notes:**
- Implement regenerateInviteCode Server Action
- Check role === 'admin' before allowing
- Call generate_invite_code() database function
- Show success toast with new code

---

### Story 3.5: Leave Home

As a home member,
I want to leave my current home,
So that I can join a different household.

**Acceptance Criteria:**

**Given** I am on /settings page
**When** I click "Leave Home"
**Then** I should see confirmation dialog with warning

**Given** I confirm leaving
**When** the action completes
**Then** my home_members record should be deleted
**And** I should be redirected to /onboarding
**And** I can now create or join a different home

**Given** I am the last member of the home
**When** I leave
**Then** the home and all its data (items) should be deleted

**Prerequisites:** Story 3.2

**Technical Notes:**
- Implement leaveHome Server Action
- Check if last member and cascade delete home
- Clear any cached home data
- Warning: "All your shopping list contributions will remain in this home"

---

## Epic 4: Shopping List Core

**Goal:** Enable users to manage their family shopping list with full CRUD operations so that families can coordinate their shopping needs.

**User Value:** Users can add, edit, mark, and delete shopping items.

### Story 4.1: Display Shopping List

As a home member,
I want to see my family's shopping list,
So that I know what needs to be purchased.

**Acceptance Criteria:**

**Given** I am logged in and have a home
**When** I visit / (home page)
**Then** I should see the shopping list with two sections:
- "DO KUPIENIA" (not purchased items)
- "KUPIONE" (purchased items)

**And** items should display:
- Name
- Quantity (if set)
- Category chip (if set)
- Checkbox for purchase status

**And** not purchased items should appear at top
**And** purchased items should appear at bottom with strikethrough

**Given** the list is empty
**When** I view the page
**Then** I should see empty state: "No items yet. Tap + to add your first item."

**Prerequisites:** Story 3.1

**Technical Notes:**
- Create app/(app)/page.tsx as Server Component
- Query shopping_list_items with RLS (auto-filtered by home)
- Sort: is_purchased ASC, created_at DESC
- Use ShoppingList component for display
- Style per UX spec: Shopping List wireframe

---

### Story 4.2: Add Shopping Item

As a home member,
I want to add items to the shopping list,
So that my family knows what to buy.

**Acceptance Criteria:**

**Given** I am on the shopping list page
**When** I tap the "+" floating action button
**Then** a bottom sheet modal should appear with "Add Item" form

**Given** I enter an item name (1-100 chars)
**When** I tap "Add" or press Enter
**Then** the item should be inserted into shopping_list_items
**And** the modal should close
**And** the item should appear at top of "DO KUPIENIA" section
**And** created_by should be set to my user_id

**Given** I optionally set quantity (e.g., "2L", "500g")
**When** I add the item
**Then** quantity should be displayed next to name

**Given** I optionally select a category
**When** I add the item
**Then** category chip should be displayed

**Given** I submit without a name
**When** validation runs
**Then** I should see error "Item name is required"

**Prerequisites:** Story 4.1

**Technical Notes:**
- Create AddItemModal client component
- Implement addShoppingItem Server Action
- Categories: Nabiał, Warzywa, Pieczywo, Mięso, Napoje, Inne
- Auto-focus name input when modal opens
- Optimistic update: show item immediately, confirm after server

---

### Story 4.3: Mark Item as Purchased

As a home member,
I want to mark items as purchased,
So that my family knows what's been bought.

**Acceptance Criteria:**

**Given** I am viewing an unpurchased item
**When** I tap the checkbox
**Then** is_purchased should be set to true
**And** the item should move to "KUPIONE" section
**And** the item should show strikethrough style
**And** checkbox should show checked state

**Given** I am viewing a purchased item
**When** I tap the checkbox
**Then** is_purchased should be set to false
**And** the item should move back to "DO KUPIENIA" section

**Prerequisites:** Story 4.2

**Technical Notes:**
- Implement toggleItemPurchased Server Action
- Use optimistic update for instant feedback
- Animate item movement between sections (CSS transition)
- Single tap interaction (< 1 second total time)

---

### Story 4.4: Edit Shopping Item

As a home member,
I want to edit existing items,
So that I can correct mistakes or update details.

**Acceptance Criteria:**

**Given** I am viewing a shopping item
**When** I tap on the item row (not checkbox)
**Then** an edit modal should appear with current values

**Given** I modify name, quantity, or category
**When** I tap "Save"
**Then** the item should be updated in database
**And** the modal should close
**And** changes should be reflected in the list

**Given** I clear the name field
**When** I try to save
**Then** I should see error "Item name is required"

**Prerequisites:** Story 4.2

**Technical Notes:**
- Reuse AddItemModal with edit mode
- Implement updateShoppingItem Server Action
- Pre-populate form with existing values
- updated_at should be set automatically via trigger

---

### Story 4.5: Delete Shopping Item

As a home member,
I want to delete items from the list,
So that I can remove items that are no longer needed.

**Acceptance Criteria:**

**Given** I am viewing a shopping item
**When** I swipe left on the item (mobile) or click delete icon
**Then** a delete button should appear in red

**Given** I tap the delete button
**When** I confirm in the dialog "Delete [item name]?"
**Then** the item should be deleted from database
**And** the item should be removed from the list with animation

**Given** I cancel the deletion
**When** I tap "Cancel"
**Then** the item should remain in the list

**Prerequisites:** Story 4.2

**Technical Notes:**
- Implement deleteShoppingItem Server Action
- Use swipe gesture library (e.g., react-swipeable)
- Confirmation dialog for destructive action
- Animate removal (fade out + collapse)

---

### Story 4.6: Category Chips and Sorting

As a home member,
I want items organized by category with visual chips,
So that I can quickly scan the list.

**Acceptance Criteria:**

**Given** items have categories assigned
**When** I view the list
**Then** each item should show its category as a colored chip

**And** category colors should be:
- Nabiał: Blue
- Warzywa: Green
- Pieczywo: Orange
- Mięso: Red
- Napoje: Purple
- Inne: Gray

**Given** I view the predefined category list
**When** adding/editing an item
**Then** I should see all 6 categories as selectable chips

**Prerequisites:** Story 4.2

**Technical Notes:**
- Style chips per UX spec color palette
- Chips should be small, pill-shaped
- Category is optional (can be null)
- Consider grouping by category in Phase 2

---

## Epic 5: Real-time Synchronization

**Goal:** Enable instant synchronization of shopping list changes across all family members so that everyone sees updates in real-time.

**User Value:** Family members see each other's changes instantly (< 2 seconds).

### Story 5.1: Real-time List Updates

As a home member,
I want to see shopping list changes from family members instantly,
So that we're always looking at the same list.

**Acceptance Criteria:**

**Given** I am viewing the shopping list
**When** another family member adds an item
**Then** the item should appear in my list within 2 seconds

**Given** another family member marks an item as purchased
**When** the change syncs
**Then** the item should move to "KUPIONE" section in my view within 2 seconds

**Given** another family member edits an item
**When** the change syncs
**Then** I should see updated name/quantity/category within 2 seconds

**Given** another family member deletes an item
**When** the change syncs
**Then** the item should disappear from my list within 2 seconds

**Prerequisites:** Story 4.3

**Technical Notes:**
- Create ShoppingListRealtime client component
- Subscribe to Supabase Realtime channel: `shopping-${homeId}`
- Listen to postgres_changes: INSERT, UPDATE, DELETE
- Use filter: `home_id=eq.${homeId}` for server-side filtering
- See Architecture doc "Real-time Architecture" for implementation

---

### Story 5.2: Connection Status Indicator

As a home member,
I want to see my connection status,
So that I know if changes are being synced.

**Acceptance Criteria:**

**Given** I am connected to Realtime
**When** the connection is established
**Then** I should see green "Online" indicator

**Given** my connection is lost
**When** the WebSocket disconnects
**Then** I should see red "Offline" indicator

**Given** I am reconnecting
**When** the connection is being re-established
**Then** I should see yellow "Connecting..." indicator

**Given** I come back online
**When** the connection is restored
**Then** status should change to "Online"
**And** any missed updates should sync

**Prerequisites:** Story 5.1

**Technical Notes:**
- Monitor channel subscription status
- Status values: SUBSCRIBED, CHANNEL_ERROR, TIMED_OUT, CLOSED
- Position indicator in top bar or status area
- Use subtle indicator (small dot + text)

---

### Story 5.3: Optimistic Updates

As a home member,
I want my actions to feel instant,
So that the app feels responsive even with network latency.

**Acceptance Criteria:**

**Given** I add a new item
**When** I tap "Add"
**Then** the item should appear immediately in the list (< 100ms)
**And** the item should sync to server in background

**Given** I mark an item as purchased
**When** I tap the checkbox
**Then** the UI should update immediately
**And** the change should sync to server in background

**Given** a server action fails
**When** the error occurs
**Then** the optimistic update should be rolled back
**And** I should see an error message

**Prerequisites:** Story 5.1

**Technical Notes:**
- Generate temporary UUID client-side for new items
- Store optimistic state in React state
- Replace with server response after confirmation
- Handle conflicts: server state wins

---

### Story 5.4: Automatic Reconnection

As a home member,
I want the app to automatically reconnect,
So that I don't miss updates after network issues.

**Acceptance Criteria:**

**Given** my connection drops
**When** I regain network connectivity
**Then** the WebSocket should automatically reconnect

**And** reconnection should use exponential backoff:
- Attempt 1: 2 seconds
- Attempt 2: 4 seconds
- Attempt 3: 8 seconds
- Maximum: 16 seconds

**Given** I reconnect successfully
**When** the channel subscribes
**Then** any changes made while offline should be fetched
**And** the list should update to current state

**Prerequisites:** Story 5.2

**Technical Notes:**
- Supabase Realtime handles reconnection automatically
- Listen to online/offline browser events
- Fetch full list on reconnect to ensure consistency
- Clear and re-subscribe to channel if needed

---

## Epic 6: Offline Capability

**Goal:** Enable users to view and modify the shopping list when offline so that they can use the app while shopping without reliable network.

**User Value:** Users can shop in stores with poor connectivity.

### Story 6.1: Offline List Viewing

As a home member,
I want to view the shopping list when offline,
So that I can see what to buy even without network.

**Acceptance Criteria:**

**Given** I loaded the shopping list while online
**When** I go offline
**Then** I should still see the last known list state

**And** the "Offline" indicator should be displayed

**Given** I am offline
**When** I try to view the list
**Then** cached data should be displayed
**And** I should see notice "You're offline - showing cached data"

**Prerequisites:** Story 5.2

**Technical Notes:**
- Implement Service Worker caching strategy
- Cache shopping list data in localStorage
- Network-first with cache fallback for API
- Cache static assets (HTML, CSS, JS) for offline access

---

### Story 6.2: Offline Mutations Queue

As a home member,
I want to add and modify items when offline,
So that I can update the list while shopping.

**Acceptance Criteria:**

**Given** I am offline
**When** I add a new item
**Then** the item should appear in the list (optimistic update)
**And** the mutation should be queued in localStorage

**Given** I am offline
**When** I mark an item as purchased
**Then** the UI should update immediately
**And** the mutation should be queued

**Given** I come back online
**When** the network is restored
**Then** all queued mutations should sync to server in order
**And** I should see "Syncing..." indicator

**Given** a queued mutation fails
**When** sync is attempted
**Then** the error should be logged
**And** retry should be attempted (max 3 times)

**Prerequisites:** Story 6.1

**Technical Notes:**
- Implement OfflineQueue class (lib/offline-queue.ts)
- Queue structure: {id, type, table, data, timestamp}
- Persist queue in localStorage
- Process queue FIFO on reconnection
- See Architecture doc "Offline Architecture" for implementation

---

### Story 6.3: Offline Indicator and Sync Status

As a home member,
I want to see offline status and pending changes,
So that I know what will sync when I'm back online.

**Acceptance Criteria:**

**Given** I am offline with pending changes
**When** I view the app
**Then** I should see "Offline - X changes pending"

**Given** I come back online with pending changes
**When** sync starts
**Then** I should see "Syncing X changes..."

**Given** sync completes successfully
**When** all changes are synced
**Then** I should see "All changes synced"
**And** indicator should return to "Online"

**Given** sync fails
**When** errors occur
**Then** I should see "Sync failed - tap to retry"

**Prerequisites:** Story 6.2

**Technical Notes:**
- Count pending operations in queue
- Show badge with count
- Provide manual retry button
- Toast notification on sync complete

---

## Epic 7: Push Notifications

**Goal:** Enable push notifications for shopping list activity so that family members stay informed of changes.

**User Value:** Users receive notifications when family adds or purchases items.

### Story 7.1: Notification Permission Request

As a home member,
I want to be asked for notification permission,
So that I can choose to receive updates.

**Acceptance Criteria:**

**Given** I am using the app for the first time
**When** I add my first item
**Then** I should be prompted to enable notifications
**And** the prompt should be non-intrusive (not blocking)

**Given** I click "Enable Notifications"
**When** the browser permission dialog appears
**Then** if I allow, my subscription should be saved
**And** if I deny, I should not be asked again this session

**Given** I dismissed the prompt
**When** I visit settings
**Then** I should be able to enable notifications there

**Prerequisites:** Story 4.2

**Technical Notes:**
- Use Web Push API: Notification.requestPermission()
- Only prompt after meaningful action (not on first visit)
- Save permission state to localStorage to avoid re-asking
- Create push_subscriptions record with token

---

### Story 7.2: Subscribe to Push Notifications

As a home member,
I want to subscribe to push notifications,
So that I can receive them on this device.

**Acceptance Criteria:**

**Given** I granted notification permission
**When** the subscription is created
**Then** a push subscription should be registered with the browser
**And** the subscription token should be saved to push_subscriptions table

**Given** I toggle notifications on in settings
**When** I was previously unsubscribed
**Then** a new subscription should be created

**Given** I toggle notifications off in settings
**When** I was subscribed
**Then** my subscription should be deleted from database

**Prerequisites:** Story 7.1

**Technical Notes:**
- Generate VAPID keys for Web Push
- Create Service Worker push handler
- Store subscription endpoint, p256dh, auth keys
- Handle subscription expiration/renewal

---

### Story 7.3: Send Notification on Item Added/Purchased

As a home member,
I want to receive notifications when family adds or purchases items,
So that I stay informed of shopping list changes.

**Acceptance Criteria:**

**Given** a family member adds an item
**When** the item is saved
**Then** all other home members with notifications enabled should receive:
- Title: "MyHome"
- Body: "[Name] dodał: [Item name]"

**Given** a family member marks an item as purchased
**When** the item is updated
**Then** all other home members should receive:
- Title: "MyHome"
- Body: "[Name] kupił: [Item name]"

**Given** I add or purchase an item
**When** the notification would be sent
**Then** I should NOT receive notification for my own actions

**Prerequisites:** Story 7.2

**Technical Notes:**
- Implement notification sending (Edge Function or Server Action)
- Query push_subscriptions for home members (exclude actor)
- Use web-push library for sending
- Include item name and actor name in notification

---

### Story 7.4: Notification Limits and Click Handler

As a home member,
I want notifications limited and actionable,
So that I'm not spammed and can quickly access the list.

**Acceptance Criteria:**

**Given** I receive a notification
**When** I tap/click it
**Then** the app should open to the shopping list

**Given** notification frequency
**When** more than 5 notifications would be sent in a week
**Then** additional notifications should be suppressed
**And** I should see summary "5 more updates this week" in app

**Given** I am viewing the app
**When** a notification would be sent
**Then** it should be suppressed (don't notify if already looking)

**Prerequisites:** Story 7.3

**Technical Notes:**
- Track notification count per user per week
- Store last_notified_at timestamp
- Service Worker click handler: clients.openWindow('/')
- Check document.visibilityState before sending

---

## Epic 8: PWA & Polish

**Goal:** Make the application installable as a PWA with polished UX so that users have a native-like experience.

**User Value:** Users can install the app and enjoy a polished, accessible experience.

### Story 8.1: PWA Manifest and Installation

As a user,
I want to install MyHome on my device,
So that I can access it like a native app.

**Acceptance Criteria:**

**Given** I visit the app on mobile
**When** I use it 2-3 times
**Then** I should see "Add to Home Screen" prompt

**Given** I install the PWA
**When** I open it from home screen
**Then** it should launch in standalone mode (no browser UI)
**And** it should have app icon and splash screen

**And** the manifest should include:
- name: "MyHome"
- short_name: "MyHome"
- theme_color: "#0288D1"
- background_color: "#FFFFFF"
- display: "standalone"
- icons: 192x192, 512x512, maskable

**Prerequisites:** Story 6.1

**Technical Notes:**
- Create public/manifest.json
- Add <link rel="manifest"> to layout
- Create icons in multiple sizes
- Test on iOS Safari and Chrome Android
- Configure Service Worker for offline

---

### Story 8.2: Responsive Design Implementation

As a user,
I want the app to work well on any device,
So that I can use it on phone, tablet, or desktop.

**Acceptance Criteria:**

**Given** I am on mobile (< 768px)
**When** I view the app
**Then** I should see single column layout with bottom navigation

**Given** I am on tablet (768-1024px)
**When** I view the app
**Then** layout should adapt with larger touch targets

**Given** I am on desktop (> 1024px)
**When** I view the app
**Then** I should see expanded layout with side navigation option

**And** all screens should be usable at 320px width minimum

**Prerequisites:** Story 4.1

**Technical Notes:**
- Use Tailwind responsive classes (sm:, md:, lg:)
- Mobile-first approach
- Test on iPhone SE (320px), iPhone 14 (390px), iPad (768px)
- Bottom navigation on mobile, side/top on desktop

---

### Story 8.3: Accessibility Compliance

As a user with accessibility needs,
I want the app to be accessible,
So that I can use it with assistive technologies.

**Acceptance Criteria:**

**Given** the app UI
**When** tested for accessibility
**Then** it should pass WCAG 2.1 Level AA:
- Color contrast ratio >= 4.5:1 for text
- All interactive elements have focus indicators
- All images have alt text
- Forms have associated labels
- Semantic HTML structure

**Given** I use keyboard navigation
**When** I tab through the interface
**Then** focus order should be logical
**And** all actions should be possible without mouse

**Given** I use a screen reader
**When** I navigate the app
**Then** all content should be announced properly
**And** dynamic updates should be announced (aria-live)

**Prerequisites:** Story 4.1

**Technical Notes:**
- Use semantic HTML (main, nav, section, article)
- Add aria-labels to icon buttons
- Implement skip links
- Test with VoiceOver (iOS/macOS) and NVDA (Windows)
- Minimum touch target size: 44x44px

---

### Story 8.4: Bottom Navigation and Final Polish

As a user,
I want clear navigation and polished interactions,
So that the app feels professional and easy to use.

**Acceptance Criteria:**

**Given** I am on any screen
**When** I view the bottom navigation
**Then** I should see two tabs:
- "Zakupy" (shopping icon) - Shopping list
- "Dom" (home icon) - Home settings

**And** active tab should be highlighted

**Given** I perform actions
**When** animations occur
**Then** they should be smooth and purposeful:
- Item added: fade in + slide
- Item purchased: checkbox animation + move
- Item deleted: fade out + collapse

**Given** loading states
**When** data is being fetched
**Then** appropriate skeletons/spinners should display

**And** all error states should have clear messages and recovery actions

**Prerequisites:** All previous stories

**Technical Notes:**
- Use Tailwind animations or Framer Motion
- Loading skeletons for list items
- Toast notifications for success/error feedback
- Empty states with helpful messages
- Consistent spacing per UX design tokens

---

## FR Coverage Matrix

| FR | Description | Epic | Story |
|----|-------------|------|-------|
| FR1 | Create accounts with email/password | Epic 2 | Story 2.1 |
| FR2 | Log in and maintain sessions | Epic 2 | Story 2.2 |
| FR3 | Reset password via email | Epic 2 | Story 2.3 |
| FR4 | Update account information | Epic 2 | Story 2.4 |
| FR5 | Delete account and data | Epic 2 | Story 2.5 |
| FR6 | Unique email enforcement | Epic 2 | Story 2.1 |
| FR7 | Create new home | Epic 3 | Story 3.1 |
| FR8 | Generate 6-char invite code | Epic 3 | Story 3.1 |
| FR9 | Join home via invite code | Epic 3 | Story 3.1 |
| FR10 | One home per user (MVP) | Epic 3 | Story 3.1 |
| FR11 | View home members | Epic 3 | Story 3.2 |
| FR12 | Leave home | Epic 3 | Story 3.5 |
| FR13 | Regenerate invite code | Epic 3 | Story 3.4 |
| FR14 | Copy invite code | Epic 3 | Story 3.3 |
| FR15 | Add items with name | Epic 4 | Story 4.2 |
| FR16 | Specify quantity | Epic 4 | Story 4.2 |
| FR17 | Assign category | Epic 4 | Story 4.2 |
| FR18 | Predefined categories | Epic 4 | Story 4.6 |
| FR19 | Edit items | Epic 4 | Story 4.4 |
| FR20 | Delete items | Epic 4 | Story 4.5 |
| FR21 | Mark as purchased | Epic 4 | Story 4.3 |
| FR22 | Unmark purchased | Epic 4 | Story 4.3 |
| FR23 | Display two sections | Epic 4 | Story 4.1 |
| FR24 | Sort items | Epic 4 | Story 4.1 |
| FR25 | List per home | Epic 4 | Story 4.1 |
| FR26 | Real-time sync | Epic 5 | Story 5.1 |
| FR27 | Add item sync < 2s | Epic 5 | Story 5.1 |
| FR28 | Purchase sync < 2s | Epic 5 | Story 5.1 |
| FR29 | Edit/delete sync < 2s | Epic 5 | Story 5.1 |
| FR30 | Connection status | Epic 5 | Story 5.2 |
| FR31 | Auto-reconnect and sync | Epic 5 | Story 5.4 |
| FR32 | Request notification permission | Epic 7 | Story 7.1 |
| FR33 | Enable/disable notifications | Epic 7 | Story 7.2 |
| FR34 | Notify on item added | Epic 7 | Story 7.3 |
| FR35 | Notify on item purchased | Epic 7 | Story 7.3 |
| FR36 | Notifications include context | Epic 7 | Story 7.3 |
| FR37 | Max 5 notifications/week | Epic 7 | Story 7.4 |
| FR38 | Tap notification opens app | Epic 7 | Story 7.4 |
| FR39 | View list offline | Epic 6 | Story 6.1 |
| FR40 | Add/edit/mark offline | Epic 6 | Story 6.2 |
| FR41 | Queue and sync changes | Epic 6 | Story 6.2 |
| FR42 | Display offline indicator | Epic 6 | Story 6.3 |
| FR43 | Optimistic updates | Epic 5 | Story 5.3 |
| FR44 | Only view own home's list | Epic 4 | Story 4.1 |
| FR45 | Only view own home's members | Epic 3 | Story 3.2 |
| FR46 | Cannot access other homes | Epic 4 | Story 4.1 |
| FR47 | Database enforces RLS | Epic 1 | Story 1.2 |
| FR48 | Track item creator | Epic 4 | Story 4.2 |
| FR49 | Installable as PWA | Epic 8 | Story 8.1 |
| FR50 | Responsive design | Epic 8 | Story 8.2 |
| FR51 | Works in modern browsers | Epic 8 | Story 8.2 |
| FR52 | Shopping list is home screen | Epic 4 | Story 4.1 |
| FR53 | Bottom tab navigation | Epic 8 | Story 8.4 |
| FR54 | Settings from Dom tab | Epic 3 | Story 3.2 |

---

## Summary

**Total Epics:** 8
**Total Stories:** 35
**All FRs Covered:** FR1-FR54 (FR55-FR59 are Phase 2)

**Epic Sequence Rationale:**

1. **Foundation** - Must come first (greenfield project setup)
2. **Authentication** - Required before any user features
3. **Home Management** - Required before shopping list (need home_id)
4. **Shopping List Core** - Primary user value, MVP core
5. **Real-time** - Enhances shopping list with collaboration
6. **Offline** - Enables shopping use case
7. **Notifications** - Keeps family informed
8. **PWA & Polish** - Final touches for production

**Context Incorporated:**
- PRD functional requirements (FR1-FR54)
- Architecture technical decisions (Server Actions, RLS, Supabase Realtime)
- UX wireframes and interaction patterns
- Design tokens and accessibility requirements

**Ready for:** Phase 4 Implementation (Sprint Planning)

---

_For implementation: Use the `dev-story` workflow to implement individual stories from this epic breakdown._

_This document serves as the source of truth for what will be built in MyHome MVP._
