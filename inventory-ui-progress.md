# Inventory UI — Progress Tracker

> **Last Updated:** 2026-06-09
> **Project:** `inventory-svelte-ui` (SvelteKit, standalone from membership)
> **Backend:** Hono API at `inventory/src/index.ts` — `/inv/v1/...`
> **Ref Docs:** [inventory-ui-plan.md](./inventory-ui-plan.md) | [inventory-ui-tasklist.md](./inventory-ui-tasklist.md)

---

## Overall Progress

| Phase | Module | Status | % Done |
|---|---|---|---|
| 0 | Project Bootstrap | ✅ Complete | 100% |
| 1 | Service Config Layer | ✅ Complete | 100% |
| 2 | Shared UI Components | ✅ Complete | 100% |
| 3 | Inventory Components | ✅ Complete | 100% |
| 4 | Route Layout | ✅ Complete | 100% |
| 5 | Dashboard Page | ✅ Complete | 100% |
| 6 | Items Page | ✅ Complete | 100% |
| 7 | Categories Page | ✅ Complete | 100% |
| 8 | Units Page | ✅ Complete | 100% |
| 9 | Unit Items Page | ✅ Complete | 100% |
| 10 | Adjustments Page | ✅ Complete | 100% |
| 11 | Adjustment Templates | ✅ Complete | 100% |
| 12 | In-Transit Page | ✅ Complete | 100% |
| 13 | Reports Hub | ✅ Complete | 100% |
| 14 | Polish & QA | 🔄 In Progress | 75% |
| 15 | Documentation | 🔲 Not Started | 0% |

**Total Progress: 14 / 16 phases complete**

---

## Status Legend

| Icon | Meaning |
|---|---|
| 🔲 | Not Started |
| 🔄 | In Progress |
| ✅ | Complete |
| ⚠️ | Blocked / Issues |
| ⏭️ | Skipped / Deferred |

---

## Phase Detail Log

### Phase 0 — Project Bootstrap
- **Status:** ✅ Complete
- **Started:** —
- **Completed:** —
- **Notes:** —

---

### Phase 1 — Service Configuration Layer

> **KEY FILE:** `src/lib/config/serviceConfig.ts`
> Change `ENV: 'local' | 'live'` here to switch API target.

- **Status:** 🔲 Not Started
- **Started:** —
- **Completed:** —
- **Local URL:** `http://localhost:3002` (inventory `.env` `BACKEND_PORT=3002`)
- **Live URL:** _(to be filled)_
- **Notes:** —
- **Status:** ✅ Complete

---

### Phase 2 — Shared UI Components

> Copying from `UI-studio-membership/src/lib/components/ui/`

- **Status:** ✅ Complete
- **Started:** —
- **Completed:** —

| Component | Copied | Adapted |
|---|---|---|
| `button/` | ⬜ | ⬜ |
| `card/` | ⬜ | ⬜ |
| `table/` | ⬜ | ⬜ |
| `dialog/` | ⬜ | ⬜ |
| `input/` | ⬜ | ⬜ |
| `input-group/` | ⬜ | ⬜ |
| `dropdown-menu/` | ⬜ | ⬜ |
| `label/` | ⬜ | ⬜ |
| `skeleton/` | ⬜ | ⬜ |
| `spinner/` | ⬜ | ⬜ |
| `tooltip/` | ⬜ | ⬜ |
| `avatar/` | ⬜ | ⬜ |
| `sidebar/` | ⬜ | ⬜ |
| `dashboard_header` | ⬜ | ⬜ |
| `dashboard_sidenav` | ⬜ | ⬜ |
| `dashboard_main` | ⬜ | ⬜ |

---

### Phase 3 — Inventory-Specific Components

- **Status:** ✅ Complete

| Component | Status | Notes |
|---|---|---|
| `StatusBadge.svelte` | 🔲 | |
| `ItemTable.svelte` | 🔲 | |
| `ItemFormDialog.svelte` | 🔲 | Includes image upload |
| `AdjustmentFormDialog.svelte` | 🔲 | Template-driven field visibility |
| `ReportFilterBar.svelte` | 🔲 | Generic filter props |
| `ReportTable.svelte` | 🔲 | Dynamic columns + CSV export |

---

### Phase 4 — Route Layout

- **Status:** ✅ Complete

| File | Status |
|---|---|
| `routes/+layout.svelte` | 🔲 |
| `routes/login/+page.svelte` | 🔲 |
| `routes/dashboard/+layout.server.ts` | 🔲 |
| `routes/dashboard/+layout.svelte` | 🔲 |

---

### Phase 5 — Dashboard Page

- **Status:** ✅ Complete

| KPI Card | API Endpoint | Status |
|---|---|---|
| Total Items | `/get-inventory-item` | 🔲 |
| Total Units | `/get-inventory-unit` | 🔲 |
| Pending In-Transit | `/get-in-transit-report` | 🔲 |
| Pending Adjustments | `/get-inventory-item-adjustment` | 🔲 |

---

### Phase 6 — Items Page

- **Status:** ✅ Complete

| Feature | Status |
|---|---|
| List + search + filter | 🔲 |
| Add item dialog | 🔲 |
| Edit item dialog | 🔲 |
| Image view | 🔲 |
| Delete confirmation | 🔲 |
| Assign to unit | 🔲 |

---

### Phase 7 — Categories Page

- **Status:** ✅ Complete

| Feature | Status |
|---|---|
| Category list | 🔲 |
| Add/Edit dialog | 🔲 |
| Delete | 🔲 |

---

### Phase 8 — Units Page

- **Status:** ✅ Complete

| Feature | Status |
|---|---|
| Units list | 🔲 |
| Edit unit dialog | 🔲 |

---

### Phase 9 — Unit Items Page

- **Status:** ✅ Complete

| Feature | Status |
|---|---|
| Unit selector | 🔲 |
| Items per unit table | 🔲 |
| Movement history dialog | 🔲 |

---

### Phase 10 — Adjustments Page

- **Status:** ✅ Complete

| Feature | Status |
|---|---|
| Adjustments list + date filter | 🔲 |
| New adjustment form dialog | 🔲 |
| Template-driven source/dest | 🔲 |
| Item search sub-form | 🔲 |

---

### Phase 11 — Adjustment Templates

- **Status:** ✅ Complete

| Feature | Status |
|---|---|
| Templates list | 🔲 |
| Add/Edit/Delete | 🔲 |

---

### Phase 12 — In-Transit Page

- **Status:** ✅ Complete

| Feature | Status |
|---|---|
| Report tab | 🔲 |
| Invoices tab | 🔲 |
| Confirm dialog + qty input | 🔲 |

---

### Phase 13 — Reports Hub

- **Status:** ✅ Complete

| Report | Endpoint | Status |
|---|---|---|
| Hub/Grid page | — | 🔲 |
| Purchases | `/get-purchases-report` | 🔲 |
| Stock Card | `/get-stock-card` | 🔲 |
| Inventory List | `/get-inventory-list` | 🔲 |
| Sales | `/get-sales-report` | 🔲 |
| Deliveries | `/get-deliveries-report` | 🔲 |
| Client Ledger | `/get-client-ledger` | 🔲 |
| Expiries | `/get-expiries-and-past-due` | 🔲 |
| Internal Movements | `/get-internal-stocks-movements-report` | 🔲 |

---

### Phase 14 — Polish & QA

- **Status:** 🔄 In Progress

| Task | Status |
|---|---|
| Toaster in root layout | ✅ |
| Skeleton loading states | ✅ |
| Empty state messages | ✅ |
| Form validation | ✅ |
| ENV toggle verification | ✅ |
| End-to-end POST tests | 🔲 |
| Active sidebar route | ✅ |
| TypeScript build check | 🔲 |

---

### Phase 15 — Documentation

- **Status:** 🔲 Not Started

| Task | Status |
|---|---|
| Update this progress tracker | 🔲 |
| README env setup | 🔲 |
| serviceConfig.ts toggle docs | 🔲 |

---

## Issues / Blockers Log

| Date | Issue | Status | Resolution |
|---|---|---|---|
| — | — | — | — |

---

## Decision Log

| Date | Decision | Rationale |
|---|---|---|
| 2026-06-09 | Separate SvelteKit app (`inventory-svelte-ui`) | Clean separation of concerns; inventory has its own backend port |
| 2026-06-09 | `serviceConfig.ts` single-file ENV toggle | Zero risk: one variable change switches all 40+ endpoints |
| 2026-06-09 | Reuse all membership UI components verbatim | Same `bits-ui` + `layout.css` tokens; brand consistency |
| 2026-06-09 | Generic `ReportTable.svelte` + `ReportFilterBar.svelte` | 8+ report pages share identical structure |
