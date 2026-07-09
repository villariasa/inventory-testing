<script lang="ts">
  import type { PageData } from './$types';
  import type { InventoryUnit, UnitItem, UnitItemHistory, ItemCategory } from '$lib/types';
  import { invokeService } from '$lib/service/invokeService';
  import { toast } from 'svelte-sonner';
  import * as Table from '$lib/components/ui/table/index.js';
  import * as Dialog from '$lib/components/ui/dialog/index.js';
  import { Label } from '$lib/components/ui/label/index.js';
  import { Button } from '$lib/components/ui/button/index.js';
  import { Input } from '$lib/components/ui/input/index.js';
  import Icon from '@iconify/svelte';
  import TableControls from '$lib/components/inventory/TableControls.svelte';
  import SearchCombobox from '$lib/components/ui/SearchCombobox.svelte';
  import ItemSelect from '$lib/components/inventory/ItemSelect.svelte';
  import * as DropdownMenu from '$lib/components/ui/dropdown-menu/index.js';
  import { activeUnit } from '$lib/store/unit';
  import { untrack } from 'svelte';
  import { imageCacheStore } from '$lib/store/imageCache.svelte';


  let { data } = $props<{ data: PageData & { units: InventoryUnit[]; categories: ItemCategory[]; user: any } }>();

  // Filter selection states
  let selectedUnitId = $state<number | null>(null);
  let selectedCategoryId = $state<number | null>(null);
  let searchQuery = $state('');

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

  // Validated filtering details (to trigger fetch only on explicit search / enter)
  let validatedUnitId = $state<number | null>(null);
  let validatedCategoryId = $state<number | null>(null);
  let searchExecuted = $state(false);

  // Table items state
  let unitItems = $state<UnitItem[]>([]);
  let loadingItems = $state(false);

  // Set of recently saved/edited unit_item_id to highlight rows (legacy routine)
  let savedItemIds = $state<Set<number>>(new Set());

  // Combobox dropdown options
  let unitOptions = $derived(
    data.units.map((u: any) => ({ value: u.unit_id, label: u.description }))
  );
  let categoryOptions = $derived(
    data.categories.map((c: any) => ({ value: c.item_category_id, label: c.item_category_description }))
  );

  // Table controls configuration
  const columns = [
    { key: 'image', label: 'Image' },
    { key: 'category', label: 'Category' },
    { key: 'item_description', label: 'Item Name / Description' },
    { key: 'qty', label: 'Qty On Hand' }
  ];

  let visibleColumns = $state<Record<string, boolean>>({
    image: true,
    category: true,
    item_description: true,
    qty: true
  });

  let limit = $state(10);
  let page = $state(1);

  // Local items state
  let filteredItems = $derived(
    unitItems.filter(item =>
      (item.item_description || '').toLowerCase().includes(searchQuery.toLowerCase())
    )
  );

  let paginatedItems = $derived(
    filteredItems.slice((page - 1) * limit, page * limit)
  );

  let visibleColumnCount = $derived(
    Object.values(visibleColumns).filter(Boolean).length
  );

  // Track which item_ids are currently being fetched to avoid duplicate requests
  let fetchingImageIds = new Set<number>();

  // Lazy-load images for currently visible (paginated) items
  $effect(() => {
    if (!visibleColumns.image) return;
    for (const item of paginatedItems) {
      const itemId = item.item_id;
      if (itemId && !imageCacheStore.has(itemId) && !fetchingImageIds.has(itemId)) {
        fetchingImageIds.add(itemId);
        imageCacheStore.fetch(itemId, data.user.access_token).finally(() => {
          fetchingImageIds.delete(itemId);
        });
      }
    }
  });

  // Manage selection flow
  let lastUnitId = $state<number | null>(null);

  // Automatically load unit items when unit and category are selected
  $effect(() => {
    if (selectedUnitId !== null && selectedUnitId > 0 && selectedCategoryId !== null && selectedCategoryId > 0) {
      loadUnitItems(selectedUnitId, selectedCategoryId);
    } else {
      unitItems = [];
    }
  });

  // Reset page when search changes
  $effect(() => {
    if (searchQuery) {
      page = 1;
    }
  });

  async function loadUnitItems(unitId: number, categoryId: number) {
    loadingItems = true;
    const response = await invokeService<any, any>('/get-inventory-unit-item', {
      body: {
        bol_getone: 0,
        unit_id: unitId,
        item_category_id: categoryId,
        unit_item_id: 0,
        item_description: ''
      },
      token: data.user.access_token
    });
    loadingItems = false;

    if ('data' in response && response.data.success) {
      const inner = response.data.data ?? response.data;
      unitItems = inner.json_data || [];
    } else {
      unitItems = [];
      const errMsg = 'error' in response ? response.error : (response.data?.message || 'Unknown error');
      console.error('[Unit Stock Items] Failed to load unit items:', errMsg);
      toast.error(`Failed to load unit items: ${errMsg}`);
    }
  }


  // ProperCase helper to match legacy styling
  function properCase(str: string): string {
    if (!str) return '';
    return str.split(' ').map(w => w.charAt(0).toUpperCase() + w.slice(1).toLowerCase()).join(' ');
  }

  // Dialog Form States (Add / Edit / View)
  let dialogOpen = $state(false);
  let dialogMode = $state<'Add' | 'Edit' | 'View'>('Add');
  let dialogLoading = $state(false);
  let selectedItem = $state<UnitItem | null>(null);

  // Form Fields
  let unit_item_id = $state(0);
  let selectedItemId = $state<number | null>(null);
  let itemSearchQuery = $state('');

  let selectedBinId = $state<number | null>(null);
  let binSearchQuery = $state('');

  let transactionDate = $state('');
  let lastEntry = $state('');
  let startingQuantity = $state(0);
  let quantityIn = $state(0);
  let quantityOut = $state(0);
  let unitCost = $state(0);
  let lastHighestInUnitCost = $state(0);

  // Comma formatting
  let unitCostInputStr = $state('');
  let lastHighestInUnitCostInputStr = $state('');

  function formatInputWithCommas(val: string): string {
    let clean = val.replace(/,/g, '');
    clean = clean.replace(/[^\d.]/g, '');
    const dotIndex = clean.indexOf('.');
    if (dotIndex !== -1) {
      let before = clean.substring(0, dotIndex);
      let after = clean.substring(dotIndex + 1).replace(/\./g, '');
      if (before) {
        const num = parseFloat(before);
        if (!isNaN(num)) before = num.toLocaleString('en-US');
      }
      return before + '.' + after;
    } else {
      if (!clean) return '';
      const num = parseFloat(clean);
      if (isNaN(num)) return '';
      return num.toLocaleString('en-US');
    }
  }

  function handleUnitCostInput(e: Event) {
    const input = e.currentTarget as HTMLInputElement;
    const selectionStart = input.selectionStart;
    const origLen = input.value.length;
    const formatted = formatInputWithCommas(input.value);
    unitCostInputStr = formatted;
    const numeric = parseFloat(formatted.replace(/,/g, ''));
    unitCost = isNaN(numeric) ? 0 : numeric;
    setTimeout(() => {
      const newLen = formatted.length;
      if (selectionStart !== null) {
        input.setSelectionRange(selectionStart + (newLen - origLen), selectionStart + (newLen - origLen));
      }
    }, 0);
  }

  function handleLastHighestInUnitCostInput(e: Event) {
    const input = e.currentTarget as HTMLInputElement;
    const selectionStart = input.selectionStart;
    const origLen = input.value.length;
    const formatted = formatInputWithCommas(input.value);
    lastHighestInUnitCostInputStr = formatted;
    const numeric = parseFloat(formatted.replace(/,/g, ''));
    lastHighestInUnitCost = isNaN(numeric) ? 0 : numeric;
    setTimeout(() => {
      const newLen = formatted.length;
      if (selectionStart !== null) {
        input.setSelectionRange(selectionStart + (newLen - origLen), selectionStart + (newLen - origLen));
      }
    }, 0);
  }

  // Autocomplete lists for Dialog Form
  let catalogItems = $state<{ value: number; label: string }[]>([]);
  let loadingCatalogItems = $state(false);

  let emptyBins = $state<{ value: number; label: string }[]>([]);
  let loadingEmptyBins = $state(false);

  // Reactive Derived Values for calculations (legacy keyup routines)
  let endingQuantity = $derived(
    Math.round((Number(startingQuantity) + Number(quantityIn) - Number(quantityOut)) * 100) / 100
  );
  let startingCost = $derived(
    Math.round((Number(unitCost) * Number(startingQuantity)) * 100) / 100
  );
  let costIn = $derived(
    Math.round((Number(unitCost) * Number(quantityIn)) * 100) / 100
  );
  let costOut = $derived(
    Math.round((Number(unitCost) * Number(quantityOut)) * 100) / 100
  );
  let endingCost = $derived(
    Math.round((Number(unitCost) * endingQuantity) * 100) / 100
  );

  let todayString = $derived(new Date().toISOString().split('T')[0]);

  // Autocomplete fetch triggers
  $effect(() => {
    if (dialogOpen && dialogMode === 'Add' && selectedCategoryId !== null && selectedUnitId !== null) {
      const query = itemSearchQuery;
      const uId = selectedUnitId;
      const cId = selectedCategoryId;
      const delay = setTimeout(() => {
        fetchCatalogItemsNoUnit(uId, cId, query);
      }, 300);
      return () => clearTimeout(delay);
    }
  });

  async function fetchCatalogItemsNoUnit(unitId: number, categoryId: number, query: string) {
    loadingCatalogItems = true;
    const response = await invokeService<any, any>('/get-inventory-item-no-unit', {
      body: {
        unit_id: unitId,
        item_category_id: categoryId,
        item_description: query.trim()
      },
      token: data.user.access_token
    });
    loadingCatalogItems = false;

    if ('data' in response && response.data.success) {
      const inner = response.data.data ?? response.data;
      const rawList = inner.json_data || [];
      catalogItems = rawList.map((item: any) => ({
        value: item.item_id,
        label: properCase(item.item_description)
      }));
    } else {
      catalogItems = [];
    }
  }

  async function fetchEmptyBins(unitId: number, query: string = '') {
    loadingEmptyBins = true;
    const response = await invokeService<any, any>('/get-empty-unit-bin', {
      body: {
        bol_getone: 0,
        bin_id: 0,
        unit_id: unitId,
        description: query.trim()
      },
      token: data.user.access_token
    });
    loadingEmptyBins = false;

    if ('data' in response && response.data.success) {
      const inner = response.data.data ?? response.data;
      const rawList = inner.json_data || [];
      const mapped = rawList.map((bin: any) => ({
        value: bin.bin_id,
        label: properCase(bin.description)
      }));

      // Preserve currently selected bin (since it won't be in empty list as it is already used)
      if (selectedBinId !== null && !mapped.some((b: any) => b.value === selectedBinId)) {
        let currentBinLabel = 'No Bin';
        if (selectedItem && selectedBinId === selectedItem.bin_id) {
          currentBinLabel = selectedItem.bin || selectedItem.bin_description || 'No Bin';
        } else {
          currentBinLabel = binSearchQuery || 'No Bin';
        }
        mapped.unshift({
          value: selectedBinId,
          label: properCase(currentBinLabel)
        });
      }
      emptyBins = mapped;
    } else {
      emptyBins = [];
    }
  }

  // Dialog actions
  function openAdd() {
    if (selectedUnitId === null || selectedUnitId === 0 || selectedCategoryId === null || selectedCategoryId === 0) {
      toast.error('Please select a valid unit and category first.');
      return;
    }
    dialogMode = 'Add';
    selectedItem = null;
    unit_item_id = 0;
    selectedItemId = null;
    itemSearchQuery = '';
    selectedBinId = null;
    binSearchQuery = '';
    
    transactionDate = todayString;
    lastEntry = '';
    startingQuantity = 0.00;
    quantityIn = 0.00;
    quantityOut = 0.00;
    unitCost = 0.00;
    unitCostInputStr = '';
    lastHighestInUnitCost = 0.00;
    lastHighestInUnitCostInputStr = '';

    fetchEmptyBins(selectedUnitId);
    dialogOpen = true;
  }

  async function openEditOrView(id: number, mode: 'Edit' | 'View') {
    dialogMode = mode;
    dialogLoading = true;
    dialogOpen = true;

    const response = await invokeService<any, any>('/get-inventory-unit-item', {
      body: {
        bol_getone: 1,
        unit_id: selectedUnitId || 0,
        item_category_id: selectedCategoryId || 0,
        unit_item_id: id,
        item_description: ''
      },
      token: data.user.access_token
    });
    dialogLoading = false;

    if ('data' in response && response.data.success) {
      const inner = response.data.data ?? response.data;
      const oData = inner.json_data || [];
      if (oData.length > 0) {
        const row = oData[0];
        selectedItem = row;
        unit_item_id = row.unit_item_id;
        selectedItemId = row.item_id;
        catalogItems = [{ value: row.item_id, label: properCase(row.item_description) }];
        itemSearchQuery = row.item_description;

        selectedBinId = row.bin_id;
        emptyBins = [{ value: row.bin_id, label: properCase(row.bin || row.bin_description || 'No Bin') }];
        binSearchQuery = row.bin || row.bin_description || '';

        transactionDate = row.starting_period ? row.starting_period.slice(0, 10) : '';
        lastEntry = row.last_entry ? row.last_entry.slice(0, 10) : '';
        startingQuantity = row.starting_quantity || 0;
        quantityIn = row.quantity_in || 0;
        quantityOut = row.quantity_out || 0;
        unitCost = row.unit_cost || 0;
        unitCostInputStr = row.unit_cost ? formatInputWithCommas(String(row.unit_cost)) : '';
        lastHighestInUnitCost = row.last_highest_in_unit_cost || 0;
        lastHighestInUnitCostInputStr = row.last_highest_in_unit_cost ? formatInputWithCommas(String(row.last_highest_in_unit_cost)) : '';

        fetchEmptyBins(row.unit_id);
      }
    } else {
      toast.error('Failed to load unit item details.');
      dialogOpen = false;
    }
  }

  let confirmOpen = $state(false);

  function handleSubmit(e: Event) {
    e.preventDefault();
    if (selectedUnitId === null || selectedCategoryId === null) return;
    if (selectedItemId === null) {
      toast.error('Please select an inventory item.');
      return;
    }
    if (selectedBinId === null) {
      toast.error('Please select an item bin.');
      return;
    }
    if (!transactionDate) {
      toast.error('Transaction date is required.');
      return;
    }

    const selectedDate = new Date(transactionDate);
    const today = new Date();
    today.setHours(23, 59, 59, 999);
    if (selectedDate > today) {
      toast.error('Transaction date cannot be in the future.');
      return;
    }

    confirmOpen = true;
  }

  async function executeSave() {
    confirmOpen = false;
    dialogOpen = false;

    const process_type = dialogMode === 'Add' ? 0 : 1;
    const toastId = toast.loading(dialogMode === 'Add' ? 'Saving unit item...' : 'Updating unit item...');

    const response = await invokeService<any, any>('/post-inventory-unit-item', {
      body: {
        process_type,
        unit_item_id,
        item_id: selectedItemId,
        unit_id: selectedUnitId,
        starting_period: transactionDate,
        starting_quantity: Number(startingQuantity),
        quantity_in: Number(quantityIn),
        quantity_out: Number(quantityOut),
        unit_cost: Number(unitCost),
        last_highest_in_unit_cost: Number(lastHighestInUnitCost),
        bin_id: selectedBinId,
        user_id: data.user.member?.member_id ?? 1
      },
      token: data.user.access_token
    });

    if ('data' in response && response.data.success) {
      toast.success(dialogMode === 'Add' ? 'Unit item saved successfully' : 'Unit item updated successfully', { id: toastId });
      
      const inner = response.data.data ?? response.data;
      const returnedId = Number(inner.json_data);
      if (returnedId > 0) {
        savedItemIds = new Set([...savedItemIds, returnedId]);
      }
      
      await loadUnitItems(selectedUnitId!, selectedCategoryId!);
    } else {
      const errMsg = 'error' in response ? response.error : (response.data?.message || 'Unknown error');
      toast.error(`Failed to save unit item: ${errMsg}`, { id: toastId });
    }
  }

  // Nested Bin Creation Dialog
  let addBinOpen = $state(false);
  let newBinDesc = $state('');

  function openAddBin() {
    newBinDesc = '';
    addBinOpen = true;
  }

  async function submitAddBin(e: Event) {
    e.preventDefault();
    if (!newBinDesc.trim() || selectedUnitId === null) return;

    const response = await invokeService<any, any>('/post-inventory-unit-bin', {
      body: {
        process_type: 0,
        unit_id: selectedUnitId,
        description: newBinDesc.trim(),
        user_id: data.user.member?.member_id ?? 1,
        bin_id: 0
      },
      token: data.user.access_token
    });

    if ('data' in response && response.data.success) {
      toast.success('Bin created successfully');
      addBinOpen = false;
      await fetchEmptyBins(selectedUnitId);
      
      const matched = emptyBins.find(b => b.label.toLowerCase() === newBinDesc.trim().toLowerCase());
      if (matched) {
        selectedBinId = Number(matched.value);
      }
    } else {
      const errMsg = 'error' in response ? response.error : (response.data?.message || 'Unknown error');
      toast.error(`Failed to create bin: ${errMsg}`);
    }
  }


</script>

<svelte:head>
  <title>Unit Items - Serenity Inventory</title>
</svelte:head>

<div class="space-y-6">
  <!-- Page Header -->
  <div class="flex items-center justify-between">
    <div>
      <h2 class="text-2xl font-bold font-playfair text-primary">Unit Stock Items</h2>
      <p class="text-sm text-muted-foreground">Manage, search, and assign inventory items within a selected unit or warehouse.</p>
    </div>
    {#if selectedUnitId !== null && selectedUnitId > 0 && selectedCategoryId !== null && selectedCategoryId > 0}
      <Button onclick={openAdd} class="bg-primary hover:bg-primary/95 text-white flex items-center gap-2">
        <Icon icon="mdi:plus" width="20" />
        Add Item
      </Button>
    {/if}
  </div>

  <!-- Filters & Toolbar -->
  <div class="bg-card border rounded-xl p-4 shadow-sm flex flex-wrap items-end gap-4">
    <div class="flex flex-col gap-1.5 min-w-[240px] flex-1">
      <Label class="text-xs font-semibold text-muted-foreground uppercase tracking-wider">Select Warehouse / Unit *</Label>
      <SearchCombobox
        options={unitOptions}
        bind:value={selectedUnitId}
        placeholder="Select Warehouse / Unit..."
        searchPlaceholder="Search warehouse..."
      />
    </div>

    <div class="flex flex-col gap-1.5 min-w-[240px] flex-1">
      <Label class="text-xs font-semibold text-muted-foreground uppercase tracking-wider">Select Category *</Label>
      <SearchCombobox
        options={categoryOptions}
        bind:value={selectedCategoryId}
        placeholder="Select Category..."
        searchPlaceholder="Search category..."
      />
    </div>

    <div class="flex flex-col gap-1.5 min-w-[240px] flex-1">
      <Label for="item-search" class="text-xs font-semibold text-muted-foreground uppercase tracking-wider">Search Item Description</Label>
      <div class="relative w-full">
        <Input
          id="item-search"
          type="text"
          placeholder="Search item description..."
          bind:value={searchQuery}
          autocomplete="off"
          class="pr-12 h-10 text-sm"
        />
        <div
          class="absolute right-0 top-0 h-10 px-3.5 bg-primary/10 text-primary border-l rounded-r-md flex items-center justify-center pointer-events-none"
        >
          <Icon icon="mdi:magnify" width="18" />
        </div>
      </div>
    </div>
  </div>

  <!-- Items Table Grid -->
  <div class="relative">
    {#if loadingItems}
      <div class="absolute inset-0 z-20 flex items-center justify-center bg-card/60">
        <Icon icon="mdi:loading" class="animate-spin text-primary" width="36" />
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
            {#if visibleColumns.image !== false}
              <Table.Head class="w-[56px] text-xs font-bold tracking-wider text-foreground/60 uppercase"></Table.Head>
            {/if}
            {#if visibleColumns.category !== false}
              <Table.Head class="font-bold text-xs uppercase tracking-wider text-foreground/60 text-center">Category</Table.Head>
            {/if}
            {#if visibleColumns.item_description !== false}
              <Table.Head class="font-bold text-xs uppercase tracking-wider text-foreground/60">Item Name / Description</Table.Head>
            {/if}
            {#if visibleColumns.qty !== false}
              <Table.Head class="text-right font-bold text-xs uppercase tracking-wider text-foreground/60">Qty On Hand</Table.Head>
            {/if}
            <Table.Head class="text-center w-[120px] font-bold text-xs uppercase tracking-wider text-foreground/60 font-semibold"></Table.Head>
          </Table.Row>
        </Table.Header>
        <Table.Body>
          {#if selectedUnitId === null || selectedUnitId === 0 || selectedCategoryId === null || selectedCategoryId === 0}
            <Table.Row>
              <Table.Cell colspan={visibleColumnCount + 1} class="h-40 text-center">
                <div class="flex flex-col items-center gap-2 text-muted-foreground">
                  <Icon icon="mdi:filter-outline" width="36" class="opacity-30" />
                  <span class="text-sm font-semibold">Please select a valid unit and category to view table result.</span>
                </div>
              </Table.Cell>
            </Table.Row>
          {:else}
            {#if paginatedItems.length === 0}
              <Table.Row>
                <Table.Cell colspan={visibleColumnCount + 1} class="h-40 text-center">
                  <div class="flex flex-col items-center gap-2 text-muted-foreground">
                    <Icon icon="mdi:layers-off-outline" width="36" class="opacity-30" />
                    <span class="text-sm">No items found matching the search.</span>
                  </div>
                </Table.Cell>
              </Table.Row>
            {:else}
              {#each paginatedItems as item, i (item.unit_item_id)}
                <Table.Row class="hover:bg-primary/5 transition-colors {i % 2 === 1 ? 'bg-muted/20' : ''} {savedItemIds.has(item.unit_item_id) ? 'bg-[#c7e0ff]/30 text-black font-semibold' : ''}">
                  {#if visibleColumns.image !== false}
                    <Table.Cell class="w-[56px] p-1.5">
                      {@const cachedImage = imageCacheStore.get(item.item_id)}
                      {#if cachedImage}
                        <div class="w-10 h-10 rounded-lg overflow-hidden border border-border bg-muted/30 flex items-center justify-center">
                          <img src={cachedImage} alt={item.item_description} class="w-full h-full object-cover" />
                        </div>
                      {:else if cachedImage === null}
                        <div class="w-10 h-10 rounded-lg border border-border bg-muted/20 flex items-center justify-center">
                          <Icon icon="mdi:image-off-outline" width="16" class="text-muted-foreground/40" />
                        </div>
                      {:else}
                        <div class="w-10 h-10 rounded-lg border border-border bg-muted/20 flex items-center justify-center animate-pulse">
                          <Icon icon="mdi:image-outline" width="16" class="text-muted-foreground/30" />
                        </div>
                      {/if}
                    </Table.Cell>
                  {/if}
                  {#if visibleColumns.category !== false}
                    <Table.Cell class="text-center">{properCase(item.item_category || '')}</Table.Cell>
                  {/if}
                  {#if visibleColumns.item_description !== false}
                    <Table.Cell class="font-semibold text-foreground">
                      {properCase(item.item_description)}
                    </Table.Cell>
                  {/if}
                  {#if visibleColumns.qty !== false}
                    <Table.Cell class="text-right font-mono font-bold text-foreground">
                      {(item.qty_on_hand || item.ending_quantity || 0).toLocaleString()}
                    </Table.Cell>
                  {/if}
                  <Table.Cell class="text-center">
                    <DropdownMenu.Root>
                      <DropdownMenu.Trigger class="rounded-lg p-1.5 text-muted-foreground transition-colors hover:bg-muted hover:text-foreground focus:outline-none">
                        <Icon icon="mdi:dots-vertical" width="17" />
                      </DropdownMenu.Trigger>
                      <DropdownMenu.Content class="bg-card rounded-xl shadow-xl border border-border p-1.5 min-w-44 z-50 mt-1" align="end">
                        <DropdownMenu.Item onclick={() => openEditOrView(item.unit_item_id, 'View')} class="flex items-center gap-2 hover:bg-muted px-3 py-2 rounded-lg cursor-pointer text-sm transition-colors text-foreground font-medium">
                          <Icon icon="mdi:eye-outline" width="16" class="text-muted-foreground" />
                          View Details
                        </DropdownMenu.Item>
                        <DropdownMenu.Item onclick={() => openEditOrView(item.unit_item_id, 'Edit')} class="flex items-center gap-2 hover:bg-muted px-3 py-2 rounded-lg cursor-pointer text-sm transition-colors text-teal-650 dark:text-teal-455 font-medium">
                          <Icon icon="mdi:pencil-outline" width="16" />
                          Edit Details
                        </DropdownMenu.Item>
                      </DropdownMenu.Content>
                    </DropdownMenu.Root>
                  </Table.Cell>
                </Table.Row>
              {/each}
            {/if}
          {/if}
        </Table.Body>
      </Table.Root>
    </TableControls>
  </div>

  <!-- Management Dialog (Add / Edit / View) -->
  <Dialog.Root bind:open={dialogOpen}>
    <Dialog.Content 
      onInteractOutside={(e) => e.preventDefault()}
      onEscapeKeydown={(e) => e.preventDefault()}
      class="sm:max-w-[700px] max-h-[90vh] overflow-y-auto bg-card border rounded-2xl shadow-2xl p-0 flex flex-col"
    >
      <div class="bg-primary/5 border-b px-6 py-4 shrink-0">
        <Dialog.Header>
          <div class="flex items-center gap-2">
            <div class="w-9 h-9 rounded-xl bg-primary/10 flex items-center justify-center text-primary">
              <Icon icon={dialogMode === 'Add' ? 'mdi:plus' : dialogMode === 'Edit' ? 'mdi:pencil-outline' : 'mdi:eye-outline'} width="20" />
            </div>
            <Dialog.Title class="text-xl font-bold font-playfair text-primary">
              {dialogMode} Unit Item
            </Dialog.Title>
          </div>
        </Dialog.Header>
      </div>

      {#if dialogLoading}
        <div class="p-10 flex flex-col items-center justify-center gap-2 text-muted-foreground">
          <Icon icon="mdi:loading" class="animate-spin text-primary" width="36" />
          <span class="text-sm">Loading details...</span>
        </div>
      {:else}
        <form onsubmit={handleSubmit} class="p-6 space-y-6 overflow-y-auto flex-1">
          <!-- selectors -->
          <div class="grid grid-cols-2 gap-4">
            <!-- Unit Dropdown -->
            <div class="flex flex-col gap-1.5">
              <Label class="text-xs font-semibold text-muted-foreground">Unit</Label>
              <SearchCombobox
                options={unitOptions}
                value={selectedUnitId}
                disabled={true}
                placeholder="Select unit..."
              />
            </div>

            <!-- Category Dropdown -->
            <div class="flex flex-col gap-1.5">
              <Label class="text-xs font-semibold text-muted-foreground">Category</Label>
              <SearchCombobox
                options={categoryOptions}
                value={selectedCategoryId}
                disabled={true}
                placeholder="Select category..."
              />
            </div>

            <!-- Inventory Item Search -->
            <div class="flex flex-col gap-1.5">
              <Label class="text-xs font-semibold text-muted-foreground">Inventory Item *</Label>
              <ItemSelect
                options={catalogItems}
                bind:value={selectedItemId}
                bind:searchValue={itemSearchQuery}
                placeholder={loadingCatalogItems ? "Searching..." : "Type description and select item..."}
                searchPlaceholder="Search catalog items..."
                disabled={dialogMode !== 'Add'}
                token={data.user.access_token}
              />
            </div>

            <!-- Item Bin selector -->
            <div class="flex flex-col gap-1.5">
              <Label class="text-xs font-semibold text-muted-foreground">Item Bin *</Label>
              <div class="flex gap-2">
                <div class="flex-1">
                  <SearchCombobox
                    options={emptyBins}
                    bind:value={selectedBinId}
                    bind:searchValue={binSearchQuery}
                    placeholder={loadingEmptyBins ? "Searching..." : "Select empty storage bin..."}
                    searchPlaceholder="Search empty bins..."
                    disabled={dialogMode === 'View'}
                  />
                </div>
                {#if dialogMode !== 'View'}
                  <Button
                    type="button"
                    variant="outline"
                    class="h-10 px-3 bg-primary/10 border-primary/20 text-primary hover:bg-primary/20"
                    onclick={openAddBin}
                    title="Add Storage Bin"
                  >
                    <Icon icon="mdi:plus" width="20" />
                  </Button>
                {/if}
              </div>
            </div>
          </div>

          <!-- dates -->
          <div class="grid grid-cols-2 gap-4 border-t pt-4">
            <div class="flex flex-col gap-1.5">
              <Label for="transaction_date" class="text-xs font-semibold text-muted-foreground">Transaction Date *</Label>
              <Input
                type="date"
                id="transaction_date"
                bind:value={transactionDate}
                max={todayString}
                disabled={dialogMode === 'View'}
                required
              />
            </div>

            <div class="flex flex-col gap-1.5">
              <Label for="last_entry" class="text-xs font-semibold text-muted-foreground">Last Entry</Label>
              <Input
                type="date"
                id="last_entry"
                value={lastEntry}
                disabled={true}
                readonly
              />
            </div>
          </div>

          <!-- quantities -->
          <div class="grid grid-cols-4 gap-4 border-t pt-4">
            <div class="flex flex-col gap-1.5">
              <Label for="starting_quantity" class="text-xs font-semibold text-muted-foreground">Starting Qty</Label>
              <Input
                type="number"
                id="starting_quantity"
                step="0.01"
                min="0"
                bind:value={startingQuantity}
                disabled={dialogMode === 'View'}
                required
                class="text-right"
              />
            </div>

            <div class="flex flex-col gap-1.5">
              <Label for="quantity_in" class="text-xs font-semibold text-muted-foreground">Qty In</Label>
              <Input
                type="number"
                id="quantity_in"
                value={quantityIn}
                disabled={true}
                readonly
                class="text-right bg-muted/50"
              />
            </div>

            <div class="flex flex-col gap-1.5">
              <Label for="quantity_out" class="text-xs font-semibold text-muted-foreground">Qty Out</Label>
              <Input
                type="number"
                id="quantity_out"
                value={quantityOut}
                disabled={true}
                readonly
                class="text-right bg-muted/50"
              />
            </div>

            <div class="flex flex-col gap-1.5">
              <Label for="ending_quantity" class="text-xs font-bold text-primary">Ending Qty</Label>
              <Input
                type="number"
                id="ending_quantity"
                value={endingQuantity}
                disabled={true}
                readonly
                class="text-right bg-primary/5 font-semibold text-primary"
              />
            </div>
          </div>

          <!-- costing values -->
          <div class="grid grid-cols-4 gap-4 border-t pt-4">
            <div class="flex flex-col gap-1.5">
              <Label for="starting_cost" class="text-xs font-semibold text-muted-foreground">Starting Cost</Label>
              <Input
                type="text"
                id="starting_cost"
                value={startingCost.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                disabled={true}
                readonly
                class="text-right bg-muted/50"
              />
            </div>

            <div class="flex flex-col gap-1.5">
              <Label for="cost_in" class="text-xs font-semibold text-muted-foreground">Cost In</Label>
              <Input
                type="text"
                id="cost_in"
                value={costIn.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                disabled={true}
                readonly
                class="text-right bg-muted/50"
              />
            </div>

            <div class="flex flex-col gap-1.5">
              <Label for="cost_out" class="text-xs font-semibold text-muted-foreground">Cost Out</Label>
              <Input
                type="text"
                id="cost_out"
                value={costOut.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                disabled={true}
                readonly
                class="text-right bg-muted/50"
              />
            </div>

            <div class="flex flex-col gap-1.5">
              <Label for="ending_cost" class="text-xs font-semibold text-muted-foreground">Ending Cost</Label>
              <Input
                type="text"
                id="ending_cost"
                value={endingCost.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                disabled={true}
                readonly
                class="text-right bg-muted/50"
              />
            </div>
          </div>

          <!-- pricing unit costs -->
          <div class="grid grid-cols-2 gap-4 border-t pt-4">
            <div class="flex flex-col gap-1.5">
              <Label for="unit_cost" class="text-xs font-semibold text-muted-foreground">Unit Cost (₱)</Label>
              <Input
                type="text"
                id="unit_cost"
                value={unitCostInputStr}
                oninput={handleUnitCostInput}
                disabled={dialogMode === 'View'}
                required
                class="text-right"
              />
            </div>

            <div class="flex flex-col gap-1.5">
              <Label for="last_highest_cost" class="text-xs font-semibold text-muted-foreground">Last Highest In Unit Cost (₱)</Label>
              <Input
                type="text"
                id="last_highest_cost"
                value={lastHighestInUnitCostInputStr}
                oninput={handleLastHighestInUnitCostInput}
                disabled={dialogMode !== 'Add'}
                required
                class="text-right"
              />
            </div>
          </div>

          <!-- form footer buttons -->
          <div class="flex justify-end gap-2 pt-6 border-t shrink-0">
            <Button type="button" variant="outline" onclick={() => dialogOpen = false}>
              {dialogMode === 'View' ? 'Close' : 'Cancel'}
            </Button>
            {#if dialogMode !== 'View'}
              <Button type="submit" class="bg-primary hover:bg-primary/95 text-white flex items-center gap-1.5">
                <Icon icon="mdi:check" width="16" />
                Save Changes
              </Button>
            {/if}
          </div>
        </form>
      {/if}
    </Dialog.Content>
  </Dialog.Root>

  <!-- Add Bin Sub Dialog -->
  <Dialog.Root bind:open={addBinOpen}>
    <Dialog.Content class="sm:max-w-[420px] bg-card border rounded-2xl shadow-2xl p-0 overflow-hidden z-[100]">
      <div class="bg-primary/5 border-b px-6 py-4">
        <div class="flex items-center gap-3">
          <div class="w-9 h-9 rounded-xl bg-primary/10 flex items-center justify-center text-primary">
            <Icon icon="mdi:plus" width="18" />
          </div>
          <Dialog.Title class="text-lg font-bold text-foreground">Add Storage Bin</Dialog.Title>
        </div>
      </div>
      <form onsubmit={submitAddBin} class="px-6 py-5 space-y-4">
        <div class="flex flex-col gap-1.5">
          <Label for="new_bin_desc" class="text-xs font-semibold text-muted-foreground">Bin Description *</Label>
          <Input
            id="new_bin_desc"
            placeholder="e.g., Shelf A-1, Row 3"
            bind:value={newBinDesc}
            required
            autocomplete="off"
          />
        </div>
        <div class="flex justify-end gap-2 pt-4 border-t">
          <Button type="button" variant="outline" onclick={() => addBinOpen = false}>Cancel</Button>
          <Button type="submit" class="bg-primary hover:bg-primary/95 text-white">Save Bin</Button>
        </div>
      </form>
    </Dialog.Content>
  </Dialog.Root>

  <!-- Confirmation Dialog -->
  <Dialog.Root bind:open={confirmOpen}>
    <Dialog.Content class="sm:max-w-[400px] bg-card border rounded-2xl shadow-2xl p-6 overflow-hidden z-[110] text-center">
      <div class="flex flex-col items-center gap-4">
        <div class="w-12 h-12 rounded-full bg-amber-500/10 flex items-center justify-center text-amber-500">
          <Icon icon="mdi:alert-circle-outline" width="28" />
        </div>
        <div class="space-y-2">
          <Dialog.Title class="text-lg font-bold text-foreground">Confirm Action</Dialog.Title>
          <p class="text-sm text-muted-foreground">
            Are you sure you want to {dialogMode === 'Add' ? 'save' : 'update'} this unit item?
          </p>
        </div>
      </div>
      <div class="flex justify-center gap-3 mt-6 pt-4 border-t">
        <Button type="button" variant="outline" onclick={() => confirmOpen = false}>Cancel</Button>
        <Button type="button" onclick={executeSave} class="bg-primary hover:bg-primary/95 text-white">Yes, Confirm</Button>
      </div>
    </Dialog.Content>
  </Dialog.Root>

</div>
