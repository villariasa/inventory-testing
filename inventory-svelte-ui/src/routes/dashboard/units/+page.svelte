<script lang="ts">
  import type { PageData } from './$types';
  import type { InventoryUnit } from '$lib/types';
  import { invokeService } from '$lib/service/invokeService';
  import { invalidateAll } from '$app/navigation';
  import { toast } from 'svelte-sonner';
  import { Button } from '$lib/components/ui/button/index.js';
  import { Input } from '$lib/components/ui/input/index.js';
  import { Label } from '$lib/components/ui/label/index.js';
  import * as Table from '$lib/components/ui/table/index.js';
  import * as Dialog from '$lib/components/ui/dialog/index.js';
  import * as DropdownMenu from '$lib/components/ui/dropdown-menu/index.js';
  import Icon from '@iconify/svelte';
  import SearchCombobox from '$lib/components/ui/SearchCombobox.svelte';
  import TableControls from '$lib/components/inventory/TableControls.svelte';

  let { data } = $props<{ data: PageData & { units: InventoryUnit[]; user: any } }>();

  let searchQuery = $state('');

  let filteredUnits = $derived(
    data.units.filter((u: InventoryUnit) =>
      u.description.toLowerCase().includes(searchQuery.toLowerCase()) ||
      (u.person_name && u.person_name.toLowerCase().includes(searchQuery.toLowerCase()))
    )
  );

  // Edit states
  let editOpen = $state(false);
  let selectedUnit = $state<InventoryUnit | null>(null);
  let bolWarehouse = $state(0);
  let bolEmployee = $state(0);
  let personInCharge = $state<number>(0);
  let personName = $state('');

  // Autocomplete states
  let employeeSearchQuery = $state('');
  let employees = $state<{ value: number; label: string }[]>([]);
  let loadingEmployees = $state(false);
  let searchTimeout: ReturnType<typeof setTimeout>;

  // Table controls state
  const columns = [
    { key: 'description', label: 'Description' },
    { key: 'type', label: 'Unit Type' },
    { key: 'employee', label: 'Employee' },
    { key: 'person', label: 'Person in Charge' }
  ];

  let visibleColumns = $state<Record<string, boolean>>({
    description: true,
    type: true,
    employee: true,
    person: true
  });

  let limit = $state(10);
  let page = $state(1);

  let paginatedUnits = $derived(
    filteredUnits.slice((page - 1) * limit, page * limit)
  );

  $effect(() => {
    if (filteredUnits) {
      page = 1;
    }
  });

  // Automated Debounced Search Function
  async function searchEmployees(query: string) {
    // We removed the 'if (!query.trim()) return;' line so empty strings are allowed!
    
    loadingEmployees = true;
    const res = await invokeService<any, any>('/get-employee-name', {
      body: { bol_getone: 0, employee_id: 0, employee_name: query },
      token: data.user.access_token
    });
    loadingEmployees = false;

    if ('data' in res && res.data.success) {
      const inner = res.data.data ?? res.data;
      const dataList = inner.json_data || [];
      employees = dataList.map((emp: any) => ({
        value: emp.employee_id,
        label: emp.employee_name
      }));
    } else {
      employees = [];
      console.error('[Units] Failed to query employee list:', res);
    }
  }

  // Watch for typing in the Combobox and trigger search automatically
  $effect(() => {
    // Removed the 'length >= 2' check. 
    // Now it runs immediately when the employee mode is toggled, or when typing.
    if (bolEmployee === 1) {
      clearTimeout(searchTimeout);
      // Wait 300ms to batch rapid keystrokes before calling the API
      searchTimeout = setTimeout(() => {
        searchEmployees(employeeSearchQuery || '');
      }, 300);
    }
  });

  $effect(() => {
    if (editOpen && selectedUnit) {
      bolWarehouse = selectedUnit.bol_warehouse;
      bolEmployee = selectedUnit.bol_employee;
      personInCharge = selectedUnit.person_in_charge || 0;
      personName = selectedUnit.person_name || '';
      employeeSearchQuery = '';

      if (selectedUnit.bol_employee === 1 && selectedUnit.person_in_charge) {
        employees = [{
          value: selectedUnit.person_in_charge,
          label: selectedUnit.person_name || 'Current PIC'
        }];
      } else {
        employees = [];
      }
    }
  });

  function openEdit(u: InventoryUnit) {
    selectedUnit = u;
    editOpen = true;
  }

  async function submitEdit(e: Event) {
    e.preventDefault();
    if (!selectedUnit) return;

    if (bolEmployee === 1 && personInCharge === 0) {
      toast.warning('Please select an employee');
      return;
    }

    if (bolEmployee === 0 && !personName.trim()) {
      toast.warning('Please enter the name of the Person-in-Charge');
      return;
    }

    const toastId = toast.loading('Saving unit configuration...');
    const response = await invokeService<any, any>('/post-inventory-unit', {
      body: {
        unit_id: selectedUnit.unit_id,
        bol_warehouse: bolWarehouse,
        bol_employee: bolEmployee,
        person_in_charge: personInCharge,
        person_name: personName.trim()
      },
      token: data.user.access_token
    });

    editOpen = false;

    if ('data' in response && response.data.success) {
      toast.success('Unit configuration updated successfully', { id: toastId });
      invalidateAll();
    } else {
      const errMsg = 'error' in response ? response.error : (response.data?.message || 'Unknown error');
      console.error('[Units] Failed to update unit configuration:', errMsg, response);
      toast.error(`Failed to update unit configuration: ${errMsg}`, { id: toastId });
    }
  }

  let refreshing = $state(false);

  async function refreshUnits() {
    refreshing = true;
    const toastId = toast.loading('Refreshing inventory units...');
    const response = await invokeService<any, any>('/post-update-inventory-unit', {
      body: {},
      token: data.user.access_token
    });
    refreshing = false;

    if ('data' in response && response.data.success) {
      toast.success(response.data?.message || 'Inventory units successfully refreshed and updated', { id: toastId });
      invalidateAll();
    } else {
      const errMsg = 'error' in response ? response.error : (response.data?.message || 'Unknown error');
      console.error('[Units] Failed to refresh inventory units:', errMsg, response);
      toast.error(`Failed to refresh inventory units: ${errMsg}`, { id: toastId });
    }
  }
</script>

<svelte:head>
  <title>Inventory Units - Serenity Inventory</title>
</svelte:head>

<div class="space-y-6">
  <div class="flex items-center justify-between">
    <div>
      <h2 class="text-2xl font-bold font-playfair text-primary">Warehouse Units</h2>
      <p class="text-sm text-muted-foreground">Manage storage units, warehouses, and person-in-charge assignments.</p>
    </div>
    <Button onclick={refreshUnits} disabled={refreshing} class="bg-primary hover:bg-primary/95 text-white flex items-center gap-2">
      {#if refreshing}
        <Icon icon="mdi:loading" class="animate-spin" width="20" />
      {:else}
        <Icon icon="mdi:refresh" width="20" />
      {/if}
      Refresh Inventory Unit
    </Button>
  </div>

  <div class="bg-card border rounded-xl p-4 shadow-sm">
    <div class="relative w-full sm:max-w-md">
      <Icon icon="mdi:magnify" width="16" class="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground pointer-events-none" />
      <Input
        type="text"
        placeholder="Search unit description or personnel..."
        bind:value={searchQuery}
        autocomplete="off"
        class="pl-9 h-10"
      />
    </div>
  </div>

  <TableControls
    {columns}
    bind:visibleColumns
    bind:limit
    bind:page
    total={filteredUnits.length}
  >
    <Table.Root>
      <Table.Header>
        <Table.Row class="bg-primary/5 hover:bg-primary/5 border-b-2 border-primary/10">
          {#if visibleColumns.description !== false}
            <Table.Head class="font-bold text-xs uppercase tracking-wider text-foreground/60">Description</Table.Head>
          {/if}
          {#if visibleColumns.type !== false}
            <Table.Head class="text-center w-[120px] font-bold text-xs uppercase tracking-wider text-foreground/60">Unit Type</Table.Head>
          {/if}
          {#if visibleColumns.employee !== false}
            <Table.Head class="text-center w-[110px] font-bold text-xs uppercase tracking-wider text-foreground/60">Employee</Table.Head>
          {/if}
          {#if visibleColumns.person !== false}
            <Table.Head class="font-bold text-xs uppercase tracking-wider text-foreground/60">Person in Charge</Table.Head>
          {/if}
          <Table.Head class="text-center w-[60px] font-bold text-xs uppercase tracking-wider text-foreground/60"></Table.Head>
        </Table.Row>
      </Table.Header>
      <Table.Body>
        {#if paginatedUnits.length === 0}
          <Table.Row>
            <Table.Cell colspan={columns.filter(c => visibleColumns[c.key] !== false).length + 1} class="h-40 text-center">
              <div class="flex flex-col items-center gap-2 text-muted-foreground">
                <Icon icon="mdi:warehouse-off" width="36" class="opacity-30" />
                <span class="text-sm">No units found.</span>
              </div>
            </Table.Cell>
          </Table.Row>
        {:else}
          {#each paginatedUnits as u, i (u.unit_id)}
            <Table.Row class="hover:bg-primary/5 transition-colors {i % 2 === 1 ? 'bg-muted/20' : ''}">
              {#if visibleColumns.description !== false}
                <Table.Cell class="font-semibold text-foreground">{u.description}</Table.Cell>
              {/if}
              {#if visibleColumns.type !== false}
                <Table.Cell class="text-center">
                  {#if u.bol_warehouse === 1}
                    <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-md text-xs font-bold bg-emerald-50 text-emerald-700 border border-emerald-200">WAREHOUSE</span>
                  {:else}
                    <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-md text-xs font-bold bg-teal-50 text-teal-700 border border-teal-200">STORE</span>
                  {/if}
                </Table.Cell>
              {/if}
              {#if visibleColumns.employee !== false}
                <Table.Cell class="text-center">
                  {#if u.bol_employee === 1}
                    <span class="inline-flex items-center gap-1 px-2 py-0.5 rounded-md text-xs font-bold bg-teal-50 text-teal-700 border border-teal-200">YES</span>
                  {:else}
                    <span class="inline-flex items-center gap-1 px-2 py-0.5 rounded-md text-xs font-bold bg-muted text-muted-foreground border">NO</span>
                  {/if}
                </Table.Cell>
              {/if}
              {#if visibleColumns.person !== false}
                <Table.Cell>
                  {#if u.person_name}
                    <div class="flex items-center gap-2">
                      <span class="font-medium text-foreground">{u.person_name}</span>
                      {#if u.bol_employee === 1 && u.person_in_charge}
                        <span class="text-xs text-muted-foreground font-mono bg-muted px-1.5 py-0.5 rounded">#{u.person_in_charge}</span>
                      {/if}
                    </div>
                  {:else}
                    <span class="text-muted-foreground italic text-xs">Unassigned</span>
                  {/if}
                </Table.Cell>
              {/if}
              <Table.Cell class="text-center">
                <DropdownMenu.Root>
                  <DropdownMenu.Trigger class="rounded-lg p-1.5 text-muted-foreground transition-colors hover:bg-muted hover:text-foreground focus:outline-none">
                    <Icon icon="mdi:dots-vertical" width="17" />
                  </DropdownMenu.Trigger>
                  <DropdownMenu.Content class="bg-card rounded-xl shadow-xl border border-border p-1.5 min-w-44 z-50 mt-1" align="end">
                    <DropdownMenu.Item onclick={() => openEdit(u)} class="flex items-center gap-2 hover:bg-muted px-3 py-2 rounded-lg cursor-pointer text-sm transition-colors text-teal-650 dark:text-teal-450 font-medium">
                      <Icon icon="mdi:cog-outline" width="16" />
                      Configure
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

  <Dialog.Root bind:open={editOpen}>
    <Dialog.Content
      onInteractOutside={(e) => e.preventDefault()}
      onEscapeKeydown={(e) => e.preventDefault()}
      class="sm:max-w-[460px] bg-card border-0 rounded-2xl shadow-2xl p-0 overflow-hidden"
    >
      {#if selectedUnit}
        <div class="bg-primary/5 border-b px-6 py-4">
          <div class="flex items-center gap-3">
            <div class="w-9 h-9 rounded-xl bg-primary/10 flex items-center justify-center">
              <Icon icon="mdi:cog-outline" width="18" class="text-primary" />
            </div>
            <Dialog.Title class="text-lg font-bold text-foreground">Configure: {selectedUnit.description}</Dialog.Title>
          </div>
        </div>
        <form onsubmit={submitEdit} class="px-6 py-5 space-y-4">
          <div class="flex flex-col gap-1.5">
            <Label class="text-xs font-bold uppercase tracking-wider text-muted-foreground">Unit Type</Label>
            <div class="grid grid-cols-2 gap-4">
              <label class="flex items-center gap-2 cursor-pointer p-3 rounded-xl border hover:bg-muted/50 transition-colors {bolWarehouse === 1 ? 'border-primary bg-primary/5' : 'border-border'}">
                <input
                  type="radio"
                  name="unit_type"
                  checked={bolWarehouse === 1}
                  onchange={() => bolWarehouse = 1}
                  class="size-4 text-teal-600 focus:ring-teal-500"
                />
                <span class="text-sm font-semibold">Warehouse</span>
              </label>
              <label class="flex items-center gap-2 cursor-pointer p-3 rounded-xl border hover:bg-muted/50 transition-colors {bolWarehouse === 0 ? 'border-primary bg-primary/5' : 'border-border'}">
                <input
                  type="radio"
                  name="unit_type"
                  checked={bolWarehouse === 0}
                  onchange={() => bolWarehouse = 0}
                  class="size-4 text-teal-600 focus:ring-teal-500"
                />
                <span class="text-sm font-semibold">Store</span>
              </label>
            </div>
          </div>

          <div class="flex flex-col gap-1.5">
            <Label class="text-xs font-bold uppercase tracking-wider text-muted-foreground">Person-in-Charge Assignment</Label>
            <label class="flex items-center gap-2 cursor-pointer py-1.5 select-none">
              <input
                type="checkbox"
                checked={bolEmployee === 1}
                onchange={(e) => {
                  bolEmployee = e.currentTarget.checked ? 1 : 0;
                  personInCharge = 0;
                  personName = '';
                  employees = [];
                }}
                class="size-4 rounded border-gray-300 text-teal-600 focus:ring-teal-500"
              />
              <span class="text-sm font-semibold">Person-in-Charge is an Employee</span>
            </label>
          </div>

          {#if bolEmployee === 1}
            <div class="flex flex-col gap-1.5">
              <Label class="text-xs font-bold uppercase tracking-wider text-muted-foreground">Search & Select Employee *</Label>
              <SearchCombobox
                options={employees}
                bind:value={personInCharge}
                bind:searchValue={employeeSearchQuery}
                onchange={(val) => {
                  if (val) {
                    const emp = employees.find(e => e.value === val);
                    if (emp) personName = emp.label;
                  } else {
                    personName = '';
                  }
                }}
                placeholder={loadingEmployees ? "Searching..." : "Type to search employees..."}
                searchPlaceholder="Search directory..."
              />
            </div>
          {:else}
            <div class="flex flex-col gap-1.5">
              <Label for="pic_name" class="text-xs font-bold uppercase tracking-wider text-muted-foreground">Person Name *</Label>
              <Input
                type="text"
                id="pic_name"
                placeholder="e.g. John Doe"
                bind:value={personName}
                autocomplete="off"
                class="h-10"
                required
              />
            </div>
          {/if}

          <div class="flex justify-end gap-2 pt-4 border-t">
            <Button type="button" variant="outline" onclick={() => editOpen = false} class="h-9 px-5">Cancel</Button>
            <Button type="submit" class="h-9 px-5 bg-primary hover:bg-primary/90 text-white">Save Configuration</Button>
          </div>
        </form>
      {/if}
    </Dialog.Content>
  </Dialog.Root>
</div>