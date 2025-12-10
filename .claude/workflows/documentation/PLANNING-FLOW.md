# PLANNING-FLOW

> **Version:** 1.0
> **Definition:** @.claude/workflows/definitions/product/planning-flow.yaml
> **Author:** ORCHESTRATOR
> **Updated:** 2025-12-08

---

## Workflow Purpose

PLANNING-FLOW connects DISCOVERY-FLOW outputs to EPIC-WORKFLOW inputs. It handles:

1. **Input consolidation** from discovery and research
2. **PRD creation/update** with measurable outcomes
3. **Epic identification** and dependency mapping
4. **Prioritization** and NOW/NEXT/LATER roadmap creation
5. **Story preparation** for sprint intake

---

## When to Use

| Mode | Trigger | Phases | Example |
|------|---------|--------|---------|
| **PORTFOLIO** | New project, major pivot | All 6 phases | Greenfield project |
| **EPIC-SCOPED** | New functionality | Skip: outcomes | Adding payment module |
| **ADJUSTMENT** | Priority changes | Only: context, prioritization, confirmation | Mid-sprint reprioritization |

---

## Flow Diagram

```
                    ┌─────────────────────────────────────────────────────────────┐
                    │                     PLANNING-FLOW                            │
                    └─────────────────────────────────────────────────────────────┘
                                              │
        ┌─────────────────────────────────────┼─────────────────────────────────────┐
        │                                     │                                     │
        ▼                                     ▼                                     ▼
   ┌─────────┐                          ┌─────────┐                           ┌─────────┐
   │PORTFOLIO│                          │  EPIC   │                           │ADJUSTMENT│
   │  MODE   │                          │ SCOPED  │                           │  MODE   │
   └────┬────┘                          └────┬────┘                           └────┬────┘
        │                                    │                                     │
        ▼                                    ▼                                     ▼
┌───────────────┐                    ┌───────────────┐                     ┌───────────────┐
│ 1. CONTEXT    │                    │ 1. CONTEXT    │                     │ 1. CONTEXT    │
│   Gathering   │                    │   Gathering   │                     │   Gathering   │
└───────┬───────┘                    └───────┬───────┘                     └───────┬───────┘
        │                                    │                                     │
        ▼                                    │                                     │
┌───────────────┐                            │                                     │
│ 2. OUTCOMES   │                            │                                     │
│   & PRD       │                            │                                     │
└───────┬───────┘                            │                                     │
        │                                    │                                     │
        ▼                                    ▼                                     │
┌───────────────┐                    ┌───────────────┐                             │
│ 3. EPIC       │                    │ 3. EPIC       │                             │
│  DISCOVERY    │                    │  DISCOVERY    │                             │
└───────┬───────┘                    └───────┬───────┘                             │
        │                                    │                                     │
        ▼                                    ▼                                     ▼
┌───────────────┐                    ┌───────────────┐                     ┌───────────────┐
│ 4. PRIORITI-  │                    │ 4. PRIORITI-  │                     │ 4. PRIORITI-  │
│    ZATION     │                    │    ZATION     │                     │    ZATION     │
└───────┬───────┘                    └───────┬───────┘                     └───────┬───────┘
        │                                    │                                     │
        ▼                                    │                                     │
┌───────────────┐                            │                                     │
│ 5. SPRINT     │                            │                                     │
│   INTAKE      │                            │                                     │
└───────┬───────┘                            │                                     │
        │                                    │                                     │
        ▼                                    ▼                                     ▼
┌───────────────┐                    ┌───────────────┐                     ┌───────────────┐
│ 6. CONFIR-    │                    │ 6. CONFIR-    │                     │ 6. CONFIR-    │
│   MATION      │                    │   MATION      │                     │   MATION      │
└───────┬───────┘                    └───────┬───────┘                     └───────┬───────┘
        │                                    │                                     │
        └────────────────────────────────────┼─────────────────────────────────────┘
                                             │
                                             ▼
                                    ┌───────────────┐
                                    │ EPIC-WORKFLOW │
                                    │  (Phase 2+)   │
                                    └───────────────┘
```

---

## Phase Details

### Phase 1: CONTEXT GATHERING

**Agent:** orchestrator

**Purpose:** Collect and validate all inputs needed for planning.

**Inputs:**

| Source | Path | Required |
|--------|------|----------|
| Discovery Output | `docs/0-DISCOVERY/PROJECT-UNDERSTANDING.md` | Yes |
| Research | `docs/0-DISCOVERY/research/*.md` | Optional |
| Existing PRD | `docs/1-BASELINE/product/prd.md` | Optional |
| User Context | {user provided} | Optional |

**Activities:**

1. Validate discovery outputs completeness
2. Identify information gaps
3. Trigger research agents if needed (parallel)
4. Consolidate all inputs

**Research Triggers:**

```yaml
parallel_research:
  - trigger: technology_unknown
    agent: research-agent
    type: tech_evaluation

  - trigger: market_gap
    agent: research-agent
    type: market_analysis

  - trigger: competitor_analysis_needed
    agent: research-agent
    type: competitor_research
```

**Output:** `docs/0-DISCOVERY/planning-context.md`

**Quality Gate:**

- [ ] Clarity score >= 60%
- [ ] All required inputs available
- [ ] No critical unknowns blocking

---

### Phase 2: OUTCOMES & PRD

**Agent:** pm-agent

**Purpose:** Define measurable outcomes and create/update PRD.

**Activities:**

1. **Define SMART Success Metrics**
   - Specific: What exactly are we measuring?
   - Measurable: How do we measure? What baseline?
   - Achievable: Is it realistic?
   - Relevant: Is it aligned with business goal?
   - Time-bound: By when?

2. **Create/Update PRD**
   - Functional Requirements (FR)
   - Non-Functional Requirements (NFR)
   - Constraints
   - Assumptions

3. **Apply MoSCoW Prioritization**
   - **Must:** Without this, project makes no sense
   - **Should:** Important but can be worked around
   - **Could:** Nice to have
   - **Won't:** Explicit out of scope (important!)

4. **Define Scope Boundaries**
   - IN SCOPE: What we do
   - OUT OF SCOPE: What we do NOT do
   - FUTURE: What we'll consider later

**Template:** `@.claude/templates/prd-template.md`

**Output:**
- `docs/1-BASELINE/product/prd.md`
- `docs/1-BASELINE/product/success-metrics.md`

**Quality Gate:**

- [ ] All requirements have MoSCoW priority
- [ ] Success metrics are SMART
- [ ] Scope explicitly defined (IN/OUT/FUTURE)
- [ ] Min. 3 MUST requirements

---

### Phase 3: EPIC DISCOVERY

**Agent:** architect-agent

**Purpose:** Identify epics, map dependencies, assess risks.

#### 3.1 Epic Identification

**Activities:**

1. Map PRD requirements → Epics
2. Define boundaries for each epic
3. Validate INVEST at epic level

**Template:** `@.claude/templates/epic-template.md`

**Output:** `docs/2-MANAGEMENT/epics/epic-catalog.md`

**Checkpoints:**

- [ ] Each PRD requirement mapped to epic
- [ ] Epic boundaries are clear
- [ ] No orphan requirements

#### 3.2 Dependency Mapping

**Activities:**

1. Identify technical dependencies
2. Identify business dependencies
3. Create dependency graph
4. Identify critical path

**Template:** `@.claude/templates/epic-dependency-graph.md`

**Output:** `docs/2-MANAGEMENT/epics/dependency-graph.md`

```
Dependency Types:
- BLOCKS: A must be before B
- ENHANCES: A works better with B but doesn't require it
- CONFLICTS: A and B cannot run in parallel
```

**Checkpoints:**

- [ ] All dependencies explicit
- [ ] No circular dependencies
- [ ] Critical path identified

#### 3.3 Risk Assessment

**Activities:**

1. Identify technical risks
2. Identify business risks
3. Propose mitigations
4. Flag unknowns requiring research

**Template:** `@.claude/templates/risk-registry.md`

**Output:** `docs/2-MANAGEMENT/risks/risk-registry.md`

**Risk Matrix:**

| Probability \ Impact | Low | Medium | High |
|---------------------|-----|--------|------|
| **High** | Medium | High | Critical |
| **Medium** | Low | Medium | High |
| **Low** | Low | Low | Medium |

---

### Phase 4: PRIORITIZATION

**Agent:** product-owner

**Purpose:** Prioritize epics and create roadmap.

#### 4.1 Value Scoring

**Scoring Framework:**

| Criterion | Weight | Scale |
|-----------|--------|-------|
| Business Value | 30% | 1-5 |
| User Impact | 25% | 1-5 |
| Technical Risk | 20% | 1-5 (inverse) |
| Dependency Weight | 15% | 0-3 |
| Strategic Alignment | 10% | 1-5 |

**Formula:**

```
Score = (BV * 0.30) + (UI * 0.25) + ((6-TR) * 0.20) + ((4-DW) * 0.15) + (SA * 0.10)
```

**Output:** `docs/2-MANAGEMENT/epics/prioritized-backlog.md`

#### 4.2 Roadmap Creation

**NOW / NEXT / LATER Framework:**

| Bucket | Horizon | Max Epics | Criteria |
|--------|---------|-----------|----------|
| **NOW** | Current sprint cycle | 2-3 | Highest score, dependencies met |
| **NEXT** | Next 2-3 sprints | 3-5 | High score, some dependencies |
| **LATER** | Backlog | Unlimited | Lower score or blocked |

**Template:** `@.claude/templates/roadmap.md`

**Output:** `docs/2-MANAGEMENT/roadmap.md`

**Checkpoints:**

- [ ] NOW bucket has max 2-3 epics
- [ ] Dependencies respected in sequencing
- [ ] Clear milestone definitions

---

### Phase 5: SPRINT INTAKE

**Agents:** architect-agent + product-owner

**Purpose:** Prepare first epics for sprint planning.

#### 5.1 Story Breakdown (architect-agent)

**Activities:**

1. Break epic into stories
2. Apply INVEST criteria
3. Define AC in Given/When/Then format
4. Estimate complexity (S/M/L)

**Template:** `@.claude/templates/story-template.md`

**Output:** `docs/2-MANAGEMENT/epics/epic-{N}-stories.md`

#### 5.2 INVEST Validation (product-owner)

**INVEST Criteria:**

| Letter | Criterion | Control Question |
|--------|-----------|------------------|
| **I** | Independent | Can it be developed without other stories? |
| **N** | Negotiable | Is the HOW flexible? |
| **V** | Valuable | Does it deliver value to user/business? |
| **E** | Estimable | Can it be estimated? |
| **S** | Small | Does it fit in 1-3 sessions? |
| **T** | Testable | Are AC verifiable? |

**Template:** `@.claude/templates/story-checklist-template.md`

**Output:** `docs/2-MANAGEMENT/reviews/invest-review-epic-{N}.md`

**Decision:**
- APPROVED → Confirmation
- NEEDS_REVISION → Return to Story Breakdown (max 2 iterations)

---

### Phase 6: CONFIRMATION

**Agent:** orchestrator

**Purpose:** Final verification and handoff to EPIC-WORKFLOW.

**Activities:**

1. Verify all artifacts
2. Confirm stakeholder alignment
3. Prepare handoff

**Output:** `docs/2-MANAGEMENT/planning-summary.md`

**Planning Summary includes:**

```markdown
## Planning Summary

### Roadmap Overview
- NOW: [Epic-1, Epic-2]
- NEXT: [Epic-3, Epic-4, Epic-5]
- LATER: [Epic-6, ...]

### First Sprint Candidates
| Story | Epic | Complexity | Dependencies |
|-------|------|------------|--------------|
| 1.1 | Epic-1 | S | None |
| 1.2 | Epic-1 | M | 1.1 |

### Key Risks
1. [Risk 1] - Mitigation: [plan]
2. [Risk 2] - Mitigation: [plan]

### Open Questions
- [ ] [Question for user]
```

**Next Workflow:**
- → EPIC-WORKFLOW (Phase 2: Story Breakdown) for implementation
- or → new-project.yaml (scope_validation) for full validation

---

## Quality Gates Between Phases

```
CONTEXT ──────────────────────► OUTCOMES
         ├─ clarity_score >= 60
         └─ no_critical_unknowns

OUTCOMES ─────────────────────► EPIC DISCOVERY
         ├─ prd_complete
         ├─ requirements_prioritized
         └─ scope_defined

EPIC DISCOVERY ───────────────► PRIORITIZATION
         ├─ epics_identified
         ├─ dependencies_mapped
         └─ risks_assessed

PRIORITIZATION ───────────────► SPRINT INTAKE
         ├─ roadmap_created
         └─ now_bucket_defined

SPRINT INTAKE ────────────────► CONFIRMATION
         ├─ stories_invest_compliant
         └─ ac_testable
```

---

## Artifacts

| Artifact | Path | Phase |
|----------|------|-------|
| Planning Context | `docs/0-DISCOVERY/planning-context.md` | Context |
| PRD | `docs/1-BASELINE/product/prd.md` | Outcomes |
| Success Metrics | `docs/1-BASELINE/product/success-metrics.md` | Outcomes |
| Epic Catalog | `docs/2-MANAGEMENT/epics/epic-catalog.md` | Epic Discovery |
| Dependency Graph | `docs/2-MANAGEMENT/epics/dependency-graph.md` | Epic Discovery |
| Risk Registry | `docs/2-MANAGEMENT/risks/risk-registry.md` | Epic Discovery |
| Prioritized Backlog | `docs/2-MANAGEMENT/epics/prioritized-backlog.md` | Prioritization |
| Roadmap | `docs/2-MANAGEMENT/roadmap.md` | Prioritization |
| Stories | `docs/2-MANAGEMENT/epics/epic-{N}-stories.md` | Sprint Intake |
| INVEST Review | `docs/2-MANAGEMENT/reviews/invest-review-epic-{N}.md` | Sprint Intake |
| Planning Summary | `docs/2-MANAGEMENT/planning-summary.md` | Confirmation |

---

## Error Recovery

| Error | Action | Message |
|-------|--------|---------|
| Clarity too low | Return to DISCOVERY | "Need more information" |
| Circular dependency | Escalate to user | "Circular dependency detected" |
| Scope creep | Pause | "Scope expansion detected - confirmation required" |
| INVEST fail x2 | Escalate | "Stories don't meet INVEST after 2 iterations" |

---

## Integration with Other Workflows

### Input: DISCOVERY-FLOW

```
DISCOVERY-FLOW
    │
    ▼
PROJECT-UNDERSTANDING.md ─────► PLANNING-FLOW (Context)
```

### Output: EPIC-WORKFLOW

```
PLANNING-FLOW (Confirmation)
    │
    ▼
epic-{N}-stories.md ──────────► EPIC-WORKFLOW (Phase 2+)
```

---

## Usage Example

### PORTFOLIO Mode (New Project)

```bash
# Start
ORCHESTRATOR: "Starting PLANNING-FLOW in PORTFOLIO mode"

# Phase 1
→ Check docs/0-DISCOVERY/PROJECT-UNDERSTANDING.md
→ Trigger research-agent for technology evaluation
→ Create planning-context.md

# Phase 2
→ pm-agent creates PRD with MoSCoW priorities
→ Define SMART success metrics

# Phase 3
→ architect-agent identifies 5 epics
→ Maps dependencies (Epic-2 blocks Epic-4)
→ Assesses risks (High: third-party API integration)

# Phase 4
→ product-owner scores epics
→ Creates roadmap: NOW=[Epic-1, Epic-2], NEXT=[Epic-3, Epic-5], LATER=[Epic-4]

# Phase 5
→ architect-agent breaks Epic-1 into 6 stories
→ product-owner validates INVEST

# Phase 6
→ Planning summary created
→ Handoff to EPIC-WORKFLOW
```

---

**Related:**
- @.claude/workflows/documentation/DISCOVERY-FLOW.md
- @.claude/workflows/documentation/EPIC-WORKFLOW.md
- @.claude/agents/PM-AGENT.md
- @.claude/agents/ARCHITECT-AGENT.md
- @.claude/agents/PRODUCT-OWNER.md
