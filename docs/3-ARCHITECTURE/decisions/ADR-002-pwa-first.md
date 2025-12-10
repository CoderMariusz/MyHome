# ADR-002: PWA First Strategy

## Status
ACCEPTED

## Data
2025-12-09

## Context

HomeOS jest aplikacja do zarzadzania domem, ktora bedzie uzywana glownie na telefonach.
Mamy 3 tygodnie na MVP i ograniczony budzet.

Opcje:
1. Tylko web (responsive)
2. PWA (Progressive Web App)
3. React Native (hybrid)
4. Native apps (iOS + Android)

## Decision

Wybieramy **PWA** jako glowna platforme dla MVP:
- Next.js 15 z App Router
- Mobile-first responsive design
- Service Worker dla basic caching
- Web Push API dla notifications
- Add to Home Screen

Native apps (React Native) rozwazymy w Phase 2+ po walidacji produktu.

## Alternatives Considered

| Alternatywa | Pros | Cons |
|-------------|------|------|
| **Tylko web** | Najszybszy development | Brak instalacji, brak push |
| **PWA** | Instalacja, push, offline-ready | Ograniczenia iOS Safari |
| **React Native** | Native feel, pelne API | Dluzszy development, dwa codebases |
| **Native** | Najlepsza wydajnosc | 3x codebase, najdluzszy dev |

## Consequences

### Positive
- **Najszybszy time-to-market** - 1 codebase
- **Web + mobile z 1 deploya** - Vercel
- **Push notifications** - Web Push API dziala na Android, Chrome, Firefox
- **Add to Home Screen** - UX podobny do native
- **SEO friendly** - landing page indeksowalna
- **Latwa iteracja** - deploy na Vercel = instant update

### Negative
- **iOS Safari ograniczenia**:
  - Push notifications wymagaja iOS 16.4+ i "Add to Home Screen"
  - Brak background sync
  - Service Worker ograniczenia
- **Brak dostepu do native APIs** (kontakty, kalendarz, etc.) - ale nie potrzebujemy w MVP
- **Brak App Store presence** - trudniejsza dystrybucja

### Risks
- **iOS users nie instaluja PWA** - mitygacja: clear install prompts, onboarding
- **Push notifications zawodne na iOS** - mitygacja: test early, backup email

## Implementation Notes

### PWA Manifest
```json
{
  "name": "HomeOS",
  "short_name": "HomeOS",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#000000"
}
```

### Service Worker (basic)
- Cache static assets
- Offline fallback page
- No offline data sync in MVP

### Web Push
- VAPID keys
- Opt-in pattern
- web-push library dla server-side

## Migration Path

Jesli walidacja wykazze potrzebe native:
1. **Phase 2**: React Native z Expo
2. **Shared**: API (Supabase), business logic (TypeScript)
3. **Separate**: UI components, navigation

## References
- [web.dev PWA](https://web.dev/progressive-web-apps/)
- [iOS PWA Support](https://webkit.org/blog/12945/meet-web-push/)
- [Next.js PWA](https://nextjs.org/docs/app/building-your-application/configuring/progressive-web-apps)
