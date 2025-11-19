# Story 1.1: Project Initialization

Status: drafted

## Story

As a **developer**,
I want **to initialize the Next.js 15 project with TypeScript and Tailwind**,
so that **I have a properly configured development environment**.

## Acceptance Criteria

1. **AC1: Project Structure Created**
   - Given a new project directory
   - When the project is initialized
   - Then the following should be configured:
     - Next.js 15 with App Router
     - TypeScript 5.x with strict mode
     - Tailwind CSS 3.x with custom config
     - ESLint + Prettier configuration
     - Git repository with .gitignore

2. **AC2: Folder Structure Matches Architecture**
   - Given the initialized project
   - When examining folder structure
   - Then it should match:
     ```
     app/
       layout.tsx
       page.tsx
     components/
     lib/
     public/
     ```

3. **AC3: Development Server Works**
   - Given the project is initialized
   - When running `npm run dev`
   - Then development server should start on localhost:3000

4. **AC4: Build Succeeds**
   - Given the project is initialized
   - When running `npm run build`
   - Then build should complete without errors

5. **AC5: Design Tokens Configured**
   - Given the Tailwind config
   - When examining theme settings
   - Then UX design tokens should be present:
     - Primary color: #0288D1 (Sky Blue)
     - Secondary color: #66BB6A (Fresh Green)
     - Font family: Inter

## Tasks / Subtasks

- [ ] **Task 1: Create Next.js Project** (AC: 1, 3, 4)
  - [ ] Run `npx create-next-app@latest --typescript --tailwind --app --src-dir=false`
  - [ ] Verify Next.js 15.x installed
  - [ ] Verify TypeScript 5.x with strict mode in tsconfig.json
  - [ ] Test `npm run dev` starts server
  - [ ] Test `npm run build` completes

- [ ] **Task 2: Configure Path Aliases** (AC: 2)
  - [ ] Add path aliases to tsconfig.json (@/*)
  - [ ] Configure import paths for components, lib, actions

- [ ] **Task 3: Set Up ESLint & Prettier** (AC: 1)
  - [ ] Install Prettier and ESLint Prettier plugin
  - [ ] Create .prettierrc with project settings
  - [ ] Configure ESLint rules for React/Next.js
  - [ ] Add lint scripts to package.json

- [ ] **Task 4: Configure Tailwind with Design Tokens** (AC: 5)
  - [ ] Update tailwind.config.ts with custom theme
  - [ ] Add UX design tokens from ux-design-specification.md:
    - `--color-primary: #0288D1`
    - `--color-secondary: #66BB6A`
    - `--color-accent: #FF7043`
  - [ ] Configure Inter font via next/font
  - [ ] Add spacing, radius, shadow tokens

- [ ] **Task 5: Create Base Folder Structure** (AC: 2)
  - [ ] Create components/ directory
  - [ ] Create lib/ directory
  - [ ] Create app/actions/ directory (for Server Actions)
  - [ ] Verify public/ exists for static assets

- [ ] **Task 6: Initialize Git Repository** (AC: 1)
  - [ ] Verify .gitignore includes node_modules, .env*, .next
  - [ ] Create initial commit with project setup
  - [ ] Add docs folder to gitignore if needed

## Dev Notes

### Architecture Constraints

- **Framework**: Next.js 15 with App Router (not Pages Router) [Source: docs/architecture.md#ADR-001]
- **TypeScript**: Strict mode enabled for type safety [Source: docs/architecture.md#Technology-Stack-Summary]
- **Styling**: Tailwind CSS 3.x with utility-first approach
- **Components**: Will use Shadcn/ui (installed in later stories)

### Design System Integration

From UX Design Specification [Source: docs/ux-design-specification.md#Design-Tokens]:

```css
/* Primary Colors */
--color-primary: #0288D1;      /* Sky Blue */
--color-secondary: #66BB6A;     /* Fresh Green */
--color-accent: #FF7043;        /* Warm Coral */
--color-background: #FAFAFA;
--color-surface: #FFFFFF;
--color-text-primary: #212121;
--color-text-secondary: #757575;

/* Typography */
--font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
--font-size-body: 16px;

/* Spacing */
--spacing-xs: 4px;
--spacing-sm: 8px;
--spacing-md: 12px;
--spacing-lg: 16px;
--spacing-xl: 24px;

/* Borders */
--radius-sm: 4px;
--radius-md: 8px;
--radius-lg: 12px;
```

### Project Structure Notes

Expected file structure after completion [Source: docs/architecture.md#File-Structure]:

```
my-home/
├── app/
│   ├── layout.tsx          # Root layout with fonts, metadata
│   ├── page.tsx             # Home page (will be shopping list)
│   └── globals.css          # Global styles with Tailwind imports
├── components/
│   └── ui/                  # Future: Shadcn components
├── lib/
│   └── utils.ts             # Utility functions
├── public/
│   └── icons/               # Future: PWA icons
├── .eslintrc.json
├── .prettierrc
├── next.config.js
├── tailwind.config.ts
├── tsconfig.json
└── package.json
```

### Testing Notes

- No unit tests required for this story (infrastructure setup)
- Verification is manual: dev server runs, build succeeds
- Future stories will add Vitest for unit tests

### References

- [Source: docs/architecture.md#Technology-Stack-Summary] - Stack versions
- [Source: docs/architecture.md#File-Structure] - Project structure
- [Source: docs/architecture.md#ADR-001] - App Router decision
- [Source: docs/ux-design-specification.md#Design-Tokens] - Color palette and typography
- [Source: docs/prd.md#Technical-Type] - Next.js 15 requirement

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
