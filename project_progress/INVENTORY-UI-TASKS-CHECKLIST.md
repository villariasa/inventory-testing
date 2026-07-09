# INVENTORY UI — TASKS CHECKLIST

Apply a SvelteKit UI to the completed `inventory/` Hono backend service.
Source of truth: `project_specs/INVENTORY-MIGRATION.md`, `project_specs/CODING_CONVENTION_TECHSTACK.md`, and `UI-studio-membership/` (SvelteKit reference).

- Frontend: SvelteKit 2 + Svelte 5, Tailwind v4, bits-ui v2 (port 3002)
- Backend: Hono `OpenAPIHono`, all routes POST-only under base path `/inv/v1` (port 3000)
- Service proxy pattern: UI `/service/...` → backend `/inv/v1/...` via `invokeService.ts`
- Reference quirk: UI-studio-membership proxies target `/api_v1`; inventory MUST target `/inv/v1`
- POST-only endpoints; send `{}` body when no params
- 49 endpoints across 11 functional domains

---

## Phase 0 — Foundation / Scaffolding

- [ ] Create SvelteKit project (`package.json`, `svelte.config.js`, `vite.config.ts`, `tsconfig.json`)
- [ ] Configure Tailwind v4 (`@tailwindcss/vite`, `@tailwindcss/forms`, `app.css`)
- [ ] Copy reference shell: `app.html`, `app.d.ts`, `hooks.server.ts`
- [ ] Port `lib/components/ui/*` primitives from UI-studio-membership (button, card, input, label, table, dialog, dropdown-menu, sheet, sidebar, separator, skeleton, spinner, tooltip, navigation-menu, avatar, textarea, input-group)
- [ ] Create `lib/utils.ts`, `lib/store/user.ts`, `lib/types/index.ts`
- [ ] Create `routes/service/invokeService.ts` (generic POST fetch → `/inv/v1/...`)
- [ ] `.env` (BACKEND base URL → `/inv/v1`, FRONTEND_PORT=3002)
- [ ] Root `+layout.svelte`, dashboard shell (`+layout.server.ts`, sidenav, header)

## Phase 1 — Pages (grouped by domain)

### Common & Dropdowns (shared selectors / lookups)
- [ ] service proxy + UI selectors: getUnitName (`/get-unit-name`)
- [ ] service proxy + UI selectors: getUserUnit (`/get-user-unit`)
- [ ] service proxy + UI selectors: getUserUnitArray (`/get-user-unit-array`)
- [ ] service proxy + UI selectors: getUserDesignatedUnit (`/get-user-designated-unit`)
- [ ] service proxy + UI selectors: getAdjustmentUserUnit (`/get-adjustment-user-unit`)

### Item Category page
- [ ] List/grid: getInventoryItemCategory (`/get-inventory-item-category`)
- [ ] Create/edit/delete form: postInventoryItemCategory (`/post-inventory-item-category`)

### Item page
- [ ] List/grid: getInventoryItem (`/get-inventory-item`)
- [ ] No-unit list: getInventoryItemNoUnit (`/get-inventory-item-no-unit`)
- [ ] Image viewer: getItemImage (`/get-item-image`)
- [ ] Empty-bin selector: getEmptyUnitBin (`/get-empty-unit-bin`)
- [ ] Create/edit form: postInventoryItem (`/post-inventory-item`)
- [ ] Assign-to-units dialog: postItemToUnits (`/post-item-to-units`)

### Unit Bin page
- [ ] List/grid: getInventoryUnitBin (`/get-inventory-unit-bin`)
- [ ] Bin selector (except one): getUnitBinExceptOne (`/get-unit-bin-except-one`)

### Units page
- [ ] List/grid: getInventoryUnit (`/get-inventory-unit`)
- [ ] Detail/lookup: getUnit (`/get-unit`)
- [ ] Create/edit form: postInventoryUnit (`/post-inventory-unit`)

### Unit Items page
- [ ] List/grid: getInventoryUnitItem (`/get-inventory-unit-item`)
- [ ] Bin-contents view: getUnitItemInfoByBin (`/get-unit-item-info-by-bin`)
- [ ] Bin-switch dialog: postUnitItemBinSwitch (`/post-unit-item-bin-switch`)

### Adjustment page
- [ ] Item picker: getItemForAdjustment (`/get-item-for-adjustment`)
- [ ] List/grid: getInventoryItemAdjustment (`/get-inventory-item-adjustment`)
- [ ] Template list: getInventoryItemAdjustmentTemplate (`/get-inventory-item-adjustment-template`)
- [ ] Create adjustment form: postInventoryItemAdjustment (`/post-inventory-item-adjustment`)
- [ ] Template create/edit form: postInventoryItemAdjustmentTemplate (`/post-inventory-item-adjustment-template`)

### Item Imports page
- [ ] Import list: getItemImportList (`/get-item-import-list`)
- [ ] Imports lookup: getItemImports (`/get-item-imports`)
- [ ] Import items list: getImportItems (`/get-import-items`)
- [ ] Create/edit form: postItemImports (`/post-item-imports`)

### In-Transit page
- [ ] In-transit report: getInstransitReport (`/get-instransit-report`)
- [ ] In-transit report (v2): getInTransitReport (`/get-in-transit-report`)
- [ ] Invoices list: getInTransitItemsInvoices (`/get-in-transit-items-invoices`)
- [ ] Confirm-receipt form: postConfirmInTransitItems (`/post-confirm-in-transit-items`)

### Reports page (filters + tabular output)
- [ ] Purchases: getPurchasesReport (`/get-purchases-report`)
- [ ] Client name lookup: getClientName (`/get-client-name`)
- [ ] Internal stock movements: getInternalStocksMovementsReport (`/get-internal-stocks-movements-report`)
- [ ] Deliveries: getDeliveriesReport (`/get-deliveries-report`)
- [ ] Sales/receivables/collections: getSalesReceivablesCollectionsJSON (`/get-sales-receivables-collections`)
- [ ] Sales: getSalesReport (`/get-sales-report`)
- [ ] Client ledger: getClientLedger (`/get-client-ledger`)
- [ ] Expiries & past due: getExpiriesAndPastDue (`/get-expiries-and-past-due`)
- [ ] Stock card: getJSONStockCard (`/get-stock-card`)
- [ ] Inventory list: getInventoryList (`/get-inventory-list`)
- [ ] Payables & supplier transactions: getJSONPayablesAndTransactionsWithSuppliers (`/get-payables-and-transactions-with-suppliers`)
- [ ] Payables to suppliers: getPayablesToSuppliersJSON (`/get-payables-to-suppliers`)
- [ ] Customer inactivity: getCustomerInactivity (`/get-customer-inactivity`)

### Cross / Misc
- [ ] Employee name lookup: getEmployeeName (`/get-employee-name`)
- [ ] Notifications: getNotification (`/get-notification`)

## Phase 2 — Verification

- [ ] ESLint all TypeScript/Svelte (0 errors)
- [ ] Each page renders backend data via `/service/...` → `/inv/v1/...` proxy
- [ ] Forms post correct payloads (honor source quirks: `quanttiy_confirmed`, `charUnitList`, `dateFrom`/`dateTo`)
- [ ] Responsive layout + dashboard nav across all pages
