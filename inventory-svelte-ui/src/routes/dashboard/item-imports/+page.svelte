<script lang="ts">
  import type { PageData } from './$types';
  import { invokeService } from '$lib/service/invokeService';
  import { toast } from 'svelte-sonner';
  import { Button } from '$lib/components/ui/button/index.js';
  import { Input } from '$lib/components/ui/input/index.js';
  import { Label } from '$lib/components/ui/label/index.js';
  import Textarea from '$lib/components/ui/textarea/textarea.svelte';
  import * as Table from '$lib/components/ui/table/index.js';
  import * as Dialog from '$lib/components/ui/dialog/index.js';
  import * as DropdownMenu from '$lib/components/ui/dropdown-menu/index.js';
  import Icon from '@iconify/svelte';
  import TableControls from '$lib/components/inventory/TableControls.svelte';

  let { data } = $props<{ data: PageData & { importTypes: { import_name: string; import_type: string }[]; user: any } }>();

  // Table controls state
  const columns = [
    { key: 'description', label: 'Description' }
  ];

  let visibleColumns = $state<Record<string, boolean>>({
    description: true
  });

  let limit = $state(10);
  let page = $state(1);

  // ─── Icon / colour maps ────────────────────────────────────────────────────
  const typeIconMap: Record<string, string> = {
    brand: 'mdi:tag-outline',
    size: 'mdi:resize',
    vehiclePart: 'mdi:car-cog',
    vehiclePartNumber: 'mdi:barcode'
  };

  const typeBadgeMap: Record<string, string> = {
    brand: 'text-teal-700 bg-teal-100 dark:text-teal-300 dark:bg-teal-900/40',
    size: 'text-indigo-700 bg-indigo-100 dark:text-indigo-300 dark:bg-indigo-900/40',
    vehiclePart: 'text-amber-700 bg-amber-100 dark:text-amber-300 dark:bg-amber-900/40',
    vehiclePartNumber: 'text-purple-700 bg-purple-100 dark:text-purple-300 dark:bg-purple-900/40'
  };

  const typePlaceholder: Record<string, string> = {
    brand: 'e.g. Michelin, Bridgestone',
    size: 'e.g. 205/65 R15',
    vehiclePart: 'e.g. Front Brake Pad',
    vehiclePartNumber: 'e.g. BP-2034-FT'
  };

  // ─── Selected import type for the view ────────────────────────────────────
  let activeType = $state<string>('');                         // '' = not yet chosen
  let activeTypeMeta = $derived(
    data.importTypes.find((t: any) => t.import_type === activeType) ?? null
  );

  // ─── Records ──────────────────────────────────────────────────────────────
  let records = $state<{ id: number; description: string }[]>([]);
  let loading = $state(false);
  let searchQuery = $state('');

  let filtered = $derived(
    records.filter(r => r.description.toLowerCase().includes(searchQuery.toLowerCase()))
  );

  let paginated = $derived(
    filtered.slice((page - 1) * limit, page * limit)
  );

  // Reset page when active type or search changes
  $effect(() => {
    if (activeType || searchQuery) {
      page = 1;
    }
  });

  async function loadRecords(type: string) {
    loading = true;
    records = [];
    const res = await invokeService<any, any>('/get-item-imports', {
      body: { import_type: type, bol_getone: 0, id: 0, description: '' },
      token: data.user.access_token
    });
    console.log(res)
    loading = false;
    if ('data' in res && res.data.success) {
      // Backend: { success, data: { success, json_data } }
      const inner = res.data.data ?? res.data;
      records = inner.json_data ?? [];
    } else {
      const errMsg = 'error' in res ? res.error : (res.data?.message || 'Unknown error');
      console.error('[Item Imports] Failed to load records:', errMsg, res);
      toast.error(`Failed to load records: ${errMsg}`);
    }
  }

  // Auto-load when activeType changes (only if a type is actually selected)
  $effect(() => {
    if (activeType) {
      searchQuery = '';
      loadRecords(activeType);
    }
  });

  function selectType(type: string) {
    activeType = type;
  }

  // ─── Add / Edit dialog ────────────────────────────────────────────────────
  let formOpen = $state(false);
  let selectedRecord = $state<{ id: number; description: string } | null>(null);
  let formType = $state<string>('');      // import_type chosen inside the Add dialog
  let formDescription = $state('');

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
      const isDuplicate = formType === activeType && records.some(r => r.description.trim().toLowerCase() === item.toLowerCase());
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
    formDescription = '';
  }

  let formTypeMeta = $derived(
    data.importTypes.find((t: any) => t.import_type === formType) ?? null
  );

  function openAdd() {
    selectedRecord = null;
    // Pre-select the current active type (if any) but let the user change it
    formType = activeType || data.importTypes[0]?.import_type || '';
    resetAddForm();
    formOpen = true;
  }

  function openEdit(rec: { id: number; description: string }) {
    selectedRecord = rec;
    formType = activeType;             // locked to current view type for edits
    resetAddForm();
    formDescription = rec.description;
    formOpen = true;
  }

  async function submitForm(e: Event) {
    e.preventDefault();
    if (!formType) return;

    if (addMode === 'single') {
      if (!formDescription.trim()) return;
      const isEdit = !!selectedRecord;
      const toastId = toast.loading(isEdit ? 'Updating...' : 'Creating...');
      console.log('[Item Imports] Saving record payload:', {
        process_type: isEdit ? 1 : 0,
        import_type: formType,
        description: formDescription,
        user_id: data.user.member?.member_id ?? 1,
        id: isEdit ? selectedRecord!.id : 0
      });
      const res = await invokeService<any, any>('/post-item-imports', {
        body: {
          process_type: isEdit ? 1 : 0,
          import_type: formType,
          description: formDescription.trim(),
          user_id: data.user.member?.member_id ?? 1,
          id: isEdit ? selectedRecord!.id : 0
        },
        token: data.user.access_token
      });

      formOpen = false;
      if ('data' in res && res.data.success) {
        toast.success(isEdit ? 'Updated successfully' : 'Created successfully', { id: toastId });
        if (formType === activeType) loadRecords(activeType);
      } else {
        const errMsg = 'error' in res ? res.error : (res.data?.message || 'Unknown error');
        console.error('[Item Imports] Failed to save record:', errMsg, res);
        toast.error(`Failed to save record: ${errMsg}`, { id: toastId });
      }
    } else {
      // Bulk mode
      const itemsToAdd = bulkItemsPreview.filter(item => !item.isDuplicate && !item.isExcluded).map(item => item.value);
      if (itemsToAdd.length === 0) {
        toast.error('No new, valid records to add.');
        return;
      }

      formOpen = false;
      const toastId = toast.loading(`Adding ${itemsToAdd.length} record(s)... (0/${itemsToAdd.length})`);
      
      let successCount = 0;
      let failCount = 0;
      const failedItems: string[] = [];

      for (let i = 0; i < itemsToAdd.length; i++) {
        const item = itemsToAdd[i];
        toast.loading(`Adding ${itemsToAdd.length} record(s)... (${i}/${itemsToAdd.length})`, { id: toastId });
        
        const res = await invokeService<any, any>('/post-item-imports', {
          body: {
            process_type: 0,
            import_type: formType,
            description: item,
            user_id: data.user.member?.member_id ?? 1,
            id: 0
          },
          token: data.user.access_token
        });

        if ('data' in res && res.data.success) {
          successCount++;
        } else {
          failCount++;
          failedItems.push(item);
        }
      }

      if (formType === activeType) {
        await loadRecords(activeType);
      }

      if (failCount === 0) {
        toast.success(`Successfully added all ${successCount} record(s)!`, { id: toastId });
      } else if (successCount > 0) {
        toast.warning(`Added ${successCount} record(s), ${failCount} failed.`, { id: toastId });
        bulkInput = failedItems.join(', ');
        excludedBulkItems = new Set();
        formOpen = true;
      } else {
        toast.error(`Failed to add any records.`, { id: toastId });
        bulkInput = failedItems.join(', ');
        excludedBulkItems = new Set();
        formOpen = true;
      }
    }
  }

  // ─── Delete dialog ────────────────────────────────────────────────────────
  let deleteOpen = $state(false);
  let deleteTarget = $state<{ id: number; description: string } | null>(null);

  function openDelete(rec: { id: number; description: string }) {
    deleteTarget = rec;
    deleteOpen = true;
  }

  async function deleteRecord() {
    if (!deleteTarget) return;
    const toastId = toast.loading('Deleting...');

    const res = await invokeService<any, any>('/post-item-imports', {
      body: {
        process_type: 2,
        import_type: activeType,
        description: deleteTarget.description,
        user_id: data.user.member?.member_id ?? 1,
        id: deleteTarget.id
      },
      token: data.user.access_token
    });

    deleteOpen = false;
    if ('data' in res && res.data.success) {
      toast.success('Deleted successfully', { id: toastId });
      loadRecords(activeType);
    } else {
      const errMsg = 'error' in res ? res.error : (res.data?.message || 'Unknown error');
      console.error('[Item Imports] Failed to delete record:', errMsg, res);
      toast.error(`Failed to delete record: ${errMsg}`, { id: toastId });
    }
  }
</script>

<svelte:head>
  <title>Item Imports - Serenity Inventory</title>
</svelte:head>

<div class="space-y-6">

  <!-- ─── Page Header ──────────────────────────────────────────────── -->
  <div class="flex items-start justify-between gap-4 flex-wrap">
    <div>
      <h2 class="text-2xl font-bold font-playfair text-primary">Item Imports</h2>
      <p class="text-sm text-muted-foreground mt-0.5">
        Manage lookup values used in item forms — brands, sizes, parts, and part numbers.
      </p>
    </div>
    <Button onclick={openAdd} class="bg-primary hover:bg-primary/90 text-white flex items-center gap-2 shrink-0">
      <Icon icon="mdi:plus" width="20" />
      Add New Record
    </Button>
  </div>

  <!-- ─── Step 1: Select Import Type ──────────────────────────────── -->
  <div class="bg-card border rounded-2xl shadow-sm overflow-hidden">
    <!-- Section header -->
    <div class="flex items-center gap-2.5 px-5 py-3.5 border-b bg-primary/5">
      <div class="w-6 h-6 rounded-full bg-primary text-white flex items-center justify-center text-xs font-bold">1</div>
      <span class="text-sm font-bold text-foreground">Select Import Type</span>
      <span class="text-xs text-muted-foreground ml-1">— Choose which category to browse or manage</span>
    </div>

    <!-- Type option cards -->
    <div class="grid grid-cols-2 sm:grid-cols-4 gap-3 p-4">
      {#each data.importTypes as type}
        {@const isActive = activeType === type.import_type}
        <button
          onclick={() => selectType(type.import_type)}
          class="relative flex flex-col items-start gap-2.5 p-4 rounded-xl border-2 text-left transition-all duration-150
            {isActive
              ? 'border-primary bg-primary/5 dark:bg-primary/10 shadow-sm'
              : 'border-border bg-background hover:border-primary/40 hover:bg-muted/20'}"
        >
          <div class="p-2 rounded-lg {typeBadgeMap[type.import_type] ?? 'text-muted-foreground bg-muted'}">
            <Icon icon={typeIconMap[type.import_type] ?? 'mdi:database-outline'} width="20" />
          </div>
          <div>
            <p class="text-sm font-bold {isActive ? 'text-primary' : 'text-foreground'}">{type.import_name}</p>
            <p class="text-xs text-muted-foreground font-mono mt-0.5">{type.import_type}</p>
          </div>
          {#if isActive}
            <div class="absolute top-3 right-3 flex items-center gap-1">
              <Icon icon="mdi:check-circle" width="18" class="text-primary" />
            </div>
          {/if}
        </button>
      {/each}
    </div>
  </div>

  <!-- ─── Step 2: Browse Records (only shown after type selected) ── -->
  {#if !activeType}
    <!-- Prompt state -->
    <div class="rounded-2xl border border-dashed bg-card/50 flex flex-col items-center justify-center py-16 gap-3 text-muted-foreground">
      <div class="p-4 rounded-2xl bg-primary/5">
        <Icon icon="mdi:hand-pointing-up" width="40" class="text-primary/50" />
      </div>
      <p class="text-base font-semibold text-foreground/60">Select an import type above to load its records</p>
      <p class="text-sm">Once selected, the list will appear here and you can search, add, edit or delete entries.</p>
    </div>
  {:else}
    <!-- Section header for step 2 -->
    <div class="flex items-center gap-2.5 px-5 py-3.5 rounded-t-2xl border border-b-0 bg-primary/5">
      <div class="w-6 h-6 rounded-full bg-primary text-white flex items-center justify-center text-xs font-bold">2</div>
      <span class="text-sm font-bold text-foreground">
        Browse
        <span class="{typeBadgeMap[activeType] ?? ''} px-2 py-0.5 rounded-md text-xs font-bold ml-1">
          {activeTypeMeta?.import_name ?? activeType}
        </span>
        Records
      </span>
      {#if !loading}
        <span class="ml-auto text-xs text-muted-foreground font-medium">{filtered.length} record{filtered.length !== 1 ? 's' : ''}</span>
      {/if}
    </div>

    <!-- Search bar -->
    <!-- Search bar & Table layout -->
    <div class="space-y-4">
      <div class="flex items-center gap-3 px-4 py-3 border rounded-2xl bg-card shadow-sm">
        <div class="relative flex-1 sm:max-w-md">
          <Icon icon="mdi:magnify" width="16" class="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground pointer-events-none" />
          <input
            type="text"
            placeholder="Search {activeTypeMeta?.import_name ?? ''}..."
            bind:value={searchQuery}
            autocomplete="off"
            class="w-full pl-9 pr-3 h-9 text-sm rounded-lg border border-input bg-background focus:outline-none focus:ring-1 focus:ring-ring"
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
        <button
          onclick={() => loadRecords(activeType)}
          title="Refresh"
          class="p-2 rounded-lg border border-input bg-background hover:bg-primary/5 text-muted-foreground hover:text-primary transition-colors"
        >
          <Icon icon="mdi:refresh" width="17" />
        </button>
      </div>

      <!-- Table -->
      <TableControls
        {columns}
        bind:visibleColumns
        bind:limit
        bind:page
        total={filtered.length}
      >
        <Table.Root>
          <Table.Header>
            <Table.Row class="bg-primary/5 hover:bg-primary/5 border-b-2 border-primary/10">
              {#if visibleColumns.description !== false}
                <Table.Head class="font-bold text-xs uppercase tracking-wider text-foreground/60">Description</Table.Head>
              {/if}
              <Table.Head class="text-center w-[60px] font-bold text-xs uppercase tracking-wider text-foreground/60"></Table.Head>
            </Table.Row>
          </Table.Header>
          <Table.Body>
            {#if loading}
              <Table.Row>
                <Table.Cell colspan={columns.filter(c => visibleColumns[c.key] !== false).length + 1} class="h-40 text-center">
                  <div class="flex flex-col items-center gap-2 text-muted-foreground">
                    <Icon icon="mdi:loading" class="animate-spin" width="32" />
                    <span class="text-sm">Loading {activeTypeMeta?.import_name ?? ''} records...</span>
                  </div>
                </Table.Cell>
              </Table.Row>
            {:else}
              {#if paginated.length === 0}
                <Table.Row>
                  <Table.Cell colspan={columns.filter(c => visibleColumns[c.key] !== false).length + 1} class="h-40 text-center">
                    <div class="flex flex-col items-center gap-2 text-muted-foreground">
                      <Icon icon={typeIconMap[activeType] ?? 'mdi:database-off-outline'} width="36" class="opacity-30" />
                      <span class="text-sm font-medium">
                        {searchQuery ? `No results for "${searchQuery}"` : `No ${activeTypeMeta?.import_name ?? ''} records yet`}
                      </span>
                      {#if searchQuery}
                        <button onclick={() => searchQuery = ''} class="text-xs text-primary underline">Clear search</button>
                      {/if}
                    </div>
                  </Table.Cell>
                </Table.Row>
              {:else}
                {#each paginated as rec, i (rec.id)}
                  <Table.Row class="hover:bg-primary/5 transition-colors {i % 2 === 1 ? 'bg-muted/20 dark:bg-muted/10' : ''}">
                    {#if visibleColumns.description !== false}
                      <Table.Cell>
                        <div class="flex items-center gap-2">
                          <div class="w-1.5 h-1.5 rounded-full {typeBadgeMap[activeType]?.includes('teal') ? 'bg-teal-500' : typeBadgeMap[activeType]?.includes('indigo') ? 'bg-indigo-500' : typeBadgeMap[activeType]?.includes('amber') ? 'bg-amber-500' : 'bg-purple-500'}"></div>
                          <span class="font-semibold text-foreground text-sm">{rec.description}</span>
                        </div>
                      </Table.Cell>
                    {/if}
                    <Table.Cell class="text-center">
                      <DropdownMenu.Root>
                        <DropdownMenu.Trigger class="rounded-lg p-1.5 text-muted-foreground transition-colors hover:bg-muted hover:text-foreground focus:outline-none">
                          <Icon icon="mdi:dots-vertical" width="17" />
                        </DropdownMenu.Trigger>
                        <DropdownMenu.Content class="bg-card rounded-xl shadow-xl border border-border p-1.5 min-w-44 z-50 mt-1" align="end">
                          <DropdownMenu.Item onclick={() => openEdit(rec)} class="flex items-center gap-2 hover:bg-muted px-3 py-2 rounded-lg cursor-pointer text-sm transition-colors text-teal-650 dark:text-teal-450 font-medium">
                            <Icon icon="mdi:pencil-outline" width="16" />
                            Edit
                          </DropdownMenu.Item>
                          <DropdownMenu.Separator class="my-1 border-t border-border" />
                          <DropdownMenu.Item onclick={() => openDelete(rec)} class="flex items-center gap-2 hover:bg-rose-500/10 text-rose-500 px-3 py-2 rounded-lg cursor-pointer text-sm font-semibold transition-colors">
                            <Icon icon="mdi:delete-outline" width="16" />
                            Delete
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
  {/if}
</div>

<!-- ─── Add / Edit Dialog ─────────────────────────────────────────────────── -->
<Dialog.Root bind:open={formOpen}>
  <Dialog.Content
    onInteractOutside={(e) => e.preventDefault()}
    onEscapeKeydown={(e) => e.preventDefault()}
    class="sm:max-w-[460px] bg-card border-0 rounded-2xl shadow-2xl p-0 overflow-hidden"
  >
    <!-- Header -->
    <div class="bg-primary/5 border-b px-6 py-4 flex items-center gap-3">
      <div class="w-9 h-9 rounded-xl bg-primary/10 flex items-center justify-center shrink-0">
        <Icon icon={selectedRecord ? 'mdi:pencil' : 'mdi:database-plus-outline'} width="18" class="text-primary" />
      </div>
      <div>
        <Dialog.Title class="text-base font-bold text-foreground leading-tight">
          {selectedRecord ? 'Edit Record' : 'Add New Record'}
        </Dialog.Title>
        <p class="text-xs text-muted-foreground mt-0.5">
          {selectedRecord ? 'Update the description below.' : 'Select the type and enter a description.'}
        </p>
      </div>
    </div>

    <form onsubmit={submitForm} class="px-6 py-5 space-y-4">

      <!-- Import type selector — shown for Add; locked for Edit -->
      <div class="flex flex-col gap-1.5">
        <Label class="text-xs font-bold uppercase tracking-wider text-muted-foreground">
          Import Type *
        </Label>

        {#if selectedRecord}
          <!-- Locked display for edits -->
          <div class="flex items-center gap-2 h-10 px-3 rounded-lg border border-input bg-muted/40 cursor-not-allowed">
            <div class="p-1 rounded {typeBadgeMap[formType] ?? ''}">
              <Icon icon={typeIconMap[formType] ?? 'mdi:database'} width="14" />
            </div>
            <span class="text-sm font-semibold">{formTypeMeta?.import_name ?? formType}</span>
            <Icon icon="mdi:lock-outline" width="14" class="ml-auto text-muted-foreground/60" />
          </div>
        {:else}
          <!-- Selectable buttons for Add -->
          <div class="grid grid-cols-2 gap-2">
            {#each data.importTypes as type}
              {@const isSelected = formType === type.import_type}
              <button
                type="button"
                onclick={() => formType = type.import_type}
                class="flex items-center gap-2.5 px-3 py-2.5 rounded-lg border-2 text-left transition-all duration-100
                  {isSelected
                    ? 'border-primary bg-primary/5 dark:bg-primary/10'
                    : 'border-border bg-background hover:border-primary/30 hover:bg-muted/20'}"
              >
                <div class="p-1.5 rounded-md {typeBadgeMap[type.import_type] ?? 'bg-muted text-muted-foreground'}">
                  <Icon icon={typeIconMap[type.import_type] ?? 'mdi:database'} width="15" />
                </div>
                <span class="text-sm font-semibold {isSelected ? 'text-primary' : 'text-foreground'}">{type.import_name}</span>
                {#if isSelected}
                  <Icon icon="mdi:check-circle" width="15" class="ml-auto text-primary shrink-0" />
                {/if}
              </button>
            {/each}
          </div>
        {/if}
      </div>

      {#if !selectedRecord}
        <!-- Segmented Tab Control -->
        <div class="grid grid-cols-2 p-1 bg-muted rounded-xl text-xs font-semibold">
          <button
            type="button"
            onclick={() => addMode = 'single'}
            class="py-1.5 rounded-lg text-center transition-all duration-150
              {addMode === 'single' ? 'bg-background text-foreground shadow-sm' : 'text-muted-foreground hover:text-foreground'}"
          >
            Single Entry
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
        <!-- Description -->
        <div class="flex flex-col gap-1.5">
          <Label for="import_desc" class="text-xs font-bold uppercase tracking-wider text-muted-foreground">
            {formTypeMeta?.import_name ?? 'Description'} Name *
          </Label>
          <Input
            type="text"
            id="import_desc"
            placeholder={typePlaceholder[formType] ?? 'Enter name...'}
            bind:value={formDescription}
            autocomplete="off"
            class="h-10"
            required={addMode === 'single'}
          />
        </div>
      {:else}
        <!-- Bulk Add Textarea -->
        <div class="flex flex-col gap-1.5">
          <Label for="bulk_desc" class="text-xs font-bold uppercase tracking-wider text-muted-foreground">
            Bulk {formTypeMeta?.import_name ?? 'Description'} Names *
          </Label>
          <Textarea
            id="bulk_desc"
            placeholder="Enter multiple items separated by newlines, commas, or semicolons (e.g. Michelin, Bridgestone, Goodyear)..."
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
          disabled={!formType || (addMode === 'single' ? !formDescription.trim() : parsedBulkItems.length === 0)}
          class="h-9 px-5 bg-primary hover:bg-primary/90 text-white disabled:opacity-50 disabled:cursor-not-allowed"
        >
          <Icon icon="mdi:check" width="16" class="mr-1.5" />
          {#if selectedRecord}
            Save Changes
          {:else if addMode === 'single'}
            Add {formTypeMeta?.import_name ?? 'Record'}
          {:else}
            Smart Add {bulkItemsPreview.filter(x => !x.isExcluded && !x.isDuplicate).length} {formTypeMeta?.import_name ?? 'Record'}(s)
          {/if}
        </Button>
      </div>
    </form>
  </Dialog.Content>
</Dialog.Root>

<!-- ─── Delete Confirm Dialog ─────────────────────────────────────────────── -->
<Dialog.Root bind:open={deleteOpen}>
  <Dialog.Content class="sm:max-w-[400px] bg-card border-0 rounded-2xl shadow-2xl p-0 overflow-hidden">
    {#if deleteTarget}
      <div class="bg-rose-50 border-b border-rose-100 dark:bg-rose-950/20 dark:border-rose-900/30 px-6 py-4">
        <div class="flex items-center gap-3">
          <div class="w-9 h-9 rounded-xl bg-rose-100 dark:bg-rose-900/30 flex items-center justify-center">
            <Icon icon="mdi:delete-alert-outline" width="18" class="text-rose-600 dark:text-rose-400" />
          </div>
          <div>
            <Dialog.Title class="text-base font-bold text-rose-700 dark:text-rose-400 leading-tight">
              Delete {activeTypeMeta?.import_name ?? 'Record'}
            </Dialog.Title>
            <p class="text-xs text-rose-500/80 dark:text-rose-400/60 mt-0.5">This action cannot be undone</p>
          </div>
        </div>
      </div>
      <div class="px-6 py-5">
        <p class="text-sm text-muted-foreground">
          Are you sure you want to delete
          <span class="font-bold text-foreground">"{deleteTarget.description}"</span>?
          Items referencing this {activeTypeMeta?.import_name?.toLowerCase() ?? 'record'} may be affected.
        </p>
        <div class="flex justify-end gap-2 pt-5 border-t mt-5">
          <Button variant="outline" onclick={() => deleteOpen = false} class="h-9 px-5">Cancel</Button>
          <Button onclick={deleteRecord} class="h-9 px-5 bg-rose-600 hover:bg-rose-700 text-white">
            <Icon icon="mdi:delete" width="16" class="mr-1.5" />
            Delete
          </Button>
        </div>
      </div>
    {/if}
  </Dialog.Content>
</Dialog.Root>
