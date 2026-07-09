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
    clientId: 0,
    clientLabel: 'All Clients'
  });

  function parseNumber(val: any): number {
    if (val === null || val === undefined || val === '') return 0;
    const clean = String(val).replace(/[^0-9.-]/g, '');
    const parsed = parseFloat(clean);
    return isNaN(parsed) ? 0 : parsed;
  }

  const columns = [
    { key: 'transaction_date', label: 'Date' },
    { key: 'reference', label: 'Reference' },
    { key: 'client', label: 'Client' },
    { key: 'debit_disp', label: 'Debit', align: 'right' as const },
    { key: 'credit_disp', label: 'Credit', align: 'right' as const },
    { key: 'balance_disp', label: 'Running Balance', align: 'right' as const },
    { key: 'payment_for', label: 'Payment For' },
    { key: 'posted_by', label: 'Posted By' },
    { key: 'posting_unit', label: 'Posting Unit' }
  ];

  async function handleFilter(filters: any) {
    loading = true;

    currentFilters = {
      dateFrom: filters.dateFrom,
      dateTo: filters.dateTo,
      clientId: filters.clientId,
      clientLabel: filters.clientLabel || 'All Clients'
    };

    const response = await invokeService<any, any[]>('/get-client-ledger', {
      body: {
        start_date: filters.dateFrom,
        end_date: filters.dateTo,
        client_id: filters.clientId || 0
      },
      token: data.user.access_token
    });
    loading = false;

    if ('data' in response && response.data.success) {
      const list = response.data?.data?.json_data || [];
      rows = list.map((item: any) => {
        const deb = parseNumber(item.debit);
        const cred = parseNumber(item.credit);
        const bal = parseNumber(item.running_balance);
        const col = item.col_balance || '';

        return {
          ...item,
          debit_disp: deb > 0 ? `PHP ${deb.toLocaleString('en-US', { minimumFractionDigits: 2 })}` : '—',
          credit_disp: cred > 0 ? `PHP ${cred.toLocaleString('en-US', { minimumFractionDigits: 2 })}` : '—',
          balance_disp: `PHP ${bal.toLocaleString('en-US', { minimumFractionDigits: 2 })} ${col}`.trim(),
          raw_debit: deb,
          raw_credit: cred,
          raw_balance: bal
        };
      });
    } else {
      rows = [];
      const errMsg = 'error' in response ? response.error : (response.data?.message || 'Unknown error');
      console.error('[Client Ledger Report] Failed to load report data:', errMsg, response);
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
      doc.text('Client Ledger Report', 14, currentY);

      currentY += 6;
      doc.setFontSize(9);
      doc.setTextColor(greyMuted[0], greyMuted[1], greyMuted[2]);
      const dateRangeText = `Period: ${currentFilters.dateFrom || 'N/A'} to ${currentFilters.dateTo || 'N/A'}`;
      const clientLabelText = `Client: ${currentFilters.clientLabel || 'All Clients'}`;
      const generatedAtText = `Generated: ${new Date().toLocaleString('en-US', { hour12: true })}`;
      doc.text(`${dateRangeText}   |   ${clientLabelText}   |   ${generatedAtText}`, 14, currentY);

      const tableStartY = currentY + 5;

      const headers = [
        'Date', 'Reference', 'Client', 'Debit', 'Credit', 'Running Balance', 'Payment For', 'Posted By', 'Posting Unit'
      ];

      const tableData = rows.map((row: any) => [
        row.transaction_date || '—',
        row.reference || '—',
        row.client || '—',
        row.debit_disp || '—',
        row.credit_disp || '—',
        row.balance_disp || '—',
        row.payment_for || '—',
        row.posted_by || '—',
        row.posting_unit || '—'
      ]);

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
          fontSize: 8,
          textColor: textDark
        },
        alternateRowStyles: {
          fillColor: [249, 250, 251]
        },
        columnStyles: {
          3: { halign: 'right', cellWidth: 'wrap' },
          4: { halign: 'right', cellWidth: 'wrap' },
          5: { halign: 'right', cellWidth: 'wrap' }
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

      doc.save(`client_ledger_${new Date().toISOString().split('T')[0]}.pdf`);
      toast.success('PDF report exported successfully!');
    } catch (error) {
      console.error('Failed to export PDF:', error);
      toast.error('Failed to export PDF report');
    }
  }
</script>

<div class="space-y-6">
  <ReportFilterBar
    activeId="client-ledger"
    units={data.units}
    token={data.user.access_token}
    showUnit={false}
    showClient={true}
    showCostToggle={false}
    onfilter={handleFilter}
  />

  <ReportTable
    title="Client Ledger"
    {columns}
    {rows}
    {loading}
    onexportPdf={exportToPDF}
  />
</div>
