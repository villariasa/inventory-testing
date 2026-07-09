# Inventory UI — Detailed Implementation Plan

> **Scope:** A standalone SvelteKit app (`inventory-svelte-ui`) that reuses the design system, UI components, and theme from `UI-studio-membership/src` but is deployed separately with its own routes and service layer connecting to the Inventory Hono API backend.

---

## 1. Project Overview

| Attribute | Value |
|---|---|
| Framework | SvelteKit (Vite) |
| Language | TypeScript |
| Styling | TailwindCSS v4 (same `layout.css` token system) |
| UI Library | `bits-ui` + Iconify (same as membership) |
| Fonts | Nunito Sans (body) + Playfair Display (headings) |
| Backend | Hono API at `/inv/v1/...` (already built) |
| Auth | `SessionAuth` header token passed on every service call |
| Service Config | Single root file `src/lib/config/serviceConfig.ts` — toggle local/live URL here |

---

## 2. Service Configuration (Single Root File)

> [!IMPORTANT]
> **This is the ONLY file you need to touch to switch between local dev and live/production API.**

### `src/lib/config/serviceConfig.ts`

```ts
// ============================================================
//  SERVICE CONFIG — CHANGE THIS FILE TO SWITCH ENVIRONMENTS
// ============================================================

const ENV: 'local' | 'live' = 'local';   // <-- toggle here

const BASE_URLS = {
  local: 'http://localhost:3002',          // inventory/.env FRONTEND_PORT
  live:  'https://api.yourdomain.com'     // production URL
};

export const BASE_URL = BASE_URLS[ENV];

// All API route prefixes
export const INV_API = `${BASE_URL}/inv/v1`;

// Convenience endpoint builder
export function endpoint(path: string): string {
  return `${INV_API}${path}`;
}
```

### How it flows into `invokeService.ts` (reused from membership):

```ts
// src/lib/service/invokeService.ts  — identical to membership pattern
import { BASE_URL } from '$lib/config/serviceConfig';

export async function invokeService<TBody = unknown, TResponse = unknown>(
  path: string,
  options: ApiOptions<TBody> = {}
): Promise<{ data: TResponse; accessToken?: string } | { error: string; raw: string }> {
  const url = `${BASE_URL}${path}`;
  const res = await fetch(url, {
    method: options.method ?? 'POST',
    headers: {
      'Content-Type': 'application/json',
      'SessionAuth': options.token ?? '',
      ...(options.headers ?? {})
    },
    body: options.body ? JSON.stringify(options.body) : undefined
  });
  // ... same response parsing as membership
}
```

---

## 3. Full API Endpoint Map

All routes use `POST` and live under `/inv/v1/`. The UI service layer will call these directly via `invokeService`.

### 3.1 Common & Dropdowns

| Route | Path | Purpose |
|---|---|---|
| Get Unit Name | `/get-unit-name` | Dropdown: unit name by `unit_id` |
| Get User Unit | `/get-user-unit` | Units assigned to a user |
| Get User Unit Array | `/get-user-unit-array` | Array of units for a user |
| Get User Designated Unit | `/get-user-designated-unit` | Designated unit(s) |
| Get Adjustment User Unit | `/get-adjustment-user-unit` | Units for adjustment context |
| Get Selectable Accounts | `/get-selectable-accounts` | GL/SL accounts for dropdown |

### 3.2 Item Management

| Route | Path | Purpose |
|---|---|---|
| Get Inventory Item | `/get-inventory-item` | List / detail items |
| Get Item No Unit | `/get-inventory-item-no-unit` | Items not yet assigned to a unit |
| Get Item Image | `/get-item-image` | Fetch item image by `item_id` |
| Get Empty Unit Bin | `/get-empty-unit-bin` | Available bins per unit |
| Post Inventory Item | `/post-inventory-item` | Create / Update / Delete item |
| Post Item To Units | `/post-item-to-units` | Assign item to unit(s) + bin |

### 3.3 Item Categories

| Route | Path | Purpose |
|---|---|---|
| Get Item Category | `/get-item-category` | List categories |
| Post Item Category | `/post-item-category` | Create / Update / Delete category |

### 3.4 Unit Bins

| Route | Path | Purpose |
|---|---|---|
| Get Unit Bin | `/get-unit-bin` | Get bins per unit |
| Post Unit Bin | `/post-unit-bin` | Create / Update / Delete bin |

### 3.5 Units

| Route | Path | Purpose |
|---|---|---|
| Get Inventory Unit | `/get-inventory-unit` | List all inventory units |
| Get Unit | `/get-unit` | Get a single unit |
| Post Inventory Unit | `/post-inventory-unit` | Update unit config |

### 3.6 Unit Item

| Route | Path | Purpose |
|---|---|---|
| Get Unit Item | `/get-unit-item` | Items within a unit |
| Get Unit Item History | `/get-unit-item-history` | Movement history |
| Post Unit Item | `/post-unit-item` | Modify unit-item relationship |

### 3.7 Adjustment

| Route | Path | Purpose |
|---|---|---|
| Get Item For Adjustment | `/get-item-for-adjustment` | Items eligible for adjustment |
| Get Item Adjustment | `/get-inventory-item-adjustment` | Adjustment list / detail |
| Get Adjustment Template | `/get-inventory-item-adjustment-template` | Templates |
| Post Adjustment | `/post-inventory-item-adjustment` | Submit adjustment |
| Post Adjustment Template | `/post-inventory-item-adjustment-template` | CRUD template |

### 3.8 Item Imports

| Route | Path | Purpose |
|---|---|---|
| Get Import Items | `/get-import-items` | Pending imports |
| Post Import Items | `/post-import-items` | Confirm import batch |

### 3.9 In-Transit

| Route | Path | Purpose |
|---|---|---|
| Get In-Transit Report (v1) | `/get-instransit-report` | Search-based transit report |
| Get In-Transit Report (v2) | `/get-in-transit-report` | Full transit report |
| Get In-Transit Invoices | `/get-in-transit-items-invoices` | Invoices for transit items |
| Post Confirm In-Transit | `/post-confirm-in-transit-items` | Confirm received quantities |

### 3.10 Reports

| Route | Path | Purpose |
|---|---|---|
| Purchases Report | `/get-purchases-report` | Purchases by date/client |
| Client Name | `/get-client-name` | Client name lookup |
| Internal Stocks Movements | `/get-internal-stocks-movements-report` | Internal transfer movements |
| Deliveries Report | `/get-deliveries-report` | Delivery summary |
| Sales Receivables Collections | `/get-sales-receivables-collections` | AR + collections |
| Sales Report | `/get-sales-report` | Sales by unit/date |
| Client Ledger | `/get-client-ledger` | Client-specific ledger |
| Expiries & Past Due | `/get-expiries-and-past-due` | Expiry tracking |
| Stock Card | `/get-stock-card` | Per-unit stock card |
| Inventory List | `/get-inventory-list` | Full inventory listing |
| Payables & Transactions | `/get-payables-and-transactions-with-suppliers` | AP + supplier transactions |
| Payables to Suppliers | `/get-payables-to-suppliers` | Outstanding payables |
| Customer Inactivity | `/get-customer-inactivity` | Inactive customer report |

### 3.11 Cross / Misc

| Route | Path | Purpose |
|---|---|---|
| Cross-module misc | `/cross-misc/...` | Shared utility endpoints |

---

## 4. Folder Structure — `inventory-svelte-ui`

```
inventory-svelte-ui/
├── src/
│   ├── app.html
│   ├── app.css                          ← copy from membership (fonts)
│   ├── lib/
│   │   ├── config/
│   │   │   └── serviceConfig.ts         ← 🔑 ROOT TOGGLE FILE (local vs live)
│   │   ├── service/
│   │   │   └── invokeService.ts         ← reused from membership
│   │   ├── types/
│   │   │   └── index.ts                 ← inventory-specific types
│   │   ├── stores/
│   │   │   └── user.ts                  ← writable<User> (same as membership)
│   │   └── components/
│   │       ├── ui/                      ← REUSED: all bits-ui wrappers from membership
│   │       │   ├── dashboard_header.svelte
│   │       │   ├── dashboard_sidenav.svelte
│   │       │   ├── dashboard_main.svelte
│   │       │   ├── button/
│   │       │   ├── card/
│   │       │   ├── table/
│   │       │   ├── dialog/
│   │       │   ├── input/
│   │       │   ├── input-group/
│   │       │   ├── dropdown-menu/
│   │       │   ├── label/
│   │       │   ├── skeleton/
│   │       │   ├── spinner/
│   │       │   ├── tooltip/
│   │       │   ├── avatar/
│   │       │   └── ...                  ← all others unchanged
│   │       └── inventory/               ← NEW: inventory-specific components
│   │           ├── ItemTable.svelte
│   │           ├── ItemFormDialog.svelte
│   │           ├── AdjustmentFormDialog.svelte
│   │           ├── ReportFilterBar.svelte
│   │           ├── ReportTable.svelte
│   │           └── StatusBadge.svelte
│   └── routes/
│       ├── +layout.svelte               ← dashboard layout (sidenav + header)
│       ├── layout.css                   ← REUSED: exact copy from membership
│       ├── +page.svelte                 ← redirect to /dashboard
│       ├── login/
│       │   └── +page.svelte
│       └── dashboard/
│           ├── +layout.svelte
│           ├── +layout.server.ts        ← session guard
│           ├── +page.svelte             ← Dashboard: KPI cards
│           ├── items/
│           │   ├── +page.svelte         ← Item list + CRUD
│           │   └── +page.server.ts
│           ├── categories/
│           │   ├── +page.svelte         ← Category management
│           │   └── +page.server.ts
│           ├── units/
│           │   ├── +page.svelte         ← Inventory Units management
│           │   └── +page.server.ts
│           ├── unit-items/
│           │   ├── +page.svelte         ← Items per unit view
│           │   └── +page.server.ts
│           ├── adjustments/
│           │   ├── +page.svelte         ← Adjustment list + form
│           │   └── +page.server.ts
│           ├── adjustment-templates/
│           │   ├── +page.svelte         ← Templates CRUD
│           │   └── +page.server.ts
│           ├── in-transit/
│           │   ├── +page.svelte         ← In-transit invoices + confirm
│           │   └── +page.server.ts
│           └── reports/
│               ├── +page.svelte         ← Report selector/hub
│               ├── purchases/
│               │   └── +page.svelte
│               ├── stock-card/
│               │   └── +page.svelte
│               ├── inventory-list/
│               │   └── +page.svelte
│               ├── sales/
│               │   └── +page.svelte
│               ├── deliveries/
│               │   └── +page.svelte
│               ├── client-ledger/
│               │   └── +page.svelte
│               └── expiries/
│                   └── +page.svelte
├── static/
│   └── images/
├── package.json
├── svelte.config.js
├── tsconfig.json
└── vite.config.ts
```

---

## 5. Theme & Design Tokens (Reused)

Copy `layout.css` verbatim from the membership project. The following CSS custom properties are the full design system:

### Color Palette (Light Mode)

| Token | Value | Usage |
|---|---|---|
| `--teal-dark` | `#226c64` | Primary, sidebar background |
| `--green-muted` | `#558B71` | Muted accents |
| `--green-soft` | `#7FCFA8` | Secondary |
| `--mint-light` | `#98FBCB` | Accent, highlights |
| `--background` | `#F5F5F5` | Page background |
| `--card` | `#FFFFFF` | Card surfaces |
| `--destructive` | `#ef4444` | Delete / error |
| `--border` | `#E5E7EB` | Borders |

### Typography

| Family | Font | Usage |
|---|---|---|
| Body | Nunito Sans (300–900) | All body text |
| Headings | Playfair Display (400–900) | h1–h6, page titles |

### Sidebar Tokens

```css
--sidebar:           var(--teal-dark)      /* bg */
--sidebar-foreground: #ECFDF5             /* text */
--sidebar-accent:    #1B5750              /* hover */
--sidebar-border:    #1B5750
```

---

## 6. Shared UI Components Reuse Map

| Component | From Membership | Inventory Usage |
|---|---|---|
| `dashboard_sidenav.svelte` | ✅ Reuse | Inventory nav items injected |
| `dashboard_header.svelte` | ✅ Reuse | Page name map updated |
| `dashboard_main.svelte` | ✅ Reuse | Slot wrapper unchanged |
| `Card.*` | ✅ Reuse | KPI cards, list wrappers |
| `Table.*` | ✅ Reuse | All data tables |
| `Dialog.*` | ✅ Reuse | Add / Edit / Delete modals |
| `Button` | ✅ Reuse | All actions |
| `Input` / `InputGroup.*` | ✅ Reuse | All form fields |
| `DropdownMenu.*` | ✅ Reuse | Filters, selects |
| `Label` | ✅ Reuse | Form labels |
| `Skeleton` | ✅ Reuse | Loading states |
| `Spinner` | ✅ Reuse | Loading overlay |
| `Tooltip` | ✅ Reuse | Action button hints |
| `Avatar.*` | ✅ Reuse | Header user display |
| `Icon` (Iconify) | ✅ Reuse | All icons |
| `svelte-sonner` | ✅ Reuse | Toast notifications |

---

## 7. Sidebar Navigation (Inventory)

```ts
const inventoryMenuItems = [
  { id: 'Dashboard',              icon: 'mdi:view-dashboard',      url: '/dashboard' },
  { id: 'Items',                  icon: 'mdi:package-variant',     url: '/dashboard/items' },
  { id: 'Categories',             icon: 'mdi:tag-multiple',        url: '/dashboard/categories' },
  { id: 'Units',                  icon: 'mdi:warehouse',           url: '/dashboard/units' },
  { id: 'Unit Items',             icon: 'mdi:package-variant-closed', url: '/dashboard/unit-items' },
  { id: 'Adjustments',            icon: 'mdi:swap-horizontal',     url: '/dashboard/adjustments' },
  { id: 'Adjustment Templates',   icon: 'mdi:file-document-edit',  url: '/dashboard/adjustment-templates' },
  { id: 'In-Transit',             icon: 'mdi:truck-delivery',      url: '/dashboard/in-transit' },
  { id: 'Reports',                icon: 'mdi:chart-bar',           url: '/dashboard/reports' },
];
```

---

## 8. Page-by-Page UI Specification

### 8.1 Dashboard (`/dashboard`)

- **KPI Cards** (same `Card.*` pattern as membership dashboard)
  - Total Items
  - Total Units
  - Pending In-Transit
  - Pending Adjustments
- Each card: icon + count + `View more` button
- All counts fetched via corresponding `/get-*` endpoints with `bol_getone: 0`

---

### 8.2 Items (`/dashboard/items`)

**Layout:** `Card.Root` > `Card.Content` > toolbar + table + dialogs

**Toolbar:**
- `InputGroup` search field (client-side filter by `item_description`)
- Filter button → `DropdownMenu` for `item_category_id`
- `+ Add Item` `Button variant="default"`

**Table columns:** `ID | Category | Description | Stocking Unit | Retail Unit | Cost | Selling Price | Actions`

**Dialogs:**
- **Add/Edit** (`Dialog.*`): fields for all `postInventoryItemRequestSchema` payload fields; image upload preview
- **View**: read-only with image thumbnail

**Service calls:**
```ts
GET items:    endpoint('/get-inventory-item')   body: { bol_getone:0, item_category_id:0, item_id:0, item_description:'' }
POST item:    endpoint('/post-inventory-item')  body: { process_type, ...fields }
GET image:    endpoint('/get-item-image')       body: { item_id }
GET bins:     endpoint('/get-empty-unit-bin')   body: { bol_getone:0, ... }
```

---

### 8.3 Categories (`/dashboard/categories`)

**Table columns:** `ID | Category Name | Status | Actions`

**Add/Edit Dialog:** `category_name`, `status` dropdown

**Service calls:**
```ts
endpoint('/get-item-category')   body: { bol_getone:0, item_category_id:0, item_category_description:'' }
endpoint('/post-item-category')  body: { process_type, item_category_id, item_category_description, user_id }
```

---

### 8.4 Units (`/dashboard/units`)

**Table columns:** `ID | Description | Warehouse | Employee | Person In Charge | Actions`

**Edit Dialog:** `bol_warehouse`, `bol_employee`, `person_in_charge`, `person_name`

**Service calls:**
```ts
endpoint('/get-inventory-unit')   body: { bol_getone:0, unit_id:0, description:'' }
endpoint('/post-inventory-unit')  body: { unit_id, bol_warehouse, bol_employee, person_in_charge, person_name }
```

---

### 8.5 Unit Items (`/dashboard/unit-items`)

**Filter bar:** Unit selector (dropdown from `/get-inventory-unit`)

**Table columns:** `Item | Category | Stocking Unit | On-Hand Qty | History`

**History Dialog:** calls `/get-unit-item-history` and renders movement log

---

### 8.6 Adjustments (`/dashboard/adjustments`)

**Filter bar:** date range pickers + unit selector

**Table columns:** `ID | Date | Template | Source Unit | Dest. Unit | Item | Qty | Cost | Remarks | Status`

**Add Adjustment Dialog:**
- Template selector → populates `source_unit_id` / `destination_unit_id` visibility
- Item search → calls `/get-item-for-adjustment`
- Qty + unit cost + remarks inputs

**Service calls:**
```ts
endpoint('/get-inventory-item-adjustment')  body: { bol_getone:0, adjustment_id:0, date_from:'', date_to:'' }
endpoint('/post-inventory-item-adjustment') body: { template_id, source_unit_id, destination_unit_id, item_id, quantity, unit_cost, remarks, user_id }
endpoint('/get-item-for-adjustment')        body: { template_id, source_unit_id, destination_unit_id, item_description:'' }
```

---

### 8.7 Adjustment Templates (`/dashboard/adjustment-templates`)

**Table columns:** `ID | Description | Requires Src/Dest | Add to Qty | Actions`

**Add/Edit Dialog:** full form matching `PostInventoryItemAdjustmentTemplateRequestSchema`

---

### 8.8 In-Transit (`/dashboard/in-transit`)

**Sub-tabs:** `Report` | `Invoices`

**Report tab:** search input → table from `/get-instransit-report`

**Invoices tab:**
- Table: `Invoice ID | Reference | Status | Actions`
- `View / Confirm` Dialog: line items with `quantity_confirmed` input per item
- Submit → `/post-confirm-in-transit-items`

---

### 8.9 Reports Hub (`/dashboard/reports`)

**Layout:** Card grid of report shortcuts

| Report | Icon | Route |
|---|---|---|
| Purchases | `mdi:cart` | `/dashboard/reports/purchases` |
| Stock Card | `mdi:card-bulleted` | `/dashboard/reports/stock-card` |
| Inventory List | `mdi:format-list-bulleted` | `/dashboard/reports/inventory-list` |
| Sales | `mdi:cash-register` | `/dashboard/reports/sales` |
| Deliveries | `mdi:truck` | `/dashboard/reports/deliveries` |
| Client Ledger | `mdi:book-open` | `/dashboard/reports/client-ledger` |
| Expiries | `mdi:calendar-alert` | `/dashboard/reports/expiries` |
| Internal Movements | `mdi:transfer` | `/dashboard/reports/movements` |

Each report page: `ReportFilterBar.svelte` + `ReportTable.svelte` (generic components)

---

## 9. Common Patterns (Consistent Across All Pages)

### Loading Overlay
```svelte
{#if loading}
  <div class="absolute inset-0 z-10 flex items-center justify-center bg-white/70">
    <Icon icon="mdi:loading" class="text-primary animate-spin" width="32" />
  </div>
{/if}
```

### Status Badge
```svelte
<!-- StatusBadge.svelte -->
<span class="inline-block px-2 py-1 rounded text-sm font-semibold {statusClass(status)}">
  {status}
</span>
```

### Toast Notifications
```ts
import { toast } from 'svelte-sonner';
toast.success('Item saved successfully');
toast.error('Failed to save item');
```

### Pagination (same as membership)
```ts
const perPage = 10;
let currentPage = 1;
$: paginated = data.slice((currentPage - 1) * perPage, currentPage * perPage);
```

---

## 10. Environment Switch — Quick Reference

| Setting | File | What to change |
|---|---|---|
| Local ↔ Live | `src/lib/config/serviceConfig.ts` | `const ENV: 'local' \| 'live' = 'local'` |
| Local API port | `serviceConfig.ts` `BASE_URLS.local` | Match `inventory/.env` `BACKEND_PORT` |
| Live API URL | `serviceConfig.ts` `BASE_URLS.live` | Your production domain |

---

## 11. Dependency List (mirrors membership)

```json
{
  "devDependencies": {
    "@sveltejs/kit": "^2",
    "@sveltejs/adapter-auto": "^7",
    "@tailwindcss/vite": "^4",
    "tailwindcss": "^4",
    "tw-animate-css": "^1",
    "bits-ui": "^2",
    "svelte": "^5",
    "typescript": "^5",
    "vite": "^7"
  },
  "dependencies": {
    "@fontsource/nunito-sans": "^5",
    "@fontsource/playfair-display": "^5",
    "@iconify/svelte": "^5",
    "svelte-sonner": "^1"
  }
}
```

---

## 12. Open Questions / Decisions

> [!NOTE]
> Clarify these before starting implementation:

1. **Auth strategy**: Does the inventory UI have its own login page, or is it accessed from the membership app with a shared session token?
2. **User roles for inventory**: Which roles can access what? (e.g., admin can CRUD items, warehouse staff can only view/confirm in-transit?)
3. **Image storage**: Where do item images live — local filesystem, S3, or base64 in DB?
4. **Report export**: Do reports need CSV/Excel export or just on-screen display?
5. **In-transit confirm**: Is confirmation a one-time action, or can quantities be partially confirmed?
