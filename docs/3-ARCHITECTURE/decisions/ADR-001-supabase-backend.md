# ADR-001: Supabase jako Backend

## Status
ACCEPTED

## Data
2025-12-09

## Context

Projekt HomeOS wymaga backendu obslugujacego:
- Autentykacje (email + Google OAuth)
- Baze danych z Row Level Security dla multi-tenant
- Real-time sync (w przyslych fazach)
- Push notifications
- Szybki czas do wdrozenia (3 tygodnie MVP)

Budzet projektu jest ograniczony - side project z potencjalem komercjalizacji.

## Decision

Wybieramy **Supabase** jako glowny backend:
- PostgreSQL jako baza danych
- Supabase Auth dla autentykacji
- Supabase RLS dla security
- Supabase Realtime (Phase 2)
- Supabase Edge Functions (opcjonalnie)

## Alternatives Considered

| Alternatywa | Pros | Cons |
|-------------|------|------|
| **Firebase** | Dobry real-time, SDK | NoSQL (trudniejsze relacje), vendor lock-in, pricing |
| **Custom API (Node.js + Prisma)** | Pelna kontrola | Wiecej kodu, dluzszy development, hosting |
| **PlanetScale + Clerk** | Skalowalna baza, dobry auth | Dwa serwisy, wiecej integracji |
| **Supabase** | PostgreSQL, Auth, RLS, Free tier, realtime | Vendor lock-in (mniejszy niz Firebase) |

## Consequences

### Positive
- **Szybki start** - auth, database, RLS out of the box
- **Free tier** - wystarczajacy na MVP i wczesny wzrost
- **PostgreSQL** - pelny SQL, relacje, JSON support
- **RLS** - security na poziomie bazy danych
- **Realtime ready** - latwy upgrade w Phase 2
- **TypeScript SDK** - dobrze typed client

### Negative
- **Vendor lock-in** - migracja do innego Postgres jest mozliwa, ale auth/realtime trudniejsze
- **Limity free tier** - 500MB storage, 2GB bandwidth, 50K MAU
- **Cold starts** - Edge Functions maja cold start (ale nie uzywamy ich w MVP)

### Risks
- **Supabase outage** - mitygacja: graceful degradation, monitoring
- **Free tier przekroczony** - mitygacja: monitoring, upgrade plan ready (~$25/msc Pro)

## References
- [Supabase Docs](https://supabase.com/docs)
- [Supabase Pricing](https://supabase.com/pricing)
- [technical-research.md](/docs/1-BASELINE/research/technical-research.md)
