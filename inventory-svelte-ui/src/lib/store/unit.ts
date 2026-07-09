import { writable } from 'svelte/store';
import { browser } from '$app/environment';

export interface ActiveUnit {
  unit_id: number;
  description: string;
}

export const DEFAULT_UNIT: ActiveUnit = { unit_id: 3, description: 'Litecloud Ph' };

function createActiveUnitStore() {
  const getInitial = (): ActiveUnit | null => {
    if (!browser) return null;
    const stored = localStorage.getItem('active_unit');
    if (stored) {
      try {
        return JSON.parse(stored);
      } catch (e) {
        console.error('Failed to parse active unit from localStorage:', e);
      }
    }
    return null;
  };

  const { subscribe, set, update } = writable<ActiveUnit | null>(getInitial());

  return {
    subscribe,
    set: (unit: ActiveUnit | null) => {
      if (browser) {
        if (unit) {
          localStorage.setItem('active_unit', JSON.stringify(unit));
        } else {
          localStorage.removeItem('active_unit');
        }
      }
      set(unit);
    },
    clear: () => {
      if (browser) {
        localStorage.removeItem('active_unit');
      }
      set(null);
    }
  };
}

export const activeUnit = createActiveUnitStore();
