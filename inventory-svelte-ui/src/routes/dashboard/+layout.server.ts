import type { LayoutServerLoad } from './$types';
import { redirect } from '@sveltejs/kit';

export const load: LayoutServerLoad = async ({ locals }) => {
  if (!locals.user) {
    throw redirect(302, '/login');
  }

  const status = locals.user.member?.status;
  if (status && ['SUSPENDED', 'DELETED', 'INACTIVE'].includes(status)) {
    throw redirect(302, '/login');
  }

  return {
    user: locals.user
  };
};
