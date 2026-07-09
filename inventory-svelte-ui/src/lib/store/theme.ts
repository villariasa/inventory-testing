import { writable } from 'svelte/store';
import { browser } from '$app/environment';

function createThemeStore() {
  // Default: check localStorage, then system preference
  const getInitial = (): 'light' | 'dark' => {
    if (!browser) return 'light';
    const stored = localStorage.getItem('inv_theme');
    if (stored === 'dark' || stored === 'light') return stored;
    return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
  };

  const { subscribe, set, update } = writable<'light' | 'dark'>(getInitial());

  function applyTheme(theme: 'light' | 'dark') {
    if (!browser) return;
    document.documentElement.classList.toggle('dark', theme === 'dark');
    localStorage.setItem('inv_theme', theme);
  }

  // Apply on init
  if (browser) applyTheme(getInitial());

  return {
    subscribe,
    toggle: () => update(current => {
      const next = current === 'light' ? 'dark' : 'light';
      applyTheme(next);
      return next;
    }),
    set: (theme: 'light' | 'dark') => {
      applyTheme(theme);
      set(theme);
    }
  };
}

export const theme = createThemeStore();
