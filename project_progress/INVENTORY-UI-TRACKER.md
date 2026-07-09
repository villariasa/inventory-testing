# INVENTORY UI — TRACKER

Spec refs: project_progress/INVENTORY-UI-TASKS-CHECKLIST.md, project_progress/INVENTORY-UI-THEME-STYLE.md

## Status
- Frontend stack: SvelteKit 2 + Svelte 5 (runes) + Tailwind CSS v4, modeled on `UI-studio-membership/` reference.
- Theme: indigo primary (#4F46E5) / teal accent (#0891B2), Inter font, light + dark via `.dark` class + localStorage no-flash.
- Service layer: UI `/service/<domain>/<action>/+server.ts` proxies → backend `http://localhost:3000/inv/v1/...` (all POST, StandardResponse envelope).
- Scope of THIS increment: Phase 0 scaffolding → Item Category page only. STOP for user testing after.

## Completed Tasks
- **Phase 0 — Scaffold:** SvelteKit project, Tailwind v4 theme entry (indigo/teal, light+dark no-flash), ported UI primitives (card/table/dialog/button/input/label/textarea), `cn` util, `invokeService.ts`, root layout + sidenav adapted to inventory domains, `.env`, `hooks.server.ts` → `locals.user`.
- **Phase 1 — Item Category page:** list (getInventoryItemCategory) + create/edit/delete modal form (postInventoryItemCategory, process_type 0/1/2). Columns: Category / Charge Account / Action. Delete gated on `predefined === 0`. View/Edit/Save via `use:enhance`; readonly description when `predefined === 1`.
- Service proxies: `service/item-category/get-inventory-item-category` + `service/item-category/post-inventory-item-category`.
- **Phase 2 — Items page:** `routes/items` (+page.server.ts already wired, +page.svelte rebuilt with enhanced, non-default styling).
  - **List table (8 cols):** Image thumbnail (size-10 / lucide:image placeholder), Item (model_description + units subtitle), Category (teal badge), Brand, Mark-Up %, Selling Price (₱ formatted), Qty, Action (View/Edit/Delete). Gradient indigo card header (lucide:package), item count, search box, "Add Item"; hover row highlight; styled empty state.
  - **Modal (Add/View/Edit):** large sectioned dialog with gradient header — Classification (searchable comboboxes: Category, Brand, Size, Part Description, Part Number + model_description), Units (stocking_unit / retail_unit / rtu_over_stu), Pricing (WAC vs Fixed pill toggle → conditional wtd_ave_cost / fixed_price, mark_up_rate, selling_price, last_highest_cost), Image (click / paste / drag dropzone, preview + Remove), Assembly checkbox (has_empty_case). Sticky footer Cancel/Save; Save hidden in View.
  - **Delete dialog** via process_type 2.
  - **Data:** load returns items/categories/brands/sizes/parts/partNumbers; imports via `get-item-imports` (`brand`, `size`, `vehiclePart`, `vehiclePartNumber`). Save action posts process_type 0/1/2 with user_id.

## STOPPED — Awaiting User Testing
- Run dev server (port 3002), navigate to `/items` to verify list table + modal (Add/View/Edit/Delete), searchable dropdowns, pricing toggle, and image upload.

## Next Task (pending user confirmation)
- Continue remaining pages: Unit Bins, Units, Unit Items, Adjustments, Item Imports, In-Transit, Reports.
