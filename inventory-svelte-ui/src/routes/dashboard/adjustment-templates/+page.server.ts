import type { PageServerLoad } from './$types';
import { invokeService } from '$lib/service/invokeService';
import type { AdjustmentTemplate } from '$lib/types';

export const load: PageServerLoad = async ({ locals }) => {
  const token = locals.user?.access_token;

  const response = await invokeService<any, AdjustmentTemplate[]>('/get-inventory-item-adjustment-template', {
    body: { bol_getone: 0, template_id: 0, description: '' },
    token
  });

  let templates: AdjustmentTemplate[] = [];
  if ('data' in response && response.data.success) {
    templates = response.data?.data?.json_data || [];
  } else {
    const errMsg = 'error' in response ? response.error : (response.data?.message || 'Unknown error');
    console.error('[Adjustment Templates Page Server Load] Failed to load templates:', errMsg, response);
  }

  return {
    templates
  };
};
