// ============================================================
//  SERVICE CONFIG — CHANGE THIS FILE TO SWITCH ENVIRONMENTS
// ============================================================

const ENV: 'local' | 'live' = 'local';   // <-- toggle here

const isBrowser = typeof window !== 'undefined';
const host = isBrowser ? window.location.hostname : 'localhost';

const BASE_URLS = {
  local: `http://${host}:3000`,          // inventory backend port
  live:  'https://api.yourdomain.com'     // production URL
};

const AUTH_BASE_URLS = {
  local: `http://${host}:3000`,          // membership backend port (for auth)
  live:  'https://auth.yourdomain.com'
};

export const BASE_URL = BASE_URLS[ENV];
export const AUTH_BASE_URL = AUTH_BASE_URLS[ENV];

// All API route prefixes
export const INV_API = `${BASE_URL}/inv/v1`;
export const AUTH_API = `${AUTH_BASE_URL}/api_v1`;

// Convenience endpoint builder
export function endpoint(path: string): string {
  if (path.startsWith('http://') || path.startsWith('https://')) {
    return path;
  }
  return `${INV_API}${path}`;
}
