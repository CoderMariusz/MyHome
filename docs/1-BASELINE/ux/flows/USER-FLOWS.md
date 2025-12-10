# HomeOS - User Flows (MVP)

**Data:** 2025-12-09
**Wersja:** 1.0
**Status:** Draft
**Autor:** UX Designer (Sally)

**Ref:**
- @docs/1-BASELINE/ux/WIREFRAMES.md
- @docs/1-BASELINE/PRD.md

---

## Table of Contents

1. [Onboarding - Register & Create Household](#1-onboarding---register--create-household)
2. [Onboarding - Join Existing Household](#2-onboarding---join-existing-household)
3. [Add Shopping Item](#3-add-shopping-item)
4. [Check Off Item](#4-check-off-item)
5. [Invite Family Member](#5-invite-family-member)
6. [Create New Shopping List](#6-create-new-shopping-list)
7. [Edit Shopping Item](#7-edit-shopping-item)
8. [Delete Item](#8-delete-item)
9. [Switch Theme (Dark Mode)](#9-switch-theme-dark-mode)

---

## 1. Onboarding - Register & Create Household

### Flow Info
| Field | Value |
|-------|-------|
| Feature | Authentication + Household Setup |
| Story | US-01, US-03 |
| User Goal | Założyć konto i utworzyć gospodarstwo domowe |
| Entry Point | Landing page, "Zarejestruj się" link |
| Success Metric | User reaches Dashboard with household created |

---

### Flow Diagram

```
                    [LANDING PAGE]
                          |
                          | tap "Zarejestruj się"
                          v
                  +---------------+
                  |   REGISTER    |
                  |   SCREEN      |
                  +-------+-------+
                          |
                          | fill form + tap "Utwórz konto"
                          v
                  +---------------+
                  |   LOADING     |
                  +-------+-------+
                          |
          +---------------+---------------+
          |                               |
          | SUCCESS                       | ERROR
          v                               v
  +---------------+               +---------------+
  | VERIFICATION  |               | SHOW ERROR    |
  | SENT SCREEN   |               | (stay on form)|
  +-------+-------+               +-------+-------+
          |                               |
          | user clicks email link        | fix + retry
          v                               |
  +---------------+                       |
  | EMAIL         |                       |
  | VERIFIED      |                       |
  +-------+-------+                       |
          |                               |
          | redirect                      |
          v                               |
  +---------------+                       |
  | HOUSEHOLD     |                       |
  | SETUP SCREEN  | <---------------------+
  +-------+-------+
          |
          | choose "Stwórz nowe gospodarstwo"
          v
  +---------------+
  | CREATE        |
  | HOUSEHOLD     |
  | MODAL         |
  +-------+-------+
          |
          | enter name + tap "Utwórz"
          v
  +---------------+
  |   LOADING     |
  +-------+-------+
          |
          | SUCCESS
          v
  +---------------+
  | SUCCESS       |
  | MODAL         |
  | (created)     |
  +-------+-------+
          |
          | tap "Przejdź do aplikacji"
          v
  +---------------+
  |   DASHBOARD   |
  +---------------+
```

---

### Steps Detail

#### Step 1: Landing → Register
| Aspect | Description |
|--------|-------------|
| User sees | Landing page with login form |
| User does | Taps "Nie masz konta? Zarejestruj się" link |
| System responds | Navigates to Register screen |
| Next | Register screen |

#### Step 2: Register Form
| Aspect | Description |
|--------|-------------|
| User sees | Register form (email, password, confirm password, terms checkbox) |
| User does | Fills form and taps "Utwórz konto" |
| System responds | Validates inputs, sends request to backend |
| Next | Loading state → Verification Sent OR Error state |

**Validation rules:**
- Email: Valid format, not already registered
- Password: Min 8 characters
- Confirm password: Matches password
- Terms: Must be checked

#### Step 3: Verification Sent
| Aspect | Description |
|--------|-------------|
| User sees | "Sprawdź swoją skrzynkę" screen with email address |
| User does | Opens email app, clicks verification link |
| System responds | Verifies email, marks account as active |
| Next | Household Setup screen |

#### Step 4: Household Setup - Choice
| Aspect | Description |
|--------|-------------|
| User sees | Two cards: "Stwórz nowe" or "Dołącz" |
| User does | Taps "Stwórz nowe gospodarstwo" |
| System responds | Opens Create Household modal |
| Next | Create Household modal |

#### Step 5: Create Household
| Aspect | Description |
|--------|-------------|
| User sees | Modal with input field for household name |
| User does | Enters name (e.g., "Rodzina Kowalskich"), taps "Utwórz" |
| System responds | Creates household, assigns Admin role, generates invite code |
| Next | Success modal |

#### Step 6: Success
| Aspect | Description |
|--------|-------------|
| User sees | "Gospodarstwo utworzone" with option to invite or go to app |
| User does | Taps "Przejdź do aplikacji" |
| System responds | Navigates to Dashboard |
| Next | Dashboard (empty state) |

---

### Decision Points

| Condition | True Path | False Path |
|-----------|-----------|------------|
| Email valid? | Continue to verification | Show error on form |
| Password strong? | Continue | Show error "Min 8 znaków" |
| Terms accepted? | Continue | Show error "Musisz zaakceptować" |
| Email verified? | Go to household setup | Stay on verification screen |
| Household created? | Go to dashboard | Show error |

---

### Edge Cases

#### User Cancels Registration
- **When:** Any step before dashboard
- **Action:** Back button or close modal
- **Destination:** Returns to Landing page
- **Note:** Draft not saved (user must re-register)

#### Email Already Exists
- **When:** Submit register form
- **Display:** "Ten email jest już zarejestrowany. Zaloguj się"
- **Recovery:** Link to login screen

#### Verification Email Not Received
- **When:** User waiting on verification screen
- **Display:** "Nie otrzymałeś? Wyślij ponownie" link
- **Recovery:** Tap to resend (60s cooldown)

#### Network Error During Registration
- **When:** Submit form
- **Display:** Toast "Brak połączenia. Sprawdź internet."
- **Recovery:** Retry button

---

### Success State
- **User sees:** Dashboard with empty state prompts
- **System state:** User account created, household created, user is Admin
- **Next options:** Add shopping list, invite members, explore app

---

### Metrics / Analytics

| Event | Trigger | Parameters |
|-------|---------|------------|
| registration_started | Tap "Utwórz konto" | source (landing) |
| registration_completed | Email verified | user_id, timestamp |
| household_created | Create household success | household_id, name |
| onboarding_completed | Reach dashboard | user_id, duration_seconds |
| onboarding_abandoned | Exit before dashboard | last_step |

---

## 2. Onboarding - Join Existing Household

### Flow Info
| Field | Value |
|-------|-------|
| Feature | Household Setup |
| Story | US-05 |
| User Goal | Dołączyć do istniejącego gospodarstwa |
| Entry Point | Household Setup screen, "Dołącz do gospodarstwa" card |

---

### Flow Diagram

```
            [HOUSEHOLD SETUP SCREEN]
                      |
                      | tap "Dołącz do gospodarstwa"
                      v
              +---------------+
              |   JOIN        |
              |   SCREEN      |
              +-------+-------+
                      |
                      | enter 6-digit code OR scan QR
                      v
              +---------------+
              |   LOADING     |
              | (validating)  |
              +-------+-------+
                      |
      +---------------+---------------+
      |                               |
      | VALID CODE                    | INVALID CODE
      v                               v
+---------------+             +---------------+
|   SUCCESS     |             | ERROR STATE   |
|   MODAL       |             | (stay on form)|
+-------+-------+             +-------+-------+
        |                             |
        | tap "Przejdź do aplikacji"  | fix + retry
        v                             |
+---------------+                     |
|   DASHBOARD   | <-------------------+
+---------------+
```

---

### Steps Detail

#### Step 1: Choose Join
| Aspect | Description |
|--------|-------------|
| User sees | Household Setup screen with two cards |
| User does | Taps "Dołącz do gospodarstwa" card |
| System responds | Navigates to Join screen |
| Next | Join screen |

#### Step 2: Enter Code
| Aspect | Description |
|--------|-------------|
| User sees | 6 input boxes for code OR "Zeskanuj kod QR" button |
| User does | Enters 6-character code (auto-focus, auto-advance) |
| System responds | When 6 chars entered, auto-validates |
| Next | Loading → Success OR Error |

**Alternative:** Scan QR code
- Tap "Zeskanuj kod QR" → Camera opens
- Scan QR → Auto-fills code → Auto-validates

#### Step 3: Validation
| Aspect | Description |
|--------|-------------|
| User sees | Loading spinner "Sprawdzanie kodu..." |
| System responds | Checks if code valid, not expired, household exists |
| Next | Success modal OR Error state |

#### Step 4: Success
| Aspect | Description |
|--------|-------------|
| User sees | "Dołączyłeś do gospodarstwa!" + household name |
| User does | Taps "Przejdź do aplikacji" |
| System responds | Assigns user to household, sets role (Member or Child) |
| Next | Dashboard (with household data) |

---

### Decision Points

| Condition | True Path | False Path |
|-----------|-----------|------------|
| Code valid? | Success modal | Error "Nieprawidłowy kod" |
| Code not expired? | Continue | Error "Kod wygasł" |
| Household exists? | Continue | Error "Nie znaleziono" |
| User not already member? | Continue | Error "Już jesteś członkiem" |

---

### Edge Cases

#### Invalid Code
- **When:** Enter incorrect code
- **Display:** Red border + "Nieprawidłowy kod lub wygasł"
- **Recovery:** Clear code, re-enter, or contact inviter

#### Code Expired
- **When:** Code older than 7 days
- **Display:** "Kod wygasł. Poproś o nowy."
- **Recovery:** Contact Admin to generate new invite

#### Camera Permission Denied (QR scan)
- **When:** Tap "Zeskanuj kod QR"
- **Display:** "Brak dostępu do kamery. Zmień ustawienia."
- **Recovery:** Manually enter code

#### Network Error
- **When:** Validating code
- **Display:** Toast "Brak połączenia"
- **Recovery:** Retry when connection restored

---

## 3. Add Shopping Item

### Flow Info
| Field | Value |
|-------|-------|
| Feature | Shopping List Management |
| Story | US-09 |
| User Goal | Dodać produkt do listy zakupów |
| Entry Point | Shopping List Detail screen, FAB "+" button |

---

### Flow Diagram

```
        [SHOPPING LIST DETAIL SCREEN]
                    |
                    | tap FAB "+"
                    v
            +---------------+
            |   ADD ITEM    |
            |   MODAL       |
            +-------+-------+
                    |
                    | input autofocus, keyboard appears
                    |
                    | user types product name
                    | (optional: select category, quantity, assign)
                    |
                    | tap "Dodaj" or press Enter
                    v
            +---------------+
            |   OPTIMISTIC  |
            |   UPDATE      |
            +-------+-------+
                    |
                    | modal closes, item appears at top of list
                    | background: sync to server
                    v
            +---------------+
            |   LIST DETAIL |
            | (item added)  |
            +---------------+
```

---

### Steps Detail

#### Step 1: Open Modal
| Aspect | Description |
|--------|-------------|
| User sees | List Detail screen with FAB at bottom right |
| User does | Taps FAB "+" button |
| System responds | Modal slides up from bottom, input autofocuses |
| Next | Add Item modal |

#### Step 2: Fill Form
| Aspect | Description |
|--------|-------------|
| User sees | Modal with input field (focused), category dropdown, optional fields |
| User does | Types product name (e.g., "Mleko 2L") |
| System responds | Autocomplete suggests previously added products |
| Next | User continues or submits |

**Optional fields:**
- Category: Dropdown (default: "Inne")
- Quantity: Number + unit (e.g., "2 litr")
- Assign to: Dropdown (default: "Wszyscy")

#### Step 3: Submit
| Aspect | Description |
|--------|-------------|
| User sees | Filled form |
| User does | Taps "Dodaj" button or presses Enter key |
| System responds | Validates (name required), closes modal |
| Next | Optimistic update |

#### Step 4: Optimistic Update
| Aspect | Description |
|--------|-------------|
| User sees | Modal closes (slide down), new item appears at top of list |
| System responds | Adds item locally, syncs to server in background |
| Next | List Detail screen (item visible) |

**Animation:**
- Modal slides down (300ms)
- New item fades in at top (200ms)

---

### Decision Points

| Condition | True Path | False Path |
|-----------|-----------|------------|
| Name filled? | Add item | Show error "Nazwa wymagana" |
| Network available? | Sync to server | Queue for later sync |

---

### Edge Cases

#### Empty Name
- **When:** Tap "Dodaj" without entering name
- **Display:** Red border + "Nazwa produktu jest wymagana"
- **Recovery:** Enter name, submit again

#### Network Error (Background Sync)
- **When:** Item added locally but sync fails
- **Display:** No immediate error (optimistic update)
- **Recovery:** Retry sync when connection restored, show toast if persistent failure

#### User Cancels
- **When:** Tap "Anuluj" or outside modal
- **Action:** Modal closes, no item added
- **Destination:** Back to List Detail

#### Autocomplete Selected
- **When:** User taps autocomplete suggestion
- **Action:** Auto-fills name + category (from history)
- **Recovery:** User can edit before submitting

---

### Success State
- **User sees:** Item added to list, positioned at top (or in category section)
- **System state:** Item saved to database, visible to all household members
- **Next options:** Add more items, checkoff items, back to lists

---

### Metrics

| Event | Trigger | Parameters |
|-------|---------|------------|
| add_item_modal_opened | Tap FAB | list_id, source |
| add_item_submitted | Tap "Dodaj" | item_name, category, has_quantity, assigned |
| add_item_autocomplete_used | Select suggestion | suggestion_used |

---

## 4. Check Off Item

### Flow Info
| Field | Value |
|-------|-------|
| Feature | Shopping List Item Checkoff |
| Story | US-12 |
| User Goal | Oznaczyć produkt jako kupiony |
| Entry Point | Shopping List Detail screen, tap checkbox |

---

### Flow Diagram

```
        [SHOPPING LIST DETAIL SCREEN]
                    |
                    | user taps checkbox next to item
                    v
            +---------------+
            |   CHECKBOX    |
            |   ANIMATION   |
            +-------+-------+
                    |
                    | scale down → draw check → scale up
                    | (300ms)
                    v
            +---------------+
            |   ITEM MOVES  |
            | TO "KUPIONE"  |
            +-------+-------+
                    |
                    | slide down animation (300ms)
                    | strikethrough appears
                    v
            +---------------+
            |   LIST DETAIL |
            | (item checked)|
            +-------+-------+
                    |
                    | background: sync to server
                    v
            [Item status saved]
```

---

### Steps Detail

#### Step 1: Tap Checkbox
| Aspect | Description |
|--------|-------------|
| User sees | List Detail with unchecked items |
| User does | Taps checkbox next to item (e.g., "Mleko 2L") |
| System responds | Checkbox animation starts |
| Next | Animation sequence |

#### Step 2: Animation
| Aspect | Description |
|--------|-------------|
| User sees | Checkbox scales down (0.9) → Checkmark draws → Scales up (1.0) |
| System responds | Item opacity reduces to 50%, strikethrough appears |
| Next | Item moves to "Kupione" section |

**Animation timeline:**
1. Scale down: 100ms
2. Draw checkmark: 200ms
3. Slide down to "Kupione": 300ms
4. Total: ~600ms

#### Step 3: Item Relocated
| Aspect | Description |
|--------|-------------|
| User sees | Item moves to bottom "Kupione" section (collapsed by default) |
| System responds | Saves checked state, syncs to server |
| Next | List Detail (item in "Kupione") |

#### Step 4: Un-check (Optional)
| Aspect | Description |
|--------|-------------|
| User sees | Checked item in "Kupione" section |
| User does | Taps checkbox again to uncheck |
| System responds | Reverse animation, item moves back to main list |
| Next | List Detail (item unchecked) |

---

### Decision Points

| Condition | True Path | False Path |
|-----------|-----------|------------|
| Item unchecked? | Check it | Uncheck it |
| Network available? | Sync to server | Queue for later |

---

### Edge Cases

#### Network Error (Sync Failure)
- **When:** Item checked locally but sync fails
- **Display:** No immediate error (optimistic update)
- **Recovery:** Retry sync when connection restored, persist local state

#### Conflict (Another User Unchecked)
- **When:** User A checks, User B unchecks at same time
- **Display:** Last write wins (show toast "Lista zaktualizowana")
- **Recovery:** Refresh to see latest state

#### Rapid Taps (Double-check)
- **When:** User taps checkbox twice quickly
- **Action:** Debounce (ignore 2nd tap during animation)
- **Recovery:** N/A (prevents glitchy animation)

---

### Success State
- **User sees:** Item checked, moved to "Kupione" section
- **System state:** Item status = checked, timestamp saved, visible to all members
- **Next options:** Check more items, add items, clear purchased

---

### Metrics

| Event | Trigger | Parameters |
|-------|---------|------------|
| item_checked | Tap checkbox (check) | item_id, list_id, user_id |
| item_unchecked | Tap checkbox (uncheck) | item_id, list_id, user_id |

---

## 5. Invite Family Member

### Flow Info
| Field | Value |
|-------|-------|
| Feature | Household Management |
| Story | US-04 |
| User Goal | Zaprosić członka rodziny do gospodarstwa |
| Entry Point | Settings → "Zaproś członka" |

---

### Flow Diagram

```
                [SETTINGS SCREEN]
                        |
                        | tap "Zaproś członka"
                        v
                +---------------+
                |   INVITE      |
                |   MODAL       |
                +-------+-------+
                        |
                        | modal displays:
                        | - 6-digit code
                        | - QR code
                        |
                        | user taps "Kopiuj kod" or "Udostępnij"
                        v
        +---------------+---------------+
        |                               |
        | COPY CODE                     | SHARE
        v                               v
+---------------+             +---------------+
| CODE COPIED   |             | SHARE SHEET   |
| (clipboard)   |             | (WhatsApp,    |
|               |             |  SMS, etc.)   |
+-------+-------+             +-------+-------+
        |                               |
        | paste in WhatsApp/SMS         | select app
        v                               v
+---------------+             +---------------+
| INVITE SENT   |             | INVITE SENT   |
+---------------+             +---------------+
        |                               |
        | recipient receives code       |
        v                               |
+---------------+                       |
| RECIPIENT     | <---------------------+
| JOINS         |
| (see Flow #2) |
+---------------+
```

---

### Steps Detail

#### Step 1: Open Invite Modal
| Aspect | Description |
|--------|-------------|
| User sees | Settings screen |
| User does | Taps "Zaproś członka" row |
| System responds | Generates invite code (if not exists), opens modal |
| Next | Invite modal |

#### Step 2: View Invite Code
| Aspect | Description |
|--------|-------------|
| User sees | Modal with 6-digit code (e.g., "ABCDEF") and QR code |
| User does | Decides how to share: copy code or share |
| Next | Copy or Share |

**Code properties:**
- 6 characters: uppercase letters + numbers
- Valid for 7 days
- Single-use or reusable? (TBD - assume reusable for household)

#### Step 3a: Copy Code
| Aspect | Description |
|--------|-------------|
| User sees | "Kopiuj kod" button |
| User does | Taps button |
| System responds | Copies code to clipboard, shows toast "Kod skopiowany" |
| Next | User pastes in messaging app |

#### Step 3b: Share via Share Sheet
| Aspect | Description |
|--------|-------------|
| User sees | "Udostępnij" button |
| User does | Taps button |
| System responds | Opens native share sheet with pre-filled message |
| Next | User selects app (WhatsApp, SMS, Email, etc.) |

**Share message template:**
```
Dołącz do naszego gospodarstwa w HomeOS!
Kod: ABCDEF
Lub zeskanuj QR: [link do QR]
```

#### Step 4: Close Modal
| Aspect | Description |
|--------|-------------|
| User sees | Invite modal (code shared) |
| User does | Taps X to close or taps outside |
| System responds | Modal closes, returns to Settings |
| Next | Settings screen |

---

### Decision Points

| Condition | True Path | False Path |
|-----------|-----------|------------|
| Code exists? | Show existing code | Generate new code |
| Code expired? | Generate new code | Show existing code |

---

### Edge Cases

#### Code Already Exists
- **When:** Admin previously generated code
- **Action:** Show existing code (if not expired)
- **Recovery:** Option to "Wygeneruj nowy kod" (invalidates old)

#### Code Expired (>7 days)
- **When:** Open invite modal with old code
- **Action:** Auto-generate new code
- **Recovery:** Display new code

#### Share Sheet Cancelled
- **When:** User opens share sheet but cancels
- **Action:** Returns to modal (no action taken)
- **Recovery:** Can retry share

#### Recipient Can't Scan QR
- **When:** Camera doesn't work
- **Action:** Manual code entry as fallback
- **Recovery:** Recipient types 6-digit code

---

### Success State
- **User sees:** Invite sent (via WhatsApp/SMS/Email)
- **System state:** Invite code active, waiting for recipient to join
- **Next options:** Close modal, wait for recipient, invite more members

---

### Metrics

| Event | Trigger | Parameters |
|-------|---------|------------|
| invite_modal_opened | Tap "Zaproś członka" | user_id, household_id |
| invite_code_copied | Tap "Kopiuj kod" | code |
| invite_shared | Tap "Udostępnij" | share_method |
| invite_accepted | Recipient joins | code, new_member_id |

---

## 6. Create New Shopping List

### Flow Info
| Field | Value |
|-------|-------|
| Feature | Shopping List Management |
| Story | US-08 |
| User Goal | Utworzyć nową listę zakupów |
| Entry Point | Shopping Lists screen, FAB "+" |

---

### Flow Diagram

```
            [SHOPPING LISTS SCREEN]
                        |
                        | tap FAB "+"
                        v
                +---------------+
                |   CREATE LIST |
                |   MODAL       |
                +-------+-------+
                        |
                        | input autofocus
                        | user types list name
                        | (e.g., "Biedronka sobota")
                        |
                        | tap "Utwórz"
                        v
                +---------------+
                |   LOADING     |
                +-------+-------+
                        |
                        | SUCCESS
                        v
                +---------------+
                |   LIST DETAIL |
                |   (empty)     |
                +---------------+
```

---

### Steps Detail

#### Step 1: Open Modal
| Aspect | Description |
|--------|-------------|
| User sees | Shopping Lists screen with FAB |
| User does | Taps FAB "+" |
| System responds | Modal opens, input autofocuses |
| Next | Create List modal |

#### Step 2: Enter Name
| Aspect | Description |
|--------|-------------|
| User sees | Modal with single input field "Nazwa listy" |
| User does | Types list name (e.g., "Biedronka sobota") |
| System responds | Shows hint: "np. 'Biedronka sobota'" |
| Next | User submits |

#### Step 3: Submit
| Aspect | Description |
|--------|-------------|
| User sees | Filled input |
| User does | Taps "Utwórz" button or presses Enter |
| System responds | Validates (name required), creates list |
| Next | Loading → List Detail |

#### Step 4: Navigate to List
| Aspect | Description |
|--------|-------------|
| User sees | Modal closes, navigates to List Detail screen (empty state) |
| System responds | List created, visible to all household members |
| Next | List Detail (empty, ready to add items) |

---

### Decision Points

| Condition | True Path | False Path |
|-----------|-----------|------------|
| Name filled? | Create list | Show error "Nazwa wymagana" |
| Network available? | Sync to server | Queue for later |

---

### Edge Cases

#### Empty Name
- **When:** Tap "Utwórz" without name
- **Display:** Red border + "Nazwa listy jest wymagana"
- **Recovery:** Enter name, submit again

#### User Cancels
- **When:** Tap "Anuluj" or outside modal
- **Action:** Modal closes, no list created
- **Destination:** Back to Shopping Lists

#### Duplicate Name (Optional validation)
- **When:** List with same name exists
- **Display:** Warning toast "Lista o tej nazwie już istnieje"
- **Recovery:** Add anyway or rename

---

### Success State
- **User sees:** List Detail screen (empty state) for new list
- **System state:** List created in database, visible to household
- **Next options:** Add items via FAB, back to lists

---

## 7. Edit Shopping Item

### Flow Info
| Field | Value |
|-------|-------|
| Feature | Shopping List Item Management |
| Story | US-09 |
| User Goal | Edytować istniejący produkt |
| Entry Point | Shopping List Detail, tap item row |

---

### Flow Diagram

```
        [SHOPPING LIST DETAIL SCREEN]
                    |
                    | tap item row
                    v
            +---------------+
            |   EDIT ITEM   |
            |   MODAL       |
            +-------+-------+
                    |
                    | pre-filled with existing data
                    | user modifies fields
                    |
                    | tap "Zapisz"
                    v
            +---------------+
            |   OPTIMISTIC  |
            |   UPDATE      |
            +-------+-------+
                    |
                    | modal closes, item updated in list
                    v
            +---------------+
            |   LIST DETAIL |
            | (item edited) |
            +---------------+
```

---

### Steps Detail

#### Step 1: Open Edit Modal
| Aspect | Description |
|--------|-------------|
| User sees | List Detail with items |
| User does | Taps item row (not checkbox) |
| System responds | Opens Edit Item modal, pre-fills fields |
| Next | Edit Item modal |

#### Step 2: Modify Fields
| Aspect | Description |
|--------|-------------|
| User sees | Modal with pre-filled data (name, category, quantity, assigned) |
| User does | Changes name, category, or quantity |
| System responds | Updates fields as user types |
| Next | User submits |

#### Step 3: Submit
| Aspect | Description |
|--------|-------------|
| User sees | Modified fields |
| User does | Taps "Zapisz" |
| System responds | Validates, updates item |
| Next | Optimistic update |

#### Step 4: Update List
| Aspect | Description |
|--------|-------------|
| User sees | Modal closes, item updated in list |
| System responds | Syncs to server, visible to all members |
| Next | List Detail (item edited) |

---

### Edge Cases

#### Empty Name
- **When:** User clears name field
- **Display:** Error "Nazwa produktu jest wymagana"
- **Recovery:** Re-enter name

#### User Cancels
- **When:** Tap "Anuluj" or back
- **Action:** Modal closes, no changes saved
- **Destination:** List Detail (item unchanged)

---

## 8. Delete Item

### Flow Info
| Field | Value |
|-------|-------|
| Feature | Shopping List Item Management |
| Story | US-09 |
| User Goal | Usunąć produkt z listy |
| Entry Point | Shopping List Detail, swipe left or 3-dot menu |

---

### Flow Diagram

```
        [SHOPPING LIST DETAIL SCREEN]
                    |
                    | swipe left on item
                    v
            +---------------+
            |   DELETE      |
            |   BUTTON      |
            |   REVEALED    |
            +-------+-------+
                    |
                    | tap "Usuń"
                    v
            +---------------+
            | CONFIRMATION  |
            |   MODAL       |
            +-------+-------+
                    |
                    | tap "Usuń" (confirm)
                    v
            +---------------+
            |   DELETE      |
            |   ANIMATION   |
            +-------+-------+
                    |
                    | slide out + height collapse (250ms)
                    v
            +---------------+
            |   LIST DETAIL |
            | (item removed)|
            +---------------+
```

---

### Steps Detail

#### Step 1: Reveal Delete
| Aspect | Description |
|--------|-------------|
| User sees | List Detail with items |
| User does | Swipes left on item row |
| System responds | Red delete button slides in from right |
| Next | Delete button visible |

#### Step 2: Tap Delete
| Aspect | Description |
|--------|-------------|
| User sees | Delete button |
| User does | Taps "Usuń" button |
| System responds | Opens confirmation modal |
| Next | Confirmation modal |

#### Step 3: Confirm
| Aspect | Description |
|--------|-------------|
| User sees | Modal: "Usunąć [item name]?" with "Anuluj" and "Usuń" |
| User does | Taps "Usuń" (red button) |
| System responds | Deletes item, closes modal |
| Next | Delete animation |

#### Step 4: Animation
| Aspect | Description |
|--------|-------------|
| User sees | Item slides out left, row height collapses |
| System responds | Removes from UI, syncs to server |
| Next | List Detail (item gone) |

**Animation:**
1. Slide out left: 250ms
2. Height collapse: 150ms

---

### Edge Cases

#### User Cancels Swipe
- **When:** Swipe left but release before threshold
- **Action:** Delete button not shown, item stays in place
- **Recovery:** Swipe again to reveal

#### User Cancels Confirmation
- **When:** Tap "Anuluj" in confirmation modal
- **Action:** Modal closes, item not deleted
- **Destination:** List Detail (item intact)

#### Undo Delete (Post-MVP)
- **When:** Item deleted
- **Display:** Toast "Produkt usunięty" with "Cofnij" button
- **Recovery:** Tap "Cofnij" to restore (within 5s)

---

## 9. Switch Theme (Dark Mode)

### Flow Info
| Field | Value |
|-------|-------|
| Feature | Theme Settings |
| Story | US-17 |
| User Goal | Przełączyć między jasnym a ciemnym motywem |
| Entry Point | Top bar (moon/sun icon) or Settings |

---

### Flow Diagram

```
                [ANY SCREEN]
                      |
                      | tap theme toggle icon
                      v
              +---------------+
              |   THEME       |
              |   TRANSITION  |
              +-------+-------+
                      |
                      | smooth color transition (200ms)
                      v
              +---------------+
              |   THEME       |
              |   SWITCHED    |
              +---------------+
                      |
                      | preference saved
                      v
              [Persist for future sessions]
```

---

### Steps Detail

#### Step 1: Tap Toggle
| Aspect | Description |
|--------|-------------|
| User sees | Moon icon (if light mode) or sun icon (if dark mode) in top bar |
| User does | Taps icon |
| System responds | Initiates theme transition |
| Next | Transition animation |

#### Step 2: Transition
| Aspect | Description |
|--------|-------------|
| User sees | Colors smoothly transition (background, text, cards) |
| System responds | Applies dark/light color palette |
| Next | Theme switched |

**Animation:**
- Duration: 200ms
- Easing: ease-out
- All colors transition smoothly (no jarring flash)

#### Step 3: Save Preference
| Aspect | Description |
|--------|-------------|
| User sees | New theme applied |
| System responds | Saves preference to localStorage / user settings |
| Next | Theme persists across sessions |

---

### Edge Cases

#### System Preference Change
- **When:** User changes OS theme while app open
- **Action:** App auto-switches if "Auto" mode enabled
- **Recovery:** N/A (expected behavior)

#### Reduced Motion
- **When:** User has `prefers-reduced-motion` enabled
- **Action:** Instant switch (no transition animation)
- **Recovery:** N/A (accessibility feature)

---

### Success State
- **User sees:** App in new theme (dark or light)
- **System state:** Theme preference saved, applied to all screens
- **Next options:** Continue using app in preferred theme

---

## 10. Flow Interactions Summary

| Flow | Average Duration | Complexity | Critical Path? |
|------|------------------|------------|----------------|
| Register + Create Household | ~2-3 min | High | Yes (onboarding) |
| Join Household | ~30 sec | Medium | Yes (onboarding) |
| Add Shopping Item | ~10 sec | Low | Yes (core feature) |
| Check Off Item | ~1 sec | Low | Yes (core feature) |
| Invite Member | ~30 sec | Low | Yes (household growth) |
| Create List | ~10 sec | Low | Yes (core feature) |
| Edit Item | ~15 sec | Low | No |
| Delete Item | ~5 sec | Low | No |
| Switch Theme | ~1 sec | Low | No |

---

## 11. Analytics Events Summary

### Onboarding
- `registration_started`
- `registration_completed`
- `household_created`
- `household_joined`
- `onboarding_completed`
- `onboarding_abandoned`

### Shopping Lists
- `list_created`
- `list_deleted`
- `add_item_submitted`
- `item_checked`
- `item_unchecked`
- `item_edited`
- `item_deleted`

### Household
- `invite_modal_opened`
- `invite_code_copied`
- `invite_shared`
- `invite_accepted`

### Settings
- `theme_switched`
- `language_changed`

---

## 12. Handoff Notes

### For Frontend Developers:

1. **Optimistic Updates:** Implement for add/edit/checkoff actions (instant UI update, background sync)
2. **Animations:** Use specified durations (100-300ms) and easing (ease-out)
3. **Error Handling:** Graceful degradation for network errors (queue for retry)
4. **Accessibility:** Ensure all flows keyboard-navigable, screen-reader friendly
5. **Analytics:** Implement event tracking at key points in each flow

### For QA:

1. **Happy Paths:** Test each flow end-to-end
2. **Edge Cases:** Test all documented edge cases
3. **Network:** Test with slow/offline network
4. **Multi-device:** Test sync across devices (two users, same household)
5. **Accessibility:** Test with keyboard, screen reader, reduced motion

---

**Document Version:** 1.0
**Last Updated:** 2025-12-09
**Author:** Sally (UX Designer)
**Status:** Draft - Ready for Review

**Related Docs:**
- @docs/1-BASELINE/ux/WIREFRAMES.md
- @docs/1-BASELINE/ux/UX-SPECIFICATION.md
- @docs/1-BASELINE/PRD.md
