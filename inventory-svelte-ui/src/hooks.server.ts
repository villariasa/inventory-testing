import type { Handle } from '@sveltejs/kit';
import { redirect } from '@sveltejs/kit';

const STATUS_REDIRECT_MAP: Record<string, string> = {
  SUSPENDED: '/login',
  DELETED: '/login',
  INACTIVE: '/login'
};

const PUBLIC_PATHS = [
  '/login',
  '/service/auth/login',
  '/service/auth/logout'
];

export const handle: Handle = async ({ event, resolve }) => {
  const userCookie = event.cookies.get('user');

  if (userCookie) {
    try {
      event.locals.user = JSON.parse(userCookie);
    } catch (e) {
      console.error('Failed to parse user cookie: ', e);
      event.cookies.delete('user', { path: '/' });
      event.locals.user = null;
    }
  } else {
    event.locals.user = null;
  }

  const user = event.locals.user;
  const status = user?.member?.status;
  const pathname = event.url.pathname;

  const isPublicPath = PUBLIC_PATHS.some(p => pathname.startsWith(p));

  // Redirect to login if account status is invalid
  if (!isPublicPath && status && STATUS_REDIRECT_MAP[status]) {
    event.cookies.delete('user', { path: '/' });
    event.locals.user = null;
    throw redirect(302, '/login');
  }

  const tokenBefore = event.locals.user?.access_token;
  const isServiceRoute = pathname.startsWith('/service/');

  const response = await resolve(event);

  const tokenAfter = event.locals.user?.access_token;

  // Append Set-Cookie if the access token was refreshed by backend calls
  if (isServiceRoute && event.locals.user && tokenAfter && tokenAfter !== tokenBefore) {
    const cookieValue = encodeURIComponent(JSON.stringify(event.locals.user));
    response.headers.append(
      'Set-Cookie',
      `user=${cookieValue}; Path=/; HttpOnly; SameSite=Lax; Max-Age=3600`
    );
  }

  // Required for cross-origin isolation (security best practice)
  response.headers.set('Cross-Origin-Opener-Policy', 'same-origin');

  return response;
};
