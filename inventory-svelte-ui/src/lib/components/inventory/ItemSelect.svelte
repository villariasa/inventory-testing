<script lang="ts">
  import * as Popover from '$lib/components/ui/popover/index.js';
  import Icon from '@iconify/svelte';
  import { imageCacheStore } from '$lib/store/imageCache.svelte';

  type Option = {
    value: string | number;
    label: string;
    itemId?: number; // Optional: specify catalog item ID if value is unit_item_id
  };

  let {
    options = [],
    value = $bindable<string | number | null>(null),
    searchValue = $bindable<string>(''),
    placeholder = 'Select item...',
    searchPlaceholder = 'Search items...',
    disabled = false,
    required = false,
    class: className = '',
    token = '',
    onchange = (_v: string | number | null) => {}
  } = $props<{
    options: Option[];
    value?: string | number | null;
    searchValue?: string;
    placeholder?: string;
    searchPlaceholder?: string;
    disabled?: boolean;
    required?: boolean;
    class?: string;
    token?: string;
    onchange?: (v: string | number | null) => void;
  }>();

  let open = $state(false);
  let searchVal = $state('');
  let highlightedIndex = $state(0);
  let listContainer = $state<HTMLDivElement | null>(null);

  // Sync changes from parent prop to local state
  $effect(() => {
    searchVal = searchValue ?? '';
  });

  // Reset highlightedIndex when searchVal changes or popover opens
  $effect(() => {
    if (open) {
      highlightedIndex = 0;
    }
  });

  $effect(() => {
    if (filtered.length === 0) {
      highlightedIndex = -1;
    } else if (highlightedIndex >= filtered.length) {
      highlightedIndex = 0;
    } else if (highlightedIndex < 0 && filtered.length > 0) {
      highlightedIndex = 0;
    }
  });

  // Scroll active element into view
  $effect(() => {
    if (highlightedIndex >= 0 && listContainer) {
      const activeEl = listContainer.querySelector(`[data-index="${highlightedIndex}"]`) as HTMLElement;
      if (activeEl) {
        activeEl.scrollIntoView({ block: 'nearest' });
      }
    }
  });

  let selected = $derived(options.find((o: Option) => o.value === value) ?? null);

  let filtered = $derived(
    (searchVal.trim()
      ? options.filter((o: Option) => o.label && String(o.label).toLowerCase().includes(searchVal.trim().toLowerCase()))
      : options
    ).slice(0, 30)
  );

  // Trigger loading of images for the filtered options
  $effect(() => {
    if (!token) return;
    for (const opt of filtered) {
      const itemId = opt.itemId ?? Number(opt.value);
      if (itemId && !imageCacheStore.has(itemId)) {
        imageCacheStore.fetch(itemId, token);
      }
    }
  });

  // Trigger loading of image for the currently selected option
  $effect(() => {
    if (!token || value === null || value === undefined) return;
    const itemId = selected?.itemId ?? Number(value);
    if (itemId && !imageCacheStore.has(itemId)) {
      imageCacheStore.fetch(itemId, token);
    }
  });

  function handleInput(e: Event) {
    const val = (e.target as HTMLInputElement).value;
    searchVal = val;
    searchValue = val;
  }

  function handleKeyDown(e: KeyboardEvent) {
    if (filtered.length === 0) return;

    if (e.key === 'ArrowDown') {
      e.preventDefault();
      highlightedIndex = (highlightedIndex + 1) % filtered.length;
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      highlightedIndex = (highlightedIndex - 1 + filtered.length) % filtered.length;
    } else if (e.key === 'Enter') {
      e.preventDefault();
      if (highlightedIndex >= 0 && highlightedIndex < filtered.length) {
        select(filtered[highlightedIndex]);
      }
    } else if (e.key === 'Escape') {
      open = false;
    }
  }

  function handleTriggerKeyDown(e: KeyboardEvent) {
    if (disabled) return;
    if (e.key === 'ArrowDown' || e.key === 'ArrowUp') {
      e.preventDefault();
      open = true;
    }
  }

  function select(opt: Option) {
    value = opt.value;
    onchange(opt.value);
    open = false;
    searchVal = '';
    searchValue = '';
  }

  function clear() {
    value = null;
    onchange(null);
    searchVal = '';
    searchValue = '';
  }
</script>

<Popover.Root bind:open>
  <Popover.Trigger class="w-full min-w-0 block" {disabled}>
    {#snippet child({ props })}
      <button
        {...props}
        title={selected ? selected.label : placeholder}
        onkeydown={handleTriggerKeyDown}
        class="flex h-10 w-full min-w-0 items-center justify-between rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background
          focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2
          disabled:cursor-not-allowed disabled:opacity-50 overflow-hidden
          {selected ? 'text-foreground' : 'text-muted-foreground'}
          {className}"
      >
        {#if selected}
          {@const img = imageCacheStore.get(selected.itemId ?? Number(selected.value))}
          <div class="flex items-center gap-2 min-w-0 flex-1 text-left">
            <div class="w-6 h-6 rounded border border-border bg-muted/20 shrink-0 flex items-center justify-center overflow-hidden">
              {#if selected.value === 0 || selected.itemId === 0}
                <Icon icon="mdi:format-list-bulleted" width="12" class="text-muted-foreground/60" />
              {:else if img}
                <img src={img} alt={selected.label} class="w-full h-full object-cover" />
              {:else if img === null}
                <Icon icon="mdi:image-off-outline" width="10" class="text-muted-foreground/45 animate-in fade-in duration-200" />
              {:else}
                <Icon icon="mdi:image-outline" width="10" class="text-muted-foreground/35 animate-pulse" />
              {/if}
            </div>
            <span class="truncate min-w-0 flex-1 pr-1">{selected.label}</span>
          </div>
        {:else}
          <span class="truncate min-w-0 flex-1 text-left pr-1">{placeholder}</span>
        {/if}
        
        <div class="flex items-center gap-0.5 shrink-0 ml-1">
          {#if selected}
            <span
              role="button"
              tabindex="0"
              onkeydown={(e) => e.key === 'Enter' && clear()}
              onclick={(e) => { e.stopPropagation(); clear(); }}
              class="p-0.5 rounded hover:bg-muted text-muted-foreground hover:text-foreground transition-colors"
              title="Clear selection"
            >
              <Icon icon="mdi:close" width="14" />
            </span>
          {/if}
          <Icon icon={open ? 'mdi:chevron-up' : 'mdi:chevron-down'} width="16" class="text-muted-foreground" />
        </div>
      </button>
    {/snippet}
  </Popover.Trigger>

  <Popover.Content
    class="w-[var(--bits-popover-anchor-width)] max-w-sm min-w-[200px] p-0 z-50 bg-card border rounded-md shadow-md"
    align="start"
  >
    <!-- Search input -->
    <div class="p-2 border-b border-border">
      <div class="relative">
        <Icon icon="mdi:magnify" width="15" class="absolute left-2.5 top-1/2 -translate-y-1/2 text-muted-foreground pointer-events-none" />
        <input
          type="text"
          autocomplete="off"
          placeholder={searchPlaceholder}
          value={searchVal}
          oninput={handleInput}
          onkeydown={handleKeyDown}
          class="w-full pl-8 pr-3 h-8 text-sm rounded-md border border-input bg-background focus:outline-none focus:ring-1 focus:ring-ring"
        />
      </div>
    </div>

    <!-- Option list -->
    <div bind:this={listContainer} class="max-h-52 overflow-y-auto py-1">
      {#if filtered.length === 0}
        <div class="px-3 py-6 text-center text-sm text-muted-foreground">
          <Icon icon="mdi:magnify-close" width="28" class="mx-auto opacity-30 mb-1" />
          No results found
        </div>
      {:else}
        {#each filtered as opt, idx (opt.value)}
          {@const img = imageCacheStore.get(opt.itemId ?? Number(opt.value))}
          <button
            type="button"
            title={opt.label}
            data-index={idx}
            class="flex w-full items-center gap-2.5 px-3 py-2 text-sm hover:bg-primary/10 hover:text-foreground transition-colors
              {highlightedIndex === idx ? 'bg-muted text-accent-foreground font-semibold' : ''}
              {value === opt.value ? 'bg-primary/10 text-primary font-semibold' : 'text-foreground'}"
            onclick={() => select(opt)}
            onmouseenter={() => { highlightedIndex = idx; }}
          >
            {#if value === opt.value}
              <Icon icon="mdi:check" width="15" class="text-primary shrink-0" />
            {:else}
              <span class="w-[15px] shrink-0"></span>
            {/if}
            <div class="w-8 h-8 rounded border border-border bg-muted/20 shrink-0 flex items-center justify-center overflow-hidden">
              {#if opt.value === 0 || opt.itemId === 0}
                <Icon icon="mdi:format-list-bulleted" width="16" class="text-muted-foreground/60" />
              {:else if img}
                <img src={img} alt={opt.label} class="w-full h-full object-cover animate-in fade-in duration-200" />
              {:else if img === null}
                <Icon icon="mdi:image-off-outline" width="12" class="text-muted-foreground/45 animate-in fade-in duration-200" />
              {:else}
                <Icon icon="mdi:image-outline" width="12" class="text-muted-foreground/35 animate-pulse" />
              {/if}
            </div>

            <!-- overflow-hidden + break-words: long labels wrap to next line instead of overflowing -->
            <span class="flex-1 min-w-0 text-left overflow-hidden" style="overflow-wrap: anywhere">{opt.label}</span>
          </button>
        {/each}
      {/if}
    </div>
  </Popover.Content>
</Popover.Root>
