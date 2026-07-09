import type { RequestHandler } from './$types';
import { invokeService } from '$lib/service/invokeService';
import { AUTH_API } from '$lib/config/serviceConfig';

// ─────────────────────────────────────────────
//  DEV BYPASS — remove this block before going live
//  Credentials: dev@dev.com / devpass
// ─────────────────────────────────────────────
const DEV_EMAIL    = 'dev@dev.com';
const DEV_PASSWORD = 'devpass';

const DEV_USER = {
  member: {
    member_id: 1,
    email: DEV_EMAIL,
    first_name: 'Dev',
    last_name:  'Admin',
    phone: '09000000000',
    status: 'ACTIVE',
    avatar_url: '/images/default_user.jpeg'
  },
  role: {
    role_id: 1,
    role_name: 'admin'
  },
  loggedIn: true,
  session_id:   'dev-session-id',
  access_token: 'dev-access-token'
};
// ─────────────────────────────────────────────

export const POST: RequestHandler = async (event) => {
  let responseBody: string;
  let statusCode: number;

  try {
    const payload = await event.request.json();
    const { email, password, terminate_existing_session } = payload;

    if (!email || !password) {
      responseBody = JSON.stringify({ success: false, error: 'Email and password are required' });
      statusCode = 400;
      return new Response(responseBody, { status: statusCode, headers: { 'Content-Type': 'application/json' } });
    }

    // ── DEV BYPASS ──────────────────────────────
    if (email === DEV_EMAIL && password === DEV_PASSWORD) {
      event.cookies.set('user', JSON.stringify(DEV_USER), {
        path: '/',
        httpOnly: true,
        sameSite: 'lax',
        secure: false,
        maxAge: 60 * 60 * 8  // 8 hours
      });
      return new Response(
        JSON.stringify({ success: true, user: DEV_USER }),
        { status: 200, headers: { 'Content-Type': 'application/json' } }
      );
    }
    // ────────────────────────────────────────────

    // Call the central membership authentication service API
    const result = await invokeService<any, any>(
      `${AUTH_API}/auth/login`,
      {
        method: 'POST',
        body: { email, password, terminate_existing_session }
      }
    );

    if ('error' in result) {
      responseBody = JSON.stringify({ success: false, error: result.error });
      statusCode = 500;
      return new Response(responseBody, { status: statusCode, headers: { 'Content-Type': 'application/json' } });
    }

    const { data: response, accessToken } = result;

    if (
      !response.success &&
      response.error_code === 'SESSION_CONFLICT' &&
      response.session_conflict?.has_active_session
    ) {
      responseBody = JSON.stringify({
        success: false,
        session_conflict: true,
        error_code: 'SESSION_CONFLICT',
        message: response.message
      });
      statusCode = 409;
      return new Response(responseBody, { status: statusCode, headers: { 'Content-Type': 'application/json' } });
    }

    if (!response.success) {
      responseBody = JSON.stringify({
        success: false,
        error_code: response.error_code,
        message: response.message
      });
      statusCode = 401;
      return new Response(responseBody, { status: statusCode, headers: { 'Content-Type': 'application/json' } });
    }

    const memberInfo = response.data;

    if (!memberInfo?.session_id || !accessToken) {
      responseBody = JSON.stringify({ success: false, error: 'Login failed: missing session or accessToken' });
      statusCode = 500;
      return new Response(responseBody, { status: statusCode, headers: { 'Content-Type': 'application/json' } });
    }

    const userData = {
      member: {
        member_id: memberInfo.member_id,
        email: memberInfo.email,
        first_name: memberInfo.first_name,
        last_name: memberInfo.last_name,
        phone: memberInfo.mobile_phone,
        status: memberInfo.status,
        avatar_url: memberInfo.avatar_url || '/images/default_user.jpeg'
      },
      role: {
        role_id: memberInfo.role_id || 1,
        role_name: memberInfo.role || 'guest'
      },
      loggedIn: true,
      session_id: memberInfo.session_id,
      access_token: accessToken
    };

    event.cookies.set('user', JSON.stringify(userData), {
      path: '/',
      httpOnly: true,
      sameSite: 'lax',
      secure: false,
      maxAge: 60 * 60
    });

    responseBody = JSON.stringify({ success: true, user: userData });
    statusCode = 200;

  } catch (error: unknown) {
    console.error('Login error:', error);
    responseBody = JSON.stringify({
      success: false,
      error: error instanceof Error ? error.message : 'Server error'
    });
    statusCode = 400;
  }

  return new Response(responseBody, { status: statusCode, headers: { 'Content-Type': 'application/json' } });
};
