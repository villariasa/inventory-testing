import type { PageServerLoad } from './$types';
import { invokeService } from '$lib/service/invokeService';
import { DEFAULT_USER_ID } from '$lib/store/user';

export const load: PageServerLoad = async ({ locals }) => {
  const token = locals.user?.access_token;
  const user_id = locals.user?.member?.member_id ?? DEFAULT_USER_ID;

  const todayDate = new Date();
  const thirtyDaysAgo = new Date();
  thirtyDaysAgo.setDate(todayDate.getDate() - 30);
  const date_from_30 = thirtyDaysAgo.toISOString().split('T')[0];
  const date_to = todayDate.toISOString().split('T')[0];

  const sixMonthsAgo = new Date();
  sixMonthsAgo.setMonth(sixMonthsAgo.getMonth() - 6);
  const date_from_6m = sixMonthsAgo.toISOString().split('T')[0];

  // ── Phase 1: Metadata — categories, units, transit, 6-month adjustments ──
  const [categoriesRes, unitsRes, transitRes, adjustmentsRes, templatesRes] = await Promise.all([
    invokeService<any, any[]>('/get-inventory-item-category', {
      body: { bol_getone: 0, item_category_id: 0, description: '' },
      token
    }),
    invokeService<any, any[]>('/get-inventory-unit', {
      body: { bol_getone: 0, unit_id: 0, description: '' },
      token
    }),
    invokeService<any, any[]>('/get-in-transit-items-invoices', {
      body: { bol_getone: 0, invoice_id: 0, user_id, invoice_reference: '' },
      token
    }),
    invokeService<any, any[]>('/get-inventory-item-adjustment', {
      body: { bol_getone: 0, adjustment_id: 0, date_from: date_from_6m, date_to },
      token
    }),
    invokeService<any, any[]>('/get-inventory-item-adjustment-template', {
      body: { bol_getone: 0, template_id: 0, description: '' },
      token
    })
  ]);

  let categories: any[] = [];
  let units: { unit_id: number; description: string }[] = [];
  let pendingTransit = 0;
  let allAdjustments6m: any[] = [];
  let templates: any[] = [];

  if ('data' in categoriesRes && categoriesRes.data.success) {
    categories = categoriesRes.data?.data?.json_data || [];
  } else {
    console.error('[Dashboard] Categories failed:', 'error' in categoriesRes ? categoriesRes.error : categoriesRes.data?.message);
  }

  if ('data' in unitsRes && unitsRes.data.success) {
    const rawUnits: any[] = unitsRes.data?.data?.json_data || [];
    units = rawUnits.map((u: any) => ({
      unit_id: u.unit_id,
      description: u.unit ?? u.description ?? `Unit ${u.unit_id}`
    }));
  } else {
    console.error('[Dashboard] Units failed:', 'error' in unitsRes ? unitsRes.error : unitsRes.data?.message);
  }

  if ('data' in transitRes && transitRes.data.success) {
    const invoices: any[] = transitRes.data?.data?.json_data || [];
    pendingTransit = invoices.filter((inv: any) => inv.status?.toUpperCase() === 'PENDING').length;
  } else {
    console.error('[Dashboard] Transit failed:', 'error' in transitRes ? transitRes.error : transitRes.data?.message);
  }

  if ('data' in adjustmentsRes && adjustmentsRes.data.success) {
    allAdjustments6m = adjustmentsRes.data?.data?.json_data || [];
  } else {
    console.error('[Dashboard] Adjustments failed:', 'error' in adjustmentsRes ? adjustmentsRes.error : adjustmentsRes.data?.message);
  }

  if ('data' in templatesRes && templatesRes.data.success) {
    templates = templatesRes.data?.data?.json_data || [];
  } else {
    console.error('[Dashboard] Templates failed:', 'error' in templatesRes ? templatesRes.error : templatesRes.data?.message);
  }

  // ── Phase 2: Fan-out items per category (all in parallel) ──
  let totalItems = 0;
  let allItems: any[] = [];
  const categoryBreakdown: { label: string; count: number; category_id: number }[] = [];

  if (categories.length > 0) {
    const itemResponses = await Promise.all(
      categories.map((cat: any) =>
        invokeService<any, any[]>('/get-inventory-item', {
          body: { bol_getone: 0, item_category_id: cat.item_category_id, item_id: 0, item_description: '' },
          token
        })
      )
    );

    for (let i = 0; i < itemResponses.length; i++) {
      const res = itemResponses[i];
      const cat = categories[i];
      if ('data' in res && res.data.success) {
        const catItems: any[] = res.data?.data?.json_data || [];
        totalItems += catItems.length;
        allItems = allItems.concat(catItems);
        categoryBreakdown.push({
          label: cat.description ?? cat.item_category_description ?? `Category ${cat.item_category_id}`,
          count: catItems.length,
          category_id: cat.item_category_id
        });
      }
    }
    categoryBreakdown.sort((a, b) => b.count - a.count);
  }

  // New Catalog Additions: sort all items by datetime_created DESC, take top 8
  const recentItems = [...allItems]
    .sort((a: any, b: any) => {
      const da = a.datetime_created ? new Date(a.datetime_created).getTime() : 0;
      const db = b.datetime_created ? new Date(b.datetime_created).getTime() : 0;
      return db - da;
    })
    .slice(0, 8);

  // KPI: adjustments count for last 30 days (subset of 6m)
  const cutoff30 = new Date(date_from_30);
  const totalAdjustments = allAdjustments6m.filter((adj: any) => {
    const raw = adj.adjustment_date || adj.added_date;
    if (!raw) return false;
    const d = new Date(raw);
    return !isNaN(d.getTime()) && d >= cutoff30;
  }).length;

  // Template lookup map for addition/subtraction classification
  const templateMap = new Map<number, any>(templates.map((t: any) => [Number(t.template_id), t]));

  // Recent adjustments: 5 most recent, with is_addition flag pre-computed
  const recentAdjustments = [...allAdjustments6m]
    .sort((a: any, b: any) => {
      const da = new Date(a.adjustment_date || a.added_date || 0).getTime();
      const db = new Date(b.adjustment_date || b.added_date || 0).getTime();
      return db - da;
    })
    .slice(0, 5)
    .map((adj: any) => {
      const tmpl = templateMap.get(Number(adj.template_id));
      return {
        ...adj,
        is_addition: tmpl ? Number(tmpl.add_to_quantity) === 1 : true
      };
    });

  // Phase 3: Stock card ledger for Movement chart (unit_id: 0 = ALL movements)
  // The stock card SP accepts unit_id: 0 as "all unit items" via OR ? = 0 clause,
  // which returns the full 6-month ledger across every warehouse item.

  // Build zero-filled 6-month buckets with a deterministic key format "Mmm YYYY"
  // (avoids toLocaleDateString year:'2-digit' which varies by Node/ICU version)
  function monthKey(d: Date): string {
    return d.toLocaleDateString('en-US', { month: 'short' }) + ' ' + d.getFullYear();
    // e.g. "Jun 2026"
  }

  function buildMonthBuckets(
    from: Date,
    to: Date
  ): Map<string, { value1: number; value2: number; sortKey: number }> {
    const m = new Map<string, { value1: number; value2: number; sortKey: number }>();
    const cursor = new Date(from.getFullYear(), from.getMonth(), 1);
    while (cursor <= to) {
      const key = monthKey(cursor);
      if (!m.has(key)) {
        m.set(key, { value1: 0, value2: 0, sortKey: cursor.getTime() });
      }
      cursor.setMonth(cursor.getMonth() + 1);
    }
    return m;
  }

  const stockCardRes = await invokeService<any, any[]>('/get-stock-card', {
    body: { unit_id: 0, start_date: date_from_6m, end_date: date_to },
    token
  });

  const movementByMonthMap = buildMonthBuckets(sixMonthsAgo, todayDate);

  if ('data' in stockCardRes && stockCardRes.data.success) {
    const scRows: any[] = stockCardRes.data?.data?.json_data || [];
    for (const row of scRows) {
      // Skip forwarded-balance header rows
      if (!row.entry_date || String(row.reference ?? '').toUpperCase() === 'QTYFWD') continue;

      // entry_date format from SP: '2026 Jun 19' (DATE_FORMAT %Y %b %d)
      const parts = String(row.entry_date).trim().split(/\s+/);
      if (parts.length < 2) continue;
      const [year, mon] = [parts[0], parts[1]];
      const key = `${mon} ${year}`; // "Jun 2026" — matches bucket keys above

      if (!movementByMonthMap.has(key)) continue;
      const itemIn = parseFloat(String(row.item_in ?? '0').replace(/,/g, ''));
      const itemOut = parseFloat(String(row.item_out ?? '0').replace(/,/g, ''));
      const bucket = movementByMonthMap.get(key)!;
      if (!isNaN(itemIn)) bucket.value1 += itemIn;
      if (!isNaN(itemOut)) bucket.value2 += itemOut;
    }
  } else {
    console.error('[Dashboard] Stock card failed:', 'error' in stockCardRes ? stockCardRes.error : stockCardRes.data?.message);
  }

  const movementPoints = [...movementByMonthMap.entries()]
    .sort((a, b) => a[1].sortKey - b[1].sortKey)
    .map(([month, v]) => ({ month, value1: v.value1, value2: v.value2 }));

  // Adjustment chart — zero-filled buckets with same "Mmm YYYY" key format
  const adjByMonthMap = buildMonthBuckets(sixMonthsAgo, todayDate);
  for (const adj of allAdjustments6m) {
    const rawDate = adj.adjustment_date || adj.added_date;
    if (!rawDate) continue;
    const d = new Date(rawDate);
    if (isNaN(d.getTime())) continue;
    const key = monthKey(d); // "Jun 2026" — matches bucket keys
    if (!adjByMonthMap.has(key)) continue;
    const bucket = adjByMonthMap.get(key)!;
    const tmpl = templateMap.get(Number(adj.template_id));
    const isAddition = tmpl ? Number(tmpl.add_to_quantity) === 1 : true;
    if (isAddition) bucket.value1++;
    else bucket.value2++;
  }
  const adjustmentPoints = [...adjByMonthMap.entries()]
    .sort((a, b) => a[1].sortKey - b[1].sortKey)
    .map(([month, v]) => ({ month, value1: v.value1, value2: v.value2 }));

  // Phase 4: Inventory list for Valuation chart (current stock value per warehouse)
  // withCost: 1 (integer) — the SP checks for 0/1, not boolean true/false
  const invListRes = await invokeService<any, any[]>('/get-inventory-list', {
    body: { units: ['0'], withCost: 1 },
    token
  });

  let valuationPoints: { month: string; value1: number }[] = [];
  if ('data' in invListRes && invListRes.data.success) {
    const invList: any[] = invListRes.data?.data?.json_data || [];
    const byUnit = new Map<string, number>();
    for (const row of invList) {
      // warehouse_store = the warehouse/unit name (row.unit = stocking unit of measure, e.g. "pcs")
      const unitName: string = row.warehouse_store || row.warehouse || 'Unknown';
      // inventory_cost = unit cost; total row value = ending_quantity × inventory_cost
      const qty = parseFloat(String(row.ending_quantity ?? '0').replace(/,/g, ''));
      const unitCost = parseFloat(String(row.inventory_cost ?? '0').replace(/,/g, ''));
      const rowTotal = (isNaN(qty) ? 0 : qty) * (isNaN(unitCost) ? 0 : unitCost);
      byUnit.set(unitName, (byUnit.get(unitName) ?? 0) + rowTotal);
    }
    valuationPoints = [...byUnit.entries()]
      .sort((a, b) => b[1] - a[1])
      .slice(0, 8)
      .map(([unit, val]) => ({ month: unit, value1: val }));
  } else {
    console.error('[Dashboard] Inventory list failed:', 'error' in invListRes ? invListRes.error : invListRes.data?.message);
  }

  return {
    stats: {
      totalItems,
      totalUnits: units.length,
      pendingTransit,
      totalAdjustments
    },
    recentItems,
    recentAdjustments,
    units,
    defaultUnitId: 0,
    categoryBreakdown: categoryBreakdown.slice(0, 5),
    chartData: {
      movementPoints,
      adjustmentPoints,
      valuationPoints
    }
  };
};
