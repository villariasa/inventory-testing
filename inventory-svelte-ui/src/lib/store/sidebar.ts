import { writable } from 'svelte/store';
import { browser } from '$app/environment';

function createSidebarStore() {
  const stored = browser ? localStorage.getItem('inv_sidebar_collapsed') : null;
  const initial = stored === 'true';
  const { subscribe, set, update } = writable(initial);

  return {
    subscribe,
    toggle: () => update(v => {
      const next = !v;
      if (browser) localStorage.setItem('inv_sidebar_collapsed', String(next));
      return next;
    }),
    setCollapsed: (v: boolean) => {
      if (browser) localStorage.setItem('inv_sidebar_collapsed', String(v));
      set(v);
    }
  };
}

export const sidebarCollapsed = createSidebarStore();

// Mobile overlay open state (separate from collapsed)
export const mobileSidebarOpen = writable(false);
