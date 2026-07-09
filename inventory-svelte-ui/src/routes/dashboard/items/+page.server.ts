// page.server.ts
import type { PageServerLoad } from './$types';
import { invokeService } from '$lib/service/invokeService';
import type { ItemCategory, InventoryUnit } from '$lib/types';

export const load: PageServerLoad = async ({ locals }) => {
  const token = locals.user?.access_token;

  // Only load categories and units on initial page load.
  // Items are fetched client-side once the user selects a category.
  const [categoriesRes, unitsRes] = await Promise.all([
    invokeService<any, ItemCategory[]>('/get-inventory-item-category', {
      body: { bol_getone: 0, item_category_id: 0, description: '' },
      token
    }),
    invokeService<any, InventoryUnit[]>('/get-inventory-unit', {
      body: { bol_getone: 0, unit_id: 0, description: '' },
      token
    })
  ]);

  let categories: ItemCategory[] = [];
  let units: InventoryUnit[] = [];

  if ('data' in categoriesRes && categoriesRes.data.success) {
    categories = categoriesRes.data?.data?.json_data || [];
  } else {
    const errMsg = 'error' in categoriesRes ? categoriesRes.error : (categoriesRes.data?.message || 'Unknown error');
    console.error('[Items Page Server Load] Failed to load categories:', errMsg, categoriesRes);
  }
  if ('data' in unitsRes && unitsRes.data.success) {
    const rawList = unitsRes.data?.data?.json_data || [];
    units = rawList.map((u: any) => ({
      unit_id: u.unit_id,
      description: u.unit ?? u.description ?? '',
      bol_warehouse: u.warehouse ?? u.bol_warehouse ?? 0,
      bol_employee: u.person_in_charge_id ? 1 : (u.bol_employee ?? 0),
      person_in_charge: u.person_in_charge_id ?? u.person_in_charge ?? 0,
      person_name: u.person_in_charge ?? u.person_name ?? ''
    }));
  } else {
    const errMsg = 'error' in unitsRes ? unitsRes.error : (unitsRes.data?.message || 'Unknown error');
    console.error('[Items Page Server Load] Failed to load inventory units:', errMsg, unitsRes);
  }

  return {
    categories,
    units
  };
};