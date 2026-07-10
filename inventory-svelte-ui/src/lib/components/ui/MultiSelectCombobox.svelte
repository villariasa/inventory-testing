<script lang="ts">
  import * as Popover from '$lib/components/ui/popover/index.js';
  import Icon from '@iconify/svelte';

  type Option = { value: string | number; label: string };

  let {
    options = [],
    value = $bindable<(string | number)[]>([]),
    searchValue = $bindable<string>(''),
    placeholder = 'Select multiple...',
    searchPlaceholder = 'Search...',
    disabled = false,
    class: className = '',
    onchange = (_v: (string | number)[]) => {}
  } = $props<{
    options: Option[];
    value?: (string | number)[];
    searchValue?: string;
    placeholder?: string;
    searchPlaceholder?: string;
    disabled?: boolean;
    class?: string;
    onchange?: (v: (string | number)[]) => void;
  }>();

  let open = $state(false);
  let searchVal = $state('');

  // Sync changes from parent prop to local state
  $effect(() => {
    searchVal = searchValue ?? '';
  });

  // Get selected option objects
  let selectedOptions = $derived(
    options.filter((o: Option) => value.includes(o.value))
  );

  let filtered = $derived(
    (searchVal.trim()
      ? options.filter((o: Option) => o.label && String(o.label).toLowerCase().includes(searchVal.trim().toLowerCase()))
      : options
    ).slice(0, 30)
  );

  function handleInput(e: Event) {
    const val = (e.target as HTMLInputElement).value;
    searchVal = val;
    searchValue = val;
  }

  function toggleSelect(opt: Option) {
    let newValue: (string | number)[];
    if (value.includes(opt.value)) {
      newValue = value.filter((v: string | number) => v !== opt.value);
    } else {
      newValue = [...value, opt.value];
    }
    value = newValue;
    onchange(newValue);
  }

  function clearAll() {
    value = [];
    onchange([]);
    searchVal = '';
    searchValue = '';
  }

  function removeOne(optValue: string | number) {
    const newValue = value.filter((v: string | number) => v !== optValue);
    value = newValue;
    onchange(newValue);
  }
</script>

<Popover.Root bind:open>
  <Popover.Trigger class="w-full min-w-0 block" {disabled}>
    {#snippet child({ props })}
      <button
        {...props}
        type="button"
        class="flex min-h-10 w-full min-w-0 items-center justify-between rounded-md border border-input bg-background px-3 py-1.5 text-sm ring-offset-background
          focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2
          disabled:cursor-not-allowed disabled:opacity-50 overflow-hidden
          {className}"
      >
        <div class="flex flex-wrap gap-1 items-center min-w-0 flex-1 text-left">
          {#if selectedOptions.length === 0}
            <span class="text-muted-foreground truncate">{placeholder}</span>
          {:else if selectedOptions.length <= 2}
            {#each selectedOptions as opt}
              <span class="inline-flex items-center gap-1 rounded bg-secondary px-2 py-0.5 text-xs font-medium text-secondary-foreground mr-1 max-w-[120px] truncate">
                <span class="truncate">{opt.label}</span>
                <span
                  role="button"
                  tabindex="0"
                  onclick={(e) => { e.stopPropagation(); removeOne(opt.value); }}
                  onkeydown={(e) => e.key === 'Enter' && removeOne(opt.value)}
                  class="p-0.5 rounded-full hover:bg-muted-foreground/25 cursor-pointer text-muted-foreground hover:text-foreground shrink-0"
                >
                  <Icon icon="mdi:close" width="10" />
                </span>
              </span>
            {/each}
          {:else}
            <span class="inline-flex items-center rounded bg-secondary px-2 py-0.5 text-xs font-semibold text-secondary-foreground">
              {selectedOptions.length} units selected
            </span>
          {/if}
        </div>
        <div class="flex items-center gap-0.5 shrink-0 ml-1">
          {#if selectedOptions.length > 0}
            <span
              role="button"
              tabindex="0"
              onkeydown={(e) => e.key === 'Enter' && clearAll()}
              onclick={(e) => { e.stopPropagation(); clearAll(); }}
              class="p-0.5 rounded hover:bg-muted text-muted-foreground hover:text-foreground transition-colors"
              title="Clear all"
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
    class="w-[var(--bits-popover-anchor-width)] max-w-sm min-w-[200px] p-0 z-[100] bg-card border rounded-md shadow-md"
    align="start"
    onOpenAutoFocus={(e) => e.preventDefault()}
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
          class="w-full pl-8 pr-3 h-8 text-sm rounded-md border border-input bg-background focus:outline-none focus:ring-1 focus:ring-ring"
        />
      </div>
    </div>

    <!-- Option list -->
    <div class="max-h-52 overflow-y-auto py-1">
      {#if filtered.length === 0}
        <div class="px-3 py-6 text-center text-sm text-muted-foreground">
          <Icon icon="mdi:magnify-close" width="28" class="mx-auto opacity-30 mb-1" />
          No results found
        </div>
      {:else}
        {#each filtered as opt (opt.value)}
          <button
            type="button"
            title={opt.label}
            class="flex w-full items-center gap-2 px-3 py-2 text-sm hover:bg-primary/10 hover:text-foreground transition-colors
              {value.includes(opt.value) ? 'bg-primary/10 text-primary font-semibold' : 'text-foreground'}"
            onclick={() => toggleSelect(opt)}
          >
            {#if value.includes(opt.value)}
              <Icon icon="mdi:checkbox-marked" width="16" class="text-primary shrink-0" />
            {:else}
              <Icon icon="mdi:checkbox-blank-outline" width="16" class="text-muted-foreground shrink-0" />
            {/if}
            <span class="flex-1 min-w-0 text-left overflow-hidden" style="overflow-wrap: anywhere">{opt.label}</span>
          </button>
        {/each}
      {/if}
    </div>
  </Popover.Content>
</Popover.Root>
