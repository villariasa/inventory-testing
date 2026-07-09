import { writable } from 'svelte/store';
import type { User } from '$lib/types';

export const userStore = writable<User>({
  member: null,
  role: { role_id: 1, role_name: 'guest' },
  loggedIn: false,
  access_token: undefined,
  session_id: undefined
});

export const DEFAULT_USER_ID = 1; // Change this value here to apply a different user ID globally for testing
