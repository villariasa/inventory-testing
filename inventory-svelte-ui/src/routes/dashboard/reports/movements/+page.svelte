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
    unitLabel: 'All Units'
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

  const columns = [
    { key: 'fmt_entry_date', label: 'Date' },
    { key: 'description', label: 'Type / Description' },
    { key: 'source_unit', label: 'From Unit' },
    { key: 'receiving_unit', label: 'To Unit' },
    { key: 'category', label: 'Category' },
    { key: 'brand', label: 'Brand' },
    { key: 'item', label: 'Item' },
    { key: 'qty_display', label: 'Qty Moved', align: 'right' as const },
    { key: 'remarks', label: 'Remarks' },
    { key: 'posted_by', label: 'Processed By' }
  ];

  async function handleFilter(filters: any) {
    loading = true;

    const unitList = (filters.unitIds || []).map((id: any) => String(id));
    if (unitList.length === 0) {
      unitList.push('0');
    }

    const matchedUnitLabels = (filters.unitIds || []).map((id: any) => {
      const u = data.units.find((unit: any) => unit.unit_id === Number(id));
      return u ? u.description : '';
    }).filter(Boolean);
    const unitLabel = matchedUnitLabels.length > 0 ? matchedUnitLabels.join(', ') : 'All Units';

    currentFilters = {
      dateFrom: filters.dateFrom,
      dateTo: filters.dateTo,
      unitIds: filters.unitIds,
      unitLabel
    };

    const response = await invokeService<any, any[]>('/get-internal-stocks-movements-report', {
      body: {
        start_date: filters.dateFrom,
        end_date: filters.dateTo,
        units: unitList
      },
      token: data.user.access_token
    });
    loading = false;

    if ('data' in response && response.data.success) {
      const list = response.data?.data?.json_data || [];
      rows = list.map((item: any) => ({
        ...item,
        qty_display: `${item.quantity || '0.00'} ${item.stocking_unit || ''}`.trim()
      }));
    } else {
      rows = [];
      const errMsg = 'error' in response ? response.error : (response.data?.message || 'Unknown error');
      console.error('[Internal Stock Movements Report] Failed to load report data:', errMsg, response);
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
      doc.text('Internal Stock Movements Report', 14, currentY);

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
      const tableData = rows.map((row: any) => {
        const hasImg = !!imageCacheStore.get(row.item_id);
        const prefix = hasImg ? '         ' : '';
        return [
          row.fmt_entry_date || '—',
          row.description || '—',
          row.source_unit || '—',
          row.receiving_unit || '—',
          row.category || '—',
          row.brand || '—',
          prefix + (row.item || '—'),
          row.qty_display || '—',
          row.remarks || '—',
          row.posted_by || '—'
        ];
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
        columnStyles: {
          7: { halign: 'right' } // Qty column
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

      doc.save(`internal_stock_movements_report_${new Date().toISOString().split('T')[0]}.pdf`);
      toast.success('PDF report exported successfully!');
    } catch (error) {
      console.error('Failed to export PDF:', error);
      toast.error('Failed to export PDF report');
    }
  }
</script>

<div class="space-y-6">
  <ReportFilterBar
    activeId="movements"
    units={data.units}
    showUnit={true}
    showClient={false}
    showCostToggle={false}
    allowMultiUnit={true}
    onfilter={handleFilter}
  />

  <ReportTable
    title="Internal Stock Movements"
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
