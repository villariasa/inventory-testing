# Inventory UI — Task Checklist

> Track every implementation task here. Update status as work progresses.
>
> **Status Legend:** `[ ]` = Todo · `[/]` = In Progress · `[x]` = Done

---

## Phase 0 — Project Bootstrap

- [x] Scaffold `inventory-svelte-ui/` SvelteKit project inside `inventory/`
  - [x] Run `npx -y sv create inventory-svelte-ui` with TailwindCSS + TypeScript options
  - [x] Verify `npm run dev` starts on port `3003` (or update `.env` `FRONTEND_PORT`)
- [x] Install all shared dependencies matching membership `package.json`
  - [x] `@fontsource/nunito-sans`
  - [x] `@fontsource/playfair-display`
  - [x] `@iconify/svelte`
  - [x] `svelte-sonner`
  - [x] `bits-ui`
  - [x] `tw-animate-css`
- [x] Copy `layout.css` from membership → `inventory-svelte-ui/src/routes/layout.css`
- [x] Copy `app.css` (font imports) → `inventory-svelte-ui/src/app.css`

---

## Phase 1 — Service Configuration Layer

- [x] Create `src/lib/config/serviceConfig.ts`
  - [x] Add `ENV: 'local' | 'live'` toggle variable
  - [x] Add `BASE_URLS` object with `local` and `live` values
  - [x] Export `BASE_URL`, `INV_API`, and `endpoint()` helper
- [x] Create `src/lib/service/invokeService.ts`
  - [x] Copy base pattern from membership `invokeService.ts`
  - [x] Integrate `BASE_URL` from `serviceConfig.ts`
  - [x] Add `SessionAuth` header support
  - [x] Add `accessToken` refresh handling (x-new-access-token header)
- [x] Create `src/lib/types/index.ts`
  - [x] Define `InventoryItem` type
  - [x] Define `ItemCategory` type
  - [x] Define `InventoryUnit` type
  - [x] Define `UnitItem` type
  - [x] Define `Adjustment` type
  - [x] Define `AdjustmentTemplate` type
  - [x] Define `InTransitInvoice` type
  - [x] Define `InTransitItem` type
  - [x] Define `ReportRow` generic type
- [x] Create `src/lib/store/user.ts` (same as membership writable store)

---

## Phase 2 — Shared UI Components (Copy & Adapt)

- [x] Copy all `bits-ui` component wrappers from membership `src/lib/components/ui/`
  - [x] `button/`
  - [x] `card/`
  - [x] `table/`
  - [x] `dialog/`
  - [x] `input/`
  - [x] `input-group/`
  - [x] `dropdown-menu/`
  - [x] `label/`
  - [x] `skeleton/`
  - [x] `spinner/`
  - [x] `tooltip/`
  - [x] `avatar/`
  - [x] `separator/`
  - [x] `sheet/`
  - [x] `sidebar/`
  - [x] `switch/`
  - [x] `checkbox/`
- [x] Copy layout components
  - [x] `dashboard_header.svelte` → update `pageNameMap` for inventory routes
  - [x] `dashboard_sidenav.svelte` → replace menu items with inventory nav items
  - [x] `dashboard_main.svelte` → keep as-is

---

## Phase 3 — Inventory-Specific Components

- [x] Create `src/lib/components/inventory/StatusBadge.svelte`
  - [x] Accept `status: string` prop
  - [x] Apply color class mapping (`ACTIVE`=green, `INACTIVE`=gray, etc.)
- [x] Create `src/lib/components/inventory/ItemTable.svelte`
  - [x] Accept `items[]`, `loading`, `currentPage`, `perPage` props
  - [x] Emit `onEdit`, `onView`, `onDelete` events
- [x] Create `src/lib/components/inventory/ItemFormDialog.svelte`
  - [x] All fields from `PostInventoryItemRequestSchema`
  - [x] Image preview + upload control
  - [x] Category dropdown (from API)
  - [x] Emit `onSave` event
- [x] Create `src/lib/components/inventory/AdjustmentFormDialog.svelte`
  - [x] Template selector → dynamically show/hide source/dest unit fields
  - [x] Item search (calls `/get-item-for-adjustment`)
  - [x] Qty + unit cost + remarks inputs
  - [x] Emit `onSubmit` event
- [x] Create `src/lib/components/inventory/ReportFilterBar.svelte`
  - [x] Accept filter config: date range, unit selector, client selector
  - [x] Emit `onFilter` event with collected values
- [x] Create `src/lib/components/inventory/ReportTable.svelte`
  - [x] Accept `columns[]`, `rows[]`, `loading` props
  - [x] Dynamic column rendering
  - [x] Export to CSV button

---

## Phase 4 — Route Layout

- [x] Create root `+layout.svelte` (font + theme imports)
- [x] Create `routes/login/+page.svelte`
  - [x] Email + password fields
  - [x] Submit → calls auth endpoint
  - [x] Store session token
- [x] Create `routes/dashboard/+layout.server.ts`
  - [x] Session guard: redirect to `/login` if not authenticated
  - [x] Pass `user` to all dashboard pages
- [x] Create `routes/dashboard/+layout.svelte`
  - [x] `SidebarProvider` wrapping `dashboard_sidenav` + `dashboard_header` + `<slot>`

---

## Phase 5 — Dashboard Page

- [x] Create `routes/dashboard/+page.svelte`
  - [x] KPI card: Total Items (calls `/get-inventory-item`)
  - [x] KPI card: Total Units (calls `/get-inventory-unit`)
  - [x] KPI card: Pending In-Transit (calls `/get-in-transit-report`)
  - [x] KPI card: Pending Adjustments (calls `/get-inventory-item-adjustment`)
  - [x] Each card uses `Card.*` + icon + count + "View more" Button

---

## Phase 6 — Items Page

- [x] Create `routes/dashboard/items/+page.server.ts`
  - [x] Load items list via `/get-inventory-item`
  - [x] Load categories via `/get-item-category`
- [x] Create `routes/dashboard/items/+page.svelte`
  - [x] Toolbar: search input + category filter + `+ Add Item` button
  - [x] `ItemTable.svelte` with pagination
  - [x] Add/Edit `ItemFormDialog.svelte` (process_type 0=add, 1=edit)
  - [x] View dialog (read-only + image)
  - [x] Delete confirmation `Dialog.*` (process_type 2=delete)
  - [x] Post-save reload via `invalidateAll()` or local state update

---

## Phase 7 — Categories Page

- [x] Create `routes/dashboard/categories/+page.server.ts`
  - [x] Load categories via `/get-item-category`
- [x] Create `routes/dashboard/categories/+page.svelte`
  - [x] Table: ID | Category Name | Status | Actions
  - [x] Add/Edit/Delete dialogs
  - [x] Calls `/post-item-category`

---

## Phase 8 — Units Page

- [x] Create `routes/dashboard/units/+page.server.ts`
  - [x] Load units via `/get-inventory-unit`
- [x] Create `routes/dashboard/units/+page.svelte`
  - [x] Table: ID | Description | Warehouse | Employee | Person In Charge | Actions
  - [x] Edit dialog (calls `/post-inventory-unit`)

---

## Phase 9 — Unit Items Page

- [x] Create `routes/dashboard/unit-items/+page.svelte`
  - [x] Unit selector dropdown (calls `/get-inventory-unit`)
  - [x] Items table for selected unit (calls `/get-unit-item`)
  - [x] History dialog per item (calls `/get-unit-item-history`)

---

## Phase 10 — Adjustments Page

- [x] Create `routes/dashboard/adjustments/+page.server.ts`
  - [x] Load adjustments list via `/get-inventory-item-adjustment`
- [x] Create `routes/dashboard/adjustments/+page.svelte`
  - [x] Date range filter + unit filter toolbar
  - [x] Adjustments table with all columns
  - [x] `AdjustmentFormDialog.svelte` for new adjustment
  - [x] Calls `/post-inventory-item-adjustment`

---

## Phase 11 — Adjustment Templates Page

- [x] Create `routes/dashboard/adjustment-templates/+page.server.ts`
  - [x] Load templates via `/get-inventory-item-adjustment-template`
- [x] Create `routes/dashboard/adjustment-templates/+page.svelte`
  - [x] Templates table: ID | Description | Requires Src/Dest | Add to Qty | Actions
  - [x] Add/Edit/Delete dialogs (calls `/post-inventory-item-adjustment-template`)

---

## Phase 12 — In-Transit Page

- [x] Create `routes/dashboard/in-transit/+page.svelte`
  - [x] Sub-tab: `Report` | `Invoices`
  - [x] Report tab: search input → table (calls `/get-instransit-report`)
  - [x] Invoices tab: invoice list (calls `/get-in-transit-items-invoices`)
  - [x] Confirm Dialog: line items with qty input per row
  - [x] Submit → `/post-confirm-in-transit-items`

---

## Phase 13 — Reports Hub

- [x] Create `routes/dashboard/reports/+page.svelte`
  - [x] Card grid of report shortcuts (icon + name + link)
- [x] Create `routes/dashboard/reports/purchases/+page.svelte`
  - [x] Date range + client filter → table (calls `/get-purchases-report`)
- [x] Create `routes/dashboard/reports/stock-card/+page.svelte`
  - [x] Unit + date range filter → table (calls `/get-stock-card`)
- [x] Create `routes/dashboard/reports/inventory-list/+page.svelte`
  - [x] Unit multiselect + withCost toggle → table (calls `/get-inventory-list`)
- [x] Create `routes/dashboard/reports/sales/+page.svelte`
  - [x] Date range + unit list filter → table (calls `/get-sales-report`)
- [x] Create `routes/dashboard/reports/deliveries/+page.svelte`
  - [x] Date range + unit list + withCost → table (calls `/get-deliveries-report`)
- [x] Create `routes/dashboard/reports/client-ledger/+page.svelte`
  - [x] Client + date range → table (calls `/get-client-ledger`)
- [x] Create `routes/dashboard/reports/expiries/+page.svelte`
  - [x] Unit multiselect → table (calls `/get-expiries-and-past-due`)

---

## Phase 14 — Polish & QA

- [x] Add `svelte-sonner` `<Toaster />` to root layout
- [x] Add loading skeletons to all table pages
- [x] Add empty state messages for zero-data tables
- [x] Add form validation (required fields, number ranges)
- [x] Verify `serviceConfig.ts` toggle works for both `local` and `live`
- [x] Test all POST endpoints (add / edit / delete) end-to-end
- [x] Verify sidebar active state highlights current route
- [x] Verify dark mode tokens apply correctly (if dark mode toggle added)
- [x] Code review: no hardcoded URLs anywhere outside `serviceConfig.ts`
- [x] Final `npm run build` — no TypeScript errors

---

## Phase 15 — Documentation

- [x] Update `inventory-ui-progress.md` to `100%` on all modules
- [x] Add env setup instructions to `README.md`
- [x] Document `serviceConfig.ts` toggle in README
