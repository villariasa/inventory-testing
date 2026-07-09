import type { PageServerLoad } from './$types';
import { invokeService } from '$lib/service/invokeService';

export const load: PageServerLoad = async ({ locals }) => {
  const token = locals.user?.access_token;

  const listRes = await invokeService<any, any>('/get-item-import-list', {
    body: {},
    token
  });

  let importTypes: { import_name: string; import_type: string }[] = [];
  if ('data' in listRes && listRes.data.success) {
    // Backend wraps result: { success, data: { success, json_data } }
    const inner = listRes.data.data ?? listRes.data;
    importTypes = inner.json_data || [];
  } else {
    const errMsg = 'error' in listRes ? listRes.error : (listRes.data?.message || 'Unknown error');
    console.error('[Item Imports Page Server Load] Failed to load import types:', errMsg, listRes);
  }

  return { importTypes };
};
