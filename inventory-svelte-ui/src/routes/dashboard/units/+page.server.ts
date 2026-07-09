import type { PageServerLoad } from './$types';
import { invokeService } from '$lib/service/invokeService';
import type { InventoryUnit } from '$lib/types';

export const load: PageServerLoad = async ({ locals }) => {
  const token = locals.user?.access_token;

  const response = await invokeService<any, InventoryUnit[]>('/get-inventory-unit', {
    body: { bol_getone: 0, unit_id: 0, description: '' },
    token
  });

  let units: InventoryUnit[] = [];
  if ('data' in response && response.data.success) {
    const rawList = response.data?.data?.json_data || [];
    units = rawList.map((u: any) => ({
      unit_id: u.unit_id,
      description: u.unit ?? u.description ?? '',
      bol_warehouse: u.warehouse ?? u.bol_warehouse ?? 0,
      bol_employee: u.person_in_charge_id ? 1 : (u.bol_employee ?? 0),
      person_in_charge: u.person_in_charge_id ?? u.person_in_charge ?? 0,
      person_name: u.person_in_charge ?? u.person_name ?? ''
    }));
  } else {
    const errMsg = 'error' in response ? response.error : (response.data?.message || 'Unknown error');
    console.error('[Units Page Server Load] Failed to load units:', errMsg, response);
  }

  return {
    units
  };
};
