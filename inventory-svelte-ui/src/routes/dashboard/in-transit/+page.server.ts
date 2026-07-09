import type { PageServerLoad } from './$types';
import { invokeService } from '$lib/service/invokeService';
import { DEFAULT_USER_ID } from '$lib/store/user';

export const load: PageServerLoad = async ({ locals }) => {
  const token = locals.user?.access_token;
  const user_id = locals.user?.member?.member_id ?? DEFAULT_USER_ID;

  const [reportRes, invoicesRes] = await Promise.all([
    invokeService<any, any[]>('/get-in-transit-report', {
      body: {},
      token
    }),
    invokeService<any, any[]>('/get-in-transit-items-invoices', {
      body: { bol_getone: 0, invoice_id: 0, user_id, invoice_reference: '' },
      token
    })
  ]);

  let transitReport: any[] = [];
  let transitInvoices: any[] = [];

  if ('data' in reportRes && reportRes.data.success) {
    transitReport = reportRes.data?.data?.json_data || [];
  } else {
    const errMsg = 'error' in reportRes ? reportRes.error : (reportRes.data?.message || 'Unknown error');
    console.error('[In-Transit Page Server Load] Failed to load in-transit report:', errMsg, reportRes);
  }
  if ('data' in invoicesRes && invoicesRes.data.success) {
    transitInvoices = invoicesRes.data?.data?.json_data || [];
  } else {
    const errMsg = 'error' in invoicesRes ? invoicesRes.error : (invoicesRes.data?.message || 'Unknown error');
    console.error('[In-Transit Page Server Load] Failed to load in-transit invoices:', errMsg, invoicesRes);
  }

  return {
    transitReport,
    transitInvoices
  };
};
