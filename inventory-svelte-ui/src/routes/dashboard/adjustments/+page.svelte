<script lang="ts">
  import type { PageData } from './$types';
  import type { Adjustment } from '$lib/types';
  import { invokeService } from '$lib/service/invokeService';
  import { invalidateAll } from '$app/navigation';
  import { toast } from 'svelte-sonner';
  import StatusBadge from '$lib/components/inventory/StatusBadge.svelte';
  import AdjustmentFormDialog from '$lib/components/inventory/AdjustmentFormDialog.svelte';
  import { Button } from '$lib/components/ui/button/index.js';
  import { Input } from '$lib/components/ui/input/index.js';
  import { Label } from '$lib/components/ui/label/index.js';
  import * as Table from '$lib/components/ui/table/index.js';
  import * as Dialog from '$lib/components/ui/dialog/index.js';
  import Icon from '@iconify/svelte';
  import TableControls from '$lib/components/inventory/TableControls.svelte';
  import * as Tooltip from '$lib/components/ui/tooltip/index.js';
  import { imageCacheStore } from '$lib/store/imageCache.svelte';

  let { data } = $props<{ data: PageData & { adjustments: Adjustment[]; templates: any[]; units: any[]; user: any } }>();

  // Filter local state
  const todayStr = new Date().toISOString().split('T')[0];
  const thirtyDaysAgo = new Date();
  thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
  const thirtyDaysAgoStr = thirtyDaysAgo.toISOString().split('T')[0];

  let dateFrom = $state(thirtyDaysAgoStr);
  let dateTo = $state(todayStr);
  let searchQuery = $state('');
  let listAdjustments = $state<Adjustment[]>([]);
  let loadingList = $state(false);

  // Sync adjustments from loader initial data
  $effect(() => {
    listAdjustments = data.adjustments;
  });

  // Calculate client side filter of loaded items
  let filteredAdjustments = $derived(
    listAdjustments.filter(adj => {
      const matchSearch = !searchQuery.trim() || 
        (adj.item_description && adj.item_description.toLowerCase().includes(searchQuery.toLowerCase())) ||
        (adj.remarks && adj.remarks.toLowerCase().includes(searchQuery.toLowerCase()));
      return matchSearch;
    })
  );

  let formOpen = $state(false);

  // Confirmation state variables
  let confirmSubmitOpen = $state(false);
  let pendingSubmitPayload = $state<any | null>(null);

  // Table controls state
  const columns = [
    { key: 'date', label: 'Date' },
    { key: 'template', label: 'Template' },
    { key: 'srcUnit', label: 'Source Unit' },
    { key: 'destUnit', label: 'Dest. Unit' },
    { key: 'item', label: 'Item Details' },
    { key: 'qty', label: 'Qty' },
    { key: 'cost', label: 'Unit Cost' },
    { key: 'remarks', label: 'Remarks' }
  ];

  let visibleColumns = $state<Record<string, boolean>>({
    date: true,
    template: true,
    srcUnit: true,
    destUnit: true,
    item: true,
    qty: true,
    cost: true,
    remarks: true
  });

  let limit = $state(10);
  let page = $state(1);

  let paginatedAdjustments = $derived(
    filteredAdjustments.slice((page - 1) * limit, page * limit)
  );

  $effect(() => {
    if (filteredAdjustments) {
      page = 1;
    }
  });

  // Track which item_ids are currently being fetched to avoid duplicate requests
  let fetchingImageIds = new Set<number>();

  // Lazy-load images for currently visible (paginated) adjustments
  $effect(() => {
    for (const adj of paginatedAdjustments) {
      const itemId = adj.item_id;
      if (itemId && !imageCacheStore.has(itemId) && !fetchingImageIds.has(itemId)) {
        fetchingImageIds.add(itemId);
        imageCacheStore.fetch(itemId, data.user.access_token).finally(() => {
          fetchingImageIds.delete(itemId);
        });
      }
    }
  });

  // Helper to format cost values safely
  function formatCost(cost: any): string {
    if (cost === null || cost === undefined || cost === '') return '—';
    if (typeof cost === 'number') {
      return '₱' + cost.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 });
    }
    // If it's a string, strip commas and parse as float
    const str = String(cost).replace(/,/g, '');
    const parsed = parseFloat(str);
    if (isNaN(parsed)) return String(cost);
    return '₱' + parsed.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  }

  // Fetch adjustments with new date parameters
  async function handleFilter() {
    loadingList = true;
    const response = await invokeService<any, Adjustment[]>('/get-inventory-item-adjustment', {
      body: {
        bol_getone: 0,
        adjustment_id: 0,
        date_from: dateFrom,
        date_to: dateTo
      },
      token: data.user.access_token
    });
    loadingList = false;
    console.log(response)

    if ('data' in response && response.data.success) {
      listAdjustments = response.data?.data?.json_data || [];
    } else {
      const errMsg = 'error' in response ? response.error : (response.data?.message || 'Unknown error');
      console.error('[Adjustments] Failed to load adjustments:', errMsg, response);
      toast.error(`Failed to load adjustments for range: ${errMsg}`);
    }
  }

  // Create adjustment submission
  function submitAdjustment(payload: any) {
    pendingSubmitPayload = payload;
    confirmSubmitOpen = true;
  }

  async function executeSubmitAdjustment() {
    if (!pendingSubmitPayload) return;
    const payload = pendingSubmitPayload;
    confirmSubmitOpen = false;
    console.log(payload)

    const toastId = toast.loading('Submitting adjustment...');
    console.log(payload)
    const response = await invokeService<any, any>('/post-inventory-item-adjustment', {
      body: payload,
      token: data.user.access_token
    });

    if ('data' in response && response.data.success) {
      toast.success('Adjustment saved successfully', { id: toastId });
      formOpen = false;
      pendingSubmitPayload = null;
      // Reload both server data and local lists
      await invalidateAll();
      handleFilter();
    } else {
      const errMsg = 'error' in response ? response.error : (response.data?.message || 'Unknown error');
      console.error('[Adjustments] Failed to submit adjustment:', errMsg, response);
      toast.error(`Failed to submit adjustment: ${errMsg}`, { id: toastId });
    }
  }
</script>

<svelte:head>
  <title>Adjustments - Serenity Inventory</title>
</svelte:head>

<div class="space-y-6">
  <!-- Page Header -->
  <div class="flex items-center justify-between">
    <div>
      <h2 class="text-2xl font-bold font-playfair text-primary">Inventory Adjustments</h2>
      <p class="text-sm text-muted-foreground">Log additions, subtractions, and stock transfers across warehouses.</p>
    </div>
    <Button onclick={() => formOpen = true} class="bg-primary hover:bg-primary/95 text-white flex items-center gap-2">
      <Icon icon="mdi:swap-horizontal" width="20" />
      New Adjustment
    </Button>
  </div>

  <!-- Filter Toolbar -->
  <div class="bg-card border rounded-xl p-4 shadow-sm flex flex-wrap items-end gap-4">
    <div class="flex flex-col gap-1.5 min-w-[150px]">
      <Label for="date_from" class="text-xs font-bold uppercase tracking-wider text-muted-foreground">Date From</Label>
      <Input type="date" id="date_from" bind:value={dateFrom} autocomplete="off" class="h-10" />
    </div>
    <div class="flex flex-col gap-1.5 min-w-[150px]">
      <Label for="date_to" class="text-xs font-bold uppercase tracking-wider text-muted-foreground">Date To</Label>
      <Input type="date" id="date_to" bind:value={dateTo} autocomplete="off" class="h-10" />
    </div>
    <div class="flex flex-col gap-1.5 w-full sm:max-w-md">
      <Label for="search" class="text-xs font-bold uppercase tracking-wider text-muted-foreground">Search Item / Remarks</Label>
      <div class="relative w-full">
        <Icon icon="mdi:magnify" width="16" class="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground pointer-events-none" />
        <Input type="text" id="search" placeholder="Type keywords..." bind:value={searchQuery} autocomplete="off" class="pl-9 h-10" />
      </div>
    </div>
    <Button variant="outline" class="h-10 flex items-center gap-1.5 text-primary border-primary/30 hover:bg-primary/10 shadow-sm" onclick={handleFilter}>
      <Icon icon="mdi:filter-variant" width="18" />
      Apply Range
    </Button>
  </div>

  <!-- Adjustments Listing Grid -->
  <TableControls
    {columns}
    bind:visibleColumns
    bind:limit
    bind:page
    total={filteredAdjustments.length}
  >
    <Table.Root>
      <Table.Header>
        <Table.Row class="bg-primary/5 hover:bg-primary/5 border-b-2 border-primary/10">
          {#if visibleColumns.date !== false}
            <Table.Head class="font-bold text-xs uppercase tracking-wider text-foreground/60">Date</Table.Head>
          {/if}
          {#if visibleColumns.template !== false}
            <Table.Head class="font-bold text-xs uppercase tracking-wider text-foreground/60">Template</Table.Head>
          {/if}
          {#if visibleColumns.srcUnit !== false}
            <Table.Head class="font-bold text-xs uppercase tracking-wider text-foreground/60">Source Unit</Table.Head>
          {/if}
          {#if visibleColumns.destUnit !== false}
            <Table.Head class="font-bold text-xs uppercase tracking-wider text-foreground/60">Dest. Unit</Table.Head>
          {/if}
          {#if visibleColumns.item !== false}
            <Table.Head class="font-bold text-xs uppercase tracking-wider text-foreground/60">Item Details</Table.Head>
          {/if}
          {#if visibleColumns.qty !== false}
            <Table.Head class="text-right font-bold text-xs uppercase tracking-wider text-foreground/60">Qty</Table.Head>
          {/if}
          {#if visibleColumns.cost !== false}
            <Table.Head class="text-right font-bold text-xs uppercase tracking-wider text-foreground/60">Unit Cost</Table.Head>
          {/if}
          {#if visibleColumns.remarks !== false}
            <Table.Head class="font-bold text-xs uppercase tracking-wider text-foreground/60">Remarks</Table.Head>
          {/if}
        </Table.Row>
      </Table.Header>
      <Table.Body>
        {#if paginatedAdjustments.length === 0}
          <Table.Row>
            <Table.Cell colspan={columns.filter(c => visibleColumns[c.key] !== false).length} class="h-40 text-center">
              <div class="flex flex-col items-center gap-2 text-muted-foreground">
                <Icon icon="mdi:swap-horizontal" width="36" class="opacity-30" />
                <span class="text-sm">No adjustments found for this range.</span>
              </div>
            </Table.Cell>
          </Table.Row>
        {:else}
          {#each paginatedAdjustments as adj, i (adj.adjustment_id)}
            <Table.Row class="hover:bg-primary/5 transition-colors {i % 2 === 1 ? 'bg-muted/20' : ''}">
              {#if visibleColumns.date !== false}
                <Table.Cell class="whitespace-nowrap text-xs text-muted-foreground">
                  {adj.frmt_adjustment_date || (adj.adjustment_date ? new Date(adj.adjustment_date).toLocaleDateString() : (adj.added_date ? new Date(adj.added_date).toLocaleDateString() : '—'))}
                </Table.Cell>
              {/if}
              {#if visibleColumns.template !== false}
                <Table.Cell class="font-semibold text-slate-700 dark:text-slate-300">{adj.template || adj.template_description || 'Adjustment'}</Table.Cell>
              {/if}
              {#if visibleColumns.srcUnit !== false}
                <Table.Cell>{adj.source_unit || adj.source_unit_description || '—'}</Table.Cell>
              {/if}
              {#if visibleColumns.destUnit !== false}
                <Table.Cell>{adj.destination_unit || adj.destination_unit_description || '—'}</Table.Cell>
              {/if}
              {#if visibleColumns.item !== false}
                <Table.Cell class="max-w-[280px]">
                  {@const cachedImage = imageCacheStore.get(adj.item_id)}
                  <div class="flex items-center gap-3">
                    {#if cachedImage}
                      <div class="w-10 h-10 rounded-lg overflow-hidden border border-border bg-muted/30 flex items-center justify-center shrink-0 shadow-sm">
                        <img src={cachedImage} alt={adj.item_description} class="w-full h-full object-cover" />
                      </div>
                    {:else if cachedImage === null}
                      <div class="w-10 h-10 rounded-lg border border-border bg-muted/20 flex items-center justify-center shrink-0">
                        <Icon icon="mdi:image-off-outline" width="16" class="text-muted-foreground/40" />
                      </div>
                    {:else}
                      <div class="w-10 h-10 rounded-lg border border-border bg-muted/20 flex items-center justify-center animate-pulse shrink-0">
                        <Icon icon="mdi:image-outline" width="16" class="text-muted-foreground/30" />
                      </div>
                    {/if}
                    
                    <div class="flex-1 min-w-0">
                      <Tooltip.Provider delayDuration={0}>
                        <Tooltip.Root>
                          <Tooltip.Trigger class="text-left font-medium text-foreground hover:text-primary transition-colors cursor-pointer hover:underline truncate block w-full">
                            {adj.item_description || 'Item ID: ' + adj.item_id}
                          </Tooltip.Trigger>
                          <Tooltip.Content class="max-w-xs p-3 bg-popover text-popover-foreground rounded-lg border border-border shadow-md" side="top" align="start" sideOffset={6}>
                            <div class="space-y-1">
                              <p class="text-[10px] font-bold uppercase tracking-wider text-muted-foreground">Full Item Details</p>
                              <p class="text-xs leading-relaxed font-medium break-words text-foreground">
                                {adj.item_description || 'Item ID: ' + adj.item_id}
                              </p>
                            </div>
                          </Tooltip.Content>
                        </Tooltip.Root>
                      </Tooltip.Provider>
                    </div>
                  </div>
                </Table.Cell>
              {/if}
              {#if visibleColumns.qty !== false}
                <Table.Cell class="text-right font-mono font-bold text-slate-800 dark:text-slate-200">{adj.quantity}</Table.Cell>
              {/if}
              {#if visibleColumns.cost !== false}
                <Table.Cell class="text-right font-mono text-xs text-muted-foreground">{formatCost(adj.unit_cost)}</Table.Cell>
              {/if}
              {#if visibleColumns.remarks !== false}
                <Table.Cell class="max-w-[150px] truncate" title={adj.remarks}>{adj.remarks || '—'}</Table.Cell>
              {/if}
            </Table.Row>
          {/each}
        {/if}
      </Table.Body>
    </Table.Root>
  </TableControls>

  <!-- Create Form Modal -->
  <AdjustmentFormDialog
    bind:open={formOpen}
    templates={data.templates}
    units={data.units}
    user={data.user}
    onsubmit={submitAdjustment}
  />

  <!-- Submit Adjustment Confirmation Dialog -->
  <Dialog.Root bind:open={confirmSubmitOpen}>
    <Dialog.Content class="sm:max-w-[400px] bg-card border rounded-2xl shadow-2xl p-6 overflow-hidden z-[110] text-center">
      <div class="flex flex-col items-center gap-4">
        <div class="w-12 h-12 rounded-full bg-amber-500/10 flex items-center justify-center text-amber-500">
          <Icon icon="mdi:alert-circle-outline" width="28" />
        </div>
        <div class="space-y-2">
          <Dialog.Title class="text-lg font-bold text-foreground">Confirm Stock Adjustment</Dialog.Title>
          <p class="text-sm text-muted-foreground">
            Are you sure you want to submit this inventory adjustment transaction?
          </p>
        </div>
      </div>
      <div class="flex justify-center gap-3 mt-6 pt-4 border-t">
        <Button type="button" variant="outline" onclick={() => { confirmSubmitOpen = false; pendingSubmitPayload = null; }}>Cancel</Button>
        <Button type="button" onclick={executeSubmitAdjustment} class="bg-primary hover:bg-primary/95 text-white">Yes, Confirm</Button>
      </div>
    </Dialog.Content>
  </Dialog.Root>
</div>
