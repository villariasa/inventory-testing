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
    unitId: null,
    unitLabel: 'All Units',
    itemId: null
  });

  let columns = $derived([
    { key: 'fmt_entry_date', label: 'Date' },
    ...(currentFilters.itemId === 0 ? [{ key: 'item_details', label: 'Item Details' }] : []),
    { key: 'reference', label: 'Reference No' },
    { key: 'description', label: 'Type / Description' },
    { key: 'qty_in', label: 'Qty In', align: 'right' as const },
    { key: 'qty_out', label: 'Qty Out', align: 'right' as const },
    { key: 'qty_balance', label: 'Running Balance', align: 'right' as const },
    { key: 'remark', label: 'Remarks' },
    { key: 'posted_by', label: 'Posted By' }
  ]);

  // Track which item_ids are currently being fetched to avoid duplicate requests
  let fetchingImageIds = new Set<number>();

  // Lazy-load images for currently loaded stock card rows
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

  const formatDate = (dateStr: string) => {
    if (!dateStr) return '—';
    const d = new Date(dateStr);
    return d.toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: '2-digit' });
  };

  async function handleFilter(filters: any) {
    if (filters.itemId === null || filters.itemId === undefined) {
      toast.error('Please select an item first.');
      return;
    }

    loading = true;
    const matchedUnit = data.units.find((unit: any) => unit.unit_id === Number(filters.unitId));
    const unitLabel = matchedUnit ? matchedUnit.description : 'Unknown Unit';

    currentFilters = {
      dateFrom: filters.dateFrom,
      dateTo: filters.dateTo,
      unitId: filters.unitId,
      unitLabel,
      itemId: Number(filters.itemId)
    };

    const response = await invokeService<any, any>('/get-stock-card', {
      body: {
        start_date: filters.dateFrom,
        end_date: filters.dateTo,
        unit_id: Number(filters.itemId)
      },
      token: data.user.access_token
    });
    loading = false;

    if ('data' in response && response.data.success) {
      const list = response.data?.data?.json_data || [];
      rows = list.map((item: any) => ({
        ...item,
        fmt_entry_date: formatDate(item.entry_date),
        item_details: item.item_description || '—',
        qty_in: Number(item.item_in || 0).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }),
        qty_out: Number(item.item_out || 0).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }),
        qty_balance: Number(item.ending_quantity || 0).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
      }));
    } else {
      rows = [];
      const errMsg = 'error' in response ? response.error : (response.data?.message || 'Unknown error');
      console.error('[Stock Card Report] Failed to load report data:', errMsg, response);
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
      doc.text('Stock Card Report', 14, currentY);

      // Metadata Info
      currentY += 6;
      doc.setFontSize(9);
      doc.setTextColor(greyMuted[0], greyMuted[1], greyMuted[2]);
      const dateRangeText = `Period: ${currentFilters.dateFrom || 'N/A'} to ${currentFilters.dateTo || 'N/A'}`;
      const unitLabelText = `Unit/Warehouse: ${currentFilters.unitLabel || 'All Units'}`;
      const generatedAtText = `Generated: ${new Date().toLocaleString('en-US', { hour12: true })}`;
      doc.text(`${dateRangeText}   |   ${unitLabelText}   |   ${generatedAtText}`, 14, currentY);

      const tableStartY = currentY + 5;

      // Table headers & data
      const headers = columns.map(c => c.label);
      const tableData = rows.map((row: any) => 
        columns.map(col => {
          if (col.key === 'item_details') {
            const hasImg = !!imageCacheStore.get(row.item_id);
            const prefix = hasImg ? '         ' : '';
            return prefix + (row.item_description || '—');
          }
          if (col.key === 'qty_in') return row.qty_in || '0.00';
          if (col.key === 'qty_out') return row.qty_out || '0.00';
          if (col.key === 'qty_balance') return row.qty_balance || '0.00';
          return row[col.key] || '—';
        })
      );

      // Generate column styles dynamically based on columns alignments
      const colStyles: Record<number, any> = {};
      columns.forEach((col, index) => {
        if (col.align === 'right') {
          colStyles[index] = { halign: 'right' };
        }
      });

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
          fillColor: [249, 250, 251]
        },
        columnStyles: colStyles,
        didDrawCell: (drawData) => {
          if (drawData.row.section === 'body') {
            const colHeader = headers[drawData.column.index];
            if (colHeader === 'Item Details') {
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
        didDrawPage: (drawData) => {
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

      doc.save(`stock_card_report_${new Date().toISOString().split('T')[0]}.pdf`);
      toast.success('PDF report exported successfully!');
    } catch (error) {
      console.error('Failed to export PDF:', error);
      toast.error('Failed to export PDF report');
    }
  }
</script>

<div class="space-y-6">
  <ReportFilterBar
    activeId="stock-card"
    units={data.units}
    token={data.user.access_token}
    showUnit={true}
    showItem={true}
    showClient={false}
    showCostToggle={false}
    allowMultiUnit={false}
    onfilter={handleFilter}
  />

  <ReportTable
    title="Stock Card Report"
    {columns}
    {rows}
    {loading}
    onexportPdf={exportToPDF}
  >
    {#snippet cell(row, col)}
      {#if col.key === 'item_details'}
        {@const cachedImage = imageCacheStore.get(row.item_id)}
        <div class="flex items-center gap-2 text-left min-w-[200px]">
          {#if cachedImage}
            <div class="w-8 h-8 rounded border border-border bg-muted/30 flex items-center justify-center overflow-hidden shrink-0 shadow-sm">
              <img src={cachedImage} alt={row.item_description} class="w-full h-full object-cover animate-in fade-in duration-200" />
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
          <span class="truncate min-w-0 flex-1 font-medium text-slate-700 dark:text-slate-300" title={row.item_description}>
            {row.item_description || '—'}
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
