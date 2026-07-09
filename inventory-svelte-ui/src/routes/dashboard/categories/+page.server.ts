import type { PageServerLoad } from './$types';
import { invokeService } from '$lib/service/invokeService';
import type { ItemCategory } from '$lib/types';

export const load: PageServerLoad = async ({ locals }) => {
  const token = locals.user?.access_token;

  const [categoriesRes, accountsRes] = await Promise.all([
    invokeService<any, ItemCategory[]>('/get-inventory-item-category', {
      body: { bol_getone: 0, item_category_id: 0, description: '' },
      token
    }),
    invokeService<any, any>('/get-selectable-accounts', {
      body: { glsl_id: 0, account_description: '' },
      token
    })
  ]);
  console.log('Item Category Response:', categoriesRes);
  let categories: ItemCategory[] = [];
  let glslAccounts: { glsl_id: number; account: string }[] = [];

  if ('data' in categoriesRes && categoriesRes.data.success) {
    const inner = categoriesRes.data.data ?? categoriesRes.data;
    categories = inner.json_data || [];
  } else {
    const errMsg = 'error' in categoriesRes ? categoriesRes.error : (categoriesRes.data?.message || 'Unknown error');
    console.error('[Categories Page Server Load] Failed to load categories:', errMsg, categoriesRes);
  }
  if ('data' in accountsRes && accountsRes.data.success) {
    const inner = accountsRes.data.data ?? accountsRes.data;
    glslAccounts = inner.json_data || [];
  } else {
    const errMsg = 'error' in accountsRes ? accountsRes.error : (accountsRes.data?.message || 'Unknown error');
    console.error('[Categories Page Server Load] Failed to load GLSL accounts:', errMsg, accountsRes);
  }

  return { categories, glslAccounts };
};
