// ============================================================
//  SERVICE CONFIG — CHANGE THIS FILE TO SWITCH ENVIRONMENTS
// ============================================================

import { env } from '$env/dynamic/public';

const ENV: 'local' | 'live' = import.meta.env.PROD ? 'live' : 'local';

const isBrowser = typeof window !== 'undefined';
const host = isBrowser ? window.location.hostname : 'localhost';

const BASE_URLS = {
  local: `http://${host}:3000`,          // inventory backend port
  live:  env.PUBLIC_INV_API_URL || 'https://inventory-backend.medyvillarias36.workers.dev'
};

const AUTH_BASE_URLS = {
  local: `http://${host}:3000`,          // membership backend port (for auth)
  live:  env.PUBLIC_AUTH_API_URL || 'https://inventory-backend.medyvillarias36.workers.dev'
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
