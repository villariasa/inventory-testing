<script lang="ts">
  import * as Table from '$lib/components/ui/table/index.js';
  import { Button } from '$lib/components/ui/button/index.js';
  import Icon from '@iconify/svelte';
  import TableControls from './TableControls.svelte';
  import type { Snippet } from 'svelte';

  let {
    columns = [],
    rows = [],
    loading = false,
    title = 'Report',
    onexportPdf = undefined,
    cell = undefined
  } = $props<{
    columns: {
      key: string;
      label: string;
      align?: 'left' | 'right' | 'center';
      format?: (val: any) => string;
    }[];
    rows: any[];
    loading?: boolean;
    title?: string;
    onexportPdf?: () => void;
    cell?: Snippet<[any, any]>;
  }>();

  let visibleColumns = $state<Record<string, boolean>>({});
  let limit = $state(10);
  let page = $state(1);

  // Initialize columns configuration
  $effect(() => {
    columns.forEach((col: any) => {
      if (visibleColumns[col.key] === undefined) {
        visibleColumns[col.key] = true;
      }
    });
  });

  // Reset page when new query results arrive
  $effect(() => {
    if (rows) {
      page = 1;
    }
  });

  // Paginate rows client-side
  let paginatedRows = $derived(
    rows.slice((page - 1) * limit, page * limit)
  );

  function exportToCSV() {
    if (rows.length === 0) return;
    
    // Only export columns that are currently visible
    const activeCols = columns.filter((c: any) => visibleColumns[c.key] !== false);
    
    const headerRow = activeCols.map((c: any) => `"${c.label.replace(/"/g, '""')}"`).join(',');
    const bodyRows = rows.map((row: any) =>
      activeCols.map((c: any) => {
        let val = row[c.key];
        if (c.format) {
          val = c.format(val);
        }
        val = val !== null && val !== undefined ? String(val) : '';
        return `"${val.replace(/"/g, '""')}"`;
      }).join(',')
    );

    const csvContent = '\uFEFF' + [headerRow, ...bodyRows].join('\r\n');
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.setAttribute('download', `${title.toLowerCase().replace(/\s+/g, '_')}_export_${new Date().toISOString().split('T')[0]}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  }
</script>

<div class="bg-card border border-border rounded-xl shadow-sm p-4 relative overflow-hidden">
  <div class="flex items-center justify-between mb-4">
    <h3 class="font-bold font-playfair text-lg text-primary">{title} Results</h3>
    {#if rows.length > 0}
      <div class="flex items-center gap-2">
        {#if onexportPdf}
          <Button variant="outline" size="sm" class="flex items-center gap-1.5 hover:bg-rose-500/10 hover:text-rose-600 border-rose-200" onclick={onexportPdf}>
            <Icon icon="mdi:file-pdf-box" width="16" class="text-rose-500" />
            Export PDF
          </Button>
        {/if}
        <Button variant="outline" size="sm" class="flex items-center gap-1.5 hover:bg-primary/10 hover:text-primary" onclick={exportToCSV}>
          <Icon icon="mdi:download" width="16" />
          Export CSV
        </Button>
      </div>
    {/if}
  </div>

  {#if loading}
    <div class="absolute inset-0 z-20 flex items-center justify-center bg-card/60">
      <div class="flex flex-col items-center gap-2">
        <Icon icon="mdi:loading" class="animate-spin text-primary" width="36" />
        <span class="text-xs text-muted-foreground font-semibold">Generating report...</span>
      </div>
    </div>
  {/if}

  <TableControls
    {columns}
    bind:visibleColumns
    bind:limit
    bind:page
    total={rows.length}
  >
    <div class="overflow-x-auto w-full">
      <Table.Root>
        <Table.Header class="bg-muted/50">
          <Table.Row>
            {#each columns as col}
              {#if visibleColumns[col.key] !== false}
                <Table.Head class={col.align === 'right' ? 'text-right' : col.align === 'center' ? 'text-center' : 'text-left'}>
                  {col.label}
                </Table.Head>
              {/if}
            {/each}
          </Table.Row>
        </Table.Header>
        <Table.Body>
          {#if paginatedRows.length === 0}
            <Table.Row>
              <Table.Cell colspan={columns.filter((c: any) => visibleColumns[c.key] !== false).length} class="h-32 text-center text-muted-foreground">
                No data generated. Adjust filters and click "Generate Report".
              </Table.Cell>
            </Table.Row>
          {:else}
            {#each paginatedRows as row, i}
              <Table.Row class="hover:bg-muted/20">
                {#each columns as col}
                  {#if visibleColumns[col.key] !== false}
                    <Table.Cell class={col.align === 'right' ? 'text-right font-mono' : col.align === 'center' ? 'text-center' : 'text-left'}>
                      {#if cell}
                        {@render cell(row, col)}
                      {:else if col.format}
                        {col.format(row[col.key])}
                      {:else}
                        {row[col.key] !== null && row[col.key] !== undefined ? row[col.key] : '—'}
                      {/if}
                    </Table.Cell>
                  {/if}
                {/each}
              </Table.Row>
            {/each}
          {/if}
        </Table.Body>
      </Table.Root>
    </div>
  </TableControls>
</div>
