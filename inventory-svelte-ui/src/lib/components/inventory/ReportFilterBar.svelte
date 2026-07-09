<script lang="ts">
  import type { InventoryUnit } from '$lib/types';
  import { Button } from '$lib/components/ui/button/index.js';
  import { Input } from '$lib/components/ui/input/index.js';
  import { Label } from '$lib/components/ui/label/index.js';
  import Icon from '@iconify/svelte';
  import SearchCombobox from '$lib/components/ui/SearchCombobox.svelte';
  import MultiSelectCombobox from '$lib/components/ui/MultiSelectCombobox.svelte';
  import ItemSelect from '$lib/components/inventory/ItemSelect.svelte';
  import { invokeService } from '$lib/service/invokeService';
  import * as DropdownMenu from '$lib/components/ui/dropdown-menu/index.js';
  import { afterNavigate } from '$app/navigation';

  let {
    activeId = '',
    units = [],
    token = '',
    showDateRange = true,
    showUnit = true,
    showClient = false,
    showCostToggle = false,
    allowMultiUnit = false,
    showItem = false,
    onfilter = () => {}
  } = $props<{
    activeId?: string;
    units?: InventoryUnit[];
    token?: string;
    showDateRange?: boolean;
    showUnit?: boolean;
    showClient?: boolean;
    showCostToggle?: boolean;
    allowMultiUnit?: boolean;
    showItem?: boolean;
    onfilter: (filters: {
      dateFrom: string;
      dateTo: string;
      unitId: number | null;
      unitIds: (string | number)[];
      itemId?: number | null;
      clientId: number | null;
      clientLabel?: string;
      withCost: number;
    }) => void;
  }>();

  const reports = [
    {
      id: 'purchases',
      name: 'Purchases Report',
      description: 'Review cost, client data, and purchase history.',
      icon: 'mdi:cart',
      color: 'text-teal-dark bg-teal-50 dark:text-teal-400 dark:bg-teal-950/30',
      url: '/dashboard/reports/purchases'
    },
    {
      id: 'stock-card',
      name: 'Stock Card Ledger',
      description: 'Check stock card transactions, movements, and ledger details.',
      icon: 'mdi:card-bulleted',
      color: 'text-emerald-600 bg-emerald-50 dark:text-emerald-400 dark:bg-emerald-950/30',
      url: '/dashboard/reports/stock-card'
    },
    {
      id: 'inventory-list',
      name: 'Inventory List',
      description: 'Get full current stock values and listings.',
      icon: 'mdi:format-list-bulleted',
      color: 'text-sky-600 bg-sky-50 dark:text-sky-400 dark:bg-sky-950/30',
      url: '/dashboard/reports/inventory-list'
    },
    {
      id: 'sales',
      name: 'Sales Report',
      description: 'Generate report details for sales orders.',
      icon: 'mdi:cash-register',
      color: 'text-indigo-600 bg-indigo-50 dark:text-indigo-400 dark:bg-indigo-950/30',
      url: '/dashboard/reports/sales'
    },
    {
      id: 'deliveries',
      name: 'Deliveries Report',
      description: 'Monitor dispatched and completed deliveries.',
      icon: 'mdi:truck',
      color: 'text-amber-600 bg-amber-50 dark:text-amber-400 dark:bg-amber-950/30',
      url: '/dashboard/reports/deliveries'
    },
    {
      id: 'client-ledger',
      name: 'Client Ledger',
      description: 'Trace client account ledger entries and statement histories.',
      icon: 'mdi:book-open',
      color: 'text-violet-600 bg-violet-50 dark:text-violet-400 dark:bg-violet-950/30',
      url: '/dashboard/reports/client-ledger'
    },
    {
      id: 'expiries',
      name: 'Expiries & Past Due',
      description: 'Audit expiring inventory batches and shelf life details.',
      icon: 'mdi:calendar-alert',
      color: 'text-rose-600 bg-rose-50 dark:text-rose-400 dark:bg-rose-950/30',
      url: '/dashboard/reports/expiries'
    },
    {
      id: 'movements',
      name: 'Internal Movements',
      description: 'Track stock transfers and movement logs internally.',
      icon: 'mdi:transfer',
      color: 'text-purple-600 bg-purple-50 dark:text-purple-400 dark:bg-purple-950/30',
      url: '/dashboard/reports/movements'
    }
  ];

  let menuOpen = $state(false);
  let activeReport = $derived(reports.find(r => r.id === activeId));

  // Close menu on click outside
  function handleOutsideClick(event: MouseEvent) {
    const target = event.target as HTMLElement;
    if (menuOpen && !target.closest('.report-quick-switcher-container')) {
      menuOpen = false;
    }
  }

  $effect(() => {
    document.addEventListener('click', handleOutsideClick);
    return () => document.removeEventListener('click', handleOutsideClick);
  });

  afterNavigate(() => {
    menuOpen = false;
  });

  // Get first day and current day of the month as defaults
  const today = new Date();
  const firstDay = new Date(today.getFullYear(), today.getMonth(), 1);
  const formatDate = (date: Date) => date.toISOString().split('T')[0];

  // Local state
  let dateFrom = $state(formatDate(firstDay));
  let dateTo = $state(formatDate(today));
  let datePeriod = $state('custom');
  let unitId = $state<number | null>(null);
  let unitIds = $state<(string | number)[]>([]);
  let itemId = $state<number | null>(null);
  let itemOptions = $state<{ value: number; label: string }[]>([]);
  let itemLoading = $state(false);
  let clientId = $state<number | null>(0); // Default to 0 (All Clients)
  let withCost = $state(0);

  let clientOptions = $state<{ value: number; label: string }[]>([]);
  let clientLoading = $state(false);

  let unitOptions = $derived(
    units.map((u: any) => ({ value: u.unit_id, label: u.description }))
  );

  // Sync initial values
  $effect(() => {
    if (units.length > 0) {
      if (unitId === null) {
        unitId = units[0].unit_id;
      }
      if (unitIds.length === 0 && allowMultiUnit) {
        unitIds = [units[0].unit_id];
      }
    }
  });

  // Fetch unit items when unit changes
  $effect(() => {
    if (showItem && unitId) {
      loadUnitItems(unitId);
    } else {
      itemOptions = [];
      itemId = null;
    }
  });

  async function loadUnitItems(uId: number) {
    itemLoading = true;
    try {
      const response = await invokeService<any, any>('/get-inventory-unit-item', {
        body: {
          bol_getone: 0,
          unit_id: uId,
          item_category_id: 0,
          unit_item_id: 0,
          item_description: ''
        },
        token
      });
      if (response && 'data' in response && response.data.success) {
        const inner = response.data.data ?? response.data;
        const list = inner.json_data || [];
        const mapped = list.map((item: any) => ({
          value: Number(item.unit_item_id),
          label: `${item.item_description} (${item.item_category})`,
          itemId: Number(item.item_id)
        }));
        itemOptions = [
          { value: 0, label: 'All Items', itemId: 0 },
          ...mapped
        ];
        itemId = 0;
      } else {
        itemOptions = [];
        itemId = null;
      }
    } catch (e) {
      console.error('Error loading items:', e);
      itemOptions = [];
      itemId = null;
    } finally {
      itemLoading = false;
    }
  }

  // Fetch clients if showClient is true and token is available
  $effect(() => {
    if (showClient && token && clientOptions.length === 0) {
      loadClients();
    }
  });

  async function loadClients() {
    clientLoading = true;
    try {
      const response = await invokeService<any, any>('/get-client-name', {
        body: { entity_id: 0 },
        token
      });
      if (response && 'data' in response && response.data.success) {
        const list = response.data.data.json_data || [];
        clientOptions = [
          { value: 0, label: 'All Clients' },
          ...list.map((c: any) => ({
            value: Number(c.clientId),
            label: c.clientName
          }))
        ];
      } else {
        console.error('Failed to load clients:', response);
      }
    } catch (e) {
      console.error('Error loading clients:', e);
    } finally {
      clientLoading = false;
    }
  }

  function handlePeriodChange() {
    const todayDate = new Date();
    if (datePeriod === 'last-7-days') {
      const start = new Date();
      start.setDate(todayDate.getDate() - 7);
      dateFrom = formatDate(start);
      dateTo = formatDate(todayDate);
    } else if (datePeriod === 'last-month') {
      const start = new Date(todayDate.getFullYear(), todayDate.getMonth() - 1, 1);
      const lastDay = new Date(todayDate.getFullYear(), todayDate.getMonth(), 0);
      dateFrom = formatDate(start);
      dateTo = formatDate(lastDay);
    } else if (datePeriod === 'custom') {
      dateFrom = formatDate(firstDay);
      dateTo = formatDate(todayDate);
    }
  }

  function handleFilter() {
    const selectedClient = clientOptions.find(o => o.value === clientId);
    onfilter({
      dateFrom: showDateRange ? dateFrom : '',
      dateTo: showDateRange ? dateTo : '',
      unitId: showUnit ? unitId : null,
      unitIds: showUnit ? unitIds : [],
      itemId: showItem ? itemId : null,
      clientId: showClient ? clientId : null,
      clientLabel: selectedClient ? selectedClient.label : 'All Clients',
      withCost: showCostToggle ? withCost : 0
    });
  }
</script>

<div class="bg-card border border-border rounded-xl shadow-sm mb-6 overflow-visible">
  {#if activeId}
    <!-- Report Header & Quick Switcher (Inside Card) -->
    <div class="p-5 border-b border-border flex flex-col md:flex-row md:items-center justify-between gap-4 relative">
      <div class="flex items-center gap-4">
        <Button href="/dashboard/reports" variant="ghost" size="icon-sm" class="hover:bg-muted shrink-0">
          <Icon icon="mdi:arrow-left" width="20" />
        </Button>
        <div class="h-8 w-px bg-border hidden md:block"></div>
        <div class="relative min-w-[240px] report-quick-switcher-container">
          <!-- Switcher Trigger -->
          <!-- svelte-ignore a11y_click_events_have_key_events -->
          <!-- svelte-ignore a11y_no_static_element_interactions -->
          <div 
            onclick={() => menuOpen = !menuOpen}
            class="flex items-center gap-3 group text-left cursor-pointer select-none max-w-fit"
          >
            <div class="p-2.5 rounded-xl shrink-0 {activeReport?.color || 'bg-primary/10 text-primary'}">
              <Icon icon={activeReport?.icon || 'mdi:chart-bar'} width="24" height="24" />
            </div>
            <div>
              <div class="flex items-center gap-1.5">
                <h2 class="text-xl font-bold font-playfair text-primary leading-tight group-hover:text-primary/80">
                  {activeReport?.name || 'Report'}
                </h2>
                <Icon icon="mdi:chevron-down" width="20" class="text-primary transition-transform duration-200 {menuOpen ? 'rotate-180' : ''}" />
              </div>
              <p class="text-xs text-muted-foreground mt-0.5 font-normal leading-normal pr-4">{activeReport?.description}</p>
            </div>
          </div>

          {#if menuOpen}
            <!-- Dropdown Menu Card -->
            <div 
              class="absolute left-0 top-full mt-3.5 w-[310px] sm:w-[540px] bg-card border border-border rounded-2xl shadow-xl p-3.5 z-50 grid grid-cols-1 sm:grid-cols-2 gap-2.5"
            >
              {#each reports as r}
                {@const isActive = r.id === activeId}
                <a 
                  href={r.url}
                  class="flex items-start gap-3 p-3 rounded-xl transition-all duration-150 text-left border
                    {isActive 
                      ? 'bg-teal-50/70 border-teal-200/50 text-teal-dark font-semibold dark:bg-teal-950/20 dark:border-teal-900/30' 
                      : 'bg-card border-transparent hover:bg-muted/50 hover:border-border/60 text-foreground'}"
                >
                  <div class="p-2 rounded-lg shrink-0 {r.color}">
                    <Icon icon={r.icon} width="18" height="18" />
                  </div>
                  <div class="min-w-0 flex-1">
                    <p class="text-xs font-bold truncate leading-snug">{r.name}</p>
                    <p class="text-[10px] text-muted-foreground line-clamp-2 mt-0.5 leading-tight">{r.description}</p>
                  </div>
                </a>
              {/each}
            </div>
          {/if}
        </div>
      </div>
    </div>
  {/if}

  <div class="p-5 flex flex-wrap items-end gap-6">
    {#if showDateRange}
      <div class="flex flex-col gap-1.5 min-w-[150px]">
        <Label class="text-xs font-semibold text-muted-foreground uppercase tracking-wider">Date Period</Label>
        <DropdownMenu.Root>
          <DropdownMenu.Trigger class="flex h-9 w-full items-center justify-between rounded-md border border-input bg-background px-3 py-1 text-sm shadow-sm ring-offset-background placeholder:text-muted-foreground focus:outline-none focus:ring-1 focus:ring-ring disabled:cursor-not-allowed disabled:opacity-50">
            <span class="truncate pr-2">
              {#if datePeriod === 'custom'}
                Custom Range
              {:else if datePeriod === 'last-7-days'}
                Last 7 Days
              {:else if datePeriod === 'last-month'}
                Last Month
              {/if}
            </span>
            <Icon icon="mdi:chevron-down" width="16" class="opacity-50 shrink-0" />
          </DropdownMenu.Trigger>
          <DropdownMenu.Content class="w-[var(--bits-dropdown-menu-anchor-width)] min-w-[150px] bg-card border border-border rounded-md shadow-md p-1 z-50">
            <DropdownMenu.Item
              onclick={() => { datePeriod = 'custom'; handlePeriodChange(); }}
              class={datePeriod === 'custom' ? 'bg-accent/50 font-semibold' : ''}
            >
              Custom Range
            </DropdownMenu.Item>
            <DropdownMenu.Item
              onclick={() => { datePeriod = 'last-7-days'; handlePeriodChange(); }}
              class={datePeriod === 'last-7-days' ? 'bg-accent/50 font-semibold' : ''}
            >
              Last 7 Days
            </DropdownMenu.Item>
            <DropdownMenu.Item
              onclick={() => { datePeriod = 'last-month'; handlePeriodChange(); }}
              class={datePeriod === 'last-month' ? 'bg-accent/50 font-semibold' : ''}
            >
              Last Month
            </DropdownMenu.Item>
          </DropdownMenu.Content>
        </DropdownMenu.Root>
      </div>
      <div class="flex flex-col gap-1.5 min-w-[150px]">
        <Label for="dateFrom" class="text-xs font-semibold text-muted-foreground uppercase tracking-wider">Date From</Label>
        <Input type="date" id="dateFrom" bind:value={dateFrom} class="h-9" disabled={datePeriod !== 'custom'} />
      </div>
      <div class="flex flex-col gap-1.5 min-w-[150px]">
        <Label for="dateTo" class="text-xs font-semibold text-muted-foreground uppercase tracking-wider">Date To</Label>
        <Input type="date" id="dateTo" bind:value={dateTo} class="h-9" disabled={datePeriod !== 'custom'} />
      </div>
    {/if}

    {#if showUnit}
      <div class="flex flex-col gap-1.5 min-w-[200px]">
        <Label for="filter_unit" class="text-xs font-semibold text-muted-foreground uppercase tracking-wider">Unit / Warehouse</Label>
        {#if allowMultiUnit}
          <MultiSelectCombobox
            options={unitOptions}
            bind:value={unitIds}
            placeholder="Select Units..."
            searchPlaceholder="Search units..."
            class="h-9"
          />
        {:else}
          <SearchCombobox
            options={unitOptions}
            bind:value={unitId}
            placeholder="Select Unit..."
            searchPlaceholder="Search unit..."
            class="h-9"
          />
        {/if}
      </div>
    {/if}

    {#if showItem}
      <div class="flex flex-col gap-1.5 min-w-[250px] flex-grow">
        <Label for="filter_item" class="text-xs font-semibold text-muted-foreground uppercase tracking-wider">Inventory Item</Label>
        {#if itemLoading}
          <div class="h-9 flex items-center justify-center border border-input rounded-md bg-muted/20 px-3 text-xs text-muted-foreground">
            <Icon icon="line-md:loading-twotone-loop" width="16" class="mr-2" />
            Loading items...
          </div>
        {:else if itemOptions.length === 0}
          <div class="h-9 flex items-center justify-center border border-input rounded-md bg-muted/10 px-3 text-xs text-muted-foreground">
            No items in selected unit
          </div>
        {:else}
          <ItemSelect
            options={itemOptions}
            bind:value={itemId}
            placeholder="Select Item..."
            searchPlaceholder="Search item..."
            class="h-9"
            token={token}
          />
        {/if}
      </div>
    {/if}

    {#if showClient}
      <div class="flex flex-col gap-1.5 min-w-[200px]">
        <Label for="client_select" class="text-xs font-semibold text-muted-foreground uppercase tracking-wider">Client</Label>
        {#if clientLoading}
          <div class="h-9 flex items-center justify-center border border-input rounded-md bg-muted/20 px-3 text-xs text-muted-foreground">
            <Icon icon="line-md:loading-twotone-loop" width="16" class="mr-2" />
            Loading clients...
          </div>
        {:else}
          <SearchCombobox
            options={clientOptions}
            bind:value={clientId}
            placeholder="All Clients"
            searchPlaceholder="Search client..."
            class="h-9"
          />
        {/if}
      </div>
    {/if}

    {#if showCostToggle}
      <div class="flex items-center gap-2 h-9">
        <input
          type="checkbox"
          id="cost_toggle"
          checked={withCost === 1}
          onchange={(e) => withCost = e.currentTarget.checked ? 1 : 0}
          class="size-4 rounded border-border text-primary focus:ring-primary"
        />
        <Label for="cost_toggle" class="text-sm font-semibold text-muted-foreground cursor-pointer">Include Cost Data</Label>
      </div>
    {/if}

    <div>
      <Button variant="default" class="bg-primary hover:bg-primary/95 text-white h-9 px-4 flex items-center gap-2" onclick={handleFilter}>
        <Icon icon="mdi:filter-variant" width="18" />
        Generate Report
      </Button>
    </div>
  </div>
</div>
