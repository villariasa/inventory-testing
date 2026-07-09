import type { RequestHandler } from './$types';
import { invokeService } from '$lib/service/invokeService';
import { AUTH_API } from '$lib/config/serviceConfig';

export const POST: RequestHandler = async (event) => {
  const userCookie = event.cookies.get('user');

  if (userCookie) {
    try {
      const user = JSON.parse(userCookie);
      if (user.member?.email && user.session_id) {
        // Notify core auth system of logout
        await invokeService(
          `${AUTH_API}/auth/logout`,
          {
            method: 'POST',
            body: {
              email: user.member.email,
              session_id: user.session_id
            },
            token: user.access_token
          }
        );
      }
    } catch (e) {
      console.error('Failed to logout cleanly from backend:', e);
    }
  }

  // Always delete user session cookie locally
  event.cookies.delete('user', { path: '/' });
  event.locals.user = null;

  return new Response(JSON.stringify({ success: true }), {
    status: 200,
    headers: { 'Content-Type': 'application/json' }
  });
};
