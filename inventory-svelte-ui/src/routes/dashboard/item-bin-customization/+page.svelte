<script lang="ts">
  import type { PageData } from './$types';
  import type { UnitItem, UnitBin } from '$lib/types';
  import { invokeService } from '$lib/service/invokeService';
  import { toast } from 'svelte-sonner';
  import { Button } from '$lib/components/ui/button/index.js';
  import { Input } from '$lib/components/ui/input/index.js';
  import { Label } from '$lib/components/ui/label/index.js';
  import * as Table from '$lib/components/ui/table/index.js';
  import Icon from '@iconify/svelte';
  import TableControls from '$lib/components/inventory/TableControls.svelte';
  import SearchCombobox from '$lib/components/ui/SearchCombobox.svelte';
  import { activeUnit } from '$lib/store/unit';
  import { untrack } from 'svelte';

  let { data } = $props<{ data: PageData & { units: any[]; user: any } }>();

  // Table controls state
  const columns = [
    { key: 'item_description', label: 'Item Description' },
    { key: 'category', label: 'Category' },
    { key: 'stocking_unit', label: 'Stocking Unit' },
    { key: 'current_bin', label: 'Current Bin' },
    { key: 'switch_bin', label: 'Switch to Bin' }
  ];

  let visibleColumns = $state<Record<string, boolean>>({
    item_description: true,
    category: true,
    stocking_unit: true,
    current_bin: true,
    switch_bin: true
  });

  let limit = $state(10);
  let page = $state(1);

  let selectedUnitId = $state<number | null>(data.units[0]?.unit_id || null);

  // Sync selectedUnitId with global activeUnit store
  $effect(() => {
    if ($activeUnit) {
      selectedUnitId = $activeUnit.unit_id;
    }
  });

  $effect(() => {
    if (selectedUnitId !== null && selectedUnitId > 0) {
      untrack(() => {
        const match = data.units.find((u: any) => u.unit_id === selectedUnitId);
        if (match && (!$activeUnit || $activeUnit.unit_id !== selectedUnitId)) {
          activeUnit.set({ unit_id: match.unit_id, description: match.description });
        }
      });
    }
  });

  let searchQuery = $state('');
  let unitItems = $state<UnitItem[]>([]);
  let unitBins = $state<UnitBin[]>([]);
  let loadingData = $state(false);
  let savingChanges = $state(false);

  let unitOptions = $derived(
    data.units.map((u: any) => ({ value: u.unit_id, label: u.description }))
  );
  let binOptions = $derived([
    { value: 0, label: 'None / Select Bin' },
    ...unitBins.map((b: any) => ({ value: b.bin_id, label: b.description }))
  ]);

  // Tracks selected bin_id per unit_item_id
  let binAssignments = $state<Record<number, number>>({});

  async function loadData() {
    if (!selectedUnitId) {
      unitItems = [];
      unitBins = [];
      binAssignments = {};
      return;
    }

    loadingData = true;
    const [itemsRes, binsRes] = await Promise.all([
      invokeService<any, UnitItem[]>('/get-inventory-unit-item', {
        body: {
          bol_getone: 0,
          unit_id: selectedUnitId,
          item_category_id: 0,
          unit_item_id: 0,
          item_description: ''
        },
        token: data.user.access_token
      }),
      invokeService<any, UnitBin[]>('/get-inventory-unit-bin', {
        body: {
          bol_getone: 0,
          bin_id: 0,
          unit_id: selectedUnitId,
          description: ''
        },
        token: data.user.access_token
      })
    ]);
    loadingData = false;

    if ('data' in itemsRes && itemsRes.data.success) {
      const inner = itemsRes.data.data ?? itemsRes.data;
      unitItems = inner.json_data || [];
    } else {
      unitItems = [];
      const errMsg = 'error' in itemsRes ? itemsRes.error : (itemsRes.data?.message || 'Unknown error');
      console.error('[Item Bin Customization] Failed to load unit stock items:', errMsg, itemsRes);
      toast.error(`Failed to load unit stock items: ${errMsg}`);
    }

    if ('data' in binsRes && binsRes.data.success) {
      const inner = binsRes.data.data ?? binsRes.data;
      unitBins = inner.json_data || [];
    } else {
      unitBins = [];
      const errMsg = 'error' in binsRes ? binsRes.error : (binsRes.data?.message || 'Unknown error');
      console.error('[Item Bin Customization] Failed to load unit bins:', errMsg, binsRes);
      toast.error(`Failed to load unit bins: ${errMsg}`);
    }

    // Initialize bin assignments with current bin ids
    const tempAssignments: Record<number, number> = {};
    unitItems.forEach(item => {
      if (item.unit_item_id) {
        tempAssignments[item.unit_item_id] = item.bin_id || 0;
      }
    });
    binAssignments = tempAssignments;
  }

  $effect(() => {
    if (selectedUnitId && selectedUnitId > 0) {
      loadData();
    }
  });

  let filteredItems = $derived(
    unitItems.filter(item =>
      (item.item_description || '').toLowerCase().includes(searchQuery.toLowerCase()) ||
      (item.item_category_description || '').toLowerCase().includes(searchQuery.toLowerCase())
    )
  );

  let paginatedItems = $derived(
    filteredItems.slice((page - 1) * limit, page * limit)
  );

  $effect(() => {
    if (selectedUnitId !== null || searchQuery) {
      page = 1;
    }
  });

  // Detect which items have pending modifications
  let modifiedCount = $derived(
    Object.entries(binAssignments).filter(([unitItemIdStr, toBinId]) => {
      const unitItemId = Number(unitItemIdStr);
      const original = unitItems.find(ui => ui.unit_item_id === unitItemId);
      return original && (original.bin_id || 0) !== toBinId;
    }).length
  );

  async function saveChanges() {
    const swappedItems = Object.entries(binAssignments)
      .map(([unitItemIdStr, toBinId]) => {
        const unitItemId = Number(unitItemIdStr);
        const original = unitItems.find(ui => ui.unit_item_id === unitItemId);
        const fromBinId = original?.bin_id || 0;
        return {
          unit_item_id: unitItemId,
          from_bin_id: fromBinId,
          to_bin_id: toBinId
        };
      })
      .filter(swap => swap.from_bin_id !== swap.to_bin_id && swap.to_bin_id > 0);

    if (swappedItems.length === 0) {
      toast.warning('No customizations have been modified.');
      return;
    }

    savingChanges = true;
    const toastId = toast.loading('Saving bin customizations...');
    const response = await invokeService<any, any>('/post-unit-item-bin-switch', {
      body: {
        user_id: data.user.member?.member_id ?? 1,
        swapped_items: swappedItems
      },
      token: data.user.access_token
    });
    savingChanges = false;

    if ('data' in response && response.data.success) {
      toast.success('Bin assignments switched successfully', { id: toastId });
      loadData();
    } else {
      const errMsg = 'error' in response ? response.error : (response.data?.message || 'Unknown error');
      console.error('[Item Bin Customization] Failed to switch bin assignments:', errMsg, response);
      toast.error(`Failed to switch bin assignments: ${errMsg}`, { id: toastId });
    }
  }

  function resetChanges() {
    const tempAssignments: Record<number, number> = {};
    unitItems.forEach(item => {
      if (item.unit_item_id) {
        tempAssignments[item.unit_item_id] = item.bin_id || 0;
      }
    });
    binAssignments = tempAssignments;
    toast.info('Modifications reverted');
  }
</script>

<svelte:head>
  <title>Item Bin Customization - Serenity Inventory</title>
</svelte:head>

<div class="space-y-6">
  <!-- Page Header -->
  <div class="flex items-center justify-between">
    <div>
      <h2 class="text-2xl font-bold font-playfair text-primary">Item Bin Customization</h2>
      <p class="text-sm text-muted-foreground">Re-assign and switch bin locations for items within a unit.</p>
    </div>
    {#if modifiedCount > 0}
      <div class="flex gap-2">
        <Button onclick={resetChanges} variant="outline" class="h-9 px-4">
          Reset Changes
        </Button>
        <Button onclick={saveChanges} disabled={savingChanges} class="bg-teal-600 hover:bg-teal-700 text-white h-9 px-4 flex items-center gap-1.5 shadow-sm">
          <Icon icon="mdi:content-save-outline" width="18" />
          Save Changes ({modifiedCount})
        </Button>
      </div>
    {/if}
  </div>

  <!-- Filters / Controls -->
  <div class="flex flex-wrap items-end gap-4 bg-card border rounded-xl p-4 shadow-sm">
    <div class="flex flex-col gap-1.5 min-w-[250px] w-full sm:w-auto">
      <Label for="unit-select" class="text-xs font-bold uppercase tracking-wider text-muted-foreground">Select Unit (Warehouse/Employee)</Label>
      <SearchCombobox
        options={unitOptions}
        bind:value={selectedUnitId}
        placeholder="Select Unit..."
        searchPlaceholder="Search unit..."
      />
    </div>

    <div class="flex flex-col gap-1.5 w-full sm:max-w-md">
      <Label for="item-search" class="text-xs font-bold uppercase tracking-wider text-muted-foreground">Search Items / Categories</Label>
      <div class="relative w-full">
        <Icon icon="mdi:magnify" width="16" class="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground pointer-events-none" />
        <Input
          id="item-search"
          type="text"
          placeholder="Search item description or category..."
          bind:value={searchQuery}
          autocomplete="off"
          class="pl-9 h-10"
        />
      </div>
    </div>
  </div>

  <!-- Table list -->
  <div class="relative">
    {#if loadingData}
      <div class="absolute inset-0 z-10 flex items-center justify-center bg-white/70">
        <Icon icon="mdi:loading" class="text-primary animate-spin" width="32" />
      </div>
    {/if}

    <TableControls
      {columns}
      bind:visibleColumns
      bind:limit
      bind:page
      total={filteredItems.length}
    >
      <Table.Root>
        <Table.Header>
          <Table.Row class="bg-primary/5 hover:bg-primary/5 border-b-2 border-primary/10">
            {#if visibleColumns.item_description !== false}
              <Table.Head class="font-bold text-xs uppercase tracking-wider text-foreground/60">Item Description</Table.Head>
            {/if}
            {#if visibleColumns.category !== false}
              <Table.Head class="font-bold text-xs uppercase tracking-wider text-foreground/60">Category</Table.Head>
            {/if}
            {#if visibleColumns.stocking_unit !== false}
              <Table.Head class="w-[120px] font-bold text-xs uppercase tracking-wider text-foreground/60">Stocking Unit</Table.Head>
            {/if}
            {#if visibleColumns.current_bin !== false}
              <Table.Head class="w-[150px] font-bold text-xs uppercase tracking-wider text-foreground/60">Current Bin</Table.Head>
            {/if}
            {#if visibleColumns.switch_bin !== false}
              <Table.Head class="w-[220px] font-bold text-xs uppercase tracking-wider text-foreground/60">Switch to Bin</Table.Head>
            {/if}
          </Table.Row>
        </Table.Header>
        <Table.Body>
          {#if paginatedItems.length === 0}
            <Table.Row>
              <Table.Cell colspan={columns.filter(c => visibleColumns[c.key] !== false).length} class="h-40 text-center">
                <div class="flex flex-col items-center gap-2 text-muted-foreground">
                  <Icon icon="mdi:package-variant-closed-remove" width="36" class="opacity-30" />
                  <span class="text-sm">No items found in this unit.</span>
                </div>
              </Table.Cell>
            </Table.Row>
          {:else}
            {#each paginatedItems as item, i (item.unit_item_id)}
              {@const isModified = item.unit_item_id ? (binAssignments[item.unit_item_id] !== (item.bin_id || 0)) : false}
              <Table.Row class="hover:bg-primary/5 transition-colors {isModified ? 'bg-amber-50/45 hover:bg-amber-50/70 border-l-4 border-l-amber-500' : (i % 2 === 1 ? 'bg-muted/20' : '')}">
                {#if visibleColumns.item_description !== false}
                  <Table.Cell class="font-semibold text-foreground">{item.item_description}</Table.Cell>
                {/if}
                {#if visibleColumns.category !== false}
                  <Table.Cell class="text-slate-500">{item.item_category_description || 'General'}</Table.Cell>
                {/if}
                {#if visibleColumns.stocking_unit !== false}
                  <Table.Cell class="font-mono text-xs font-bold text-foreground/60">{item.stocking_unit}</Table.Cell>
                {/if}
                {#if visibleColumns.current_bin !== false}
                  <Table.Cell>
                    {#if item.bin_description}
                      <span class="inline-flex items-center gap-1 text-xs px-2 py-1 bg-slate-100 text-slate-700 font-semibold rounded-md">
                        <Icon icon="mdi:archive-outline" width="13" />
                        {item.bin_description}
                      </span>
                    {:else}
                      <span class="text-xs text-muted-foreground italic">None Assigned</span>
                    {/if}
                  </Table.Cell>
                {/if}
                {#if visibleColumns.switch_bin !== false}
                  <Table.Cell>
                    {#if item.unit_item_id}
                      <SearchCombobox
                        options={binOptions}
                        bind:value={binAssignments[item.unit_item_id]}
                        placeholder="Select Bin..."
                        searchPlaceholder="Search bin..."
                        class="h-8 max-w-[200px] text-xs font-semibold {isModified ? 'border-amber-400 ring-1 ring-amber-400 bg-amber-50/10' : ''}"
                      />
                    {/if}
                  </Table.Cell>
                {/if}
              </Table.Row>
            {/each}
          {/if}
        </Table.Body>
      </Table.Root>
    </TableControls>
  </div>
</div>
