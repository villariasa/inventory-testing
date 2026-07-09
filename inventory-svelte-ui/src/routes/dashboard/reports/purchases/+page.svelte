<script lang="ts">
  import type { LayoutData } from '../$types';
  import { invokeService } from '$lib/service/invokeService';
  import { toast } from 'svelte-sonner';
  import ReportFilterBar from '$lib/components/inventory/ReportFilterBar.svelte';
  import ReportTable from '$lib/components/inventory/ReportTable.svelte';
  import { Button } from '$lib/components/ui/button/index.js';
  import Icon from '@iconify/svelte';
  import { imageCacheStore } from '$lib/store/imageCache.svelte';

  let { data } = $props<{ data: LayoutData & { units: any[]; user: any } }>();

  let rows = $state<any[]>([]);
  let loading = $state(false);

  let currentFilters = $state<any>({
    dateFrom: '',
    dateTo: '',
    clientId: 0,
    clientLabel: 'All Clients',
    withCost: 0
  });

  // Track which item_ids are currently being fetched to avoid duplicate requests
  let fetchingImageIds = new Set<number>();

  // Lazy-load images for loaded report rows
  $effect(() => {
    for (const row of rows) {
      const itemId = row.item_id;
      if (itemId && !imageCacheStore.has(itemId) && !fetchingImageIds.has(itemId)) {
        fetchingImageIds.add(itemId);
        imageCacheStore.fetch(itemId, data.user.access_token).finally(() => {
          fetchingImageIds.delete(itemId);
        });
      }
    }
  });

  function parseNumber(val: any): number {
    if (val === null || val === undefined || val === '') return 0;
    const clean = String(val).replace(/[^0-9.-]/g, '');
    const parsed = parseFloat(clean);
    return isNaN(parsed) ? 0 : parsed;
  }

  let columns = $derived([
    { key: 'fmt_po_date', label: 'Date' },
    { key: 'po_reference', label: 'PO Ref' },
    { key: 'supplier', label: 'Supplier' },
    { key: 'category', label: 'Category' },
    { key: 'brand', label: 'Brand' },
    { key: 'item', label: 'Item' },
    { key: 'po_quantity', label: 'Qty', align: 'right' as const },
    ...(currentFilters.withCost === 1 ? [
      { key: 'po_unitcost', label: 'Unit Cost', align: 'right' as const, format: (v: any) => `₱${parseNumber(v).toLocaleString('en-US', { minimumFractionDigits: 2 })}` },
      { key: 'po_total_cost', label: 'Total Cost', align: 'right' as const, format: (v: any) => `₱${parseNumber(v).toLocaleString('en-US', { minimumFractionDigits: 2 })}` }
    ] : []),
    { key: 'warehouse_store', label: 'Warehouse' }
  ]);

  async function handleFilter(filters: any) {
    loading = true;
    currentFilters = filters;

    const response = await invokeService<any, any[]>('/get-purchases-report', {
      body: {
        start_date: filters.dateFrom,
        end_date: filters.dateTo,
        client_id: String(filters.clientId || 0),
        withCost: filters.withCost
      },
      token: data.user.access_token
    });
    loading = false;

    if ('data' in response && response.data.success) {
      rows = response.data?.data?.json_data || [];
    } else {
      rows = [];
      const errMsg = 'error' in response ? response.error : (response.data?.message || 'Unknown error');
      console.error('[Purchases Report] Failed to load report data:', errMsg, response);
      toast.error(`Failed to load report data: ${errMsg}`);
    }
  }

  async function exportToPDF() {
    if (rows.length === 0) {
      toast.error('No report data to export');
      return;
    }

    try {
      const { jsPDF } = await import('jspdf');
      const { default: autoTable } = await import('jspdf-autotable');

      const doc = new jsPDF({
        orientation: 'landscape',
        unit: 'mm',
        format: 'a4'
      });

      // Colors matching the brand palette
      const tealDark: [number, number, number] = [34, 108, 100]; // #226c64
      const textDark: [number, number, number] = [48, 48, 48]; // #303030
      const greyMuted: [number, number, number] = [107, 114, 128]; // #6B7280

      // Load subscriber details
      const { getSubscriberDetails } = await import('$lib/service/subscriberService');
      const details = await getSubscriberDetails();
      const subscriberName = details?.name || 'Litecloud Ph';

      // Load logo if available
      let imgLoaded = false;
      let imgElement: HTMLImageElement | null = null;
      let logoWidth = 0;
      let logoHeight = 15; // Set fixed height in mm

      if (details?.subscribers_logo) {
        try {
          imgElement = await new Promise<HTMLImageElement>((resolve, reject) => {
            const img = new Image();
            img.crossOrigin = 'anonymous';
            img.onload = () => resolve(img);
            img.onerror = (e) => reject(e);
            img.src = details.subscribers_logo;
          });
          
          const imgWidth = imgElement.naturalWidth || imgElement.width || 1;
          const imgHeight = imgElement.naturalHeight || imgElement.height || 1;
          const aspectRatio = imgWidth / imgHeight;
          logoWidth = logoHeight * aspectRatio;
          imgLoaded = true;
        } catch (err) {
          console.error('Failed to load subscriber logo image:', err);
        }
      }

      let currentY = 15;

      if (imgLoaded && imgElement) {
        doc.addImage(imgElement, 'PNG', 14, 10, logoWidth, logoHeight);
        currentY = 32;
      }

      // Title & Header Info
      doc.setFont('helvetica', 'bold');
      doc.setFontSize(14);
      doc.setTextColor(tealDark[0], tealDark[1], tealDark[2]);
      doc.text(`${subscriberName.toUpperCase()} INVENTORY SYSTEM`, 14, currentY);

      currentY += 6;
      doc.setFont('helvetica', 'normal');
      doc.setFontSize(11);
      doc.setTextColor(textDark[0], textDark[1], textDark[2]);
      doc.text('Purchases Report', 14, currentY);

      // Metadata Info
      currentY += 6;
      doc.setFontSize(9);
      doc.setTextColor(greyMuted[0], greyMuted[1], greyMuted[2]);
      const dateRangeText = `Period: ${currentFilters.dateFrom || 'N/A'} to ${currentFilters.dateTo || 'N/A'}`;
      const clientLabelText = `Client: ${currentFilters.clientLabel || 'All Clients'}`;
      const generatedAtText = `Generated: ${new Date().toLocaleString('en-US', { hour12: true })}`;
      doc.text(`${dateRangeText}   |   ${clientLabelText}   |   ${generatedAtText}`, 14, currentY);

      const tableStartY = currentY + 5;

      // Table headers
      const headers = [
        'Date',
        'PO Ref',
        'Supplier',
        'Category',
        'Brand',
        'Item',
        'Qty'
      ];
      
      if (currentFilters.withCost === 1) {
        headers.push('Unit Cost');
        headers.push('Total Cost');
      }
      
      headers.push('Warehouse');

      // Convert rows to arrays
      const tableData = rows.map((row: any) => {
        const hasImg = !!imageCacheStore.get(row.item_id);
        const prefix = hasImg ? '         ' : '';
        const line = [
          row.fmt_po_date || '—',
          row.po_reference || '—',
          row.supplier || '—',
          row.category || '—',
          row.brand || '—',
          prefix + (row.item || '—'),
          row.po_quantity || '—'
        ];

        if (currentFilters.withCost === 1) {
          line.push(`PHP ${parseNumber(row.po_unitcost).toLocaleString('en-US', { minimumFractionDigits: 2 })}`);
          line.push(`PHP ${parseNumber(row.po_total_cost).toLocaleString('en-US', { minimumFractionDigits: 2 })}`);
        }

        line.push(row.warehouse_store || '—');
        return line;
      });

      // Calculate totals row if including cost
      if (currentFilters.withCost === 1) {
        let totalCostSum = 0;
        rows.forEach((row: any) => {
          const val = parseNumber(row.po_total_cost);
          totalCostSum += val;
        });

        const totalsRow = [
          'TOTAL',
          '',
          '',
          '',
          '',
          '',
          '', // Qty (varies by unit)
          '', // Unit Cost
          `PHP ${totalCostSum.toLocaleString('en-US', { minimumFractionDigits: 2 })}`,
          ''
        ];
        tableData.push(totalsRow);
      }

      // Draw table
      autoTable(doc, {
        head: [headers],
        body: tableData,
        startY: tableStartY,
        theme: 'striped',
        headStyles: {
          fillColor: tealDark,
          textColor: [255, 255, 255],
          fontSize: 8,
          fontStyle: 'bold'
        },
        bodyStyles: {
          minCellHeight: 10,
          fontSize: 8,
          textColor: textDark,
          valign: 'middle'
        },
        alternateRowStyles: {
          fillColor: [249, 250, 251] // #f9fafb
        },
        columnStyles: {
          6: { halign: 'right' }, // Qty
          ...(currentFilters.withCost === 1 ? {
            7: { halign: 'right', cellWidth: 'wrap' }, // Unit Cost
            8: { halign: 'right', cellWidth: 'wrap' }  // Total Cost
          } : {})
        },
        didDrawCell: (drawData) => {
          if (drawData.row.section === 'body') {
            // Draw item image
            const colHeader = headers[drawData.column.index];
            if (colHeader === 'Item') {
              const rowData = rows[drawData.row.index];
              const itemId = rowData?.item_id;
              if (itemId) {
                const base64Img = imageCacheStore.get(itemId);
                if (base64Img) {
                  const imgSize = 6;
                  const x = drawData.cell.x + 2;
                  const y = drawData.cell.y + (drawData.cell.height - imgSize) / 2;
                  doc.addImage(base64Img, 'PNG', x, y, imgSize, imgSize);
                }
              }
            }
          }
        },
        didParseCell: (cellData) => {
          // Style totals row
          if (currentFilters.withCost === 1 && cellData.row.index === tableData.length - 1) {
            cellData.cell.styles.fontStyle = 'bold';
            cellData.cell.styles.textColor = [0, 0, 0];
          }
        },
        didDrawPage: (drawData) => {
          // Footer page numbers
          const pageCount = doc.getNumberOfPages();
          doc.setFontSize(8);
          doc.setTextColor(greyMuted[0], greyMuted[1], greyMuted[2]);
          doc.text(
            `Page ${drawData.pageNumber} of ${pageCount}`,
            doc.internal.pageSize.width - 25,
            doc.internal.pageSize.height - 10
          );
        }
      });

      doc.save(`purchases_report_${new Date().toISOString().split('T')[0]}.pdf`);
      toast.success('PDF report exported successfully!');
    } catch (error) {
      console.error('Failed to export PDF:', error);
      toast.error('Failed to export PDF report');
    }
  }
</script>

<div class="space-y-6">
  <ReportFilterBar
    activeId="purchases"
    units={data.units}
    token={data.user.access_token}
    showUnit={false}
    showClient={true}
    showCostToggle={true}
    onfilter={handleFilter}
  />

  <ReportTable
    title="Purchases Report"
    {columns}
    {rows}
    {loading}
    onexportPdf={exportToPDF}
  >
    {#snippet cell(row, col)}
      {#if col.key === 'item'}
        {@const cachedImage = imageCacheStore.get(row.item_id)}
        <div class="flex items-center gap-2 text-left min-w-[200px]">
          {#if cachedImage}
            <div class="w-8 h-8 rounded border border-border bg-muted/30 flex items-center justify-center overflow-hidden shrink-0 shadow-sm">
              <img src={cachedImage} alt={row.item} class="w-full h-full object-cover animate-in fade-in duration-200" />
            </div>
          {:else if cachedImage === null}
            <div class="w-8 h-8 rounded border border-border bg-muted/20 flex items-center justify-center shrink-0">
              <Icon icon="mdi:image-off-outline" width="14" class="text-muted-foreground/45 animate-in fade-in duration-200" />
            </div>
          {:else}
            <div class="w-8 h-8 rounded border border-border bg-muted/20 flex items-center justify-center animate-pulse shrink-0">
              <Icon icon="mdi:image-outline" width="14" class="text-muted-foreground/35" />
            </div>
          {/if}
          <span class="truncate min-w-0 flex-1 font-medium text-slate-700 dark:text-slate-300" title={row.item}>
            {row.item || '—'}
          </span>
        </div>
      {:else if col.format}
        {col.format(row[col.key])}
      {:else}
        {row[col.key] !== null && row[col.key] !== undefined ? row[col.key] : '—'}
      {/if}
    {/snippet}
  </ReportTable>
</div>
