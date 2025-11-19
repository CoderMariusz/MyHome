# Story 1.4: Vercel Deployment Pipeline

Status: drafted

## Story

As a **developer**,
I want **to configure Vercel deployment with preview and production environments**,
so that **the application can be deployed and tested continuously**.

## Acceptance Criteria

1. **AC1: Vercel Project Connected**
   - Given the GitHub repository
   - When connected to Vercel
   - Then the project should be linked and ready for deployment

2. **AC2: Automatic Production Deployment**
   - Given code is pushed to main branch
   - When Vercel detects the push
   - Then automatic deployment to production should trigger
   - And deployment should complete successfully

3. **AC3: Preview Deployments**
   - Given code is pushed to feature branch
   - When a PR is created
   - Then preview deployment should be created with unique URL
   - And preview should be accessible for testing

4. **AC4: Environment Variables Configured**
   - Given the Vercel project settings
   - When examining environment variables
   - Then the following should be configured:
     - Production: Supabase Cloud credentials
     - Preview: Supabase staging credentials (or same as production for MVP)

5. **AC5: Build Performance**
   - Given a deployment trigger
   - When build runs
   - Then it should complete in < 2 minutes
   - And Lighthouse Performance score should be > 80

## Tasks / Subtasks

- [ ] **Task 1: Create Vercel Account/Project** (AC: 1)
  - [ ] Sign up/login to Vercel
  - [ ] Create new project
  - [ ] Connect GitHub repository
  - [ ] Select Next.js framework preset

- [ ] **Task 2: Configure Build Settings** (AC: 1, 5)
  - [ ] Verify build command: `npm run build`
  - [ ] Verify output directory: `.next`
  - [ ] Set Node.js version to 18.x or 20.x
  - [ ] Configure install command: `npm install`

- [ ] **Task 3: Set Up Production Environment Variables** (AC: 4)
  - [ ] Create Supabase Cloud project (or use existing)
  - [ ] Add NEXT_PUBLIC_SUPABASE_URL (production)
  - [ ] Add NEXT_PUBLIC_SUPABASE_ANON_KEY (production)
  - [ ] Add NEXT_PUBLIC_SITE_URL (production domain)
  - [ ] Mark as "Production" environment

- [ ] **Task 4: Set Up Preview Environment Variables** (AC: 4)
  - [ ] Add same variables for "Preview" environment
  - [ ] Consider separate Supabase project for staging (optional)
  - [ ] Verify preview deployments use correct env

- [ ] **Task 5: Configure Git Integration** (AC: 2, 3)
  - [ ] Enable automatic deployments for main branch
  - [ ] Enable preview deployments for PRs
  - [ ] Configure deployment protection rules (optional)

- [ ] **Task 6: Test Deployment Pipeline** (AC: 2, 3, 5)
  - [ ] Push to main branch
  - [ ] Verify production deployment succeeds
  - [ ] Create test PR
  - [ ] Verify preview deployment created
  - [ ] Check build time < 2 minutes

- [ ] **Task 7: Configure Domain (Optional for MVP)** (AC: 2)
  - [ ] Add custom domain (myhome.app) if available
  - [ ] Configure DNS settings
  - [ ] Verify SSL certificate provisioned

- [ ] **Task 8: Set Up Monitoring** (AC: 5)
  - [ ] Enable Vercel Analytics (optional)
  - [ ] Enable Speed Insights (optional)
  - [ ] Configure deployment notifications (Slack/email)

## Dev Notes

### Architecture Reference

**Deployment Pipeline** [Source: docs/architecture.md#Deployment-Architecture]:

```
Development → Preview → Production

1. Local Development (localhost:3000)
   ↓ git push to feature branch
2. Preview Deployment (unique URL per PR)
   ↓ merge to main
3. Production Deployment (myhome.app)
```

### Vercel Configuration

**vercel.json (optional, for custom settings):**

```json
{
  "buildCommand": "npm run build",
  "devCommand": "npm run dev",
  "installCommand": "npm install",
  "framework": "nextjs",
  "regions": ["iad1"]
}
```

### Environment Variables Structure

**Production:**
```bash
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJxxx...prod
NEXT_PUBLIC_SITE_URL=https://myhome.app
```

**Preview:**
```bash
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co  # Same or staging
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJxxx...
NEXT_PUBLIC_SITE_URL=https://xxx.vercel.app  # Auto-set by Vercel
```

### Supabase Cloud Setup

For production deployment, need Supabase Cloud project:

1. Create project at supabase.com
2. Apply migrations from local:
   ```bash
   supabase link --project-ref <project-id>
   supabase db push
   ```
3. Get production URL and anon key from Settings > API

### Performance Targets

From PRD [Source: docs/prd.md#NFR-P4]:
- Lighthouse Performance: > 85 (we set > 80 for initial)
- First Contentful Paint: < 1.5s
- Time to Interactive: < 3s

### Hosting Costs

**Vercel:**
- Hobby (free): Sufficient for MVP
- Pro ($20/mo): When > 100 families

**Supabase:**
- Free tier: 50,000 MAU, 500MB database
- Pro ($25/mo): When > 1000 homes

### Project Structure Notes

No new files in project, configuration in Vercel dashboard.

Optional vercel.json in root if custom settings needed.

### Testing Notes

- Verify build succeeds without errors
- Check all environment variables accessible
- Test preview URL accessibility
- Run Lighthouse audit on deployment

### Prerequisites

- Story 1.1 completed (project initialized)
- Story 1.2 completed (Supabase schema)
- Story 1.3 completed (Supabase client)
- GitHub repository created and pushed

### References

- [Source: docs/architecture.md#Deployment-Architecture] - Pipeline overview
- [Source: docs/architecture.md#Hosting-Stack] - Vercel + Supabase config
- [Source: docs/architecture.md#Environment-Variables] - Env var structure
- [Source: docs/prd.md#NFR-P4] - Lighthouse score requirement

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
