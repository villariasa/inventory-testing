<script lang="ts">
  import type { PageData } from './$types';
  import type { InventoryItem, ItemCategory, InventoryUnit, UnitBin } from '$lib/types';
  import { invokeService } from '$lib/service/invokeService';
  import { invalidateAll } from '$app/navigation';
  import { toast } from 'svelte-sonner';
  import ItemTable from '$lib/components/inventory/ItemTable.svelte';
  import ItemFormDialog from '$lib/components/inventory/ItemFormDialog.svelte';
  import BarcodeScanner from '$lib/components/inventory/BarcodeScanner.svelte';
  import QRCodeDisplay from '$lib/components/inventory/QRCodeDisplay.svelte';
  import { Button } from '$lib/components/ui/button/index.js';
  import { Input } from '$lib/components/ui/input/index.js';
  import * as Dialog from '$lib/components/ui/dialog/index.js';
  import * as Card from '$lib/components/ui/card/index.js';
  import Label from '$lib/components/ui/label/label.svelte';
  import Icon from '@iconify/svelte';
  import SearchCombobox from '$lib/components/ui/SearchCombobox.svelte';

  import { imageCacheStore } from '$lib/store/imageCache.svelte';

  let { data } = $props<{ data: PageData & { categories: ItemCategory[]; units: InventoryUnit[]; user: any } }>();

  // Search and Filter State
  let searchQuery = $state('');
  let barcodeScannerOpen = $state(false);
  let initialBarcodeValue = $state('');
  // 0 = All Categories (table loads all items on page mount)
  let filterCategoryId = $state<number | null>(0);

  // Success dialog states for newly created items
  let successDialogOpen = $state(false);
  let newlyCreatedItem = $state<InventoryItem | null>(null);
  let newlyCreatedItemBarcode = $derived.by(() => {
    if (!newlyCreatedItem) return '';
    const barcodeList = newlyCreatedItem.barcodes || [];
    const scannedBc = barcodeList.find((b: any) => b.barcode_type === 'SCANNED');
    const internalBc = barcodeList[0];
    return scannedBc?.barcode_value || internalBc?.barcode_value || '';
  });

  let viewCodeTab = $state<'barcode' | 'qrcode'>('barcode');

  // Client-side items state — fetched when a category is selected
  let items = $state<InventoryItem[]>([]);
  let loadingItems = $state(false);

  // ──────────────────────────────────────
  // Image cache (delegated to shared imageCacheStore)
  // ──────────────────────────────────────
  async function getItemImageCached(itemId: number): Promise<string | null> {
    return imageCacheStore.fetch(itemId, data.user?.access_token ?? '');
  }

  function invalidateImageCache(itemId: number) {
    imageCacheStore.delete(itemId);
  }

  // Category options for the combobox including All Categories
  let categoryOptions = $derived([
    { value: 0, label: 'All Categories' },
    ...data.categories.map((c: any) => ({ value: c.item_category_id, label: c.description ?? c.item_category_description ?? '' }))
  ]);

  // Fetch items from the API when category changes
  $effect(() => {
    const catId = filterCategoryId;
    if (catId === null) {
      items = [];
      return;
    }
    fetchItemsByCategory(catId);
  });

  async function fetchItemsByCategory(categoryId: number) {
    loadingItems = true;
    const response = await invokeService<any, any>('/get-inventory-item', {
      body: { 
        bol_getone: 0, 
        item_category_id: categoryId, 
        item_id: 0, 
        item_description: '',
        bypass_image_filter: categoryId === 0 ? true : false
      },
      token: data.user.access_token
    });
    loadingItems = false;

    if ('data' in response && response.data.success) {
      items = response.data?.data?.json_data || [];
    } else {
      items = [];
      const errMsg = 'error' in response ? response.error : (response.data?.message || 'Unknown error');
      console.error('[Items Page] Failed to fetch items for category', categoryId, ':', errMsg, response);
      toast.error(`Failed to load items: ${errMsg}`);
    }
  }

  // Search filter applied on top of fetched items
  let filteredItems = $derived(
    items.filter(item => {
      const query = searchQuery.toLowerCase();
      const matchSearch = item.model_description.toLowerCase().includes(query) ||
                          (item.brand_description && item.brand_description.toLowerCase().includes(query)) ||
                          (item.barcodes && item.barcodes.some(bc => bc.barcode_value.toLowerCase().includes(query)));
      return matchSearch;
    })
  );



  // Modal Dialog states
  let formOpen = $state(false);
  let selectedItemForEdit = $state<InventoryItem | null>(null);

  let viewOpen = $state(false);
  let selectedItemForView = $state<InventoryItem | null>(null);
  let barcodeEl = $state<SVGElement | null>(null);

  // Resolve standard/first barcode value
  let derivedBarcodeValue = $derived.by(() => {
    if (!selectedItemForView) return '';
    const barcodeList = selectedItemForView.barcodes || [];
    const scannedBc = barcodeList.find((b: any) => b.barcode_type === 'SCANNED');
    const internalBc = barcodeList[0];
    return scannedBc?.barcode_value || internalBc?.barcode_value || '';
  });

  function getValidBarcodeValue(val: string): { value: string; format: string } {
    const clean = val.replace(/[\s-]/g, '');
    if (/^\d{13}$/.test(clean)) {
      const first12 = clean.slice(0, 12);
      let sum = 0;
      for (let i = 0; i < 12; i++) {
        sum += parseInt(first12[i], 10) * (i % 2 === 0 ? 1 : 3);
      }
      const remainder = sum % 10;
      const checkDigit = remainder === 0 ? 0 : 10 - remainder;
      return { value: first12 + checkDigit, format: 'EAN13' };
    }
    if (/^\d{8}$/.test(clean)) {
      const first7 = clean.slice(0, 7);
      let sum = 0;
      for (let i = 0; i < 7; i++) {
        sum += parseInt(first7[i], 10) * (i % 2 === 0 ? 3 : 1);
      }
      const remainder = sum % 10;
      const checkDigit = remainder === 0 ? 0 : 10 - remainder;
      return { value: first7 + checkDigit, format: 'EAN8' };
    }
    if (/^\d{12}$/.test(clean)) {
      const first11 = clean.slice(0, 11);
      let sum = 0;
      for (let i = 0; i < 11; i++) {
        sum += parseInt(first11[i], 10) * (i % 2 === 0 ? 3 : 1);
      }
      const remainder = sum % 10;
      const checkDigit = remainder === 0 ? 0 : 10 - remainder;
      return { value: first11 + checkDigit, format: 'UPC' };
    }
    return { value: val, format: 'CODE128' };
  }

  let barcodeFormatLabel = $derived.by(() => {
    const val = derivedBarcodeValue;
    if (!val) return 'Code 128';
    const info = getValidBarcodeValue(val);
    if (info.format === 'EAN13') return 'EAN-13';
    if (info.format === 'EAN8') return 'EAN-8';
    if (info.format === 'UPC') return 'UPC';
    return 'Code 128';
  });

  $effect(() => {
    if (viewOpen && barcodeEl && derivedBarcodeValue) {
      import('jsbarcode').then(({ default: JsBarcode }) => {
        const info = getValidBarcodeValue(derivedBarcodeValue);
        try {
          JsBarcode(barcodeEl, info.value, {
            format: info.format,
            width: 2,
            height: 50,
            displayValue: true,
            fontSize: 12,
            margin: 0
          });
        } catch (err) {
          console.warn(`JsBarcode failed with format ${info.format}, falling back to CODE128:`, err);
          try {
            JsBarcode(barcodeEl, derivedBarcodeValue, {
              format: "CODE128",
              width: 2,
              height: 50,
              displayValue: true,
              fontSize: 12,
              margin: 0
            });
          } catch (fallbackErr) {
            console.error('Failed to render fallback barcode:', fallbackErr);
          }
        }
      });
    }
  });

  // Download Labels Config state
  let downloadLabelsModalOpen = $state(false);
  let labelCodeType = $state<'barcode' | 'qrcode'>('barcode');
  let labelCols = $state<number>(1);
  let labelIncludeDesc = $state(true);
  let labelIncludePrice = $state(true);
  let generatingLabels = $state(false);

  // Selection and quantity for label printing
  let labelItemSelections = $state<Record<number, { selected: boolean; qty: number }>>({});
  let labelSearchQuery = $state('');

  // Sync selections when items list updates
  $effect(() => {
    const newSelections = { ...labelItemSelections };
    let changed = false;
    for (const item of items) {
      if (!(item.item_id in newSelections)) {
        newSelections[item.item_id] = { selected: true, qty: 1 };
        changed = true;
      }
    }
    // Clean up selections for items no longer in list
    for (const key in newSelections) {
      const id = parseInt(key, 10);
      if (!items.some(i => i.item_id === id)) {
        delete newSelections[id];
        changed = true;
      }
    }
    if (changed) {
      labelItemSelections = newSelections;
    }
  });

  let dialogFilteredItems = $derived(
    items.filter(item => {
      const q = labelSearchQuery.toLowerCase().trim();
      if (!q) return true;
      return item.model_description.toLowerCase().includes(q) ||
             (item.brand_description && item.brand_description.toLowerCase().includes(q)) ||
             (item.barcodes && item.barcodes.some(bc => bc.barcode_value.toLowerCase().includes(q)));
    })
  );

  let selectedItemsCount = $derived.by(() => {
    let count = 0;
    for (const key in labelItemSelections) {
      if (labelItemSelections[key].selected) {
        count++;
      }
    }
    return count;
  });

  let totalLabelsCount = $derived.by(() => {
    let count = 0;
    for (const key in labelItemSelections) {
      const selection = labelItemSelections[key];
      if (selection.selected) {
        count += selection.qty;
      }
    }
    return count;
  });

  function toggleSelection(itemId: number, checked: boolean) {
    if (labelItemSelections[itemId]) {
      labelItemSelections[itemId].selected = checked;
    }
  }

  function updateQty(itemId: number, qty: number) {
    if (labelItemSelections[itemId]) {
      labelItemSelections[itemId].qty = Math.max(1, qty);
    }
  }

  function selectAllItems() {
    for (const item of items) {
      if (labelItemSelections[item.item_id]) {
        labelItemSelections[item.item_id].selected = true;
      }
    }
  }

  function deselectAllItems() {
    for (const item of items) {
      if (labelItemSelections[item.item_id]) {
        labelItemSelections[item.item_id].selected = false;
      }
    }
  }

  async function generateAllLabels(type: 'barcode' | 'qrcode', cols: number, showDesc: boolean, showPrice: boolean) {
    if (totalLabelsCount === 0) {
      toast.error('No items selected to generate labels.');
      return;
    }

    generatingLabels = true;
    const toastId = toast.loading('Generating label sheet...');
    
    try {
      const { default: QRCode } = await import('qrcode');
      const { default: JsBarcode } = await import('jsbarcode');
      
      const printWindow = window.open('', '_blank');
      if (!printWindow) {
        toast.error('Popup blocker prevented printing. Please allow popups.');
        generatingLabels = false;
        toast.dismiss(toastId);
        return;
      }

      // Find the current category description
      const categoryDesc = filterCategoryId === 0 ? 'All Categories' : (data.categories.find((c: any) => c.item_category_id === filterCategoryId)?.description || 'Items');

      let html = `<!DOCTYPE html>
<html>
<head>
  <title>${categoryDesc} Labels - Sheet</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
      margin: 15px;
      padding: 0;
      background-color: #ffffff;
      color: #0f172a;
    }
    .preview-header-bar {
      background: #f8fafc;
      border: 1px solid #cbd5e1;
      padding: 12px 24px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 20px;
      border-radius: 12px;
      box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
    }
    .preview-header-title {
      font-size: 14px;
      font-weight: 700;
      color: #0f172a;
    }
    .preview-header-actions {
      display: flex;
      gap: 10px;
    }
    .preview-btn {
      background: #0f172a;
      color: #ffffff;
      border: none;
      padding: 8px 16px;
      border-radius: 8px;
      font-size: 12px;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.2s;
    }
    .preview-btn:hover {
      background: #1e293b;
    }
    .preview-btn-secondary {
      background: #ffffff;
      color: #0f172a;
      border: 1px solid #cbd5e1;
    }
    .preview-btn-secondary:hover {
      background: #f1f5f9;
    }
    .grid-container {
      display: grid;
      grid-template-columns: repeat(${cols}, 1fr);
      gap: 12px;
      ${cols === 1 ? 'max-width: 280px; margin: 0 auto;' : ''}
    }
    .label-card {
      border: 1px solid #e2e8f0;
      border-radius: 8px;
      padding: 10px;
      text-align: center;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      background: white;
      box-sizing: border-box;
      page-break-inside: avoid;
      min-height: 120px;
    }
    .label-img {
      max-width: 100%;
      height: auto;
      margin-bottom: 4px;
    }
    .label-title {
      font-size: 10px;
      font-weight: 700;
      color: #1e293b;
      margin: 4px 0 2px 0;
      word-wrap: break-word;
      max-width: 100%;
      line-height: 1.2;
      display: -webkit-box;
      -webkit-line-clamp: 2;
      -webkit-box-orient: vertical;
      overflow: hidden;
    }
    .label-price {
      font-size: 10px;
      font-weight: 800;
      color: #0d9488;
      margin: 2px 0 0 0;
    }
    .label-code {
      font-size: 8px;
      font-family: SFMono-Regular, Consolas, "Liberation Mono", Menlo, monospace;
      color: #64748b;
      margin-top: 2px;
    }
    @media print {
      body {
        margin: 5px;
      }
      .preview-header-bar {
        display: none !important;
      }
      .label-card {
        border: 1px solid #94a3b8;
      }
    }
  </style>
</head>
<body>
  <div class="preview-header-bar">
    <div class="preview-header-title">Labels Print Preview (${totalLabelsCount} labels)</div>
    <div class="preview-header-actions">
      <button class="preview-btn preview-btn-secondary" onclick="window.close()">Close Preview</button>
      <button class="preview-btn" onclick="window.print()">Print Sheet</button>
    </div>
  </div>
  <div class="grid-container">`;

      for (const item of items) {
        const selection = labelItemSelections[item.item_id];
        if (!selection || !selection.selected || selection.qty <= 0) continue;

        // Resolve barcode
        const barcodeList = item.barcodes || [];
        const scannedBc = barcodeList.find((b: any) => b.barcode_type === 'SCANNED');
        const internalBc = barcodeList[0];
        const rawCode = scannedBc?.barcode_value || internalBc?.barcode_value || '';
        
        if (!rawCode) continue;

        let codeImageSrc = '';

        if (type === 'qrcode') {
          codeImageSrc = await QRCode.toDataURL(rawCode, { width: 150, margin: 1 });
        } else {
          const canvas = document.createElement('canvas');
          const info = getValidBarcodeValue(rawCode);
          try {
            JsBarcode(canvas, info.value, {
              format: info.format,
              width: 1.8,
              height: 40,
              displayValue: false, // Hide digits inside graphic to style it custom below
              margin: 0
            });
            codeImageSrc = canvas.toDataURL('image/png');
          } catch (err) {
            // Fallback to Code 128
            try {
              JsBarcode(canvas, rawCode, {
                format: 'CODE128',
                width: 1.8,
                height: 40,
                displayValue: false,
                margin: 0
              });
              codeImageSrc = canvas.toDataURL('image/png');
            } catch (fallbackErr) {
              console.error('Failed to generate printable barcode:', fallbackErr);
            }
          }
        }

        for (let q = 0; q < selection.qty; q++) {
          html += `
      <div class="label-card">
        ${codeImageSrc ? `<img class="label-img" src="${codeImageSrc}" style="max-height: ${type === 'qrcode' ? '70px' : '38px'};" />` : ''}
        <div class="label-code">${rawCode}</div>
        ${showDesc ? `<div class="label-title" title="${item.model_description}">${item.model_description}</div>` : ''}
        ${showPrice ? `<div class="label-price">₱${item.selling_price}</div>` : ''}
      </div>`;
        }
      }

      html += `
  </div>
  ` + `<` + `script>
    window.onload = function() {
      setTimeout(() => {
        window.print();
      }, 500);
    };
  ` + `<\/` + `script>
</body>
</html>`;

      printWindow.document.write(html);
      printWindow.document.close();
      toast.success('Label sheet generated successfully', { id: toastId });
    } catch (err) {
      console.error('Failed to generate label sheet:', err);
      toast.error('Failed to generate label sheet', { id: toastId });
    } finally {
      generatingLabels = false;
    }
  }

  let deleteOpen = $state(false);
  let selectedItemForDelete = $state<InventoryItem | null>(null);

  let assignOpen = $state(false);
  let selectedItemForAssign = $state<InventoryItem | null>(null);

  // Multi-row assignment state
  type AssignRow = {
    id: number;
    unitId: number | null;
    binId: number | null;
    bins: UnitBin[];
    loadingBins: boolean;
  };
  let assignRowIdCounter = $state(0);
  let assignRows = $state<AssignRow[]>([]);

  // Confirmation state variables
  let confirmSaveOpen = $state(false);
  let pendingSavePayload = $state<Partial<InventoryItem> | null>(null);
  let confirmAssignOpen = $state(false);

  let assignUnitOptions = $derived(
    data.units.map((u: any) => ({ value: u.unit_id, label: u.description }))
  );

  function createAssignRow(): AssignRow {
    assignRowIdCounter++;
    return { id: assignRowIdCounter, unitId: null, binId: null, bins: [], loadingBins: false };
  }

  function addAssignRow() {
    assignRows = [...assignRows, createAssignRow()];
  }

  function removeAssignRow(rowId: number) {
    assignRows = assignRows.filter(r => r.id !== rowId);
  }

  function getBinOptionsForRow(row: AssignRow) {
    return row.bins.map((b: any) => ({ value: b.bin_id, label: b.description }));
  }

  async function fetchBinsForRow(rowId: number, unitId: number) {
    // Mark loading
    assignRows = assignRows.map(r => r.id === rowId ? { ...r, loadingBins: true, bins: [], binId: null } : r);

    const response = await invokeService<any, any>('/get-empty-unit-bin', {
      body: { bol_getone: 0, bin_id: 0, unit_id: unitId, description: '' },
      token: data.user.access_token
    });

    const bins = ('data' in response && response.data.success)
      ? (response.data?.data?.json_data || [])
      : [];

    if (!('data' in response && response.data.success)) {
      const errMsg = 'error' in response ? response.error : (response.data?.message || 'Unknown error');
      console.error('[Items Page] Failed to fetch empty unit bins:', errMsg, response);
      toast.error(`Failed to fetch empty unit bins: ${errMsg}`);
    }

    assignRows = assignRows.map(r => r.id === rowId ? { ...r, loadingBins: false, bins, binId: bins[0]?.bin_id || null } : r);
  }

  // Add or Edit action click
  function openAddForm() {
    selectedItemForEdit = null;
    initialBarcodeValue = '';
    formOpen = true;
  }

  async function findItemByVirtualBarcode(itemId: number) {
    const categoriesList = data.categories || [];
    const searchPromises = categoriesList.map(async (cat: any) => {
      try {
        const response = await invokeService<any, any>('/get-inventory-item', {
          body: { bol_getone: 1, item_category_id: cat.item_category_id, item_id: itemId, item_description: '' },
          token: data.user.access_token
        });
        if ('data' in response && response.data.success) {
          const returnedItems = response.data?.data?.json_data || [];
          if (returnedItems && returnedItems.length > 0) {
            return returnedItems[0];
          }
        }
      } catch (err) {
        console.error(`Failed to lookup virtual barcode for item_id ${itemId} in category ${cat.item_category_id}:`, err);
      }
      return null;
    });

    const results = await Promise.all(searchPromises);
    return results.find(item => item !== null) || null;
  }

  async function searchByBarcode(barcode: string) {
    // Strip the '-CASE' suffix if present
    const cleanBarcode = barcode.endsWith('-CASE') ? barcode.slice(0, -5) : barcode;

    loadingItems = true;
    const response = await invokeService<any, any>('/scan', {
      body: { barcode: cleanBarcode },
      token: data.user.access_token
    });

    if ('data' in response && response.data.success) {
      let returnedItems = response.data?.data?.json_data || [];

      // Fallback: If no item is found via explicit barcode lookup,
      // and the barcode is in virtual format (INV-XXXXXX), lookup by Item ID.
      if (returnedItems.length === 0) {
        const match = cleanBarcode.match(/^INV-(\d+)$/i);
        if (match) {
          const itemId = parseInt(match[1], 10);
          const foundItem = await findItemByVirtualBarcode(itemId);
          if (foundItem) {
            returnedItems = [foundItem];
          }
        }
      }

      loadingItems = false;

      if (returnedItems && returnedItems.length > 0) {
        const scannedItem = returnedItems[0];
        filterCategoryId = scannedItem.item_category_id;
        searchQuery = cleanBarcode;
        toast.success(`Found item: ${scannedItem.model_description}`);
        
        // Automatically open the View Details dialog for the scanned item!
        await openView(scannedItem);
      } else {
        toast.error('Barcode not found. Opening "Add Item" form...');
        selectedItemForEdit = null;
        initialBarcodeValue = cleanBarcode;
        formOpen = true;
      }
    } else {
      loadingItems = false;
      const errMsg = 'error' in response ? response.error : (response.data?.message || 'Unknown error');
      console.error('[Items Page] Barcode lookup failed:', errMsg, response);
      toast.error(`Barcode search failed: ${errMsg}`);
    }
  }

  async function openEditForm(item: InventoryItem) {
    // Use cached image first for a snappy open, then always fetch fresh for the edit form
    const cached = imageCacheStore.has(item.item_id) ? imageCacheStore.get(item.item_id) : undefined;
    selectedItemForEdit = { ...item, image: cached ?? null };
    formOpen = true;

    const toastId = toast.loading('Loading item image...');
    const res = await invokeService<any, any>('/get-item-image', {
      body: { item_id: item.item_id },
      token: data.user?.access_token ?? ''
    });
    toast.dismiss(toastId);

    let image: string | null = null;
    if ('data' in res && res.data.success) {
      const imageData = res.data?.data?.json_data;
      if (imageData && imageData.image) image = imageData.image;
    }
    // Refresh cache entry with the latest version
    imageCacheStore.set(item.item_id, image);

    selectedItemForEdit = { ...item, image };
  }

  async function openView(item: InventoryItem) {
    viewCodeTab = 'barcode';
    // Show cached image immediately while we confirm with a fresh fetch
    const cached = imageCacheStore.has(item.item_id) ? imageCacheStore.get(item.item_id) : undefined;
    selectedItemForView = { ...item, image: cached ?? null };
    viewOpen = true;

    const res = await invokeService<any, any>('/get-item-image', {
      body: { item_id: item.item_id },
      token: data.user?.access_token ?? ''
    });

    let image: string | null = null;
    if ('data' in res && res.data.success) {
      const imageData = res.data?.data?.json_data;
      if (imageData && imageData.image) image = imageData.image;
    }
    // Update cache
    imageCacheStore.set(item.item_id, image);

    if (viewOpen) selectedItemForView = { ...item, image };
  }

  function openDelete(item: InventoryItem) {
    selectedItemForDelete = item;
    deleteOpen = true;
  }

  function openAssign(item: InventoryItem) {
    selectedItemForAssign = item;
    assignRowIdCounter = 0;
    assignRows = [createAssignRow()];
    assignOpen = true;
  }

  // API Call submissions
  function saveItem(payload: Partial<InventoryItem>) {
    pendingSavePayload = payload;
    confirmSaveOpen = true;
  }

  async function executeSaveItem() {
    if (!pendingSavePayload) return;
    const payload = pendingSavePayload;
    confirmSaveOpen = false;

    const isEdit = !!selectedItemForEdit;
    const process_type = isEdit ? 1 : 0;
    const user_id = data.user.member?.member_id ?? 1;

    const toastId = toast.loading(isEdit ? 'Updating item...' : 'Creating item...');

    const response = await invokeService<any, any>('/post-inventory-item', {
      body: {
        ...payload,
        process_type,
        user_id
      },
      token: data.user.access_token
    });

    if ('data' in response && response.data.success) {
      toast.success(isEdit ? 'Item updated successfully' : 'Item created successfully', { id: toastId });
      formOpen = false;
      // Invalidate cache for the edited item so the table reloads the thumbnail
      if (isEdit && selectedItemForEdit) invalidateImageCache(selectedItemForEdit.item_id);
      pendingSavePayload = null;
      if (filterCategoryId !== null) {
        await fetchItemsByCategory(filterCategoryId);
        if (!isEdit && items.length > 0) {
          // Newly created item is at index 0 due to ORDER BY ii.datetime_created DESC
          newlyCreatedItem = items[0];
          successDialogOpen = true;
        }
      }
    } else {
      const errMsg = 'error' in response ? response.error : (response.data?.message || 'Unknown error');
      console.error('[Items Page] Failed to save item:', errMsg, response);
      toast.error(`Failed to save item: ${errMsg}`, { id: toastId });
    }
  }

  async function printLabelForValue(barcode: string, labelText: string) {
    try {
      const { default: QRCode } = await import('qrcode');
      const dataUrl = await QRCode.toDataURL(barcode, { width: 200, margin: 1 });
      
      const printWindow = window.open('', '_blank', 'width=350,height=350');
      if (!printWindow) {
        toast.error('Popup blocked. Please allow popups to print labels.');
        return;
      }
      
      printWindow.document.write('<!DOCTYPE html><html><head><title>Print Label</title></head><body><img src="' + dataUrl + '" alt="QR Code" style="max-width: 160px; height: auto; margin-bottom: 8px;" /><div style="font-size: 13px; font-weight: 700; color: #0f172a; margin-bottom: 2px; max-width: 200px; word-wrap: break-word;">' + labelText + '</div><div style="font-size: 11px; font-family: monospace; color: #64748b;">' + barcode + '</div><script>window.onload = function() { window.print(); setTimeout(() => { window.close(); }, 500); };<\/script></body></html>');
      
      const style = printWindow.document.createElement('style');
      style.textContent = "@page { size: auto; margin: 0; } body { margin: 0; padding: 20px; display: flex; flex-direction: column; align-items: center; justify-content: center; font-family: system-ui, -apple-system, sans-serif; text-align: center; }";
      printWindow.document.head.appendChild(style);
      
      printWindow.document.close();
    } catch (err) {
      console.error('Failed to generate printable label:', err);
      toast.error('Failed to generate printable label.');
    }
  }

  function copyToClipboard(text: string) {
    if (!text) return;
    navigator.clipboard.writeText(text)
      .then(() => {
        toast.success(`Copied to clipboard: ${text}`);
      })
      .catch((err) => {
        console.error('Failed to copy text:', err);
        toast.error('Failed to copy to clipboard');
      });
  }

  async function downloadQRCode(barcode: string, fileNamePrefix: string) {
    try {
      const { default: QRCode } = await import('qrcode');
      const dataUrl = await QRCode.toDataURL(barcode, { width: 400, margin: 1 });
      const downloadLink = document.createElement('a');
      downloadLink.href = dataUrl;
      downloadLink.download = `${fileNamePrefix.replace(/[^a-z0-9]/gi, '_').toLowerCase()}_qr.png`;
      document.body.appendChild(downloadLink);
      downloadLink.click();
      document.body.removeChild(downloadLink);
      toast.success('QR Code downloaded successfully');
    } catch (err) {
      console.error('Failed to download QR code:', err);
      toast.error('Failed to download QR code');
    }
  }

  function downloadBarcodeSVG() {
    if (!barcodeEl || !derivedBarcodeValue) return;
    try {
      const svgWidth = barcodeEl.getAttribute('width') || '250';
      const svgHeight = barcodeEl.getAttribute('height') || '100';
      
      const svgString = new XMLSerializer().serializeToString(barcodeEl);
      const svgBlob = new Blob([svgString], { type: 'image/svg+xml;charset=utf-8' });
      const DOMURL = window.URL || window.webkitURL || window;
      const url = DOMURL.createObjectURL(svgBlob);
      
      const img = new Image();
      img.onload = () => {
        const canvas = document.createElement('canvas');
        canvas.width = parseInt(svgWidth, 10) || 300;
        canvas.height = parseInt(svgHeight, 10) || 100;
        const ctx = canvas.getContext('2d');
        if (ctx) {
          ctx.fillStyle = '#FFFFFF';
          ctx.fillRect(0, 0, canvas.width, canvas.height);
          ctx.drawImage(img, 0, 0);
          
          const pngUrl = canvas.toDataURL('image/png');
          const downloadLink = document.createElement('a');
          downloadLink.href = pngUrl;
          downloadLink.download = `${derivedBarcodeValue}_barcode.png`;
          document.body.appendChild(downloadLink);
          downloadLink.click();
          document.body.removeChild(downloadLink);
          toast.success('Barcode downloaded successfully');
        }
        DOMURL.revokeObjectURL(url);
      };
      img.src = url;
    } catch (err) {
      console.error('Failed to download barcode image:', err);
      toast.error('Failed to download barcode image');
    }
  }

  async function copyImageToClipboard(blob: Blob) {
    try {
      await navigator.clipboard.write([
        new ClipboardItem({ 'image/png': blob })
      ]);
      toast.success('Image copied to clipboard!');
    } catch (err) {
      console.error('Failed to copy image to clipboard:', err);
      toast.error('Failed to copy image to clipboard.');
    }
  }

  async function copyProductImageToClipboard(imageUrl: string | null | undefined) {
    if (!imageUrl) return;
    try {
      const img = new Image();
      img.crossOrigin = 'anonymous';
      
      await new Promise((resolve, reject) => {
        img.onload = resolve;
        img.onerror = reject;
        img.src = imageUrl;
      });

      const canvas = document.createElement('canvas');
      canvas.width = img.naturalWidth;
      canvas.height = img.naturalHeight;
      const ctx = canvas.getContext('2d');
      if (!ctx) {
        throw new Error('Failed to get canvas 2D context');
      }
      ctx.drawImage(img, 0, 0);

      canvas.toBlob(async (blob) => {
        if (blob) {
          await copyImageToClipboard(blob);
        } else {
          toast.error('Failed to generate PNG blob for product image');
        }
      }, 'image/png');
    } catch (err) {
      console.error('Failed to copy product image:', err);
      toast.error('Failed to copy product image to clipboard');
    }
  }

  function downloadProductImage(imageUrl: string | null | undefined, fileNamePrefix: string) {
    if (!imageUrl) return;
    try {
      const downloadLink = document.createElement('a');
      downloadLink.href = imageUrl;
      let ext = 'png';
      if (imageUrl.startsWith('data:image/')) {
        const match = imageUrl.match(/data:image\/([a-zA-Z+]+);base64/);
        if (match && match[1]) {
          ext = match[1] === 'jpeg' ? 'jpg' : match[1];
        }
      } else {
        const parts = imageUrl.split('.');
        if (parts.length > 1) {
          const lastPart = parts.pop()?.split('?')[0];
          if (lastPart) ext = lastPart;
        }
      }
      downloadLink.download = `${fileNamePrefix.replace(/[^a-z0-9]/gi, '_').toLowerCase()}_image.${ext}`;
      document.body.appendChild(downloadLink);
      downloadLink.click();
      document.body.removeChild(downloadLink);
      toast.success('Product image downloaded successfully');
    } catch (err) {
      console.error('Failed to download product image:', err);
      toast.error('Failed to download product image');
    }
  }

  async function copyQRCodeImageToClipboard(barcode: string) {
    try {
      const { default: QRCode } = await import('qrcode');
      const canvas = document.createElement('canvas');
      await QRCode.toCanvas(canvas, barcode, { width: 300, margin: 1 });
      canvas.toBlob(async (blob) => {
        if (blob) {
          await copyImageToClipboard(blob);
        } else {
          toast.error('Failed to generate image blob');
        }
      }, 'image/png');
    } catch (err) {
      console.error('Failed to copy QR code image:', err);
      toast.error('Failed to copy QR code image');
    }
  }

  function copyBarcodeImageToClipboard() {
    if (!barcodeEl || !derivedBarcodeValue) return;
    try {
      const svgWidth = barcodeEl.getAttribute('width') || '250';
      const svgHeight = barcodeEl.getAttribute('height') || '100';
      
      const svgString = new XMLSerializer().serializeToString(barcodeEl);
      const svgBlob = new Blob([svgString], { type: 'image/svg+xml;charset=utf-8' });
      const DOMURL = window.URL || window.webkitURL || window;
      const url = DOMURL.createObjectURL(svgBlob);
      
      const img = new Image();
      img.onload = () => {
        const canvas = document.createElement('canvas');
        canvas.width = parseInt(svgWidth, 10) || 300;
        canvas.height = parseInt(svgHeight, 10) || 100;
        const ctx = canvas.getContext('2d');
        if (ctx) {
          ctx.fillStyle = '#FFFFFF';
          ctx.fillRect(0, 0, canvas.width, canvas.height);
          ctx.drawImage(img, 0, 0);
          
          canvas.toBlob(async (blob) => {
            if (blob) {
              await copyImageToClipboard(blob);
            } else {
              toast.error('Failed to generate image blob');
            }
            DOMURL.revokeObjectURL(url);
          }, 'image/png');
        } else {
          DOMURL.revokeObjectURL(url);
        }
      };
      img.src = url;
    } catch (err) {
      console.error('Failed to copy barcode image:', err);
      toast.error('Failed to copy barcode image');
    }
  }

  async function deleteItem() {
    if (!selectedItemForDelete) return;
    const toastId = toast.loading('Deleting item...');

    const response = await invokeService<any, any>('/post-inventory-item', {
      body: {
        item_id: selectedItemForDelete.item_id,
        process_type: 2, // delete
        user_id: data.user.member?.member_id ?? 1,
        // Send other fields as nullable placeholders matching the schema
        item_category_id: 0,
        model_description: '',
        stocking_unit: '',
        retail_unit: '',
        rtu_over_stu: 0,
        wtd_ave_cost: 0,
        mark_up_rate: 0,
        has_empty_case: 0,
        brand_id: null,
        part_id: null,
        part_number_id: null,
        size_id: null,
        valve_id: null,
        ratio_id: null,
        pattern_id: null,
        selling_price: null,
        image: null
      },
      token: data.user.access_token
    });

    deleteOpen = false;

    if ('data' in response && response.data.success) {
      toast.success('Item deleted successfully', { id: toastId });
      if (filterCategoryId !== null) fetchItemsByCategory(filterCategoryId);
    } else {
      const errMsg = 'error' in response ? response.error : (response.data?.message || 'Unknown error');
      console.error('[Items Page] Failed to delete item:', errMsg, response);
      toast.error(`Failed to delete item: ${errMsg}`, { id: toastId });
    }
  }

  function submitAssignment(e: Event) {
    e.preventDefault();
    const validRows = assignRows.filter(r => r.unitId && r.binId);
    if (!selectedItemForAssign || validRows.length === 0) return;
    confirmAssignOpen = true;
  }

  // Derived: are all rows valid?
  let allAssignRowsValid = $derived(assignRows.length > 0 && assignRows.every(r => r.unitId && r.binId));

  async function executeAssignment() {
    confirmAssignOpen = false;
    const validRows = assignRows.filter(r => r.unitId && r.binId);
    if (!selectedItemForAssign || validRows.length === 0) return;

    const toastId = toast.loading('Assigning item to warehouse...');
    const response = await invokeService<any, any>('/post-item-to-units', {
      body: {
        item_id: selectedItemForAssign.item_id,
        user_id: data.user.member?.member_id ?? 1,
        units: validRows.map(r => ({ unit_id: r.unitId, bin_id: r.binId }))
      },
      token: data.user.access_token
    });

    if ('data' in response && response.data.success) {
      toast.success(`Item assigned to ${validRows.length} unit(s) successfully`, { id: toastId });
      assignOpen = false;
      if (filterCategoryId !== null) fetchItemsByCategory(filterCategoryId);
    } else {
      const errMsg = 'error' in response ? response.error : (response.data?.message || 'Unknown error');
      console.error('[Items Page] Failed to assign item to unit:', errMsg, response);
      toast.error(`Failed to assign item to unit: ${errMsg}`, { id: toastId });
    }
  }
</script>

<div class="space-y-6">
  <!-- Page Header -->
  <div class="flex items-center justify-between">
    <div>
      <h2 class="text-2xl font-bold font-playfair text-primary">Catalog Items</h2>
      <p class="text-sm text-muted-foreground">Manage and assign inventory item descriptions, pricing, and classifications.</p>
    </div>
    <Button onclick={openAddForm} class="bg-primary hover:bg-primary/95 text-white flex items-center gap-2">
      <Icon icon="mdi:plus" width="20" />
      Add Item
    </Button>
  </div>

  <!-- Search and Filters -->
  <div class="flex flex-wrap items-center gap-4 bg-card border rounded-xl p-4 shadow-sm">
    <div class="relative flex-1 sm:max-w-md flex gap-2">
      <div class="relative flex-1">
        <Icon icon="mdi:magnify" width="16" class="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground pointer-events-none" />
        <Input
          type="text"
          placeholder="Search by description, brand, or barcode..."
          bind:value={searchQuery}
          autocomplete="off"
          class="pl-9 h-10"
          disabled={filterCategoryId === null}
        />
      </div>
      <Button 
        type="button" 
        onclick={() => barcodeScannerOpen = true}
        variant="outline" 
        class="h-10 px-3 flex items-center gap-1.5 shrink-0 text-primary border-primary/20 hover:bg-primary/5 shadow-sm"
      >
        <Icon icon="mdi:barcode-scan" width="18" />
        Scan to Search
      </Button>
    </div>
    <div class="min-w-[240px] w-[260px]">
      <SearchCombobox
        options={categoryOptions}
        bind:value={filterCategoryId}
        placeholder="Select a category..."
        searchPlaceholder="Search categories..."
      />
    </div>

    {#if filterCategoryId !== null && filteredItems.length > 0}
      <Button 
        type="button" 
        onclick={() => downloadLabelsModalOpen = true}
        variant="outline" 
        class="h-10 px-3.5 flex items-center gap-1.5 text-primary border-primary/20 hover:bg-primary/5 shadow-sm ml-auto sm:ml-0 cursor-pointer"
      >
        <Icon icon="mdi:download-box-outline" width="18" />
        Download Labels
      </Button>
    {/if}
  </div>

  <!-- Empty-state prompt when no category is chosen -->
  {#if filterCategoryId === null}

    <div class="flex flex-col items-center justify-center py-20 text-center border border-dashed border-border rounded-2xl bg-muted/20">
      <div class="w-14 h-14 rounded-2xl bg-primary/10 flex items-center justify-center mb-4">
        <Icon icon="mdi:filter-outline" width="28" class="text-primary" />
      </div>
      <h3 class="text-base font-semibold text-foreground mb-1">Select a Category to View Items</h3>
      <p class="text-sm text-muted-foreground max-w-xs">
        Use the category picker above to filter and browse catalog items by product group.
      </p>
    </div>
  {:else if loadingItems}
    <div class="flex flex-col items-center justify-center py-20 text-center border border-border rounded-2xl bg-card">
      <Icon icon="mdi:loading" width="32" class="text-primary animate-spin mb-3" />
      <p class="text-sm text-muted-foreground">Loading items...</p>
    </div>
  {:else}
    <!-- Items Table Grid -->
    <ItemTable
      items={filteredItems}
      imageCache={imageCacheStore.cache}
      onloadimage={getItemImageCached}
      onview={openView}
      onedit={openEditForm}
      ondelete={openDelete}
      onassign={openAssign}
    />
  {/if}

  <!-- Add/Edit Form Dialog -->
  <ItemFormDialog
    bind:open={formOpen}
    item={selectedItemForEdit}
    categories={data.categories}
    activeCategoryId={filterCategoryId}
    token={data.user?.access_token ?? ''}
    initialBarcode={initialBarcodeValue}
    onsave={saveItem}
  />

  <!-- View Dialog -->
  <Dialog.Root bind:open={viewOpen}>
    <Dialog.Content class="sm:max-w-[520px] max-h-[90vh] overflow-y-auto bg-card border border-border rounded-2xl shadow-2xl p-0 flex flex-col">
      {#if selectedItemForView}
        <div class="bg-primary/5 border-b px-6 py-4">
          <div class="flex items-center gap-3">
            <div class="w-9 h-9 rounded-xl bg-primary/10 flex items-center justify-center">
              <Icon icon="mdi:eye-outline" width="18" class="text-primary" />
            </div>
            <div>
              <Dialog.Title class="text-lg font-bold text-foreground">Item Details</Dialog.Title>
              <Dialog.Description class="text-xs text-muted-foreground">View item information</Dialog.Description>
            </div>
          </div>
        </div>
        <div class="px-6 py-5 space-y-4">
          {#if selectedItemForView.image}
            <div class="flex flex-col items-center justify-center p-3 border rounded-xl bg-muted/20 gap-2">
              <img src={selectedItemForView.image} alt={selectedItemForView.model_description ?? ''} class="h-40 object-contain rounded" />
              <div class="flex gap-2 justify-center">
                <Button
                  type="button"
                  variant="outline"
                  size="xs"
                  class="h-7 text-[10px] px-2.5 flex items-center gap-1 border-primary/20 text-primary hover:bg-primary/5 shadow-xs cursor-pointer bg-white dark:bg-slate-900"
                  onclick={() => copyProductImageToClipboard(selectedItemForView?.image)}
                >
                  <Icon icon="mdi:image-outline" width="12" /> Copy Image
                </Button>
                <Button
                  type="button"
                  variant="outline"
                  size="xs"
                  class="h-7 text-[10px] px-2.5 flex items-center gap-1 border-primary/20 text-primary hover:bg-primary/5 shadow-xs cursor-pointer bg-white dark:bg-slate-900"
                  onclick={() => downloadProductImage(selectedItemForView?.image, selectedItemForView?.model_description ?? 'item')}
                >
                  <Icon icon="mdi:download" width="12" /> Download Image
                </Button>
              </div>
            </div>
          {/if}

          <!-- Visual Codes Panel (Tabbed: Barcode vs QR Codes) -->
          {#if derivedBarcodeValue}
            <div class="border rounded-xl bg-white dark:bg-slate-900/40 shadow-inner overflow-hidden text-left">
              <div class="flex border-b border-border bg-muted/40 p-1 gap-1">
                <button
                  type="button"
                  onclick={() => viewCodeTab = 'barcode'}
                  class="flex-1 py-1.5 text-[10px] font-bold uppercase tracking-wider rounded-lg transition-all flex items-center justify-center gap-1 cursor-pointer
                    {viewCodeTab === 'barcode' ? 'bg-background shadow-sm text-primary font-extrabold border border-border/10' : 'text-muted-foreground hover:text-foreground hover:bg-background/20'}"
                >
                  <Icon icon="mdi:barcode" width="14" />
                  Barcode ({barcodeFormatLabel})
                </button>
                <button
                  type="button"
                  onclick={() => viewCodeTab = 'qrcode'}
                  class="flex-1 py-1.5 text-[10px] font-bold uppercase tracking-wider rounded-lg transition-all flex items-center justify-center gap-1 cursor-pointer
                    {viewCodeTab === 'qrcode' ? 'bg-background shadow-sm text-primary font-extrabold border border-border/10' : 'text-muted-foreground hover:text-foreground hover:bg-background/20'}"
                >
                  <Icon icon="mdi:qrcode" width="14" />
                  QR Code(s)
                </button>
              </div>

              <div class="p-4 text-center">
                <!-- Barcode Graphic Section -->
                <div class="flex flex-col items-center justify-center py-2 gap-2" class:hidden={viewCodeTab !== 'barcode'}>
                  <svg bind:this={barcodeEl} class="max-w-full h-auto"></svg>
                  <span class="text-xs font-mono font-semibold text-foreground tracking-wider">{derivedBarcodeValue}</span>
                  <div class="flex gap-1.5 justify-center">
                    <Button 
                      type="button" 
                      variant="outline" 
                      size="xs" 
                      class="h-7 text-[10px] px-2.5 flex items-center gap-1 border-primary/20 text-primary hover:bg-primary/5 shadow-xs cursor-pointer" 
                      onclick={() => copyToClipboard(derivedBarcodeValue)}
                    >
                      <Icon icon="mdi:content-copy" width="12" /> Copy Code
                    </Button>
                    <Button 
                      type="button" 
                      variant="outline" 
                      size="xs" 
                      class="h-7 text-[10px] px-2.5 flex items-center gap-1 border-primary/20 text-primary hover:bg-primary/5 shadow-xs cursor-pointer" 
                      onclick={copyBarcodeImageToClipboard}
                    >
                      <Icon icon="mdi:image-outline" width="12" /> Copy Image
                    </Button>
                    <Button 
                      type="button" 
                      variant="outline" 
                      size="xs" 
                      class="h-7 text-[10px] px-2.5 flex items-center gap-1 border-primary/20 text-primary hover:bg-primary/5 shadow-xs cursor-pointer" 
                      onclick={downloadBarcodeSVG}
                    >
                      <Icon icon="mdi:download" width="12" /> Download Barcode
                    </Button>
                  </div>
                </div>

                <!-- QR Codes Section -->
                <div class="flex flex-wrap items-center justify-center gap-6" class:hidden={viewCodeTab !== 'qrcode'}>
                  <!-- Main Item QR Code -->
                  <div class="flex flex-col items-center gap-1 text-center">
                    <QRCodeDisplay text={derivedBarcodeValue} size={100} />
                    <span class="text-[10px] font-bold text-foreground">Main Item</span>
                    <span class="text-[9px] font-mono text-muted-foreground">{derivedBarcodeValue}</span>
                    <div class="flex gap-1 mt-1 flex-wrap justify-center">
                      <Button 
                        type="button" 
                        variant="outline" 
                        size="xs" 
                        class="h-6 text-[9px] px-2 flex items-center gap-1 border-primary/20 text-primary hover:bg-primary/5 shadow-xs cursor-pointer" 
                        onclick={() => printLabelForValue(derivedBarcodeValue, selectedItemForView?.model_description ?? '')}
                      >
                        <Icon icon="mdi:printer" width="11" /> Print
                      </Button>
                      <Button 
                        type="button" 
                        variant="outline" 
                        size="xs" 
                        class="h-6 text-[9px] px-2 flex items-center gap-1 border-primary/20 text-primary hover:bg-primary/5 shadow-xs cursor-pointer" 
                        onclick={() => copyToClipboard(derivedBarcodeValue)}
                      >
                        <Icon icon="mdi:content-copy" width="11" /> Copy
                      </Button>
                      <Button 
                        type="button" 
                        variant="outline" 
                        size="xs" 
                        class="h-6 text-[9px] px-2 flex items-center gap-1 border-primary/20 text-primary hover:bg-primary/5 shadow-xs cursor-pointer" 
                        onclick={() => copyQRCodeImageToClipboard(derivedBarcodeValue)}
                      >
                        <Icon icon="mdi:image-outline" width="11" /> Copy Image
                      </Button>
                      <Button 
                        type="button" 
                        variant="outline" 
                        size="xs" 
                        class="h-6 text-[9px] px-2 flex items-center gap-1 border-primary/20 text-primary hover:bg-primary/5 shadow-xs cursor-pointer" 
                        onclick={() => downloadQRCode(derivedBarcodeValue, selectedItemForView?.model_description ?? 'item')}
                      >
                        <Icon icon="mdi:download" width="11" /> Download
                      </Button>
                    </div>
                  </div>

                  <!-- Empty Case QR Code (if applicable) -->
                  {#if selectedItemForView.is_empty_case || selectedItemForView.has_empty_case}
                    {@const caseBarcode = selectedItemForView.is_empty_case ? `INV-${String(selectedItemForView.is_empty_case).padStart(6, '0')}-CASE` : `${derivedBarcodeValue}-CASE`}
                    <div class="flex flex-col items-center gap-1 text-center">
                      <QRCodeDisplay text={caseBarcode} size={100} />
                      <span class="text-[10px] font-bold text-foreground">Empty Case</span>
                      <span class="text-[9px] font-mono text-muted-foreground">{caseBarcode}</span>
                      <div class="flex gap-1 mt-1 flex-wrap justify-center">
                        <Button 
                          type="button" 
                          variant="outline" 
                          size="xs" 
                          class="h-6 text-[9px] px-2 flex items-center gap-1 border-primary/20 text-primary hover:bg-primary/5 shadow-xs cursor-pointer" 
                          onclick={() => printLabelForValue(caseBarcode, `${selectedItemForView?.model_description ?? ''} - Case`)}
                        >
                          <Icon icon="mdi:printer" width="11" /> Print
                        </Button>
                        <Button 
                          type="button" 
                          variant="outline" 
                          size="xs" 
                          class="h-6 text-[9px] px-2 flex items-center gap-1 border-primary/20 text-primary hover:bg-primary/5 shadow-xs cursor-pointer" 
                          onclick={() => copyToClipboard(caseBarcode)}
                        >
                          <Icon icon="mdi:content-copy" width="11" /> Copy
                        </Button>
                        <Button 
                          type="button" 
                          variant="outline" 
                          size="xs" 
                          class="h-6 text-[9px] px-2 flex items-center gap-1 border-primary/20 text-primary hover:bg-primary/5 shadow-xs cursor-pointer" 
                          onclick={() => copyQRCodeImageToClipboard(caseBarcode)}
                        >
                          <Icon icon="mdi:image-outline" width="11" /> Copy Image
                        </Button>
                        <Button 
                          type="button" 
                          variant="outline" 
                          size="xs" 
                          class="h-6 text-[9px] px-2 flex items-center gap-1 border-primary/20 text-primary hover:bg-primary/5 shadow-xs cursor-pointer" 
                          onclick={() => downloadQRCode(caseBarcode, `${selectedItemForView?.model_description ?? ''}_case`)}
                        >
                          <Icon icon="mdi:download" width="11" /> Download
                        </Button>
                      </div>
                    </div>
                  {/if}
                </div>
              </div>
            </div>
          {/if}

          <div class="grid grid-cols-2 gap-x-6 gap-y-3">
            <div>
              <span class="text-[10px] font-bold uppercase tracking-wider text-muted-foreground block">Item ID</span>
              <span class="font-mono font-bold text-foreground">{selectedItemForView.item_id ?? '—'}</span>
            </div>
            <div>
              <span class="text-[10px] font-bold uppercase tracking-wider text-muted-foreground block">Category</span>
              <span>{selectedItemForView.item_category_description || selectedItemForView.item_category || '—'}</span>
            </div>
            <div>
              <span class="text-[10px] font-bold uppercase tracking-wider text-muted-foreground block">Model / Description</span>
              <span class="font-semibold text-foreground">{selectedItemForView.model_description ?? '—'}</span>
            </div>
            <div>
              <span class="text-[10px] font-bold uppercase tracking-wider text-muted-foreground block">Brand</span>
              <span>{selectedItemForView.brand || selectedItemForView.brand_id || '—'}</span>
            </div>
            <div>
              <span class="text-[10px] font-bold uppercase tracking-wider text-muted-foreground block">Stocking Unit</span>
              <span>{selectedItemForView.stocking_unit ?? '—'}</span>
            </div>
            <div>
              <span class="text-[10px] font-bold uppercase tracking-wider text-muted-foreground block">Retail Unit</span>
              <span>{selectedItemForView.retail_unit ?? '—'} ({selectedItemForView.rtu_over_stu ?? 0}/STU)</span>
            </div>
            <div>
              <span class="text-[10px] font-bold uppercase tracking-wider text-muted-foreground block">Wtd Ave Cost</span>
              <span class="font-mono text-foreground">₱{(selectedItemForView.wtd_ave_cost ?? 0).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}</span>
            </div>
            <div>
              <span class="text-[10px] font-bold uppercase tracking-wider text-muted-foreground block">Selling Price</span>
              <span class="font-mono font-bold text-teal-600">
                {#if selectedItemForView.selling_price != null}
                  ₱{selectedItemForView.selling_price.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                {:else}
                  —
                {/if}
              </span>
            </div>
            <div>
              <span class="text-[10px] font-bold uppercase tracking-wider text-muted-foreground block">Last Highest Unit Cost</span>
              <span class="font-mono text-foreground">
                {#if selectedItemForView.last_highest_in_unit_cost != null}
                  ₱{selectedItemForView.last_highest_in_unit_cost.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                {:else}
                  —
                {/if}
              </span>
            </div>
          </div>
          <div class="flex justify-end pt-4 border-t">
            <Button onclick={() => viewOpen = false} class="h-9 px-5 bg-primary hover:bg-primary/90 text-white">Close</Button>
          </div>
        </div>
      {/if}
    </Dialog.Content>
  </Dialog.Root>

  <!-- Delete Dialog -->
  <Dialog.Root bind:open={deleteOpen}>
    <Dialog.Content class="sm:max-w-[400px] bg-card border-0 rounded-2xl shadow-2xl p-0 overflow-hidden">
      {#if selectedItemForDelete}
        <div class="bg-rose-50 border-b border-rose-100 px-6 py-4">
          <div class="flex items-center gap-3">
            <div class="w-9 h-9 rounded-xl bg-rose-100 flex items-center justify-center">
              <Icon icon="mdi:delete-alert-outline" width="18" class="text-rose-600" />
            </div>
            <Dialog.Title class="text-lg font-bold text-rose-700">Confirm Delete</Dialog.Title>
          </div>
        </div>
        <div class="px-6 py-5">
          <p class="text-sm text-muted-foreground">
            Are you sure you want to permanently delete <span class="font-bold text-foreground">"{selectedItemForDelete.model_description}"</span>? This action cannot be undone.
          </p>
          <div class="flex justify-end gap-2 pt-5 border-t mt-5">
            <Button variant="outline" onclick={() => deleteOpen = false} class="h-9 px-5">Cancel</Button>
            <Button onclick={deleteItem} class="h-9 px-5 bg-rose-600 hover:bg-rose-700 text-white">Delete</Button>
          </div>
        </div>
      {/if}
    </Dialog.Content>
  </Dialog.Root>

  <!-- Assign to Unit Dialog -->
  <Dialog.Root bind:open={assignOpen}>
    <Dialog.Content
      onInteractOutside={(e) => e.preventDefault()}
      onEscapeKeydown={(e) => e.preventDefault()}
      class="sm:max-w-[580px] bg-card border-0 rounded-2xl shadow-2xl p-0 overflow-hidden"
    >
      {#if selectedItemForAssign}
        <div class="bg-primary/5 border-b px-6 py-4">
          <div class="flex items-center gap-3">
            <div class="w-9 h-9 rounded-xl bg-primary/10 flex items-center justify-center">
              <Icon icon="mdi:warehouse" width="18" class="text-primary" />
            </div>
            <div>
              <Dialog.Title class="text-lg font-bold text-foreground">Assign to Warehouse Units</Dialog.Title>
              <Dialog.Description class="text-xs text-muted-foreground mt-0.5">Assign "{selectedItemForAssign.model_description}" to one or more bin locations.</Dialog.Description>
            </div>
          </div>
        </div>
        <form onsubmit={submitAssignment} class="px-6 py-5 space-y-4">
          <!-- Assignment Rows -->
          <div class="space-y-3 max-h-[50vh] overflow-y-auto pr-1">
            {#each assignRows as row, idx (row.id)}
              <div class="relative border border-border rounded-xl p-4 bg-muted/20 space-y-3 transition-all">
                <!-- Row header with number and remove button -->
                <div class="flex items-center justify-between">
                  <span class="text-[10px] font-bold uppercase tracking-wider text-muted-foreground flex items-center gap-1.5">
                    <Icon icon="mdi:map-marker" width="13" class="text-primary" />
                    Location {idx + 1}
                  </span>
                  {#if assignRows.length > 1}
                    <button
                      type="button"
                      onclick={() => removeAssignRow(row.id)}
                      class="p-1 rounded-lg hover:bg-rose-100 dark:hover:bg-rose-500/20 text-muted-foreground hover:text-rose-600 transition-colors cursor-pointer"
                      title="Remove this location"
                    >
                      <Icon icon="mdi:close" width="14" />
                    </button>
                  {/if}
                </div>

                <!-- Unit selector -->
                <div class="flex flex-col gap-1.5">
                  <Label class="text-xs font-bold uppercase tracking-wider text-muted-foreground">Warehouse / Unit *</Label>
                  <SearchCombobox
                    options={assignUnitOptions}
                    value={row.unitId}
                    placeholder="Select Warehouse / Unit"
                    searchPlaceholder="Search unit..."
                    onchange={(v) => {
                      const unitId = typeof v === 'number' ? v : null;
                      assignRows = assignRows.map(r => r.id === row.id ? { ...r, unitId: unitId, binId: null, bins: [], loadingBins: false } : r);
                      if (unitId && unitId > 0) {
                        fetchBinsForRow(row.id, unitId);
                      }
                    }}
                  />
                </div>

                <!-- Bin selector -->
                <div class="flex flex-col gap-1.5">
                  <Label class="text-xs font-bold uppercase tracking-wider text-muted-foreground">Bin *</Label>
                  <SearchCombobox
                    options={getBinOptionsForRow(row)}
                    value={row.binId}
                    placeholder={row.loadingBins ? "Loading bins..." : row.bins.length === 0 ? "No empty bins available" : "Select Bin"}
                    searchPlaceholder="Search bin..."
                    disabled={row.loadingBins || row.bins.length === 0}
                    onchange={(v) => {
                      const binId = typeof v === 'number' ? v : null;
                      assignRows = assignRows.map(r => r.id === row.id ? { ...r, binId } : r);
                    }}
                  />
                </div>
              </div>
            {/each}
          </div>

          <!-- Add another location button -->
          <button
            type="button"
            onclick={addAssignRow}
            class="w-full flex items-center justify-center gap-2 py-2.5 px-4 rounded-xl border-2 border-dashed border-primary/30 text-primary text-sm font-semibold hover:bg-primary/5 hover:border-primary/50 transition-all cursor-pointer"
          >
            <Icon icon="mdi:plus-circle-outline" width="18" />
            Add Another Unit Location
          </button>

          <div class="flex justify-end gap-2 pt-4 border-t">
            <Button type="button" variant="outline" onclick={() => assignOpen = false} class="h-9 px-5">Cancel</Button>
            <Button type="submit" class="h-9 px-5 bg-primary hover:bg-primary/90 text-white" disabled={!allAssignRowsValid}>
              <Icon icon="mdi:check" width="16" class="mr-1" />
              Assign {assignRows.length > 1 ? `${assignRows.length} Locations` : 'Location'}
            </Button>
          </div>
        </form>
      {/if}
    </Dialog.Content>
  </Dialog.Root>

  <!-- Save/Update Item Confirmation Dialog -->
  <Dialog.Root bind:open={confirmSaveOpen}>
    <Dialog.Content class="sm:max-w-[400px] bg-card border rounded-2xl shadow-2xl p-6 overflow-hidden z-[110] text-center">
      <div class="flex flex-col items-center gap-4">
        <div class="w-12 h-12 rounded-full bg-amber-500/10 flex items-center justify-center text-amber-500">
          <Icon icon="mdi:alert-circle-outline" width="28" />
        </div>
        <div class="space-y-2">
          <Dialog.Title class="text-lg font-bold text-foreground">Confirm Action</Dialog.Title>
          <p class="text-sm text-muted-foreground">
            Are you sure you want to {selectedItemForEdit ? 'update' : 'save'} this item?
          </p>
        </div>
      </div>
      <div class="flex justify-center gap-3 mt-6 pt-4 border-t">
        <Button type="button" variant="outline" onclick={() => { confirmSaveOpen = false; pendingSavePayload = null; }}>Cancel</Button>
        <Button type="button" onclick={executeSaveItem} class="bg-primary hover:bg-primary/95 text-white">Yes, Confirm</Button>
      </div>
    </Dialog.Content>
  </Dialog.Root>

  <!-- Assign to Warehouse Confirmation Dialog -->
  <Dialog.Root bind:open={confirmAssignOpen}>
    <Dialog.Content class="sm:max-w-[400px] bg-card border rounded-2xl shadow-2xl p-6 overflow-hidden z-[110] text-center">
      <div class="flex flex-col items-center gap-4">
        <div class="w-12 h-12 rounded-full bg-amber-500/10 flex items-center justify-center text-amber-500">
          <Icon icon="mdi:alert-circle-outline" width="28" />
        </div>
        <div class="space-y-2">
          <Dialog.Title class="text-lg font-bold text-foreground">Confirm Assignment</Dialog.Title>
          <p class="text-sm text-muted-foreground">
            Are you sure you want to assign this item to {assignRows.filter(r => r.unitId && r.binId).length} warehouse location{assignRows.filter(r => r.unitId && r.binId).length > 1 ? 's' : ''}?
          </p>
        </div>
      </div>
      <div class="flex justify-center gap-3 mt-6 pt-4 border-t">
        <Button type="button" variant="outline" onclick={() => confirmAssignOpen = false}>Cancel</Button>
        <Button type="button" onclick={executeAssignment} class="bg-primary hover:bg-primary/95 text-white">Yes, Confirm</Button>
      </div>
    </Dialog.Content>
  </Dialog.Root>
  <!-- Success Dialog for newly created item -->
  <Dialog.Root bind:open={successDialogOpen}>
    <Dialog.Content class="sm:max-w-[420px] bg-card border border-border rounded-2xl shadow-2xl p-6 text-center">
      {#if newlyCreatedItem}
        <div class="flex flex-col items-center gap-4">
          <div class="w-12 h-12 rounded-full bg-emerald-500/10 flex items-center justify-center text-emerald-500 animate-bounce">
            <Icon icon="mdi:check-circle-outline" width="30" />
          </div>
          <div class="space-y-1.5">
            <Dialog.Title class="text-xl font-bold text-foreground">Item Created Successfully!</Dialog.Title>
            <p class="text-sm font-semibold text-primary">{newlyCreatedItem.model_description}</p>
          </div>

          <!-- QR Code Display -->
          {#if newlyCreatedItemBarcode}
            <div class="bg-white border rounded-xl p-4 shadow-sm flex flex-col items-center gap-2">
              <span class="text-[10px] font-bold uppercase tracking-wider text-muted-foreground">Item QR Code</span>
              <QRCodeDisplay text={newlyCreatedItemBarcode} size={140} />
              <span class="text-xs font-mono font-bold text-foreground">{newlyCreatedItemBarcode}</span>
            </div>
          {/if}
        </div>

        <div class="flex justify-center gap-3 mt-6 pt-4 border-t">
          {#if newlyCreatedItemBarcode}
            <Button 
              type="button" 
              onclick={() => printLabelForValue(newlyCreatedItemBarcode, newlyCreatedItem?.model_description ?? '')}
              class="bg-primary hover:bg-primary/95 text-white flex items-center gap-1.5 cursor-pointer"
            >
              <Icon icon="mdi:printer" width="16" />
              Print Label
            </Button>
          {/if}
          <Button type="button" variant="outline" onclick={() => successDialogOpen = false} class="cursor-pointer">Close</Button>
        </div>
      {/if}
    </Dialog.Content>
  </Dialog.Root>

  <!-- Download Labels Dialog -->
  <Dialog.Root bind:open={downloadLabelsModalOpen}>
    <Dialog.Content class="sm:max-w-[720px] max-h-[90vh] overflow-y-auto bg-card border border-border rounded-2xl shadow-2xl p-0 flex flex-col">
      <!-- Header -->
      <div class="bg-primary/5 border-b px-6 py-4 shrink-0 flex items-center justify-between">
        <div class="flex items-center gap-3">
          <div class="w-10 h-10 rounded-xl bg-primary/10 flex items-center justify-center text-primary">
            <Icon icon="mdi:download-box" width="22" />
          </div>
          <div>
            <Dialog.Title class="text-lg font-bold text-foreground">Download Labels</Dialog.Title>
            <Dialog.Description class="text-xs text-muted-foreground">Configure layout, select products, and specify label quantities.</Dialog.Description>
          </div>
        </div>
      </div>

      <!-- Body -->
      <div class="grid grid-cols-1 md:grid-cols-5 gap-6 p-6 overflow-y-auto">
        <!-- Left Panel: Configurations (2/5 cols) -->
        <div class="md:col-span-2 space-y-4 border-r border-border/60 pr-6">
          <h3 class="text-xs font-bold uppercase tracking-wider text-primary">Layout Options</h3>

          <!-- Code Type Select -->
          <div class="space-y-1.5">
            <Label class="text-xs font-bold uppercase tracking-wider text-muted-foreground">Visual Code Type</Label>
            <div class="grid grid-cols-2 gap-2">
              <button
                type="button"
                onclick={() => labelCodeType = 'barcode'}
                class="py-2.5 px-4 text-xs font-bold rounded-xl border transition-all flex items-center justify-center gap-2 cursor-pointer
                  {labelCodeType === 'barcode' ? 'bg-primary/10 border-primary text-primary font-extrabold' : 'bg-background hover:bg-muted/50 border-border text-muted-foreground'}"
              >
                <Icon icon="mdi:barcode" width="16" />
                Barcodes
              </button>
              <button
                type="button"
                onclick={() => labelCodeType = 'qrcode'}
                class="py-2.5 px-4 text-xs font-bold rounded-xl border transition-all flex items-center justify-center gap-2 cursor-pointer
                  {labelCodeType === 'qrcode' ? 'bg-primary/10 border-primary text-primary font-extrabold' : 'bg-background hover:bg-muted/50 border-border text-muted-foreground'}"
              >
                <Icon icon="mdi:qrcode" width="16" />
                QR Codes
              </button>
            </div>
          </div>

          <!-- Layout Grid Columns Selection -->
          <div class="space-y-1.5">
            <Label class="text-xs font-bold uppercase tracking-wider text-muted-foreground">Columns Per Row</Label>
            <div class="grid grid-cols-4 gap-2">
              {#each [1, 2, 3, 4] as colOption}
                <button
                  type="button"
                  onclick={() => labelCols = colOption}
                  class="py-2 px-3 text-xs font-bold rounded-xl border transition-all flex items-center justify-center gap-1.5 cursor-pointer
                    {labelCols === colOption ? 'bg-primary/10 border-primary text-primary font-extrabold' : 'bg-background hover:bg-muted/50 border-border text-muted-foreground'}"
                >
                  {colOption} Cols
                </button>
              {/each}
            </div>
          </div>

          <!-- Customizations Checkboxes -->
          <div class="space-y-2 pt-2">
            <Label class="text-xs font-bold uppercase tracking-wider text-muted-foreground">Additional Label Information</Label>
            
            <label class="flex items-center gap-2.5 text-xs text-foreground cursor-pointer select-none py-1">
              <input 
                type="checkbox" 
                bind:checked={labelIncludeDesc} 
                class="w-4 h-4 rounded border-border text-primary focus:ring-primary focus:ring-offset-background" 
              />
              <span>Include Item Description</span>
            </label>

            <label class="flex items-center gap-2.5 text-xs text-foreground cursor-pointer select-none py-1">
              <input 
                type="checkbox" 
                bind:checked={labelIncludePrice} 
                class="w-4 h-4 rounded border-border text-primary focus:ring-primary focus:ring-offset-background" 
              />
              <span>Include Selling Price</span>
            </label>
          </div>
        </div>

        <!-- Right Panel: Item Selection (3/5 cols) -->
        <div class="md:col-span-3 flex flex-col space-y-3">
          <div class="flex items-center justify-between">
            <h3 class="text-xs font-bold uppercase tracking-wider text-primary">Product Selection</h3>
            <div class="flex gap-2">
              <button 
                type="button" 
                onclick={selectAllItems}
                class="text-[10px] font-bold text-primary hover:underline cursor-pointer"
              >
                Select All
              </button>
              <span class="text-muted-foreground text-[10px]">•</span>
              <button 
                type="button" 
                onclick={deselectAllItems}
                class="text-[10px] font-bold text-muted-foreground hover:underline cursor-pointer"
              >
                Clear All
              </button>
            </div>
          </div>

          <!-- Search bar inside selector -->
          <div class="relative w-full">
            <Icon icon="mdi:magnify" width="16" class="absolute left-2.5 top-1/2 -translate-y-1/2 text-muted-foreground pointer-events-none" />
            <Input
              type="text"
              placeholder="Filter selection list..."
              bind:value={labelSearchQuery}
              class="pl-8 h-8 text-xs"
            />
          </div>

          <!-- Scrollable List of Items -->
          <div class="border border-border rounded-xl divide-y divide-border/60 overflow-y-auto max-h-[260px] bg-muted/10">
            {#each dialogFilteredItems as item (item.item_id)}
              {@const selection = labelItemSelections[item.item_id] || { selected: false, qty: 1 }}
              <div class="flex items-center justify-between p-2.5 hover:bg-muted/40 transition-colors">
                <label class="flex items-center gap-2.5 text-xs text-foreground cursor-pointer select-none max-w-[70%]">
                  <input 
                    type="checkbox" 
                    checked={selection.selected}
                    onchange={(e) => toggleSelection(item.item_id, e.currentTarget.checked)}
                    class="w-4 h-4 rounded border-border text-primary focus:ring-primary focus:ring-offset-background" 
                  />
                  <div class="truncate">
                    <span class="font-bold block truncate" title={item.model_description}>{item.model_description}</span>
                    <span class="text-[10px] text-muted-foreground font-mono truncate block">
                      {item.barcodes?.[0]?.barcode_value || 'No barcode'}
                    </span>
                  </div>
                </label>

                <!-- Quantity Input -->
                {#if selection.selected}
                  <div class="flex items-center gap-1.5">
                    <span class="text-[10px] text-muted-foreground">Qty:</span>
                    <input 
                      type="number" 
                      min="1" 
                      max="999"
                      value={selection.qty}
                      oninput={(e) => updateQty(item.item_id, parseInt(e.currentTarget.value) || 1)}
                      class="w-14 h-7 text-center text-xs border rounded-lg bg-background focus:ring-1 focus:ring-primary" 
                    />
                  </div>
                {/if}
              </div>
            {/each}
            {#if dialogFilteredItems.length === 0}
              <div class="p-6 text-center text-xs text-muted-foreground">
                No items match the search query.
              </div>
            {/if}
          </div>

          <!-- Total selection info -->
          <div class="text-[11px] text-muted-foreground flex justify-between pt-1 font-semibold">
            <span>Selected: {selectedItemsCount} product(s)</span>
            <span>Total Labels: {totalLabelsCount} pcs</span>
          </div>
        </div>
      </div>

      <!-- Footer -->
      <div class="flex justify-end gap-3 px-6 py-4 border-t shrink-0">
        <Button 
          type="button" 
          variant="outline" 
          onclick={() => downloadLabelsModalOpen = false} 
          class="cursor-pointer"
        >
          Cancel
        </Button>
        <Button 
          type="button" 
          onclick={() => {
            downloadLabelsModalOpen = false;
            generateAllLabels(labelCodeType, labelCols, labelIncludeDesc, labelIncludePrice);
          }} 
          class="bg-primary hover:bg-primary/95 text-white flex items-center gap-1.5 cursor-pointer"
          disabled={generatingLabels || selectedItemsCount === 0}
        >
          <Icon icon="mdi:printer-pos" width="16" />
          Generate Sheet
        </Button>
      </div>
    </Dialog.Content>
  </Dialog.Root>
</div>

<BarcodeScanner bind:open={barcodeScannerOpen} onscan={searchByBarcode} />
