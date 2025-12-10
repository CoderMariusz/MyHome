# Migration Workflow

> **Version:** 1.1
> **Definition:** @.claude/workflows/definitions/engineering/migration-workflow.yaml
> **Updated:** 2025-12-10

---

## Overview

Complete workflow for migrating existing projects to the Agent Methodology Pack. Handles discovery, planning, execution, and verification phases.

**Use when:**
- Integrating methodology into existing project
- Setting up new project with methodology
- Re-migrating after major changes

**Duration:** 4 hours (small) to 3 days (large)

---

## Flow Diagram

```
                              MIGRATION WORKFLOW
                                      │
        ┌─────────────────────────────┼─────────────────────────────┐
        │                             │                             │
        ▼                             ▼                             ▼
   ┌─────────┐                  ┌──────────┐                  ┌──────────┐
   │  SMALL  │                  │  MEDIUM  │                  │  LARGE   │
   │  AUTO   │                  │  HYBRID  │                  │  MANUAL  │
   │ <50 files│                  │ 50-200   │                  │  >200    │
   └────┬────┘                  └────┬─────┘                  └────┬─────┘
        │                             │                             │
        └─────────────────────────────┼─────────────────────────────┘
                                      │
                                      ▼
+=====================================================================+
│                    PHASE 1: DISCOVERY (30-45 min)                   │
│                    @migration/MIGRATION-DISCOVERY.md                │
│   - doc-auditor: Scan project, identify issues                      │
│   - discovery-agent: Optional context interview                     │
│   Output: AUDIT-REPORT.md                                           │
+=====================================================================+
                                      │
                                      ▼
+=====================================================================+
│                    PHASE 2: PLANNING (1 hour)                       │
│                    @migration/MIGRATION-PLANNING.md                 │
│   - ORCHESTRATOR: Strategy selection                                │
│   - scrum-master: Task breakdown                                    │
│   Output: MIGRATION-PLAN.md                                         │
+=====================================================================+
                                      │
                                      ▼
+=====================================================================+
│                    PHASE 3: EXECUTION (1-3 days)                    │
│                    @migration/MIGRATION-EXECUTION.md                │
│   3.1 Setup Structure     → .claude/, docs/                         │
│   3.2 Create Core Files   → CLAUDE.md, PROJECT-STATE.md             │
│   3.3 Migrate Docs        → standard documentation structure        │
│   3.4 Shard Large Files   → <500 lines each                         │
│   3.5 Generate Workspaces → Agent contexts                          │
+=====================================================================+
                                      │
                                      ▼
+=====================================================================+
│                    PHASE 4: VERIFICATION (30 min)                   │
│                    @migration/MIGRATION-VERIFICATION.md             │
│   - Validation scripts                                              │
│   - Agent loading tests                                             │
│   - Workflow tests                                                  │
│   Output: MIGRATION COMPLETE                                        │
+=====================================================================+
```

---

## Phase Documentation

| Phase | Document | Duration |
|-------|----------|----------|
| 1. Discovery | @.claude/workflows/documentation/migration/MIGRATION-DISCOVERY.md | 30-45 min |
| 2. Planning | @.claude/workflows/documentation/migration/MIGRATION-PLANNING.md | 1 hour |
| 3. Execution | @.claude/workflows/documentation/migration/MIGRATION-EXECUTION.md | 1-3 days |
| 4. Verification | @.claude/workflows/documentation/migration/MIGRATION-VERIFICATION.md | 30 min |

---

## Migration Strategies

| Strategy | Files | Duration | Use When |
|----------|-------|----------|----------|
| **AUTO** | <50 | 4-6 hours | Simple structure, minimal docs |
| **HYBRID** | 50-200 | 1-2 days | Moderate complexity |
| **MANUAL** | >200 | 2-3 days | Complex structure, extensive docs |

---

## Quick Start Checklist

### Pre-Migration
- [ ] Backup entire project
- [ ] Create Git branch: `feature/agent-methodology-migration`
- [ ] Review audit report
- [ ] Approve migration plan

### Phase 1: Discovery
- [ ] Scan project complete
- [ ] Audit report generated
- [ ] Strategy recommended

### Phase 2: Planning
- [ ] Strategy chosen
- [ ] Tasks broken down
- [ ] Risks identified
- [ ] Plan approved

### Phase 3: Execution
- [ ] Structure setup complete
- [ ] Core files created
- [ ] CLAUDE.md < 70 lines
- [ ] Docs migrated to docs/ structure
- [ ] Large files sharded
- [ ] Workspaces defined

### Phase 4: Verification
- [ ] Validation passes
- [ ] Agent loading works
- [ ] @references valid
- [ ] Team can use methodology

---

## Quality Gates

| Gate | Checkpoint | Criteria |
|------|------------|----------|
| Discovery | Audit Complete | All files scanned, issues documented |
| Planning | Plan Approved | Strategy clear, risks mitigated |
| Execution | Structure Valid | All directories, files < 500 lines |
| Verification | Migration Pass | All checks green |

---

## Error Recovery Summary

| Error | Recovery |
|-------|----------|
| CLAUDE.md > 70 lines | Extract to @references |
| Broken @references | Fix paths, re-validate |
| Large file not sharded | Re-split, update index |
| Agent load failure | Check workspace, fix paths |
| Major failure | Rollback to backup, revise plan |

**Full error recovery:** @migration/MIGRATION-VERIFICATION.md

---

## Artifacts

| Artifact | Path | Phase |
|----------|------|-------|
| Audit Report | `AUDIT-REPORT.md` | Discovery |
| Migration Context | `docs/0-DISCOVERY/MIGRATION-CONTEXT.md` | Discovery |
| Migration Plan | `MIGRATION-PLAN.md` | Planning |
| CLAUDE.md | `CLAUDE.md` | Execution |
| PROJECT-STATE.md | `PROJECT-STATE.md` | Execution |
| Workspaces | `.claude/agents/workspaces/` | Execution |

---

## Integration with Other Workflows

| After Migration | Use Workflow |
|-----------------|--------------|
| Start first epic | EPIC-WORKFLOW.md |
| Fix migration issues | BUG-WORKFLOW.md |
| Define first sprint | SPRINT-WORKFLOW.md |
| Implement first story | STORY-WORKFLOW.md |

---

**Related:**
- @.claude/workflows/documentation/EPIC-WORKFLOW.md
- @.claude/workflows/documentation/SPRINT-WORKFLOW.md
- @.claude/agents/ORCHESTRATOR.md
- @.claude/agents/TECH-WRITER.md

---

**Migration Workflow Version:** 1.1
**Last Updated:** 2025-12-10
**Maintained by:** Agent Methodology Pack Team
