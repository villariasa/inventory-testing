# INVENTORY MIGRATION — TASKS CHECKLIST

Migration of inventory back-end endpoints from C# (`inventory_service`) to TypeScript/HONO.
Source of truth: `project_specs/INVENTORY-MIGRATION.md`, `project_specs/CODING_CONVENTION_TECHSTACK.md`.

- Databases: `inventory`, `udf_and_views_inventory`
- Scope: ALL stored procedures in `udf_and_views_inventory` (not limited to `get*`)
- NO DB schema modifications. Only mandatory SP response-format mods in `udf_and_views_inventory`.
- Standard service response: `{ success, http_code, message, data }`
- SP envelope: `{ success, message, json_data }`

---

## Phase 0 — Foundation / Scaffolding

- [x] Create `package.json` (CommonJS, mirror accounting reference)
- [x] Create `.env` (DB_HOST=192.168.4.141, DB_PORT=3306, DB_USER=developer, DB_PASSWORD=dev10180, DB_NAME=mysql, BACKEND_PORT=3000, FRONTEND_PORT=3002)
- [x] Copy `src/inv_v1/lib/dbconn.ts` VERBATIM from accounting (DO NOT MODIFY)
- [x] Copy `src/inv_v1/lib/errorlogger.ts` VERBATIM from accounting (DO NOT MODIFY)
- [x] Copy `src/inv_v1/lib/database-factory.ts` VERBATIM from accounting (DO NOT MODIFY)
- [x] Create `src/inv_v1/utils/spEnvelope.ts` (parseSpEnvelope per spec)
- [x] Create new `src/index.ts` (OpenAPIHono wiring, `/doc`, `/swagger`, serve)
- [x] Verify tsconfig.json + eslint.config.js (already present — no overwrite)

## Phase 1 — Endpoints (grouped by domain)

### Common / Dropdown
- [x] getUnitName
- [x] getUserUnit
- [x] getUserUnitArray
- [x] getUserDesignatedUnit
- [x] getAdjustmentUserUnit

### Item Category
- [x] getInventoryItemCategory
- [x] postInventoryItemCategory

### Item
- [x] getInventoryItem
- [x] getInventoryItemNoUnit
- [x] getItemImage
- [x] getEmptyUnitBin
- [x] postInventoryItem
- [x] postItemToUnits

### Unit Bin
- [x] getInventoryUnitBin
- [x] getUnitBinExceptOne

### Units
- [x] getInventoryUnit
- [x] getUnit
- [x] postInventoryUnit

### Unit Items
- [x] getInventoryUnitItem
- [x] getUnitItemInfoByBin
- [x] postUnitItemBinSwitch

### Adjustment
- [x] getItemForAdjustment
- [x] getInventoryItemAdjustment
- [x] getInventoryItemAdjustmentTemplate
- [x] postInventoryItemAdjustment
- [x] postInventoryItemAdjustmentTemplate

### Item Imports
- [x] getItemImportList
- [x] getItemImports
- [x] getImportItems
- [x] postItemImports

### In-Transit
- [x] getInstransitReport
- [x] getInTransitReport
- [x] getInTransitItemsInvoices
- [x] postConfirmInTransitItems

### Reports
- [x] getPurchasesReport
- [x] getClientName
- [x] getInternalStocksMovementsReport
- [x] getDeliveriesReport
- [x] getSalesReceivablesCollectionsJSON
- [x] getSalesReport
- [x] getClientLedger
- [x] getExpiriesAndPastDue
- [x] getJSONStockCard
- [x] getInventoryList
- [x] getJSONPayablesAndTransactionsWithSuppliers
- [x] getPayablesToSuppliersJSON
- [x] getCustomerInactivity

### Cross / Misc
- [x] getEmployeeName
- [x] getNotification

## Phase 2 — Verification

- [x] ESLint all TypeScript code (0 errors; 5 warnings only in verbatim DO-NOT-MODIFY lib files)
- [x] OpenAPI/Swagger jsondef per endpoint in `src/jsondef` (all 11 domain jsondef files present)
- [ ] Integration tests with sample data queried from actual DB tables
- [ ] Confirm SP response-format compliance in `udf_and_views_inventory`
