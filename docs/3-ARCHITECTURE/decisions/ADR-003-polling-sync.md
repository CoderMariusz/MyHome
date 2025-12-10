# ADR-003: 10-Minute Polling dla Synchronizacji (MVP)

## Status
ACCEPTED (dla MVP)

## Data
2025-12-09

## Context

HomeOS wymaga synchronizacji danych miedzy czlonkami gospodarstwa.
Np. Mama dodaje "mleko" do listy, Tata powinien to zobaczyc.

Opcje synchronizacji:
1. Manual refresh only
2. Polling (co X minut)
3. Real-time (WebSocket / Supabase Realtime)
4. Hybrid (polling + manual + realtime dla critical)

## Decision

Dla MVP wybieramy **10-minute polling** z manual refresh:
- Auto-refresh co 10 minut
- Przycisk "Odswiez teraz"
- Wskaznik "Ostatnia sync: X min temu"

Real-time (Supabase Realtime) wdrozmy w Phase 2.

## Alternatives Considered

| Alternatywa | Pros | Cons |
|-------------|------|------|
| **Manual only** | Najprostsze | Slaby UX, latwo przegapic zmiany |
| **Polling 10 min** | Proste, przewidywalne | Opoznienie do 10 min |
| **Polling 1 min** | Szybsze updates | Wiecej requestow, battery drain |
| **Real-time** | Instant updates | Zlozonosc, debugging trudniejsze |
| **Hybrid** | Best of both | Jeszcze bardziej zlozone |

## Consequences

### Positive
- **Prostota implementacji** - zwykly `setInterval` + fetch
- **Przewidywalnosc** - latwe do testowania i debugowania
- **Niskie zuzycie zasobow** - 6 requestow/godzine vs continuous connection
- **Graceful degradation** - przy braku sieci nie ma broken socket
- **Latwy upgrade path** - dodanie Realtime to additive change

### Negative
- **Opoznienie do 10 minut** - Mama moze nie zobaczyc od razu
- **UX nie "instant"** - konkurenci z real-time moga wygladac lepiej
- **Manual refresh potrzebny** - users musza wiedziec o przycisku

### Risks
- **Users niezadowoleni z opoznienia** - mitygacja: user research, moze 5 min?
- **Race conditions** - mitygacja: optimistic UI + server truth

## Implementation

```typescript
// hooks/useAutoRefresh.ts
export function useAutoRefresh<T>(
  queryFn: () => Promise<T>,
  intervalMs: number = 10 * 60 * 1000
) {
  const [data, setData] = useState<T | null>(null);
  const [lastRefresh, setLastRefresh] = useState<Date>(new Date());
  const [isRefreshing, setIsRefreshing] = useState(false);

  const refresh = useCallback(async () => {
    setIsRefreshing(true);
    try {
      const result = await queryFn();
      setData(result);
      setLastRefresh(new Date());
    } finally {
      setIsRefreshing(false);
    }
  }, [queryFn]);

  useEffect(() => {
    refresh(); // Initial fetch

    const interval = setInterval(refresh, intervalMs);
    return () => clearInterval(interval);
  }, [refresh, intervalMs]);

  return { data, lastRefresh, isRefreshing, refresh };
}
```

### UI Indicators
```
+------------------------------------------+
| Lista zakupow          [Odswiez] [...]   |
| Ostatnia sync: 3 min temu                |
+------------------------------------------+
```

## Upgrade Path (Phase 2)

```typescript
// Dodanie Supabase Realtime
useEffect(() => {
  const channel = supabase
    .channel('shopping-changes')
    .on('postgres_changes', {
      event: '*',
      schema: 'public',
      table: 'shopping_list_items',
      filter: `home_id=eq.${homeId}`
    }, handleChange)
    .subscribe();

  return () => channel.unsubscribe();
}, [homeId]);
```

## References
- [Supabase Realtime](https://supabase.com/docs/guides/realtime)
- [technical-research.md](/docs/1-BASELINE/research/technical-research.md)
