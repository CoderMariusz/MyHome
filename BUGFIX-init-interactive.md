# Bug Fix: init-interactive.sh - Non-Interactive Mode Support

## Problem
Skrypt `init-interactive.sh` nie działał w Git Bash na Windows, ponieważ:
1. Git Bash (MINGW64) nie wykrywa stdin jako terminala
2. Brak obsługi argumentów CLI jako alternatywy
3. Niejasny błąd gdy stdin nie jest dostępny

## Rozwiązanie

### 1. Dodano obsługę argumentów CLI
```bash
# Nowe użycie CLI:
bash scripts/init-interactive.sh --mode new --name my-project
bash scripts/init-interactive.sh --mode existing --path /path/to/project
bash scripts/init-interactive.sh --mode audit --path .
```

### 2. Dodano walidację stdin
- Sprawdzanie czy stdin jest terminalem (`test -t 0`)
- Warning gdy stdin nie jest wykryty jako terminal
- Fallback do CLI mode z czytelnym komunikatem

### 3. Dodano funkcje CLI dla każdego trybu
- `new_project_flow_cli()` - tworzenie nowego projektu
- `existing_project_flow_cli()` - migracja istniejącego projektu
- `audit_only_flow_cli()` - audit bez zmian

### 4. Poprawiono obsługę błędów w `get_choice()`
```bash
# Teraz `read` ma fallback:
if read -r choice 2>/dev/null; then
    echo "$choice"
else
    print_error "Cannot read input in non-interactive mode"
    print_info "Use CLI arguments instead: --mode {new|existing|audit}"
    exit 1
fi
```

### 5. Dodano help message
```bash
bash scripts/init-interactive.sh --help
```

## Zmiany w kodzie

### Nowe argumenty CLI
- `--mode {new|existing|audit}` - wybór trybu operacji
- `--name PROJECT_NAME` - nazwa projektu (dla mode=new)
- `--path PROJECT_PATH` - ścieżka projektu (dla mode=existing/audit)
- `--help` - pomoc

### Nowa struktura main()
```bash
main() {
    # CLI MODE
    if [ -n "$CLI_MODE" ]; then
        case "$CLI_MODE" in
            new) new_project_flow_cli "$CLI_NAME" ;;
            existing) existing_project_flow_cli "$CLI_PATH" ;;
            audit) audit_only_flow_cli "$CLI_PATH" ;;
        esac
        exit 0
    fi

    # INTERACTIVE MODE
    # [pozostała logika interaktywna]
}
```

## Testowanie

### Test 1: Help message
```bash
bash scripts/init-interactive.sh --help
# ✅ Działa - pokazuje help
```

### Test 2: CLI mode - audit
```bash
bash scripts/init-interactive.sh --mode audit --path .
# ✅ Działa - wykonuje audit
```

### Test 3: CLI mode - new project
```bash
bash scripts/init-interactive.sh --mode new --name test-project
# ⏳ Do przetestowania (wymaga valid init-project.sh)
```

## Acceptance Criteria

- [x] Skrypt działa w interactive mode (z warning gdy stdin nie jest terminal)
- [x] Skrypt obsługuje argumenty CLI
- [x] Błąd jest czytelny gdy brak stdin
- [x] Dodane komentarze wyjaśniające zmiany
- [ ] Przeprowadzone testy end-to-end (wymaga środowiska testowego)

## Backward Compatibility

✅ **Pełna kompatybilność wsteczna**
- Stary sposób wywołania (bez argumentów) nadal działa
- Interactive mode pozostaje domyślnym
- Nowe CLI mode jest opcjonalne

## Dodatkowe usprawnienia

1. **Lepsza komunikacja błędów**
   - Precyzyjne komunikaty co poszło nie tak
   - Sugestie jak używać CLI mode

2. **Dokumentacja w headerze**
   - Przykłady użycia
   - Opis obu trybów (interactive i CLI)

3. **Walidacja wejścia**
   - Sprawdzanie poprawności argumentów
   - Walidacja ścieżek i nazw projektów

## Status

✅ **GOTOWE DO REVIEW I TESTÓW**

Kod jest naprawiony i gotowy do:
1. Code review
2. Testy end-to-end w środowisku docelowym
3. Testy na różnych platformach (Windows Git Bash, Linux, macOS)

## Files Changed

- `scripts/init-interactive.sh` - główny plik naprawiony

## Version

- Before: 1.0
- After: 1.1 (Fixed stdin handling for non-interactive environments)

---
**Created:** 2025-12-06
**Author:** SENIOR-DEV (Claude Sonnet 4.5)
