<script lang="ts">
  import type { PageData } from './$types';
  import { invokeService } from '$lib/service/invokeService';
  import { invalidateAll } from '$app/navigation';
  import { toast } from 'svelte-sonner';
  import StatusBadge from '$lib/components/inventory/StatusBadge.svelte';
  import { Button } from '$lib/components/ui/button/index.js';
  import { Input } from '$lib/components/ui/input/index.js';
  import { Label } from '$lib/components/ui/label/index.js';
  import * as Table from '$lib/components/ui/table/index.js';
  import * as Dialog from '$lib/components/ui/dialog/index.js';
  import * as DropdownMenu from '$lib/components/ui/dropdown-menu/index.js';
  import Icon from '@iconify/svelte';
  import TableControls from '$lib/components/inventory/TableControls.svelte';

  let { data } = $props<{ data: PageData & { transitReport: any[]; transitInvoices: any[]; user: any } }>();

  // Tab State
  let activeTab = $state<'report' | 'invoices'>('report');

  // Search State for report tab
  let searchQuery = $state('');
  let reportItems = $state<any[]>([]);
  let loadingReport = $state(false);

  // Sync initial report data
  $effect(() => {
    reportItems = data.transitReport;
  });

  // Client side filtering for Report items
  let filteredReportItems = $derived(
    reportItems.filter((item: any) =>
      (item.item_description && item.item_description.toLowerCase().includes(searchQuery.toLowerCase())) ||
      (item.reference_no && item.reference_no.toLowerCase().includes(searchQuery.toLowerCase())) ||
      (item.supplier_name && item.supplier_name.toLowerCase().includes(searchQuery.toLowerCase()))
    )
  );

  // Client side filtering for Invoices
  let filteredInvoices = $derived(
    data.transitInvoices.filter((inv: any) =>
      inv.invoice_reference?.toLowerCase().includes(searchQuery.toLowerCase()) ||
      inv.supplier_name?.toLowerCase().includes(searchQuery.toLowerCase())
    )
  );

  // Table 1 (Reports) controls
  const reportColumns = [
    { key: 'ref', label: 'Reference No' },
    { key: 'supplier', label: 'Supplier' },
    { key: 'item', label: 'Item Details' },
    { key: 'sentQty', label: 'Sent Qty' },
    { key: 'recvQty', label: 'Recv Qty' },
    { key: 'status', label: 'Status' },
    { key: 'shipped', label: 'Shipped' }
  ];
  let visibleReportColumns = $state<Record<string, boolean>>({
    ref: true,
    supplier: true,
    item: true,
    sentQty: true,
    recvQty: true,
    status: true,
    shipped: true
  });
  let reportLimit = $state(10);
  let reportPage = $state(1);
  let paginatedReportItems = $derived(
    filteredReportItems.slice((reportPage - 1) * reportLimit, reportPage * reportLimit)
  );

  // Table 2 (Invoices) controls
  const invoiceColumns = [
    { key: 'ref', label: 'Reference No' },
    { key: 'supplier', label: 'Supplier' },
    { key: 'created', label: 'Created' },
    { key: 'status', label: 'Status' }
  ];
  let visibleInvoiceColumns = $state<Record<string, boolean>>({
    ref: true,
    supplier: true,
    created: true,
    status: true
  });
  let invoiceLimit = $state(10);
  let invoicePage = $state(1);
  let paginatedInvoices = $derived(
    filteredInvoices.slice((invoicePage - 1) * invoiceLimit, invoicePage * invoiceLimit)
  );

  $effect(() => {
    if (searchQuery) {
      reportPage = 1;
      invoicePage = 1;
    }
  });

  // Confirm Receipt Dialog States
  let confirmOpen = $state(false);
  let selectedInvoice = $state<any | null>(null);
  let invoiceItems = $state<any[]>([]);
  let loadingItems = $state(false);
  let confirmReceiptSubmitOpen = $state(false);

  // Fetch invoice details when selectedInvoice changes
  async function openConfirm(invoice: any) {
    selectedInvoice = invoice;
    confirmOpen = true;
    loadingItems = true;
    invoiceItems = [];

    const response = await invokeService<any, any[]>('/get-in-transit-items-invoices', {
      body: {
        bol_getone: 1,
        invoice_id: invoice.invoice_id,
        user_id: data.user.member?.member_id ?? 1,
        invoice_reference: invoice.invoice_reference || ''
      },
      token: data.user.access_token
    });

    loadingItems = false;

    if ('data' in response && response.data.success) {
      const items = response.data?.data?.json_data || [];
      // Initialize quanttiy_confirmed field for each item
      invoiceItems = items.map((item: any) => ({
        ...item,
        // Default confirmed qty to sent/ordered qty
        quanttiy_confirmed: item.quantity_ordered ?? item.quantity_sent ?? item.quantity ?? 0
      }));
    } else {
      const errMsg = 'error' in response ? response.error : (response.data?.message || 'Unknown error');
      console.error('[In-Transit] Failed to load invoice item details:', errMsg, response);
      toast.error(`Failed to load invoice item details: ${errMsg}`);
      confirmOpen = false;
    }
  }

  // Confirm Receipt submission
  function submitConfirmation(e: Event) {
    e.preventDefault();
    if (!selectedInvoice) return;
    confirmReceiptSubmitOpen = true;
  }

  async function executeReceiptConfirmation() {
    confirmReceiptSubmitOpen = false;
    if (!selectedInvoice) return;

    const toastId = toast.loading('Submitting receipt confirmation...');

    // Construct array matching PostConfirmInTransitItemsRequest schema
    const payloadItems = invoiceItems.map((item: any) => ({
      in_transit_id: item.in_transit_id,
      quanttiy_confirmed: Number(item.quanttiy_confirmed) // Note the SP schema spelling!
    }));

    const response = await invokeService<any, any>('/post-confirm-in-transit-items', {
      body: {
        user_id: data.user.member?.member_id ?? 1,
        invoice_id: selectedInvoice.invoice_id,
        in_transit_items: payloadItems
      },
      token: data.user.access_token
    });

    if ('data' in response && response.data.success) {
      toast.success('In-transit items confirmed successfully', { id: toastId });
      confirmOpen = false;
      invalidateAll();
    } else {
      const errMsg = 'error' in response ? response.error : (response.data?.message || 'Unknown error');
      console.error('[In-Transit] Failed to confirm items receipt:', errMsg, response);
      toast.error(`Failed to confirm items receipt: ${errMsg}`, { id: toastId });
    }
  }

  // Trigger search on backend
  async function searchBackendReport() {
    loadingReport = true;
    const response = await invokeService<any, any[]>('/get-instransit-report', {
      body: { search: searchQuery },
      token: data.user.access_token
    });
    loadingReport = false;

    if ('data' in response && response.data.success) {
      reportItems = response.data?.data?.json_data || [];
    } else {
      const errMsg = 'error' in response ? response.error : (response.data?.message || 'Unknown error');
      console.error('[In-Transit] Failed to search in-transit report:', errMsg, response);
      toast.error(`Failed to search in-transit report: ${errMsg}`);
    }
  }
</script>

<svelte:head>
  <title>In-Transit - Serenity Inventory</title>
</svelte:head>

<div class="space-y-6">
  <!-- Page Header -->
  <div>
    <h2 class="text-2xl font-bold font-playfair text-primary">In-Transit Shipments</h2>
    <p class="text-sm text-muted-foreground">Track shipments en route and confirm stock deliveries upon receipt.</p>
  </div>

  <!-- Tabs Navigation -->
  <div class="border-b flex gap-6 border-border">
    <button
      class="pb-3 text-sm font-bold border-b-2 transition-all duration-200 {activeTab === 'report' ? 'border-primary text-primary' : 'border-transparent text-muted-foreground hover:text-foreground'}"
      onclick={() => { activeTab = 'report'; searchQuery = ''; }}
    >
      Transit Report Logs
    </button>
    <button
      class="pb-3 text-sm font-bold border-b-2 transition-all duration-200 {activeTab === 'invoices' ? 'border-primary text-primary' : 'border-transparent text-muted-foreground hover:text-foreground'}"
      onclick={() => { activeTab = 'invoices'; searchQuery = ''; }}
    >
      Pending Inbound Invoices
    </button>
  </div>

  <!-- Filter Search bar -->
  <div class="bg-card border rounded-xl p-4 shadow-sm flex items-center gap-4 flex-wrap">
    <div class="relative w-full sm:max-w-md">
      <Icon icon="mdi:magnify" width="16" class="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground pointer-events-none" />
      <Input
        type="text"
        placeholder={activeTab === 'report' ? 'Search items, suppliers, reference...' : 'Search reference, suppliers...'}
        bind:value={searchQuery}
        autocomplete="off"
        class="pl-9 h-10"
      />
    </div>
    {#if activeTab === 'report'}
      <Button variant="outline" class="h-10 flex items-center gap-1.5 text-primary border-primary/30 hover:bg-primary/10 shadow-sm" onclick={searchBackendReport} disabled={loadingReport}>
        {#if loadingReport}
          <Icon icon="mdi:loading" class="animate-spin" width="18" />
        {:else}
          <Icon icon="mdi:magnify" width="18" />
        {/if}
        Query API
      </Button>
    {/if}
  </div>

  <!-- Report Tab -->
  {#if activeTab === 'report'}
    <TableControls
      columns={reportColumns}
      bind:visibleColumns={visibleReportColumns}
      bind:limit={reportLimit}
      bind:page={reportPage}
      total={filteredReportItems.length}
    >
      <div class="overflow-x-auto w-full">
        <Table.Root>
          <Table.Header>
            <Table.Row class="bg-primary/5 hover:bg-primary/5 border-b-2 border-primary/10">
              {#if visibleReportColumns.ref !== false}
                <Table.Head class="font-bold text-xs uppercase tracking-wider text-foreground/60">Reference No</Table.Head>
              {/if}
              {#if visibleReportColumns.supplier !== false}
                <Table.Head class="font-bold text-xs uppercase tracking-wider text-foreground/60">Supplier</Table.Head>
              {/if}
              {#if visibleReportColumns.item !== false}
                <Table.Head class="font-bold text-xs uppercase tracking-wider text-foreground/60">Item Details</Table.Head>
              {/if}
              {#if visibleReportColumns.sentQty !== false}
                <Table.Head class="text-right font-bold text-xs uppercase tracking-wider text-foreground/60">Sent Qty</Table.Head>
              {/if}
              {#if visibleReportColumns.recvQty !== false}
                <Table.Head class="text-right font-bold text-xs uppercase tracking-wider text-foreground/60">Recv Qty</Table.Head>
              {/if}
              {#if visibleReportColumns.status !== false}
                <Table.Head class="text-center w-[110px] font-bold text-xs uppercase tracking-wider text-foreground/60">Status</Table.Head>
              {/if}
              {#if visibleReportColumns.shipped !== false}
                <Table.Head class="font-bold text-xs uppercase tracking-wider text-foreground/60">Shipped</Table.Head>
              {/if}
            </Table.Row>
          </Table.Header>
          <Table.Body>
            {#if paginatedReportItems.length === 0}
              <Table.Row>
                <Table.Cell colspan={reportColumns.filter(c => visibleReportColumns[c.key] !== false).length} class="h-40 text-center">
                  <div class="flex flex-col items-center gap-2 text-muted-foreground">
                    <Icon icon="mdi:truck-off-outline" width="36" class="opacity-30" />
                    <span class="text-sm">No transit shipment records found.</span>
                  </div>
                </Table.Cell>
              </Table.Row>
            {:else}
              {#each paginatedReportItems as item, i}
                <Table.Row class="hover:bg-primary/5 transition-colors {i % 2 === 1 ? 'bg-muted/20' : ''}">
                  {#if visibleReportColumns.ref !== false}
                    <Table.Cell class="font-mono font-medium text-slate-700 dark:text-slate-300">{item.reference_no}</Table.Cell>
                  {/if}
                  {#if visibleReportColumns.supplier !== false}
                    <Table.Cell>{item.supplier_name}</Table.Cell>
                  {/if}
                  {#if visibleReportColumns.item !== false}
                    <Table.Cell class="font-semibold text-slate-700 dark:text-slate-300">{item.item_description}</Table.Cell>
                  {/if}
                  {#if visibleReportColumns.sentQty !== false}
                    <Table.Cell class="text-right font-mono font-semibold text-slate-800 dark:text-slate-200">{item.quantity_sent || item.quantity_ordered || 0}</Table.Cell>
                  {/if}
                  {#if visibleReportColumns.recvQty !== false}
                    <Table.Cell class="text-right font-mono font-semibold text-emerald-600 dark:text-emerald-400">{item.quantity_received ?? '—'}</Table.Cell>
                  {/if}
                  {#if visibleReportColumns.status !== false}
                    <Table.Cell class="text-center">
                      <StatusBadge status={item.status || 'IN-TRANSIT'} />
                    </Table.Cell>
                  {/if}
                  {#if visibleReportColumns.shipped !== false}
                    <Table.Cell class="whitespace-nowrap text-xs text-muted-foreground">
                      {item.added_date ? new Date(item.added_date).toLocaleDateString() : '—'}
                    </Table.Cell>
                  {/if}
                </Table.Row>
              {/each}
            {/if}
          </Table.Body>
        </Table.Root>
      </div>
    </TableControls>
  {/if}

  <!-- Invoices Tab -->
  {#if activeTab === 'invoices'}
    <TableControls
      columns={invoiceColumns}
      bind:visibleColumns={visibleInvoiceColumns}
      bind:limit={invoiceLimit}
      bind:page={invoicePage}
      total={filteredInvoices.length}
    >
      <div class="overflow-x-auto w-full">
        <Table.Root>
          <Table.Header>
            <Table.Row class="bg-primary/5 hover:bg-primary/5 border-b-2 border-primary/10">
              {#if visibleInvoiceColumns.ref !== false}
                <Table.Head class="font-bold text-xs uppercase tracking-wider text-foreground/60">Reference No</Table.Head>
              {/if}
              {#if visibleInvoiceColumns.supplier !== false}
                <Table.Head class="font-bold text-xs uppercase tracking-wider text-foreground/60">Supplier</Table.Head>
              {/if}
              {#if visibleInvoiceColumns.created !== false}
                <Table.Head class="font-bold text-xs uppercase tracking-wider text-foreground/60">Created</Table.Head>
              {/if}
              {#if visibleInvoiceColumns.status !== false}
                <Table.Head class="text-center w-[110px] font-bold text-xs uppercase tracking-wider text-foreground/60">Status</Table.Head>
              {/if}
              <Table.Head class="text-center w-[60px] font-bold text-xs uppercase tracking-wider text-foreground/60"></Table.Head>
            </Table.Row>
          </Table.Header>
          <Table.Body>
            {#if paginatedInvoices.length === 0}
              <Table.Row>
                <Table.Cell colspan={invoiceColumns.filter(c => visibleInvoiceColumns[c.key] !== false).length + 1} class="h-40 text-center">
                  <div class="flex flex-col items-center gap-2 text-muted-foreground">
                    <Icon icon="mdi:inbox-outline" width="36" class="opacity-30" />
                    <span class="text-sm">No pending inbound invoices found.</span>
                  </div>
                </Table.Cell>
              </Table.Row>
            {:else}
              {#each paginatedInvoices as inv, i (inv.invoice_id)}
                <Table.Row class="hover:bg-primary/5 transition-colors {i % 2 === 1 ? 'bg-muted/20' : ''}">
                  {#if visibleInvoiceColumns.ref !== false}
                    <Table.Cell class="font-mono font-medium text-slate-700 dark:text-slate-300">{inv.invoice_reference || '—'}</Table.Cell>
                  {/if}
                  {#if visibleInvoiceColumns.supplier !== false}
                    <Table.Cell>{inv.supplier_name}</Table.Cell>
                  {/if}
                  {#if visibleInvoiceColumns.created !== false}
                    <Table.Cell class="whitespace-nowrap text-xs text-muted-foreground">
                      {inv.added_date ? new Date(inv.added_date).toLocaleDateString() : '—'}
                    </Table.Cell>
                  {/if}
                  {#if visibleInvoiceColumns.status !== false}
                    <Table.Cell class="text-center">
                      <StatusBadge status={inv.status || 'PENDING'} />
                    </Table.Cell>
                  {/if}
                  <Table.Cell class="text-center">
                    {#if inv.status?.toUpperCase() !== 'CONFIRMED'}
                      <DropdownMenu.Root>
                        <DropdownMenu.Trigger class="rounded-lg p-1.5 text-muted-foreground transition-colors hover:bg-muted hover:text-foreground focus:outline-none">
                          <Icon icon="mdi:dots-vertical" width="17" />
                        </DropdownMenu.Trigger>
                        <DropdownMenu.Content class="bg-card rounded-xl shadow-xl border border-border p-1.5 min-w-44 z-50 mt-1" align="end">
                          <DropdownMenu.Item onclick={() => openConfirm(inv)} class="flex items-center gap-2 hover:bg-muted px-3 py-2 rounded-lg cursor-pointer text-sm transition-colors text-emerald-650 dark:text-emerald-455 font-semibold">
                            <Icon icon="mdi:check-circle-outline" width="16" />
                            Confirm Receipt
                          </DropdownMenu.Item>
                        </DropdownMenu.Content>
                      </DropdownMenu.Root>
                    {:else}
                      <span class="text-xs font-semibold text-emerald-600 dark:text-emerald-400">CONFIRMED</span>
                    {/if}
                  </Table.Cell>
                </Table.Row>
              {/each}
            {/if}
          </Table.Body>
        </Table.Root>
      </div>
    </TableControls>
  {/if}

  <!-- Confirm Receipt Modal -->
  <Dialog.Root bind:open={confirmOpen}>
    <Dialog.Content
      onInteractOutside={(e) => e.preventDefault()}
      onEscapeKeydown={(e) => e.preventDefault()}
      class="sm:max-w-[600px] bg-card border-0 rounded-2xl shadow-2xl p-0 overflow-hidden max-h-[90vh] flex flex-col"
    >
      {#if selectedInvoice}
        <div class="bg-primary/5 border-b px-6 py-4 shrink-0">
          <div class="flex items-center gap-3">
            <div class="w-9 h-9 rounded-xl bg-primary/10 flex items-center justify-center">
              <Icon icon="mdi:truck-check-outline" width="18" class="text-primary" />
            </div>
            <div>
              <Dialog.Title class="text-lg font-bold text-foreground">Confirm Stock Receipt</Dialog.Title>
              <Dialog.Description class="text-xs text-muted-foreground mt-0.5">
                Invoice: <span class="font-mono font-semibold text-foreground">{selectedInvoice.invoice_reference}</span>
                &nbsp;·&nbsp; Supplier: <span class="font-semibold text-foreground">{selectedInvoice.supplier_name}</span>
              </Dialog.Description>
            </div>
          </div>
        </div>

        <form onsubmit={submitConfirmation} class="px-6 py-5 flex flex-col gap-4 overflow-y-auto">
          <div class="rounded-xl border overflow-hidden relative min-h-24">
            {#if loadingItems}
              <div class="absolute inset-0 flex items-center justify-center bg-card/70 backdrop-blur-[1px] z-10">
                <Icon icon="mdi:loading" class="animate-spin text-primary" width="30" />
              </div>
            {/if}

            <Table.Root>
              <Table.Header>
                <Table.Row class="bg-primary/5 hover:bg-primary/5 border-b-2 border-primary/10">
                  <Table.Head class="font-bold text-xs uppercase tracking-wider text-foreground/60">Item Details</Table.Head>
                  <Table.Head class="text-right w-[100px] font-bold text-xs uppercase tracking-wider text-foreground/60">Ordered</Table.Head>
                  <Table.Head class="text-center w-[130px] font-bold text-xs uppercase tracking-wider text-foreground/60">Confirmed Qty *</Table.Head>
                </Table.Row>
              </Table.Header>
              <Table.Body>
                {#each invoiceItems as item, idx}
                  <Table.Row class="{idx % 2 === 1 ? 'bg-muted/20' : ''}">
                    <Table.Cell class="font-semibold text-foreground">{item.item_description}</Table.Cell>
                    <Table.Cell class="text-right font-mono font-semibold text-foreground">
                      {item.quantity_ordered || item.quantity_sent || item.quantity || 0}
                    </Table.Cell>
                    <Table.Cell class="text-center">
                      <Input
                        type="number"
                        min="0"
                        bind:value={invoiceItems[idx].quanttiy_confirmed}
                        autocomplete="off"
                        class="w-24 text-center h-8 font-semibold font-mono"
                        required
                      />
                    </Table.Cell>
                  </Table.Row>
                {/each}
              </Table.Body>
            </Table.Root>
          </div>

          <div class="flex justify-end gap-2 pt-4 border-t shrink-0">
            <Button type="button" variant="outline" onclick={() => confirmOpen = false} class="h-9 px-5">Cancel</Button>
            <Button type="submit" class="h-9 px-5 bg-primary hover:bg-primary/90 text-white" disabled={invoiceItems.length === 0}>
              Submit Confirmation
            </Button>
          </div>
        </form>
      {/if}
    </Dialog.Content>
  </Dialog.Root>

  <!-- Receipt Confirmation Dialog -->
  <Dialog.Root bind:open={confirmReceiptSubmitOpen}>
    <Dialog.Content class="sm:max-w-[400px] bg-card border rounded-2xl shadow-2xl p-6 overflow-hidden z-[110] text-center">
      <div class="flex flex-col items-center gap-4">
        <div class="w-12 h-12 rounded-full bg-amber-500/10 flex items-center justify-center text-amber-500">
          <Icon icon="mdi:alert-circle-outline" width="28" />
        </div>
        <div class="space-y-2">
          <Dialog.Title class="text-lg font-bold text-foreground">Confirm Stock Receipt</Dialog.Title>
          <p class="text-sm text-muted-foreground">
            Are you sure you want to submit receipt confirmation for this inbound invoice?
          </p>
        </div>
      </div>
      <div class="flex justify-center gap-3 mt-6 pt-4 border-t">
        <Button type="button" variant="outline" onclick={() => confirmReceiptSubmitOpen = false}>Cancel</Button>
        <Button type="button" onclick={executeReceiptConfirmation} class="bg-primary hover:bg-primary/95 text-white">Yes, Confirm</Button>
      </div>
    </Dialog.Content>
  </Dialog.Root>
</div>
