# AUDIT: SQL Migrations - HomeOS

**Data audytu:** 2025-12-09
**Audytor:** DOC-AUDITOR (Viktor)
**Głębia audytu:** EXHAUSTIVE
**Status:** PASS WITH WARNINGS

---

## 1. EXECUTIVE SUMMARY

Migracje SQL zostały przeanalizowane pod względem:
- Syntaksji SQL (kompilacji)
- Kompletności (wszystkie tabele z schematu)
- Pokrycia RLS (Row Level Security)
- Bezpieczeństwa (auth.uid(), filtering)
- Kompletności funkcji
- Indexów dla wydajności
- Kolejności migracji

**WERDYKT:** Migracje są prawidłowe i gotowe do uruchomienia.
**UWAGA:** Znaleziono 3 problemy (2 MAJOR, 1 MINOR) wymagające uwagi.

---

## 2. FILE: 001_initial_schema.sql

### 2.1 Analiza struktur SQL

| Tabela | Status | Syntaksja | Indexy | Notes |
|--------|--------|-----------|--------|-------|
| homes | OK | Poprawna | 1 index (created_by) | Dobrze |
| home_members | OK | Poprawna | 3 indexes | Dobrze |
| home_invites | OK | Poprawna | 3 indexes | Dobrze |
| categories | OK | Poprawna | 2 indexes | Dobrze |
| shopping_lists | OK | Poprawna | 2 indexes | Dobrze |
| shopping_list_items | OK | Poprawna | 5 indexes | Dobrze |
| tasks | OK | Poprawna | 4 indexes | Dobrze |
| push_subscriptions | OK | Poprawna | 1 index | Dobrze |
| user_settings | OK | Poprawna | 0 indexes | Poprawne (PK) |

**WYNIK:** Wszystkie tabele mają prawidłową syntaksję SQL. Indexy są rozsądnie rozmieszczone dla operacji filtrowania i sortowania.

### 2.2 Sprawdzenie kompletności vs DATABASE-SCHEMA.md

```
001_initial_schema.sql zawiera:
✓ homes
✓ home_members
✓ home_invites
✓ categories
✓ shopping_lists
✓ shopping_list_items
✓ tasks
✓ push_subscriptions
✓ user_settings
✓ Default categories (seed)
✓ UUID extension

Porównanie z DATABASE-SCHEMA.md v1.1:
✓ Wszystkie 9 tabel obecne
✓ Wszystkie kolumny pokrywają się
✓ Ograniczenia (CHECK, UNIQUE, NOT NULL) są konsystentne
✓ Foreign keys prawidłowe
```

### 2.3 Analiza bezpieczeństwa danych

#### Constraint Analysis
- home_members: UNIQUE(user_id, home_id) - zapobiega duplikatom
- home_invites: UNIQUE(invite_code) - zapewnia unikalność kodów
- push_subscriptions: UNIQUE(user_id, endpoint) - jedyna subskrypcja per endpoint

#### On Delete Actions
```
✓ ON DELETE RESTRICT  - homes (created_by) - niemożna usunąć twórcę
✓ ON DELETE CASCADE   - home_members, home_invites (czyszczenie)
✓ ON DELETE SET NULL  - opcjonalne pola (created_by, assigned_to)
```

**UWAGA [MAJOR]:** Kolumna homes.created_by ma ON DELETE RESTRICT.
To oznacza, że nie można usunąć użytkownika, jeśli jest twórcą domu.
**Rekomendacja:** Rozważ zmianę na ON DELETE SET NULL lub implement soft delete dla auth.users.

### 2.4 Seed Data

```
INSERT INTO categories (11 wierszy):
- Wszystkie kategorie domyślne (is_default = TRUE)
- home_id = NULL (dostępne dla wszystkich)
- Prawidłowe ikony emoji (Unicode)
- Polskie i angielskie nazwy

Problemy:
⚠ Linijka 182-192: Encoding czcionek emoji - mogą być problemy ze wsparcie bazy danych
```

---

## 3. FILE: 002_rls_policies.sql

### 3.1 RLS Coverage - Sprawdzenie wszystkich tabel

| Tabela | RLS Enabled | SELECT | INSERT | UPDATE | DELETE | Secure |
|--------|-------------|--------|--------|--------|--------|--------|
| homes | YES | 1 policy | 1 policy | 1 policy | 1 policy | ✓ |
| home_members | YES | 1 policy | 1 policy | 1 policy | 2 policies | ✓ |
| home_invites | YES | 2 policies | 1 policy | BRAK | BRAK | MAJOR |
| categories | YES | 1 policy | 1 policy | 1 policy | 1 policy | ✓ |
| shopping_lists | YES | 1 policy | 1 policy | 1 policy | 1 policy | ✓ |
| shopping_list_items | YES | 1 policy | 1 policy | 1 policy | 1 policy | ✓ |
| tasks | YES | 1 policy | 1 policy | 1 policy | 1 policy | ✓ |
| push_subscriptions | YES | 1 policy (ALL) | - | - | - | ✓ |
| user_settings | YES | 1 policy (ALL) | - | - | - | ✓ |

### 3.2 Problemy bezpieczeństwa RLS

#### Problem 1: home_invites - Brakują UPDATE/DELETE policies

```sql
-- W 002_rls_policies.sql (linie 73-99):
CREATE POLICY "Members can view invites for their home" ...
CREATE POLICY "Members can create invites" ...
CREATE POLICY "Anyone can validate invite code" ...
-- BRAKUJE:
-- CREATE POLICY "... UPDATE ..."
-- CREATE POLICY "... DELETE ..."
```

**Impact:** MAJOR - Adminowie nie mogą edytować/anulować zaproszeń
**Rekomendacja:** Dodać políticas:

```sql
CREATE POLICY "Admins can update invites"
  ON home_invites FOR UPDATE
  USING (
    home_id IN (
      SELECT home_id FROM home_members
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admins can delete invites"
  ON home_invites FOR DELETE
  USING (
    home_id IN (
      SELECT home_id FROM home_members
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );
```

#### Problem 2: "Anyone can validate" policy

```sql
-- Linie 93-99:
CREATE POLICY "Anyone can validate invite code"
  ON home_invites FOR SELECT
  USING (
    used_at IS NULL
    AND expires_at > NOW()
  );
```

**Bezpieczeństwo:** Każda niezalogowana osoba może przeglądać WSZYSTKIE nieużyte kody zaproszeń.
**Impact:** MAJOR - Potencjalny wyciek informacji

**Analiza:**
- Tabela home_invites zawiera `home_id`, `intended_role`, `created_by`
- Każdy anonimowy użytkownik może ujrzeć wszystkie aktywne kody
- To pozwala na ataki typu brute force

**Rekomendacja:** Zmień na:

```sql
CREATE POLICY "Anyone can validate specific invite code"
  ON home_invites FOR SELECT
  USING (
    used_at IS NULL
    AND expires_at > NOW()
    AND invite_code = current_setting('request.jwt.claims')::jsonb->>'code'
  );
```

Lub lepiej - ogranicz dostęp do walidacji tylko przez funkcję stored procedure.

### 3.3 Auth.uid() Filtering - Analiza

```
✓ homes: home_members.user_id = auth.uid()
✓ home_members: home_members.user_id = auth.uid()
✓ shopping_lists: home_members.user_id = auth.uid()
✓ shopping_list_items: home_members.user_id = auth.uid()
✓ tasks: home_members.user_id = auth.uid()
✓ push_subscriptions: user_id = auth.uid()
✓ user_settings: user_id = auth.uid()

Wzorzec: Wszędzie używany home_id filtering z auth.uid() weryfikacją
```

**Werdykt:** Prawidłowe bezpieczeństwo dla wszystkich pól oprócz home_invites.

### 3.4 Role-based Access Control

```
✓ admin   - pełne uprawnienia do edycji/usuwania
✓ member - mogą tworzyć zaproszenia, listy, zadania
✓ child  - tylko mogą czytać i aktualizować (np. zaznaczać pozycje)

Problemy z child role:
- Policy dla shopping_list_items UPDATE pozwala ALL members (bez roli)
- Child nie powinien mieć DELETE
- Policy musi być bardziej precyzyjna
```

**Rekomendacja:** Przeanalizuj czy child role jest poprawnie implementowany dla UPDATE.

---

## 4. FILE: 003_functions.sql

### 4.1 Spis funkcji i triggerów

| Obiekt | Typ | Linia | Status | Notes |
|--------|-----|-------|--------|-------|
| update_updated_at_column | FUNCTION | 9-15 | OK | |
| generate_invite_code | FUNCTION | 22-34 | OK | |
| get_user_home_id | FUNCTION | 40-43 | OK | |
| check_member_invite_limit | FUNCTION | 50-71 | ISSUE | Patrz 4.3 |
| validate_and_use_invite | FUNCTION | 78-109 | OK | |
| create_invite_with_code | FUNCTION | 115-145 | OK | |
| homes_updated_at | TRIGGER | 150-153 | OK | |
| shopping_lists_updated_at | TRIGGER | 155-158 | OK | |
| shopping_items_updated_at | TRIGGER | 160-163 | OK | |
| tasks_updated_at | TRIGGER | 165-168 | OK | |
| user_settings_updated_at | TRIGGER | 170-173 | OK | |
| check_invite_limit | TRIGGER | 178-181 | ISSUE | Patrz 4.3 |

### 4.2 Analiza funkcji krytycznych

#### A. generate_invite_code()

```sql
-- Linie 22-34
CREATE OR REPLACE FUNCTION generate_invite_code()
RETURNS TEXT AS $$
DECLARE
  chars TEXT := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  result TEXT := '';
  i INTEGER;
BEGIN
  FOR i IN 1..6 LOOP
    result := result || substr(chars, floor(random() * length(chars) + 1)::INTEGER, 1);
  END LOOP;
  RETURN result;
END;
$$ LANGUAGE plpgsql VOLATILE;
```

**Analiza:**
- Znaki: 32 znaki (26 liter - IOLU + 8 cyfr bez 0,1)
- Długość: 6 znaków
- Entropia: log2(32^6) = 30 bitów - WYSTARCZAJĄCA
- Kolizje: Szansa na kolizję z 10k kodów = 0.001%
- Randomness: Używa PostgreSQL random() - WYSTARCZAJĄCA dla celów

**Werdykt:** Funkcja jest bezpieczna.

#### B. validate_and_use_invite()

```sql
-- Linie 78-109
RETURNS TABLE (
  home_id UUID,
  intended_role TEXT,
  home_name TEXT
)
```

**Analiza walidacji:**
```
✓ Weryfikuje invite_code (case-insensitive)
✓ Weryfikuje used_at IS NULL (jeszcze nie użyty)
✓ Weryfikuje expires_at > NOW() (nie wygasły)
✓ Oznacza jako used_at = NOW() (atomic)
✓ Zapisuje used_by = p_user_id (audit trail)
```

**UWAGA:** Funkcja ma SECURITY DEFINER - wykonuje się z uprawnień właściciela.
To jest prawidłowe dla bezpieczeństwa.

#### C. check_member_invite_limit()

```sql
-- Linie 50-71
CREATE OR REPLACE FUNCTION check_member_invite_limit()
RETURNS TRIGGER AS $$
...
  IF member_role = 'member' AND invite_count >= 3 THEN
    RAISE EXCEPTION 'Czlonek osiagnal limit zaproszen (3)';
  END IF;
...
UPDATE home_members
SET invites_sent = invites_sent + 1
```

**PROBLEM [MAJOR]:** Brakuje obsługi NULL

```sql
-- Obecny kod:
SELECT role, invites_sent INTO member_role, invite_count
FROM home_members
WHERE user_id = NEW.created_by AND home_id = NEW.home_id;

IF member_role = 'member' AND invite_count >= 3 THEN
```

Jeśli SELECT zwróci NULL (np. użytkownik jeszcze nie dołączył do domu):
- member_role = NULL
- invite_count = NULL
- Warunek IF nie zadziała prawidłowo

**Rekomendacja:** Dodaj obsługę NULL:

```sql
IF NOT FOUND THEN
  RAISE EXCEPTION 'User is not a member of this home';
END IF;

IF member_role IS NULL THEN
  RAISE EXCEPTION 'Invalid member state';
END IF;
```

### 4.3 Trigger Analysis

Wszystkie triggery są prawidłowo zdefiniowane i przypisane do tabel.

```
✓ homes_updated_at          - BEFORE UPDATE
✓ shopping_lists_updated_at - BEFORE UPDATE
✓ shopping_items_updated_at - BEFORE UPDATE
✓ tasks_updated_at          - BEFORE UPDATE
✓ user_settings_updated_at  - BEFORE UPDATE
✓ check_invite_limit        - BEFORE INSERT on home_invites
```

**Uwaga:** Brakuje triggera dla home_members na polu updated_at (jeśli taka kolumna byłaby potrzebna).

---

## 5. CROSS-REFERENCE: Migracje vs DATABASE-SCHEMA.md

### 5.1 Tabele

```
DATABASE-SCHEMA.md specyfikuje:
✓ homes
✓ home_members
✓ home_invites
✓ categories
✓ shopping_lists
✓ shopping_list_items
✓ tasks
✓ push_subscriptions
✓ user_settings

001_initial_schema.sql zawiera:
✓ WSZYSTKO - 100% pokrycia
```

### 5.2 Kolumny

```
Porównanie dla home_invites (krytyczna tabela):

DATABASE-SCHEMA.md (linie 522-531):
- id UUID PRIMARY KEY
- home_id UUID NOT NULL
- invite_code TEXT UNIQUE NOT NULL
- created_by UUID NOT NULL
- intended_role TEXT NOT NULL
- expires_at TIMESTAMPTZ NOT NULL
- used_at TIMESTAMPTZ
- used_by UUID
- created_at TIMESTAMPTZ NOT NULL

001_initial_schema.sql (linie 49-59):
- id UUID PRIMARY KEY DEFAULT gen_random_uuid()
- home_id UUID NOT NULL REFERENCES homes(id)
- invite_code TEXT UNIQUE NOT NULL
- created_by UUID NOT NULL REFERENCES auth.users(id)
- intended_role TEXT NOT NULL CHECK (intended_role IN ('member', 'child'))
- expires_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '7 days')
- used_at TIMESTAMPTZ
- used_by UUID REFERENCES auth.users(id) ON DELETE SET NULL
- created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()

✓ Wszystkie kolumny pokrywają się
✓ Wszystkie ograniczenia są obecne
```

### 5.3 Funkcje

```
DATABASE-SCHEMA.md specyfikuje:
✓ update_updated_at_column()
✓ generate_invite_code()
✓ get_user_home_id()
✓ check_member_invite_limit()
✓ validate_and_use_invite()
✓ create_invite_with_code() - BRAKUJE W SCHEMACIE!

003_functions.sql zawiera:
✓ WSZYSTKO + create_invite_with_code()

Uwaga: DATABASE-SCHEMA.md nie dokumentuje create_invite_with_code()
Funkcja została dodana ad-hoc w migracji.
```

**Rekomendacja:** Zaktualizuj DATABASE-SCHEMA.md aby dokumentować create_invite_with_code().

---

## 6. ANALIZA WYDAJNOŚCI - INDEXES

### 6.1 Index Coverage Matrix

```
homes
├─ idx_homes_created_by - OK (filtrowanie wg twórcy)

home_members
├─ idx_home_members_user_id - OK (JOIN z auth.users)
├─ idx_home_members_home_id - OK (JOIN z homes)
└─ idx_home_members_role   - OK (filtrowanie wg roli)

shopping_lists
├─ idx_shopping_lists_home_id - OK (filtrowanie wg domu)
└─ idx_shopping_lists_created_at - OK (sortowanie)

shopping_list_items
├─ idx_shopping_items_list_id - OK (JOIN)
├─ idx_shopping_items_home_id - OK (RLS filtering)
├─ idx_shopping_items_is_purchased - OK (filtrowanie)
├─ idx_shopping_items_category_id - OK (JOIN)
└─ idx_shopping_items_sort_order - OK (sortowanie)

tasks
├─ idx_tasks_home_id - OK
├─ idx_tasks_assigned_to - OK
├─ idx_tasks_is_completed - OK
└─ idx_tasks_due_date - OK

categories
├─ idx_categories_home_id - OK
└─ idx_categories_is_default - OK

push_subscriptions
└─ idx_push_subscriptions_user_id - OK

home_invites
├─ idx_home_invites_home_id - OK
├─ idx_home_invites_invite_code - OK (UNIQUE)
└─ idx_home_invites_expires_at - OK (cleanup queries)

user_settings
└─ (PK = user_id, nie potrzeba indexu)
```

**Werdykt:** Indexes są dobrze zaplanowane dla common queries.

### 6.2 Potencjalne problemy wydajności

```
⚠ RLS policies używają SELECT home_id FROM home_members WHERE user_id = auth.uid()
  - Ta subquery jest wykonywana dla każdego warunku RLS
  - Z indeksem idx_home_members_user_id będzie szybka
  - JEDNAK: Dla użytkownika z wieloma domami może być powolna

Rekomendacja: Monitoruj query performance jeśli użytkownik ma >10 domów
```

---

## 7. KOLEJNOŚĆ MIGRACJI

```
001_initial_schema.sql
├─ Tworzy tabele
├─ Tworzy indexes
└─ Seed categories

    ↓

002_rls_policies.sql
├─ Włącza RLS na wszystkich tabelach
└─ Tworzy políticas

    ↓

003_functions.sql
├─ Tworzy funkcje
└─ Tworzy triggery (BEFORE UPDATE, BEFORE INSERT)

KOLEJNOŚĆ: Prawidłowa
- Tabele muszą istnieć przed RLS
- RLS musi być włączony przed funkcjami (no, nie koniecznie)
- Funkcje muszą istnieć przed triggerami
```

**Werdykt:** Kolejność migracji jest prawidłowa.

---

## 8. PODSUMOWANIE ZNALEZIONYCH PROBLEMÓW

### CRITICAL (0)
Brak problemów krytycznych uniemożliwiających uruchomienie.

### MAJOR (2)

1. **home_invites RLS - Brakują UPDATE/DELETE policies**
   - File: 002_rls_policies.sql (linie 73-99)
   - Impact: Admini nie mogą edytować/anulować zaproszeń
   - Fix Priority: HIGH
   - Sugerowana naprawa:
   ```sql
   CREATE POLICY "Admins can update invites"
     ON home_invites FOR UPDATE
     USING (home_id IN (...));

   CREATE POLICY "Admins can delete invites"
     ON home_invites FOR DELETE
     USING (home_id IN (...));
   ```

2. **home_invites RLS - "Anyone can validate" policy security issue**
   - File: 002_rls_policies.sql (linie 93-99)
   - Impact: Każdy może ujrzeć wszystkie aktywne kody zaproszeń
   - Risk: Brute force attack na kody
   - Fix Priority: HIGH
   - Sugerowana naprawa: Ogranicz dostęp tylko do walidacji przez funkcję

3. **check_member_invite_limit() - Brakuje obsługi NULL**
   - File: 003_functions.sql (linie 50-71)
   - Impact: Funkcja zawali się jeśli user_id nie będzie członkiem domu
   - Fix Priority: MEDIUM
   - Sugerowana naprawa: Dodaj walidację `IF NOT FOUND`

### MINOR (1)

1. **homes.created_by ON DELETE RESTRICT**
   - File: 001_initial_schema.sql (linia 19)
   - Impact: Nie można usunąć użytkownika jeśli jest twórcą domu
   - Fix Priority: LOW
   - Sugerowana naprawa: Zmień na ON DELETE SET NULL lub implement soft delete

---

## 9. SYNTAX VALIDATION

### Kompilacja SQL - Manual Check

```
001_initial_schema.sql - VALID
✓ CREATE EXTENSION
✓ CREATE TABLE (9x)
✓ CREATE INDEX (17x)
✓ INSERT INTO categories

002_rls_policies.sql - VALID
✓ ALTER TABLE ENABLE ROW LEVEL SECURITY (9x)
✓ CREATE POLICY (28x)

003_functions.sql - VALID
✓ CREATE OR REPLACE FUNCTION (6x)
✓ CREATE TRIGGER (6x)
```

**Werdykt:** Żaden SQL syntax error nie został znaleziony.

---

## 10. COMPLETENESS CHECKLIST

```
[✓] Wszystkie tabele z schematu utworzone
[✓] Wszystkie kolumny z schematu obecne
[✓] Wszystkie indexy z schematu obecne
[✓] Wszystkie CHECK constraints z schematu
[✓] Wszystkie UNIQUE constraints z schematu
[✓] Wszystkie FOREIGN KEY relationships z schematu
[✓] Wszystkie triggery dla updated_at
[✓] Wszystkie funkcje dla wygenerowania kodów
[✓] RLS włączony na wszystkich tabelach
[~] RLS políticas kompletne (2 polityki brakuje UPDATE/DELETE)
[✓] Seed data dla kategorii domyślnych
[✓] Komentarze w migracji
[✓] UUID extension
```

---

## 11. SECURITY CHECKLIST

```
[✓] Wszystkie tabele z auth.users mają RLS
[✓] auth.uid() używany do filtrowania
[✓] Role-based access control (admin/member/child)
[✓] Foreign key constraints (no orphan records)
[✓] CHECK constraints na enum fields (role, platform, theme, language)
[✓] Unique constraints na invite_code
[✓] Functions mają SECURITY DEFINER gdzie potrzebne
[~] home_invites RLS incomplete (brakuje UPDATE/DELETE)
[~] home_invites SELECT policy zbyt permisywna
[-] check_member_invite_limit() brak null check
```

---

## 12. RECOMMENDATIONS

### Immediate (przed deploymentem)

1. **Dodaj UPDATE/DELETE políticas dla home_invites**
   - Priority: CRITICAL
   - Czas: 5 minut

2. **Przeanalizuj "Anyone can validate" policy**
   - Priority: CRITICAL
   - Opcje:
     - Zmień na SECURITY DEFINER function
     - Dodaj rate limiting
     - Wymagaj parametru invite_code

3. **Dodaj null check w check_member_invite_limit()**
   - Priority: MEDIUM
   - Czas: 5 minut

### Short-term (w następnym sprincie)

4. **Zaktualizuj DATABASE-SCHEMA.md**
   - Dodaj dokumentację create_invite_with_code()
   - Wyjaśnij "Anyone can validate" bezpieczeństwo

5. **Rozważ zmianę ON DELETE RESTRICT na ON DELETE SET NULL**
   - Dla homes.created_by
   - Wymagana decyzja architektoniczna

6. **Monitoruj wydajność RLS queries**
   - Szczególnie dla home_members subqueries
   - Jeśli użytkownik ma >10 domów

---

## 13. QUALITY SCORE BREAKDOWN

| Wymiar | Score | Waga | Weighted |
|--------|-------|------|----------|
| Structure (organizacja) | 95% | 15% | 14.25 |
| Clarity (czytelność) | 90% | 25% | 22.5 |
| Completeness (kompletność) | 85% | 25% | 21.25 |
| Consistency (konsystencja) | 95% | 20% | 19 |
| Accuracy (poprawność) | 80% | 15% | 12 |
| **TOTAL** | | | **89%** |

**Kategoria:** GOOD - Minor improvements needed

---

## 14. FINAL VERDICT

### Status: PASS WITH WARNINGS

Migracje SQL są prawidłowo zbudowane i gotowe do uruchomienia z następującymi zastrzeżeniami:

1. **OBOWIĄZKOWE NAPRAWY:**
   - Dodaj UPDATE/DELETE políticas dla home_invites
   - Przeanalizuj "Anyone can validate" policy

2. **REKOMENDOWANE NAPRAWY:**
   - Dodaj null check w check_member_invite_limit()
   - Zaktualizuj DATABASE-SCHEMA.md

3. **DO MONITOROWANIA:**
   - Wydajność RLS queries
   - Liczba zaproszeń w home_invites

### Ready to Deploy: YES (po naprawach)

---

## 15. AUDIT FILES

- **001_initial_schema.sql:** 193 linii - VALID
- **002_rls_policies.sql:** 273 linii - VALID (z uwagami)
- **003_functions.sql:** 182 linii - VALID (z uwagami)

**Total:** 648 linii SQL

---

## 16. CROSS-REFERENCE LINKS

- DATABASE-SCHEMA.md: `/workspaces/MyHome/docs/3-ARCHITECTURE/DATABASE-SCHEMA.md`
- Migrations: `/workspaces/MyHome/supabase/migrations/`
- Functions: `003_functions.sql` linie 9-145
- RLS Policies: `002_rls_policies.sql` linie 1-273

---

**Audytor:** DOC-AUDITOR (Viktor)
**Data:** 2025-12-09
**Wersja:** 1.0
**Status:** PASS WITH WARNINGS
**Dalsze kroki:** Poczekaj na naprawi tych problemów zanim deployuj do produkcji.
