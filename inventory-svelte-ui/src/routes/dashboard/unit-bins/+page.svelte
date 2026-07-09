<script lang="ts">
  import type { PageData } from './$types';
  import { invokeService } from '$lib/service/invokeService';
  import { toast } from 'svelte-sonner';
  import StatusBadge from '$lib/components/inventory/StatusBadge.svelte';
  import { Button } from '$lib/components/ui/button/index.js';
  import { Input } from '$lib/components/ui/input/index.js';
  import { Label } from '$lib/components/ui/label/index.js';
  import Textarea from '$lib/components/ui/textarea/textarea.svelte';
  import * as Table from '$lib/components/ui/table/index.js';
  import * as Dialog from '$lib/components/ui/dialog/index.js';
  import * as DropdownMenu from '$lib/components/ui/dropdown-menu/index.js';
  import Icon from '@iconify/svelte';
  import TableControls from '$lib/components/inventory/TableControls.svelte';
  import SearchCombobox from '$lib/components/ui/SearchCombobox.svelte';
  import { activeUnit } from '$lib/store/unit';
  import { untrack } from 'svelte';

  let { data } = $props<{ data: PageData & { units: any[]; user: any } }>();

  let unitOptions = $derived(
    data.units.map((u: any) => ({ value: u.unit_id, label: u.description }))
  );

  // Table controls state
  const columns = [
    { key: 'description', label: 'Bin Description' },
    { key: 'status', label: 'Status' }
  ];

  let visibleColumns = $state<Record<string, boolean>>({
    description: true,
    status: true
  });

  let limit = $state(10);
  let page = $state(1);

  let selectedUnitId = $state<number>(data.units[0]?.unit_id || 0);

  // Sync selectedUnitId with global activeUnit store
  $effect(() => {
    if ($activeUnit) {
      selectedUnitId = $activeUnit.unit_id;
    }
  });

  $effect(() => {
    if (selectedUnitId > 0) {
      untrack(() => {
        const match = data.units.find((u: any) => u.unit_id === selectedUnitId);
        if (match && (!$activeUnit || $activeUnit.unit_id !== selectedUnitId)) {
          activeUnit.set({ unit_id: match.unit_id, description: match.description });
        }
      });
    }
  });

  let searchQuery = $state('');
  let unitBins = $state<any[]>([]);
  let loadingBins = $state(false);

  // Form states
  let formOpen = $state(false);
  let selectedBin = $state<any | null>(null);
  let binDescription = $state('');

  // Bulk add states
  let addMode = $state<'single' | 'bulk'>('single');
  let bulkInput = $state('');
  let excludedBulkItems = $state<Set<string>>(new Set());

  let parsedBulkItems = $derived(
    bulkInput
      .split(/[\n,;]+/)
      .map(item => item.trim())
      .filter(item => item.length > 0)
  );

  let bulkItemsPreview = $derived(
    parsedBulkItems.map(item => {
      const isDuplicate = unitBins.some(b => b.description.trim().toLowerCase() === item.toLowerCase());
      const isExcluded = excludedBulkItems.has(item);
      return { value: item, isDuplicate, isExcluded };
    })
  );

  function toggleExcludeItem(item: string) {
    if (excludedBulkItems.has(item)) {
      excludedBulkItems.delete(item);
    } else {
      excludedBulkItems.add(item);
    }
    excludedBulkItems = new Set(excludedBulkItems); // trigger reactivity
  }

  function resetAddForm() {
    addMode = 'single';
    bulkInput = '';
    excludedBulkItems = new Set();
    binDescription = '';
  }

  // Delete states
  let deleteOpen = $state(false);
  let selectedBinForDelete = $state<any | null>(null);

  // Fetch bins when unit changes
  async function loadBins() {
    if (selectedUnitId === 0) {
      unitBins = [];
      return;
    }
    loadingBins = true;
    const res = await invokeService<any, any>('/get-inventory-unit-bin', {
      body: { bol_getone: 0, bin_id: 0, unit_id: selectedUnitId, description: '' },
      token: data.user.access_token
    });
    loadingBins = false;
    if ('data' in res && res.data.success) {
      const inner = res.data.data ?? res.data;
      unitBins = inner.json_data || [];
    } else {
      unitBins = [];
      const errMsg = 'error' in res ? res.error : (res.data?.message || 'Unknown error');
      console.error('[Unit Bins] Failed to load unit bins:', errMsg, res);
      toast.error(`Failed to load unit bins: ${errMsg}`);
    }
  }

  $effect(() => {
    if (selectedUnitId > 0) {
      loadBins();
    }
  });

  let filteredBins = $derived(
    unitBins.filter(b =>
      (b.description || '').toLowerCase().includes(searchQuery.toLowerCase())
    )
  );

  let paginatedBins = $derived(
    filteredBins.slice((page - 1) * limit, page * limit)
  );

  $effect(() => {
    if (selectedUnitId || searchQuery) {
      page = 1;
    }
  });

  $effect(() => {
    if (formOpen) {
      if (selectedBin) {
        binDescription = selectedBin.description;
      } else {
        binDescription = '';
      }
    }
  });

  function openAdd() {
    selectedBin = null;
    resetAddForm();
    formOpen = true;
  }

  function openEdit(bin: any) {
    selectedBin = bin;
    resetAddForm();
    binDescription = bin.description;
    formOpen = true;
  }

  function openDelete(bin: any) {
    selectedBinForDelete = bin;
    deleteOpen = true;
  }

  async function submitForm(e: Event) {
    e.preventDefault();
    if (selectedUnitId === 0) return;

    if (addMode === 'single') {
      if (!binDescription.trim()) return;
      const isEdit = !!selectedBin;
      const process_type = isEdit ? 1 : 0;
      const toastId = toast.loading(isEdit ? 'Updating bin...' : 'Creating bin...');
      console.log({
        process_type,
        unit_id: selectedUnitId,
        description: binDescription.trim(),
        user_id: data.user.member?.member_id ?? 1,
        bin_id: isEdit ? selectedBin.bin_id : 0
      });
      const response = await invokeService<any, any>('/post-inventory-unit-bin', {
        body: {
          process_type,
          unit_id: selectedUnitId,
          description: binDescription.trim(),
          user_id: data.user.member?.member_id ?? 1,
          bin_id: isEdit ? selectedBin.bin_id : 0
        },
        token: data.user.access_token
      });

      formOpen = false;

      if ('data' in response && response.data.success) {
        toast.success(isEdit ? 'Bin updated successfully' : 'Bin created successfully', { id: toastId });
        loadBins();
      } else {
        const errMsg = 'error' in response ? response.error : (response.data?.message || 'Unknown error');
        console.error('[Unit Bins] Failed to save bin:', errMsg, response);
        toast.error(`Failed to save bin: ${errMsg}`, { id: toastId });
      }
    } else {
      // Bulk mode
      const itemsToAdd = bulkItemsPreview.filter(item => !item.isDuplicate && !item.isExcluded).map(item => item.value);
      if (itemsToAdd.length === 0) {
        toast.error('No new, valid bins to add.');
        return;
      }

      formOpen = false;
      const toastId = toast.loading(`Adding ${itemsToAdd.length} bin(s)... (0/${itemsToAdd.length})`);

      let successCount = 0;
      let failCount = 0;
      const failedItems: string[] = [];

      for (let i = 0; i < itemsToAdd.length; i++) {
        const item = itemsToAdd[i];
        toast.loading(`Adding ${itemsToAdd.length} bin(s)... (${i}/${itemsToAdd.length})`, { id: toastId });

        const response = await invokeService<any, any>('/post-inventory-unit-bin', {
          body: {
            process_type: 0,
            unit_id: selectedUnitId,
            description: item,
            user_id: data.user.member?.member_id ?? 1,
            bin_id: 0
          },
          token: data.user.access_token
        });

        if ('data' in response && response.data.success) {
          successCount++;
        } else {
          failCount++;
          failedItems.push(item);
        }
      }

      await loadBins();

      if (failCount === 0) {
        toast.success(`Successfully added all ${successCount} bin(s)!`, { id: toastId });
      } else if (successCount > 0) {
        toast.warning(`Added ${successCount} bin(s), ${failCount} failed.`, { id: toastId });
        bulkInput = failedItems.join(', ');
        excludedBulkItems = new Set();
        formOpen = true;
      } else {
        toast.error(`Failed to add any bins.`, { id: toastId });
        bulkInput = failedItems.join(', ');
        excludedBulkItems = new Set();
        formOpen = true;
      }
    }
  }

  async function deleteBin() {
    if (!selectedBinForDelete || selectedUnitId === 0) return;

    const toastId = toast.loading('Deleting bin...');
    console.log({
        process_type: 2,
        unit_id: selectedUnitId,
        description: selectedBinForDelete.description,
        user_id: data.user.member?.member_id ?? 1,
        bin_id: selectedBinForDelete.bin_id
      })
    const response = await invokeService<any, any>('/post-inventory-unit-bin', {
      body: {
        process_type: 2,
        unit_id: selectedUnitId,
        description: selectedBinForDelete.description,
        user_id: data.user.member?.member_id ?? 1,
        bin_id: selectedBinForDelete.bin_id
      },
      token: data.user.access_token
    });

    deleteOpen = false;

    if ('data' in response && response.data.success) {
      toast.success('Bin deleted successfully', { id: toastId });
      loadBins();
    } else {
      const errMsg = 'error' in response ? response.error : (response.data?.message || 'Unknown error');
      console.error('[Unit Bins] Failed to delete bin:', errMsg, response);
      toast.error(`Failed to delete bin: ${errMsg}`, { id: toastId });
    }
  }
</script>

<svelte:head>
  <title>Unit Bins - Serenity Inventory</title>
</svelte:head>

<div class="space-y-6">
  <!-- Page Header -->
  <div class="flex items-center justify-between">
    <div>
      <h2 class="text-2xl font-bold font-playfair text-primary">Unit Bins</h2>
      <p class="text-sm text-muted-foreground">Manage storage bins and locations within each inventory unit.</p>
    </div>
    <Button onclick={openAdd} disabled={selectedUnitId === 0} class="bg-primary hover:bg-primary/95 text-white flex items-center gap-2">
      <Icon icon="mdi:plus" width="20" />
      Add Bin
    </Button>
  </div>

  <!-- Filters / Controls -->
  <div class="flex flex-wrap items-center gap-4 bg-card border rounded-xl p-4 shadow-sm">
    <div class="flex flex-col gap-1.5 w-full sm:max-w-xs">
      <Label class="text-xs font-bold uppercase tracking-wider text-muted-foreground">Select Unit (Warehouse/Employee)</Label>
      <SearchCombobox
        options={unitOptions}
        bind:value={selectedUnitId}
        placeholder="Select unit..."
        searchPlaceholder="Search units..."
      />
    </div>

    <div class="flex flex-col gap-1.5 w-full sm:max-w-md">
      <Label for="bin-search" class="text-xs font-bold uppercase tracking-wider text-muted-foreground">Search Bins</Label>
      <div class="relative w-full">
        <Icon icon="mdi:magnify" width="16" class="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground pointer-events-none" />
        <Input
          id="bin-search"
          type="text"
          placeholder="Search bin description..."
          bind:value={searchQuery}
          autocomplete="off"
          class="pl-9 h-10"
        />
      </div>
    </div>
  </div>

  <!-- Table list -->
  <div class="relative">
    {#if loadingBins}
      <div class="absolute inset-0 z-10 flex items-center justify-center bg-white/70">
        <Icon icon="mdi:loading" class="text-primary animate-spin" width="32" />
      </div>
    {/if}

    <TableControls
      {columns}
      bind:visibleColumns
      bind:limit
      bind:page
      total={filteredBins.length}
    >
      <Table.Root>
        <Table.Header>
          <Table.Row class="bg-primary/5 hover:bg-primary/5 border-b-2 border-primary/10">
            {#if visibleColumns.description !== false}
              <Table.Head class="font-bold text-xs uppercase tracking-wider text-foreground/60">Bin Description</Table.Head>
            {/if}
            {#if visibleColumns.status !== false}
              <Table.Head class="font-bold text-xs uppercase tracking-wider text-foreground/60">Status</Table.Head>
            {/if}
            <Table.Head class="text-center w-[60px] font-bold text-xs uppercase tracking-wider text-foreground/60"></Table.Head>
          </Table.Row>
        </Table.Header>
        <Table.Body>
          {#if paginatedBins.length === 0}
            <Table.Row>
              <Table.Cell colspan={columns.filter(c => visibleColumns[c.key] !== false).length + 1} class="h-40 text-center">
                <div class="flex flex-col items-center gap-2 text-muted-foreground">
                  <Icon icon="mdi:archive-off-outline" width="36" class="opacity-30" />
                  <span class="text-sm">No bins found. Select a unit or add a new bin.</span>
                </div>
              </Table.Cell>
            </Table.Row>
          {:else}
            {#each paginatedBins as bin, i (bin.bin_id)}
              <Table.Row class="hover:bg-primary/5 transition-colors {i % 2 === 1 ? 'bg-muted/20' : ''}">
                {#if visibleColumns.description !== false}
                  <Table.Cell class="font-semibold text-foreground">{bin.description}</Table.Cell>
                {/if}
                {#if visibleColumns.status !== false}
                  <Table.Cell>
                    <StatusBadge status={bin.status ?? 'ACTIVE'} />
                  </Table.Cell>
                {/if}
                <Table.Cell class="text-center">
                  <DropdownMenu.Root>
                    <DropdownMenu.Trigger class="rounded-lg p-1.5 text-muted-foreground transition-colors hover:bg-muted hover:text-foreground focus:outline-none">
                      <Icon icon="mdi:dots-vertical" width="17" />
                    </DropdownMenu.Trigger>
                    <DropdownMenu.Content class="bg-card rounded-xl shadow-xl border border-border p-1.5 min-w-44 z-50 mt-1" align="end">
                      <DropdownMenu.Item onclick={() => openEdit(bin)} class="flex items-center gap-2 hover:bg-muted px-3 py-2 rounded-lg cursor-pointer text-sm transition-colors text-teal-650 dark:text-teal-450 font-medium">
                        <Icon icon="mdi:pencil-outline" width="16" />
                        Edit Bin
                      </DropdownMenu.Item>
                      <DropdownMenu.Separator class="my-1 border-t border-border" />
                      <DropdownMenu.Item onclick={() => openDelete(bin)} class="flex items-center gap-2 hover:bg-rose-500/10 text-rose-500 px-3 py-2 rounded-lg cursor-pointer text-sm font-semibold transition-colors">
                        <Icon icon="mdi:delete-outline" width="16" />
                        Delete Bin
                      </DropdownMenu.Item>
                    </DropdownMenu.Content>
                  </DropdownMenu.Root>
                </Table.Cell>
              </Table.Row>
            {/each}
          {/if}
        </Table.Body>
      </Table.Root>
    </TableControls>
  </div>

  <!-- Form Dialog (Add / Edit) -->
  <Dialog.Root bind:open={formOpen}>
    <Dialog.Content
      onInteractOutside={(e) => e.preventDefault()}
      onEscapeKeydown={(e) => e.preventDefault()}
      class="sm:max-w-[460px] bg-card border-0 rounded-2xl shadow-2xl p-0 overflow-hidden"
    >
      <div class="bg-primary/5 border-b px-6 py-4">
        <div class="flex items-center gap-3">
          <div class="w-9 h-9 rounded-xl bg-primary/10 flex items-center justify-center">
            <Icon icon={selectedBin ? 'mdi:pencil' : 'mdi:plus'} width="18" class="text-primary" />
          </div>
          <Dialog.Title class="text-lg font-bold text-foreground">
            {selectedBin ? 'Edit Storage Bin' : 'New Storage Bin'}
          </Dialog.Title>
        </div>
      </div>
      <form onsubmit={submitForm} class="px-6 py-5 space-y-4">
        {#if !selectedBin}
          <!-- Segmented Tab Control -->
          <div class="grid grid-cols-2 p-1 bg-muted rounded-xl text-xs font-semibold">
            <button
              type="button"
              onclick={() => addMode = 'single'}
              class="py-1.5 rounded-lg text-center transition-all duration-150
                {addMode === 'single' ? 'bg-background text-foreground shadow-sm' : 'text-muted-foreground hover:text-foreground'}"
            >
              Single Bin
            </button>
            <button
              type="button"
              onclick={() => addMode = 'bulk'}
              class="py-1.5 rounded-lg text-center transition-all duration-150
                {addMode === 'bulk' ? 'bg-background text-foreground shadow-sm' : 'text-muted-foreground hover:text-foreground'}"
            >
              Smart Bulk Add
            </button>
          </div>
        {/if}

        {#if addMode === 'single'}
          <div class="flex flex-col gap-1.5">
            <Label for="bin_desc" class="text-xs font-bold uppercase tracking-wider text-muted-foreground">Bin Description / Code *</Label>
            <Input
              type="text"
              id="bin_desc"
              placeholder="e.g. Shelf A-1, Row 3"
              bind:value={binDescription}
              autocomplete="off"
              class="h-10"
              required={addMode === 'single'}
            />
          </div>
        {:else}
          <!-- Bulk Add Textarea -->
          <div class="flex flex-col gap-1.5">
            <Label for="bulk_bin_desc" class="text-xs font-bold uppercase tracking-wider text-muted-foreground">Bulk Bin Descriptions *</Label>
            <Textarea
              id="bulk_bin_desc"
              placeholder="Enter multiple bin codes/descriptions separated by newlines, commas, or semicolons (e.g. Shelf A-1, Shelf A-2, Shelf A-3)..."
              bind:value={bulkInput}
              class="min-h-[100px] resize-y"
              required={addMode === 'bulk'}
            />
            <p class="text-[10px] text-muted-foreground">
              Tip: You can copy and paste directly from an Excel/Sheets column.
            </p>
          </div>

          <!-- Smart Preview List -->
          {#if parsedBulkItems.length > 0}
            <div class="flex flex-col gap-1.5 border rounded-xl p-3 bg-muted/30">
              <Label class="text-xs font-bold uppercase tracking-wider text-muted-foreground flex items-center justify-between">
                <span>Preview ({bulkItemsPreview.filter(x => !x.isExcluded && !x.isDuplicate).length} to add)</span>
                <span class="text-[10px] lowercase text-muted-foreground">click 'x' to exclude</span>
              </Label>
              
              <div class="flex flex-wrap gap-1.5 max-h-[120px] overflow-y-auto pr-1">
                {#each bulkItemsPreview as item}
                  <div
                    class="inline-flex items-center gap-1 px-2.5 py-1 rounded-lg text-xs font-medium border transition-all
                      {item.isExcluded
                        ? 'bg-muted/60 text-muted-foreground/60 border-dashed line-through'
                        : item.isDuplicate
                          ? 'bg-yellow-50 text-yellow-700 border-yellow-250 dark:bg-yellow-950/30 dark:text-yellow-400 dark:border-yellow-900/40'
                          : 'bg-primary/5 text-primary border-primary/20 hover:bg-primary/10'}"
                  >
                    {#if item.isDuplicate && !item.isExcluded}
                      <Icon icon="mdi:alert-circle-outline" width="13" class="text-yellow-600 shrink-0" />
                      <span>{item.value}</span>
                      <span class="text-[9px] font-bold opacity-60 uppercase shrink-0">(Duplicate)</span>
                    {:else}
                      {#if !item.isExcluded}
                        <Icon icon="mdi:check-circle-outline" width="13" class="text-primary shrink-0" />
                      {/if}
                      <span>{item.value}</span>
                    {/if}
                    
                    <button
                      type="button"
                      onclick={() => toggleExcludeItem(item.value)}
                      class="ml-1 text-muted-foreground hover:text-foreground rounded-full p-0.5 transition-colors shrink-0"
                      title={item.isExcluded ? "Include" : "Exclude"}
                    >
                      <Icon icon={item.isExcluded ? "mdi:plus" : "mdi:close"} width="12" />
                    </button>
                  </div>
                {/each}
              </div>
            </div>
          {/if}
        {/if}

        <div class="flex justify-end gap-2 pt-4 border-t">
          <Button type="button" variant="outline" onclick={() => formOpen = false} class="h-9 px-5">Cancel</Button>
          <Button
            type="submit"
            disabled={addMode === 'single' ? !binDescription.trim() : parsedBulkItems.length === 0}
            class="h-9 px-5 bg-primary hover:bg-primary/90 text-white disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <Icon icon="mdi:check" width="16" class="mr-1.5" />
            {#if selectedBin}
              Save Bin
            {:else if addMode === 'single'}
              Add Bin
            {:else}
              Smart Add {bulkItemsPreview.filter(x => !x.isExcluded && !x.isDuplicate).length} Bin(s)
            {/if}
          </Button>
        </div>
      </form>
    </Dialog.Content>
  </Dialog.Root>

  <!-- Delete Confirmation -->
  <Dialog.Root bind:open={deleteOpen}>
    <Dialog.Content class="sm:max-w-[400px] bg-card border-0 rounded-2xl shadow-2xl p-0 overflow-hidden">
      {#if selectedBinForDelete}
        <div class="bg-rose-50 border-b border-rose-100 px-6 py-4">
          <div class="flex items-center gap-3">
            <div class="w-9 h-9 rounded-xl bg-rose-100 flex items-center justify-center text-rose-600">
              <Icon icon="mdi:alert-circle-outline" width="20" />
            </div>
            <Dialog.Title class="text-lg font-bold text-rose-800">Delete Storage Bin</Dialog.Title>
          </div>
        </div>
        <div class="px-6 py-5 space-y-4">
          <p class="text-sm text-slate-500 leading-relaxed">
            Are you sure you want to delete the bin <strong class="text-slate-800">"{selectedBinForDelete.description}"</strong>? This action cannot be undone.
          </p>
          <div class="flex justify-end gap-2 pt-4 border-t">
            <Button type="button" variant="outline" onclick={() => deleteOpen = false} class="h-9 px-5">Cancel</Button>
            <Button type="button" onclick={deleteBin} class="h-9 px-5 bg-rose-600 hover:bg-rose-700 text-white">Delete Bin</Button>
          </div>
        </div>
      {/if}
    </Dialog.Content>
  </Dialog.Root>
</div>
