# INVENTORY UI — THEME & STYLE PLAN

A design system for the inventory SvelteKit UI. Distinct from the `UI-studio-membership`
wellness/yoga reference: inventory is **data-dense, business/warehouse-oriented** — built
around tables, filters, dashboards, forms, and status badges.

- Stack: SvelteKit 2 + Svelte 5, Tailwind v4 (CSS-first `@theme`), bits-ui v2
- Theming: CSS variables + Tailwind v4 `@theme` tokens in `app.css`
- Modes: Light (default) + Dark, toggled via `.dark` class on `<html>`

---

## 1. Design Direction

| Aspect        | Choice                                                            |
|---------------|------------------------------------------------------------------|
| Mood          | Clean, professional, utilitarian (ERP/warehouse)                 |
| Density       | Compact — maximize rows/data per viewport                        |
| Primary hue   | Indigo/Blue (trust, enterprise)                                  |
| Accent        | Teal/Cyan (actions, highlights)                                  |
| Surfaces      | Neutral slate/gray, layered cards                                |
| Status colors | Green=in-stock, Amber=low/expiring, Red=out/past-due, Blue=transit |

---

## 2. Color Tokens (`app.css` → `@theme`)

### Brand / Semantic
```
--color-primary        #4F46E5   (indigo-600)
--color-primary-hover  #4338CA
--color-accent         #0891B2   (cyan-600)
--color-success        #16A34A   (in stock / confirmed)
--color-warning        #D97706   (low stock / expiring)
--color-danger         #DC2626   (out of stock / past due)
--color-info           #2563EB   (in-transit / neutral info)
```

### Light Mode Surfaces
```
--color-bg             #F8FAFC   (app background, slate-50)
--color-surface        #FFFFFF   (cards, tables, panels)
--color-surface-2      #F1F5F9   (table header, hover rows)
--color-border         #E2E8F0
--color-text           #0F172A   (slate-900)
--color-text-muted     #64748B   (slate-500)
```

### Dark Mode Surfaces (`.dark`)
```
--color-bg             #0B1220
--color-surface        #111827
--color-surface-2      #1E293B
--color-border         #334155
--color-text           #F1F5F9
--color-text-muted     #94A3B8
```

---

## 3. Typography

- Font: `Inter` (UI), `ui-monospace` for SKUs/codes/quantities
- Scale: `text-xs` (table cells/badges), `text-sm` (body/forms), `text-base` (labels),
  `text-lg`/`text-xl` (page titles), `text-2xl` (KPI numbers)
- Tabular numerals (`font-variant-numeric: tabular-nums`) for all quantity/price columns

---

## 4. Spacing, Radius, Shadows

```
--radius-sm  4px   (inputs, badges)
--radius     8px   (cards, buttons)
--radius-lg  12px  (dialogs, panels)

--shadow-card    0 1px 2px rgba(0,0,0,.05)
--shadow-popover 0 4px 12px rgba(0,0,0,.10)
```
- Table row height: ~40px (compact); cell padding `px-3 py-2`
- Page gutter: `p-6`; section gap: `gap-4`

---

## 5. App Shell / Layout

```
┌─────────────────────────────────────────────┐
│ Topbar: logo · search · unit-switcher · 🔔 · 👤 │
├──────────┬──────────────────────────────────┤
│ Sidenav  │  Page header (title + actions)   │
│ (domains)│  Filters bar                     │
│          │  Content (table / grid / form)   │
│          │  Pagination footer               │
└──────────┴──────────────────────────────────┘
```

**Sidenav groups** (collapsible, icon + label) mapped to the 11 domains:
Dashboard · Items · Item Categories · Units · Unit Bins · Unit Items ·
Adjustments · Item Imports · In-Transit · Reports · Notifications

---

## 6. Core UI Patterns (mapped to domains)

### A. List / Grid pages — *Items, Categories, Units, Unit Bins, Unit Items, Imports*
- Sticky filtered toolbar: search input + dropdown selectors (fed by Common endpoints:
  getUnitName, getUserUnit, getInventoryItemCategory)
- Data table: sortable headers, zebra rows, hover highlight, row actions (edit/delete),
  status badge column, client/server pagination, skeleton loading state
- Empty state + error state components

### B. Create / Edit forms — *postInventoryItem, postInventoryUnit, postInventoryItemCategory*
- Dialog (small forms) or full-width form page (large forms like postInventoryItem)
- Sectioned: "Classification" (category/brand/part/size/valve/ratio/pattern selectors),
  "Units & Pricing" (stocking/retail unit, rtu_over_stu, cost, mark-up, selling price),
  "Image" (upload + getItemImage preview)
- `process_type` drives Save / Update / Delete (0/1/2) — buttons styled by intent

### C. Assignment dialogs — *postItemToUnits, postUnitItemBinSwitch*
- Multi-select unit list + bin picker (getEmptyUnitBin / getUnitBinExceptOne)
- Chips for selected unit/bin pairs

### D. Adjustment pages — *getItemForAdjustment, post...Adjustment(Template)*
- Item picker → quantity delta input → reason/template selector
- Template manager as side sheet

### E. In-Transit — *getInTransitReport, getInTransitItemsInvoices, postConfirmInTransitItems*
- Invoice list → expandable item rows → "Confirm Receipt" action
- `quanttiy_confirmed` (source typo preserved) input per row
- Status badge: In-Transit (blue) → Received (green)

### F. Reports — *13 report endpoints*
- Standard layout: **Filter panel** (date range `dateFrom`/`dateTo`, unit selector
  `charUnitList`/`units`, client lookup getClientName) → **Run** → tabular output
- Export-ready table, sticky header, totals row
- Reusable `<ReportShell filters table />` wrapper

### G. Dashboard (landing)
- KPI cards (total items, low-stock count, expiring soon, in-transit) using status colors
- Recent activity / notifications (getNotification)

---

## 7. Status Badge System

| State            | Color    | Used in                          |
|------------------|----------|----------------------------------|
| In Stock         | success  | Items, Unit Items                |
| Low Stock        | warning  | Items, Reports                   |
| Out of Stock     | danger   | Items                            |
| Expiring / Past Due | warning/danger | getExpiriesAndPastDue     |
| In-Transit       | info     | In-Transit pages                 |
| Received/Confirmed | success | postConfirmInTransitItems       |

---

## 8. Component Inventory (port + restyle from reference)

button · card · input · label · table · dialog · dropdown-menu · sheet · sidebar ·
separator · skeleton · spinner · tooltip · navigation-menu · avatar · textarea · input-group

**New inventory-specific components to add:**
- `DataTable` (sort/filter/paginate wrapper)
- `StatusBadge`
- `FilterBar`
- `ReportShell`
- `KpiCard`
- `UnitSwitcher` (topbar)
- `ImagePreview` (item image)

---

## 9. Dark Mode Strategy
- Tailwind v4: define light tokens in `:root`, override in `.dark` (both in `app.css`)
- Toggle stored in localStorage, applied in `app.html`/`hooks` to avoid flash
- All components consume tokens (no hard-coded hex) so mode-switch is automatic

---

## 10. Deliverables Order (once approved)
1. `app.css` theme tokens (light + dark) + Inter font
2. Restyle ported UI primitives to tokens
3. Build shell (topbar + sidenav + dashboard)
4. Build pattern components (DataTable, FilterBar, StatusBadge, ReportShell, KpiCard)
5. Apply per-domain pages per `INVENTORY-UI-TASKS-CHECKLIST.md`
