import type { PageServerLoad } from './$types';
import { invokeService } from '$lib/service/invokeService';
import type { Adjustment, AdjustmentTemplate, InventoryUnit } from '$lib/types';

export const load: PageServerLoad = async ({ locals }) => {
  const token = locals.user?.access_token;

  const today = new Date();
  const thirtyDaysAgo = new Date();
  thirtyDaysAgo.setDate(today.getDate() - 30);
  const date_from = thirtyDaysAgo.toISOString().split('T')[0];
  const date_to = today.toISOString().split('T')[0];

  const [adjustmentsRes, templatesRes, unitsRes] = await Promise.all([
    invokeService<any, Adjustment[]>('/get-inventory-item-adjustment', {
      body: { bol_getone: 0, adjustment_id: 0, date_from, date_to },
      token
    }),
    invokeService<any, AdjustmentTemplate[]>('/get-inventory-item-adjustment-template', {
      body: { bol_getone: 0, template_id: 0, description: '' },
      token
    }),
    invokeService<any, InventoryUnit[]>('/get-inventory-unit', {
      body: { bol_getone: 0, unit_id: 0, description: '' },
      token
    })
  ]);

  let adjustments: Adjustment[] = [];
  let templates: AdjustmentTemplate[] = [];
  let units: InventoryUnit[] = [];

  if ('data' in adjustmentsRes && adjustmentsRes.data.success) {
    adjustments = adjustmentsRes.data?.data?.json_data || [];
  } else {
    const errMsg = 'error' in adjustmentsRes ? adjustmentsRes.error : (adjustmentsRes.data?.message || 'Unknown error');
    console.error('[Adjustments Page Server Load] Failed to load adjustments:', errMsg, adjustmentsRes);
  }
  if ('data' in templatesRes && templatesRes.data.success) {
    templates = templatesRes.data?.data?.json_data || [];
  } else {
    const errMsg = 'error' in templatesRes ? templatesRes.error : (templatesRes.data?.message || 'Unknown error');
    console.error('[Adjustments Page Server Load] Failed to load adjustment templates:', errMsg, templatesRes);
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
    console.error('[Adjustments Page Server Load] Failed to load inventory units:', errMsg, unitsRes);
  }

  return {
    adjustments,
    templates,
    units
  };
};
