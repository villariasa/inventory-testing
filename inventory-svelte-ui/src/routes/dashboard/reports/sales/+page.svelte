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
    dateFrom: '',
    dateTo: '',
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
    { key: 'invoice_date', label: 'Date' },
    { key: 'invoice', label: 'Invoice' },
    { key: 'client', label: 'Client' },
    { key: 'warehouse_store', label: 'Warehouse' },
    { key: 'sales_inventory_disp', label: 'Sales Inv', align: 'right' as const },
    { key: 'sales_service_disp', label: 'Sales Svc', align: 'right' as const },
    { key: 'gross_sales_disp', label: 'Gross Sales', align: 'right' as const },
    { key: 'discount_disp', label: 'Discount', align: 'right' as const },
    { key: 'net_sales_disp', label: 'Net Sales', align: 'right' as const },
    { key: 'amount_paid_disp', label: 'Amount Paid', align: 'right' as const },
    { key: 'posted_by', label: 'Posted By' }
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

    const response = await invokeService<any, any[]>('/get-sales-report', {
      body: {
        start_date: filters.dateFrom,
        end_date: filters.dateTo,
        charUnitList: unitList
      },
      token: data.user.access_token
    });
    loading = false;

    if ('data' in response && response.data.success) {
      const list = response.data?.data?.json_data || [];
      rows = list.map((item: any) => {
        const salesInv = parseNumber(item.sales_inventory);
        const salesSvc = parseNumber(item.sales_service);
        const gross = parseNumber(item.gross_sales);
        const disc = parseNumber(item.discount);
        const net = parseNumber(item.net_sales);
        const paid = parseNumber(item.amount_paid);

        return {
          ...item,
          sales_inventory_disp: `PHP ${salesInv.toLocaleString('en-US', { minimumFractionDigits: 2 })}`,
          sales_service_disp: `PHP ${salesSvc.toLocaleString('en-US', { minimumFractionDigits: 2 })}`,
          gross_sales_disp: `PHP ${gross.toLocaleString('en-US', { minimumFractionDigits: 2 })}`,
          discount_disp: `PHP ${disc.toLocaleString('en-US', { minimumFractionDigits: 2 })}`,
          net_sales_disp: `PHP ${net.toLocaleString('en-US', { minimumFractionDigits: 2 })}`,
          amount_paid_disp: `PHP ${paid.toLocaleString('en-US', { minimumFractionDigits: 2 })}`,
          raw_sales_inventory: salesInv,
          raw_sales_service: salesSvc,
          raw_gross_sales: gross,
          raw_discount: disc,
          raw_net_sales: net,
          raw_amount_paid: paid
        };
      });
    } else {
      rows = [];
      const errMsg = 'error' in response ? response.error : (response.data?.message || 'Unknown error');
      console.error('[Sales Order Report] Failed to load report data:', errMsg, response);
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
      doc.text('Sales Order Report', 14, currentY);

      currentY += 6;
      doc.setFontSize(9);
      doc.setTextColor(greyMuted[0], greyMuted[1], greyMuted[2]);
      const dateRangeText = `Period: ${currentFilters.dateFrom || 'N/A'} to ${currentFilters.dateTo || 'N/A'}`;
      const unitLabelText = `Unit/Warehouse: ${currentFilters.unitLabel || 'All Units'}`;
      const generatedAtText = `Generated: ${new Date().toLocaleString('en-US', { hour12: true })}`;
      doc.text(`${dateRangeText}   |   ${unitLabelText}   |   ${generatedAtText}`, 14, currentY);

      const tableStartY = currentY + 5;

      const headers = [
        'Date', 'Invoice', 'Client', 'Warehouse',
        'Sales Inv', 'Sales Svc', 'Gross Sales', 'Discount', 'Net Sales', 'Amount Paid', 'Posted By'
      ];

      const tableData = rows.map((row: any) => [
        row.invoice_date || '—',
        row.invoice || '—',
        row.client || '—',
        row.warehouse_store || '—',
        row.sales_inventory_disp || '—',
        row.sales_service_disp || '—',
        row.gross_sales_disp || '—',
        row.discount_disp || '—',
        row.net_sales_disp || '—',
        row.amount_paid_disp || '—',
        row.posted_by || '—'
      ]);

      // Calculate totals
      let totalInv = 0;
      let totalSvc = 0;
      let totalGross = 0;
      let totalDisc = 0;
      let totalNet = 0;
      let totalPaid = 0;

      rows.forEach((row: any) => {
        totalInv += row.raw_sales_inventory || 0;
        totalSvc += row.raw_sales_service || 0;
        totalGross += row.raw_gross_sales || 0;
        totalDisc += row.raw_discount || 0;
        totalNet += row.raw_net_sales || 0;
        totalPaid += row.raw_amount_paid || 0;
      });

      const totalsRow = [
        'TOTAL', '', '', '',
        `PHP ${totalInv.toLocaleString('en-US', { minimumFractionDigits: 2 })}`,
        `PHP ${totalSvc.toLocaleString('en-US', { minimumFractionDigits: 2 })}`,
        `PHP ${totalGross.toLocaleString('en-US', { minimumFractionDigits: 2 })}`,
        `PHP ${totalDisc.toLocaleString('en-US', { minimumFractionDigits: 2 })}`,
        `PHP ${totalNet.toLocaleString('en-US', { minimumFractionDigits: 2 })}`,
        `PHP ${totalPaid.toLocaleString('en-US', { minimumFractionDigits: 2 })}`,
        ''
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
          5: { halign: 'right', cellWidth: 'wrap' },
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

      doc.save(`sales_report_${new Date().toISOString().split('T')[0]}.pdf`);
      toast.success('PDF report exported successfully!');
    } catch (error) {
      console.error('Failed to export PDF:', error);
      toast.error('Failed to export PDF report');
    }
  }
</script>

<div class="space-y-6">
  <ReportFilterBar
    activeId="sales"
    units={data.units}
    showUnit={true}
    showClient={false}
    showCostToggle={false}
    allowMultiUnit={true}
    onfilter={handleFilter}
  />

  <ReportTable
    title="Sales Order Report"
    {columns}
    {rows}
    {loading}
    onexportPdf={exportToPDF}
  />
</div>
