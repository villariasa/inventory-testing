# INVENTORY MIGRATION — TRACKER

Spec refs: `project_specs/INVENTORY-MIGRATION.md`, `project_specs/CODING_CONVENTION_TECHSTACK.md`

## Status

- Migration plan created and grouped by endpoint domain (see `INVENTORY-TASKS-CHECKLIST.md`).
- Scope confirmed: ALL stored procedures in `udf_and_views_inventory` (not limited to `get*`).
- Databases in use: `inventory`, `udf_and_views_inventory`, `inventory_udf_and_views`.
- No DB schema modifications; only mandatory SP response-format mods in `udf_and_views_inventory`.
- Live DB re-checked: `udf_and_views_inventory` now has 50 SPs (41 get* + 9 new post*).
- Envelope compliance: all 9 post* SPs return the `{ success, message, json_data }` envelope.
  - `postInventoryItemAdjustment` is a transactional wrapper that delegates to
    `inventory_udf_and_views.postInternalItemAdjustment(jsn, @response)` and SELECTs `@response`;
    the inner SP builds the compliant envelope into OUT `jsnResponse`. Confirmed compliant.

## Completed Tasks

- Migration plan APPROVED by user ("yes pls proceed").
- Task checklist scope corrected to include ALL procedures in `udf_and_views_inventory`.
- Phase 0: `package.json` created (mirrors accounting CommonJS setup).
- Phase 0: `.env` created (DB + service ports).
- Phase 0: `src/inv_v1/lib/errorlogger.ts` created (verbatim from accounting).
- Phase 0: `src/inv_v1/lib/dbconn.ts` created (verbatim from accounting).
- Phase 0: `src/inv_v1/lib/database-factory.ts` created (verbatim from accounting).
- Phase 0: `src/inv_v1/utils/spEnvelope.ts` helper created (spec-compliant).
- Phase 0: `src/index.ts` created (OpenAPIHono wiring, `/doc`, `/swagger`, serve, graceful shutdown).
- Phase 0: `tsconfig.json` + `eslint.config.js` verified present (no overwrite).
- **Phase 0 COMPLETE.**
- Phase 1 (Common / Dropdown group) — 6 files created + mounted under `/inv/v1`:
  - `interfaces/common.interface.ts` (5 request interfaces).
  - `schemas/common.schema.ts` (5 request schemas + SP envelope + standard response).
  - `queries/common.query.ts` (5 SP CALL builders).
  - `handlers/common.handler.ts` (5 single-exit-point read handlers).
  - `routes/common.route.ts` (`commonRoute` + 5 createRoute POSTs).
  - `index.ts` mounts `commonRoute` under `/inv/v1`.
  - Endpoints: getUnitName, getUserUnit, getUserUnitArray, getUserDesignatedUnit, getAdjustmentUserUnit.
- **Phase 1 — Common / Dropdown group COMPLETE.**
- Phase 1 (Item Category group) — 5 files created + mounted under `/inv/v1`:
  - `interfaces/itemCategory.interface.ts` (2 request interfaces).
  - `schemas/itemCategory.schema.ts` (2 request schemas; re-uses `StandardResponseSchema`).
  - `queries/itemCategory.query.ts` (2 SP CALL builders).
  - `handlers/itemCategory.handler.ts` (get read handler + post mutation handler).
  - `routes/itemCategory.route.ts` (`itemCategoryRoute` + 2 createRoute POSTs).
  - `index.ts` mounts `itemCategoryRoute` under `/inv/v1`.
  - Endpoints: getInventoryItemCategory, postInventoryItemCategory.
- **Phase 1 — Item Category group COMPLETE.**
- Phase 1 (Item group) — 5 files created + mounted under `/inv/v1`:
  - `interfaces/item.interface.ts` (6 request interfaces + 1 helper).
  - `schemas/item.schema.ts` (6 request schemas; re-uses `StandardResponseSchema`).
  - `queries/item.query.ts` (6 SP CALL builders).
  - `handlers/item.handler.ts` (4 get read handlers + 2 post mutation handlers).
  - `routes/item.route.ts` (`itemRoute` + 6 createRoute POSTs).
  - `index.ts` mounts `itemRoute` under `/inv/v1`.
  - Endpoints: getInventoryItem, getInventoryItemNoUnit, getItemImage, getEmptyUnitBin, postInventoryItem, postItemToUnits.
  - All 6 SPs verified envelope-compliant (no SP mods needed).
- **Phase 1 — Item group COMPLETE.**
- Phase 1 (Unit Bin group) — 5 files created + mounted under `/inv/v1`:
  - `interfaces/unitBin.interface.ts` (2 request interfaces).
  - `schemas/unitBin.schema.ts` (2 request schemas; re-uses `StandardResponseSchema`).
  - `queries/unitBin.query.ts` (2 SP CALL builders).
  - `handlers/unitBin.handler.ts` (2 single-exit-point read handlers).
  - `routes/unitBin.route.ts` (`unitBinRoute` + 2 createRoute POSTs).
  - `index.ts` mounts `unitBinRoute` under `/inv/v1`.
  - Endpoints: getInventoryUnitBin, getUnitBinExceptOne.
  - Both SPs verified envelope-compliant (no SP mods needed).
- **Phase 1 — Unit Bin group COMPLETE.**
- Phase 1 (Units group) — 5 files created + mounted under `/inv/v1`:
  - `interfaces/units.interface.ts` (3 request interfaces).
  - `schemas/units.schema.ts` (3 request schemas; re-uses `StandardResponseSchema`).
  - `queries/units.query.ts` (3 SP CALL builders).
  - `handlers/units.handler.ts` (2 get read handlers + 1 post mutation handler).
  - `routes/units.route.ts` (`unitsRoute` + 3 createRoute POSTs).
  - `index.ts` mounts `unitsRoute` under `/inv/v1`.
  - Endpoints: getInventoryUnit, getUnit, postInventoryUnit.
  - All 3 SPs verified envelope-compliant (no SP mods needed).
- **Phase 1 — Units group COMPLETE.**
- Phase 1 (Unit Items group) — 5 files created + mounted under `/inv/v1`:
  - `interfaces/unitItem.interface.ts` (4 request interfaces incl. SwappedItem helper).
  - `schemas/unitItem.schema.ts` (3 request schemas; re-uses `StandardResponseSchema`).
  - `queries/unitItem.query.ts` (3 SP CALL builders).
  - `handlers/unitItem.handler.ts` (2 get read handlers + 1 post mutation handler).
  - `routes/unitItem.route.ts` (`unitItemRoute` + 3 createRoute POSTs).
  - `index.ts` mounts `unitItemRoute` under `/inv/v1`.
  - Endpoints: getInventoryUnitItem, getUnitItemInfoByBin, postUnitItemBinSwitch.
  - All 3 SPs verified envelope-compliant (no SP mods needed).
- **Phase 1 — Unit Items group COMPLETE.**
- Phase 1 (Adjustment group) — 5 files created + mounted under `/inv/v1`:
  - `interfaces/adjustment.interface.ts` (5 request interfaces).
  - `schemas/adjustment.schema.ts` (5 request schemas; re-uses `StandardResponseSchema`).
  - `queries/adjustment.query.ts` (5 SP CALL builders).
  - `handlers/adjustment.handler.ts` (3 get read handlers + 2 post mutation handlers).
  - `routes/adjustment.route.ts` (`adjustmentRoute` + 5 createRoute POSTs).
  - `index.ts` mounts `adjustmentRoute` under `/inv/v1`.
  - Endpoints: getItemForAdjustment, getInventoryItemAdjustment, getInventoryItemAdjustmentTemplate, postInventoryItemAdjustment, postInventoryItemAdjustmentTemplate.
  - All 5 SPs verified envelope-compliant (no SP mods needed). `postInventoryItemAdjustment` is a transactional wrapper delegating to `inventory_udf_and_views.postInternalItemAdjustment`.
- **Phase 1 — Adjustment group COMPLETE.**
- Phase 1 (Item Imports group) — 5 files created + mounted under `/inv/v1`:
  - `interfaces/itemImports.interface.ts` (4 request interfaces).
  - `schemas/itemImports.schema.ts` (4 request schemas; re-uses `StandardResponseSchema`).
  - `queries/itemImports.query.ts` (4 SP CALL builders).
  - `handlers/itemImports.handler.ts` (3 get read handlers + 1 post mutation handler).
  - `routes/itemImports.route.ts` (`itemImportsRoute` + 4 createRoute POSTs).
  - `index.ts` mounts `itemImportsRoute` under `/inv/v1` (line 23).
  - Endpoints: getItemImportList, getItemImports, getImportItems, postItemImports.
  - All 4 SPs verified envelope-compliant (no SP mods needed). `postItemImports` is transactional.
- **Phase 1 — Item Imports group COMPLETE.**
- Phase 1 (In-Transit group) — 5 files created + mounted under `/inv/v1`:
  - `interfaces/inTransit.interface.ts` (4 request interfaces + 1 helper).
  - `schemas/inTransit.schema.ts` (4 request schemas; re-uses `StandardResponseSchema`).
  - `queries/inTransit.query.ts` (4 SP CALL builders).
  - `handlers/inTransit.handler.ts` (3 get read handlers + 1 post mutation handler).
  - `routes/inTransit.route.ts` (`inTransitRoute` + 4 createRoute POSTs).
  - `index.ts` mounts `inTransitRoute` under `/inv/v1` (line 25).
  - Endpoints: getInstransitReport, getInTransitReport, getInTransitItemsInvoices, postConfirmInTransitItems.
  - All 4 SPs verified envelope-compliant (no SP mods needed). `postConfirmInTransitItems` is transactional; mirrors source key `quanttiy_confirmed` (misspelling preserved).
- **Phase 1 — In-Transit group COMPLETE.**
- Phase 1 (Reports group) — 5 files created + mounted under `/inv/v1`:
  - `interfaces/reports.interface.ts` (13 request interfaces).
  - `schemas/reports.schema.ts` (13 request schemas; re-uses `StandardResponseSchema`).
  - `queries/reports.query.ts` (13 SP CALL builders).
  - `handlers/reports.handler.ts` (13 single-exit-point read handlers).
  - `routes/reports.route.ts` (`reportsRoute` + 13 createRoute POSTs).
  - `index.ts` mounts `reportsRoute` under `/inv/v1` (line 27).
  - Endpoints: getPurchasesReport, getClientName, getInternalStocksMovementsReport, getDeliveriesReport, getSalesReceivablesCollectionsJSON, getSalesReport, getClientLedger, getExpiriesAndPastDue, getJSONStockCard, getInventoryList, getJSONPayablesAndTransactionsWithSuppliers, getPayablesToSuppliersJSON, getCustomerInactivity.
  - All 13 SPs verified envelope-compliant (no SP mods needed). Input-key quirks honored (charUnitList vs units; dateFrom/dateTo; client_id/supplier_id/entity_id; single `date`).
- **Phase 1 — Reports group COMPLETE.**
- Phase 1 (Cross / Misc group) — 5 files created + mounted under `/inv/v1`:
  - `interfaces/crossMisc.interface.ts` (2 request interfaces).
  - `schemas/crossMisc.schema.ts` (2 request schemas; re-uses `StandardResponseSchema`).
  - `queries/crossMisc.query.ts` (2 SP CALL builders).
  - `handlers/crossMisc.handler.ts` (2 single-exit-point read handlers).
  - `routes/crossMisc.route.ts` (`crossMiscRoute` + 2 createRoute POSTs).
  - `index.ts` mounts `crossMiscRoute` under `/inv/v1` (line 29).
  - Endpoints: getEmployeeName, getNotification.
  - Both SPs verified envelope-compliant (no SP mods needed). `getNotification` takes no SP param (empty-body endpoint).
- **Phase 1 — Cross / Misc group COMPLETE.**
- **PHASE 1 COMPLETE — all endpoint groups migrated.**

- **Phase 2 — ESLint COMPLETE**: ran `node node_modules/eslint/bin/eslint.js "src/**/*.ts"` → 0 errors, 5 warnings. All 5 warnings are `@typescript-eslint/no-explicit-any` confined to verbatim DO-NOT-MODIFY lib files (`database-factory.ts` 126:59/126:72, `dbconn.ts` 116:17/257:20, `errorlogger.ts` 126:29). All migrated code (handlers/routes/queries/schemas/interfaces) is a clean pass.

## Next Task

- **Phase 2 — Verification**:
  - ESLint all TypeScript code.
  - OpenAPI/Swagger jsondef per endpoint in `src/jsondef`.
  - Integration tests with sample data queried from actual DB tables.
  - Confirm SP response-format compliance in `udf_and_views_inventory`.
