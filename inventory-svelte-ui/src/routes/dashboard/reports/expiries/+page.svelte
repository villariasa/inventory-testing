<script lang="ts">
  import type { LayoutData } from '../$types';
  import { invokeService } from '$lib/service/invokeService';
  import { toast } from 'svelte-sonner';
  import ReportFilterBar from '$lib/components/inventory/ReportFilterBar.svelte';
  import ReportTable from '$lib/components/inventory/ReportTable.svelte';
  import { Button } from '$lib/components/ui/button/index.js';
  import Icon from '@iconify/svelte';

  let { data } = $props<{ data: LayoutData & { units: any[]; user: any } }>();

  let rows = $state<any[]>([]);
  let loading = $state(false);

  let currentFilters = $state<any>({
    unitIds: [],
    unitLabel: 'All Units'
  });

  function parseNumber(val: any): number {
    if (val === null || val === undefined || val === '') return 0;
    const clean = String(val).replace(/[^0-9.-]/g, '');
    const parsed = parseFloat(clean);
    return isNaN(parsed) ? 0 : parsed;
  }

  const columns = [
    { key: 'unit', label: 'Unit/Warehouse' },
    { key: 'fmt_invoice_date', label: 'Invoice Date' },
    { key: 'client', label: 'Client' },
    { key: 'invoice_reference', label: 'Invoice Ref' },
    { key: 'amount_disp', label: 'Invoice Amount', align: 'right' as const },
    { key: 'fmt_ar_due_date', label: 'Due Date' },
    { key: 'past_due_1_30_disp', label: '1-30 Days', align: 'right' as const },
    { key: 'past_due_31_60_disp', label: '31-60 Days', align: 'right' as const },
    { key: 'past_due_61_90_disp', label: '61-90 Days', align: 'right' as const },
    { key: 'past_due_over_90_disp', label: 'Over 90 Days', align: 'right' as const }
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
      unitIds: filters.unitIds,
      unitLabel
    };

    const response = await invokeService<any, any[]>('/get-expiries-and-past-due', {
      body: {
        units: unitList
      },
      token: data.user.access_token
    });
    loading = false;

    if ('data' in response && response.data.success) {
      const list = response.data?.data?.json_data || [];
      rows = list.map((item: any) => {
        const amt = parseNumber(item.invoice_amount);
        const p1 = parseNumber(item.past_due_1_30);
        const p2 = parseNumber(item.past_due_31_60);
        const p3 = parseNumber(item.past_due_61_90);
        const p4 = parseNumber(item.past_due_over_90);

        return {
          ...item,
          amount_disp: `PHP ${amt.toLocaleString('en-US', { minimumFractionDigits: 2 })}`,
          past_due_1_30_disp: p1 > 0 ? `PHP ${p1.toLocaleString('en-US', { minimumFractionDigits: 2 })}` : '—',
          past_due_31_60_disp: p2 > 0 ? `PHP ${p2.toLocaleString('en-US', { minimumFractionDigits: 2 })}` : '—',
          past_due_61_90_disp: p3 > 0 ? `PHP ${p3.toLocaleString('en-US', { minimumFractionDigits: 2 })}` : '—',
          past_due_over_90_disp: p4 > 0 ? `PHP ${p4.toLocaleString('en-US', { minimumFractionDigits: 2 })}` : '—',
          raw_amount: amt,
          raw_p1: p1,
          raw_p2: p2,
          raw_p3: p3,
          raw_p4: p4
        };
      });
    } else {
      rows = [];
      const errMsg = 'error' in response ? response.error : (response.data?.message || 'Unknown error');
      console.error('[Expiries Report] Failed to load report data:', errMsg, response);
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

      const tealDark: [number, number, number] = [34, 108, 100];
      const textDark: [number, number, number] = [48, 48, 48];
      const greyMuted: [number, number, number] = [107, 114, 128];

      const { getSubscriberDetails } = await import('$lib/service/subscriberService');
      const details = await getSubscriberDetails();
      const subscriberName = details?.name || 'Litecloud Ph';

      let imgLoaded = false;
      let imgElement: HTMLImageElement | null = null;
      let logoWidth = 0;
      let logoHeight = 15;

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

      doc.setFont('helvetica', 'bold');
      doc.setFontSize(14);
      doc.setTextColor(tealDark[0], tealDark[1], tealDark[2]);
      doc.text(`${subscriberName.toUpperCase()} INVENTORY SYSTEM`, 14, currentY);

      currentY += 6;
      doc.setFont('helvetica', 'normal');
      doc.setFontSize(11);
      doc.setTextColor(textDark[0], textDark[1], textDark[2]);
      doc.text('Expiries & Past Due Aging Report', 14, currentY);

      currentY += 6;
      doc.setFontSize(9);
      doc.setTextColor(greyMuted[0], greyMuted[1], greyMuted[2]);
      const unitLabelText = `Unit/Warehouse: ${currentFilters.unitLabel || 'All Units'}`;
      const generatedAtText = `Generated: ${new Date().toLocaleString('en-US', { hour12: true })}`;
      doc.text(`${unitLabelText}   |   ${generatedAtText}`, 14, currentY);

      const tableStartY = currentY + 5;

      const headers = [
        'Unit/Warehouse', 'Invoice Date', 'Client', 'Invoice Ref', 'Invoice Amount', 'Due Date', '1-30 Days', '31-60 Days', '61-90 Days', 'Over 90 Days'
      ];

      const tableData = rows.map((row: any) => [
        row.unit || '—',
        row.fmt_invoice_date || '—',
        row.client || '—',
        row.invoice_reference || '—',
        row.amount_disp || '—',
        row.fmt_ar_due_date || '—',
        row.past_due_1_30_disp || '—',
        row.past_due_31_60_disp || '—',
        row.past_due_61_90_disp || '—',
        row.past_due_over_90_disp || '—'
      ]);

      // Calculate totals
      let totalAmount = 0;
      let totalP1 = 0;
      let totalP2 = 0;
      let totalP3 = 0;
      let totalP4 = 0;

      rows.forEach((row: any) => {
        totalAmount += row.raw_amount || 0;
        totalP1 += row.raw_p1 || 0;
        totalP2 += row.raw_p2 || 0;
        totalP3 += row.raw_p3 || 0;
        totalP4 += row.raw_p4 || 0;
      });

      const totalsRow = [
        'TOTAL', '', '', '',
        `PHP ${totalAmount.toLocaleString('en-US', { minimumFractionDigits: 2 })}`,
        '',
        `PHP ${totalP1.toLocaleString('en-US', { minimumFractionDigits: 2 })}`,
        `PHP ${totalP2.toLocaleString('en-US', { minimumFractionDigits: 2 })}`,
        `PHP ${totalP3.toLocaleString('en-US', { minimumFractionDigits: 2 })}`,
        `PHP ${totalP4.toLocaleString('en-US', { minimumFractionDigits: 2 })}`
      ];
      tableData.push(totalsRow);

      autoTable(doc, {
        head: [headers],
        body: tableData,
        startY: tableStartY,
        theme: 'striped',
        headStyles: {
          fillColor: tealDark,
          textColor: [255, 255, 255],
          fontSize: 7,
          fontStyle: 'bold'
        },
        bodyStyles: {
          fontSize: 7,
          textColor: textDark
        },
        alternateRowStyles: {
          fillColor: [249, 250, 251]
        },
        columnStyles: {
          4: { halign: 'right', cellWidth: 'wrap' },
          6: { halign: 'right', cellWidth: 'wrap' },
          7: { halign: 'right', cellWidth: 'wrap' },
          8: { halign: 'right', cellWidth: 'wrap' },
          9: { halign: 'right', cellWidth: 'wrap' }
        },
        didParseCell: (cellData) => {
          if (cellData.row.index === tableData.length - 1) {
            cellData.cell.styles.fontStyle = 'bold';
            cellData.cell.styles.textColor = [0, 0, 0];
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

      doc.save(`expiries_report_${new Date().toISOString().split('T')[0]}.pdf`);
      toast.success('PDF report exported successfully!');
    } catch (error) {
      console.error('Failed to export PDF:', error);
      toast.error('Failed to export PDF report');
    }
  }
</script>

<div class="space-y-6">
  <ReportFilterBar
    activeId="expiries"
    units={data.units}
    showDateRange={false}
    showUnit={true}
    showClient={false}
    showCostToggle={false}
    allowMultiUnit={true}
    onfilter={handleFilter}
  />

  <ReportTable
    title="Expiries & Past Due"
    {columns}
    {rows}
    {loading}
    onexportPdf={exportToPDF}
  />
</div>
