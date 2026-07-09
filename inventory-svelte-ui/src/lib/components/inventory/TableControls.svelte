<script lang="ts">
  import Icon from '@iconify/svelte';
  import { Button } from '$lib/components/ui/button/index.js';
  import { Input } from '$lib/components/ui/input/index.js';

  let {
    columns = [],
    visibleColumns = $bindable<Record<string, boolean>>({}),
    limit = $bindable(10),
    page = $bindable(1),
    total = 0,
    showSearch = false,
    searchQuery = $bindable(''),
    searchPlaceholder = 'Search...'
  } = $props<{
    columns: { key: string; label: string }[];
    visibleColumns: Record<string, boolean>;
    limit: number;
    page: number;
    total: number;
    showSearch?: boolean;
    searchQuery?: string;
    searchPlaceholder?: string;
  }>();

  let showColMenu = $state(false);
  let showRowsMenu = $state(false);

  // Initialize visibleColumns if empty
  $effect(() => {
    columns.forEach((col: any) => {
      if (visibleColumns[col.key] === undefined) {
        visibleColumns[col.key] = true;
      }
    });
  });

  // Pagination bounds calculations
  let totalPages = $derived(Math.ceil(total / limit) || 1);
  let startEntry = $derived(total === 0 ? 0 : (page - 1) * limit + 1);
  let endEntry = $derived(Math.min(page * limit, total));

  function setPage(p: number) {
    if (p >= 1 && p <= totalPages) {
      page = p;
    }
  }

  function toggleColumn(key: string) {
    visibleColumns[key] = !visibleColumns[key];
  }
</script>

<div class="space-y-3">
  <!-- Top Control Bar (Search + Columns Toggle) -->
  <div class="flex items-center justify-between gap-4 flex-wrap">
    {#if showSearch}
      <div class="relative flex-1 max-w-sm">
        <Icon icon="mdi:magnify" width="16" class="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground pointer-events-none" />
        <Input
          type="text"
          placeholder={searchPlaceholder}
          bind:value={searchQuery}
          autocomplete="off"
          class="pl-9 h-9 text-sm"
        />
        {#if searchQuery}
          <button
            onclick={() => searchQuery = ''}
            class="absolute right-2.5 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground transition-colors"
          >
            <Icon icon="mdi:close-circle" width="15" />
          </button>
        {/if}
      </div>
    {:else}
      <div></div>
    {/if}

    <!-- Columns Customizer -->
    {#if columns.length > 0}
      <div class="relative">
        <Button
          variant="outline"
          size="sm"
          onclick={() => showColMenu = !showColMenu}
          class="h-9 px-3 flex items-center gap-1.5 hover:bg-primary/5 border border-input rounded-lg text-xs font-semibold text-foreground/80"
        >
          <Icon icon="mdi:view-column-outline" width="16" />
          Customize Columns
        </Button>

        {#if showColMenu}
          <!-- Backdrop click listener -->
          <!-- eslint-disable-next-line svelte/valid-compile -->
          <button
            type="button"
            class="fixed inset-0 z-20 cursor-default"
            onclick={() => showColMenu = false}
            aria-label="Close columns customizer"
          ></button>

          <div class="absolute right-0 mt-1.5 z-30 w-52 bg-card border rounded-xl shadow-xl p-3 space-y-2 animate-in fade-in slide-in-from-top-1 duration-150">
            <div class="font-bold text-[10px] uppercase tracking-wider text-muted-foreground pb-1.5 border-b border-border">
              Display Columns
            </div>
            <div class="max-h-48 overflow-y-auto space-y-1.5 py-0.5">
              {#each columns as col}
                <label class="flex items-center gap-2 px-1 py-0.5 rounded hover:bg-muted/50 cursor-pointer select-none text-xs font-medium text-foreground">
                  <input
                    type="checkbox"
                    checked={visibleColumns[col.key] !== false}
                    onchange={() => toggleColumn(col.key)}
                    class="size-3.5 rounded border-gray-300 text-teal-600 focus:ring-teal-500"
                  />
                  <span>{col.label}</span>
                </label>
              {/each}
            </div>
            <div class="pt-1.5 border-t border-border flex justify-end">
              <button
                onclick={() => showColMenu = false}
                class="text-[10px] font-bold text-teal-600 hover:text-teal-700"
              >
                Done
              </button>
            </div>
          </div>
        {/if}
      </div>
    {/if}
  </div>

  <!-- Children Slots for Table rendering -->
  <div class="rounded-xl border bg-card overflow-hidden">
    <slot></slot>
  </div>

  <!-- Bottom Pagination Bar -->
  <div class="flex items-center justify-end gap-4 px-2 py-1 text-xs text-muted-foreground flex-wrap">

    <!-- Rows per Page & Page Buttons -->
    <div class="flex items-center gap-6 flex-wrap">
      <!-- Rows selector -->
      <div class="flex items-center gap-2 relative">
        <span>Rows per page</span>
        <button
          type="button"
          onclick={() => showRowsMenu = !showRowsMenu}
          class="h-8 w-14 rounded-lg border border-input bg-background px-2 flex items-center justify-between text-xs font-semibold focus:outline-none focus:ring-1 focus:ring-primary text-foreground hover:bg-muted/50"
        >
          <span>{limit}</span>
          <Icon icon="mdi:chevron-down" width="14" class="text-muted-foreground" />
        </button>
        {#if showRowsMenu}
          <!-- Backdrop click listener -->
          <button
            type="button"
            class="fixed inset-0 z-20 cursor-default"
            onclick={() => showRowsMenu = false}
            aria-label="Close rows menu"
          ></button>

          <div class="absolute bottom-full mb-1.5 left-1/2 -translate-x-1/2 z-30 w-16 bg-card border rounded-lg shadow-xl p-1 space-y-0.5 animate-in fade-in slide-in-from-bottom-1 duration-150">
            {#each [5, 10, 20, 50] as size}
              <button
                type="button"
                onclick={() => { limit = size; page = 1; showRowsMenu = false; }}
                class="w-full text-center py-1 rounded hover:bg-muted text-xs font-medium text-foreground {limit === size ? 'bg-primary/10 text-primary font-bold' : ''}"
              >
                {size}
              </button>
            {/each}
          </div>
        {/if}
      </div>

      <!-- Page X of Y with Arrow Buttons -->
      <div class="flex items-center gap-2">
        <button
          onclick={() => setPage(page - 1)}
          disabled={page === 1}
          class="p-1 rounded-lg border border-input bg-background hover:bg-primary/5 disabled:opacity-40 disabled:hover:bg-background text-foreground/80 transition-colors"
        >
          <Icon icon="mdi:chevron-left" width="16" />
        </button>
        <span class="font-medium">
          Page <span class="font-bold text-foreground">{page}</span> of <span class="font-bold text-foreground">{totalPages}</span>
        </span>
        <button
          onclick={() => setPage(page + 1)}
          disabled={page === totalPages}
          class="p-1 rounded-lg border border-input bg-background hover:bg-primary/5 disabled:opacity-40 disabled:hover:bg-background text-foreground/80 transition-colors"
        >
          <Icon icon="mdi:chevron-right" width="16" />
        </button>
      </div>
    </div>
  </div>
</div>
