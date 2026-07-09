<script lang="ts">
  import type { PageData } from './$types';
  import type { AdjustmentTemplate } from '$lib/types';
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

  let { data } = $props<{ data: PageData & { templates: any[]; user: any } }>();

  let searchQuery = $state('');

  import TableControls from '$lib/components/inventory/TableControls.svelte';

  // Table controls state
  const columns = [
    { key: 'description', label: 'Description' },
    { key: 'requires_src_dest', label: 'Unit Requirements' },
    { key: 'add_to_qty', label: 'Increases Stock' }
  ];

  let visibleColumns = $state<Record<string, boolean>>({
    description: true,
    requires_src_dest: true,
    add_to_qty: true
  });

  let limit = $state(10);
  let page = $state(1);

  // Normalize fields returned by backend
  let normalizedTemplates = $derived(
    data.templates.map((t: any) => ({
      template_id: t.template_id,
      description: t.description,
      require_destination_and_source: t.require_destination_and_source ?? t.requires_src_dest ?? 0,
      add_to_quantity: t.add_to_quantity ?? t.add_to_qty ?? 0
    }))
  );

  let filteredTemplates = $derived(
    normalizedTemplates.filter((t: any) =>
      t.description.toLowerCase().includes(searchQuery.toLowerCase())
    )
  );

  let paginatedTemplates = $derived(
    filteredTemplates.slice((page - 1) * limit, page * limit)
  );

  $effect(() => {
    if (filteredTemplates) {
      page = 1;
    }
  });

  // Form states
  let formOpen = $state(false);
  let selectedTemplate = $state<any | null>(null);
  let description = $state('');
  let requireDestSrc = $state<number>(0);
  let addToQuantity = $state(0);

  // Delete states
  let deleteOpen = $state(false);
  let selectedTemplateForDelete = $state<any | null>(null);

  $effect(() => {
    if (formOpen) {
      if (selectedTemplate) {
        description = selectedTemplate.description;
        requireDestSrc = Number(selectedTemplate.require_destination_and_source);
        addToQuantity = selectedTemplate.add_to_quantity ? 1 : 0;
      } else {
        description = '';
        requireDestSrc = 0;
        addToQuantity = 0;
      }
    }
  });

  function openAdd() {
    selectedTemplate = null;
    formOpen = true;
  }

  function openEdit(t: any) {
    selectedTemplate = t;
    formOpen = true;
  }

  function openDelete(t: any) {
    selectedTemplateForDelete = t;
    deleteOpen = true;
  }

  async function submitForm(e: Event) {
    e.preventDefault();
    if (!description.trim()) return;

    const isEdit = !!selectedTemplate;
    const process_type = isEdit ? 1 : 0;
    const toastId = toast.loading(isEdit ? 'Updating template...' : 'Creating template...');

    const response = await invokeService<any, any>('/post-inventory-item-adjustment-template', {
      body: {
        process_type,
        template_id: isEdit ? selectedTemplate.template_id : 0,
        description,
        require_destination_and_source: requireDestSrc,
        add_to_quantity: addToQuantity,
        user_id: data.user.member?.member_id ?? 1
      },
      token: data.user.access_token
    });

    formOpen = false;

    if ('data' in response && response.data.success) {
      toast.success(isEdit ? 'Template updated' : 'Template created', { id: toastId });
      invalidateAll();
    } else {
      const errMsg = 'error' in response ? response.error : (response.data?.message || 'Unknown error');
      console.error('[Adjustment Templates] Failed to save template:', errMsg, response);
      toast.error(`Failed to save template: ${errMsg}`, { id: toastId });
    }
  }

  async function deleteTemplate() {
    if (!selectedTemplateForDelete) return;

    const toastId = toast.loading('Deleting template...');
    const response = await invokeService<any, any>('/post-inventory-item-adjustment-template', {
      body: {
        process_type: 2,
        template_id: selectedTemplateForDelete.template_id,
        description: selectedTemplateForDelete.description,
        require_destination_and_source: selectedTemplateForDelete.require_destination_and_source,
        add_to_quantity: selectedTemplateForDelete.add_to_quantity,
        user_id: data.user.member?.member_id ?? 1
      },
      token: data.user.access_token
    });

    deleteOpen = false;

    if ('data' in response && response.data.success) {
      toast.success('Template deleted successfully', { id: toastId });
      invalidateAll();
    } else {
      const errMsg = 'error' in response ? response.error : (response.data?.message || 'Unknown error');
      console.error('[Adjustment Templates] Failed to delete template:', errMsg, response);
      toast.error(`Failed to delete template: ${errMsg}`, { id: toastId });
    }
  }
</script>

<svelte:head>
  <title>Templates - Serenity Inventory</title>
</svelte:head>

<div class="space-y-6">
  <!-- Page Header -->
  <div class="flex items-center justify-between">
    <div>
      <h2 class="text-2xl font-bold font-playfair text-primary">Adjustment Templates</h2>
      <p class="text-sm text-muted-foreground">Configure templates defining rules for stock transactions.</p>
    </div>
    <Button onclick={openAdd} class="bg-primary hover:bg-primary/95 text-white flex items-center gap-2">
      <Icon icon="mdi:plus" width="20" />
      Add Template
    </Button>
  </div>

  <!-- Search Filter -->
  <div class="bg-card border rounded-xl p-4 shadow-sm">
      <div class="relative w-full sm:max-w-md">
        <Icon icon="mdi:magnify" width="16" class="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground pointer-events-none" />
        <Input
          type="text"
          placeholder="Search templates..."
          bind:value={searchQuery}
          autocomplete="off"
          class="pl-9 h-10"
        />
      </div>
  </div>

  <!-- Templates Table -->
  <TableControls
    {columns}
    bind:visibleColumns
    bind:limit
    bind:page
    total={filteredTemplates.length}
  >
    <Table.Root>
      <Table.Header>
        <Table.Row class="bg-primary/5 hover:bg-primary/5 border-b-2 border-primary/10">
          {#if visibleColumns.description !== false}
            <Table.Head class="font-bold text-xs uppercase tracking-wider text-foreground/60">Description</Table.Head>
          {/if}
          {#if visibleColumns.requires_src_dest !== false}
            <Table.Head class="font-bold text-xs uppercase tracking-wider text-foreground/60">Unit Requirements</Table.Head>
          {/if}
          {#if visibleColumns.add_to_qty !== false}
            <Table.Head class="text-center w-[130px] font-bold text-xs uppercase tracking-wider text-foreground/60">Increases Stock</Table.Head>
          {/if}
          <Table.Head class="text-center w-[60px] font-bold text-xs uppercase tracking-wider text-foreground/60"></Table.Head>
        </Table.Row>
      </Table.Header>
      <Table.Body>
        {#if paginatedTemplates.length === 0}
          <Table.Row>
            <Table.Cell colspan={columns.filter(c => visibleColumns[c.key] !== false).length + 1} class="h-40 text-center">
              <div class="flex flex-col items-center gap-2 text-muted-foreground">
                <Icon icon="mdi:file-document-off-outline" width="36" class="opacity-30" />
                <span class="text-sm">No templates found.</span>
              </div>
            </Table.Cell>
          </Table.Row>
        {:else}
          {#each paginatedTemplates as t, i (t.template_id)}
            <Table.Row class="hover:bg-primary/5 transition-colors {i % 2 === 1 ? 'bg-muted/20' : ''}">
              {#if visibleColumns.description !== false}
                <Table.Cell class="font-semibold text-foreground">{t.description}</Table.Cell>
              {/if}
              {#if visibleColumns.requires_src_dest !== false}
                <Table.Cell class="text-xs text-muted-foreground font-medium">
                  {#if t.require_destination_and_source === 0}External Adjust
                  {:else if t.require_destination_and_source === 1}Source Unit Only (Issuance)
                  {:else if t.require_destination_and_source === 2}Destination Unit Only (Receiving)
                  {:else if t.require_destination_and_source === 3}Both Src + Dest (Transfer)
                  {:else}Custom ({t.require_destination_and_source}){/if}
                </Table.Cell>
              {/if}
              {#if visibleColumns.add_to_qty !== false}
                <Table.Cell class="text-center">
                  {#if t.add_to_quantity === 1}
                    <span class="inline-flex items-center gap-1 px-2 py-0.5 rounded-md text-xs font-bold bg-emerald-50 text-emerald-700 border border-emerald-200">YES</span>
                  {:else}
                    <span class="inline-flex items-center gap-1 px-2 py-0.5 rounded-md text-xs font-bold bg-rose-50 text-rose-600 border border-rose-200">NO</span>
                  {/if}
                </Table.Cell>
              {/if}
              <Table.Cell class="text-center">
                <DropdownMenu.Root>
                  <DropdownMenu.Trigger class="rounded-lg p-1.5 text-muted-foreground transition-colors hover:bg-muted hover:text-foreground focus:outline-none">
                    <Icon icon="mdi:dots-vertical" width="17" />
                  </DropdownMenu.Trigger>
                  <DropdownMenu.Content class="bg-card rounded-xl shadow-xl border border-border p-1.5 min-w-44 z-50 mt-1" align="end">
                    <DropdownMenu.Item onclick={() => openEdit(t)} class="flex items-center gap-2 hover:bg-muted px-3 py-2 rounded-lg cursor-pointer text-sm transition-colors text-teal-650 dark:text-teal-450 font-medium">
                      <Icon icon="mdi:pencil-outline" width="16" />
                      Edit
                    </DropdownMenu.Item>
                    <DropdownMenu.Separator class="my-1 border-t border-border" />
                    <DropdownMenu.Item onclick={() => openDelete(t)} class="flex items-center gap-2 hover:bg-rose-500/10 text-rose-500 px-3 py-2 rounded-lg cursor-pointer text-sm font-semibold transition-colors">
                      <Icon icon="mdi:delete-outline" width="16" />
                      Delete
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

  <!-- Form Dialog -->
  <Dialog.Root bind:open={formOpen}>
    <Dialog.Content
      onInteractOutside={(e) => e.preventDefault()}
      onEscapeKeydown={(e) => e.preventDefault()}
      class="sm:max-w-[460px] bg-card border-0 rounded-2xl shadow-2xl p-0 overflow-hidden"
    >
      <div class="bg-primary/5 border-b px-6 py-4">
        <div class="flex items-center gap-3">
          <div class="w-9 h-9 rounded-xl bg-primary/10 flex items-center justify-center">
            <Icon icon={selectedTemplate ? 'mdi:pencil' : 'mdi:plus'} width="18" class="text-primary" />
          </div>
          <Dialog.Title class="text-lg font-bold text-foreground">
            {selectedTemplate ? 'Edit Template' : 'New Template'}
          </Dialog.Title>
        </div>
      </div>
      <form onsubmit={submitForm} class="px-6 py-5 space-y-4">
        <div class="flex flex-col gap-1.5">
          <Label for="description" class="text-xs font-bold uppercase tracking-wider text-muted-foreground">Template Description *</Label>
          <Input
            type="text"
            id="description"
            placeholder="e.g. Sales Issue, Stock Refill"
            bind:value={description}
            autocomplete="off"
            class="h-10"
            required
          />
        </div>

        <div class="flex flex-col gap-1.5">
          <Label for="requires" class="text-xs font-bold uppercase tracking-wider text-muted-foreground">Unit Fields Requirements *</Label>
          <select
            id="requires"
            bind:value={requireDestSrc}
            class="flex h-10 w-full rounded-xl border border-input bg-background px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
          >
            <option value={0}>0 — Neither (External Adjustment)</option>
            <option value={1}>1 — Source Unit Only (Issuance)</option>
            <option value={2}>2 — Destination Unit Only (Refill)</option>
            <option value={3}>3 — Both Source and Destination (Transfer)</option>
          </select>
        </div>

        <label class="flex items-center gap-3 cursor-pointer p-3 rounded-xl border hover:bg-muted/50 transition-colors">
          <input
            type="checkbox"
            id="add_qty"
            checked={addToQuantity === 1}
            onchange={(e) => addToQuantity = e.currentTarget.checked ? 1 : 0}
            class="size-4 rounded border-gray-300 text-teal-600 focus:ring-teal-500"
          />
          <span class="text-sm font-semibold">Increases Item Stock Quantity</span>
        </label>

        <div class="flex justify-end gap-2 pt-4 border-t">
          <Button type="button" variant="outline" onclick={() => formOpen = false} class="h-9 px-5">Cancel</Button>
          <Button type="submit" class="h-9 px-5 bg-primary hover:bg-primary/90 text-white">Save Template</Button>
        </div>
      </form>
    </Dialog.Content>
  </Dialog.Root>

  <!-- Delete Dialog -->
  <Dialog.Root bind:open={deleteOpen}>
    <Dialog.Content class="sm:max-w-[400px] bg-card border-0 rounded-2xl shadow-2xl p-0 overflow-hidden">
      {#if selectedTemplateForDelete}
        <div class="bg-rose-50 border-b border-rose-100 px-6 py-4">
          <div class="flex items-center gap-3">
            <div class="w-9 h-9 rounded-xl bg-rose-100 flex items-center justify-center">
              <Icon icon="mdi:delete-alert-outline" width="18" class="text-rose-600" />
            </div>
            <Dialog.Title class="text-lg font-bold text-rose-700">Delete Template</Dialog.Title>
          </div>
        </div>
        <div class="px-6 py-5">
          <p class="text-sm text-muted-foreground">
            Are you sure you want to delete <span class="font-bold text-foreground">"{selectedTemplateForDelete.description}"</span>? This action is permanent.
          </p>
          <div class="flex justify-end gap-2 pt-5 border-t mt-5">
            <Button variant="outline" onclick={() => deleteOpen = false} class="h-9 px-5">Cancel</Button>
            <Button onclick={deleteTemplate} class="h-9 px-5 bg-rose-600 hover:bg-rose-700 text-white">Delete</Button>
          </div>
        </div>
      {/if}
    </Dialog.Content>
  </Dialog.Root>
</div>
