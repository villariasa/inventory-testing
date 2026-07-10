<script lang="ts">
  import type { InventoryItem, ItemCategory } from '$lib/types';
  import * as Dialog from '$lib/components/ui/dialog/index.js';
  import { Button } from '$lib/components/ui/button/index.js';
  import { Input } from '$lib/components/ui/input/index.js';
  import { Label } from '$lib/components/ui/label/index.js';
  import SearchCombobox from '$lib/components/ui/SearchCombobox.svelte';
  import { invokeService } from '$lib/service/invokeService';
  import { toast } from 'svelte-sonner';
  import Icon from '@iconify/svelte';
  import BarcodeScanner from './BarcodeScanner.svelte';

  let {
    open = $bindable(false),
    item = null,
    categories = [],
    activeCategoryId = null,
    token = '',
    initialBarcode = '',
    onsave = () => {}
  } = $props<{
    open: boolean;
    item: InventoryItem | null;
    categories: ItemCategory[];
    activeCategoryId?: number | null;
    token?: string;
    initialBarcode?: string;
    onsave: (data: Partial<InventoryItem>) => void;
  }>();

  // Tab State
  let currentTab = $state<'info' | 'pricing'>('info');

  // Local form state variables
  let item_category_id = $state(0);
  let brand_id = $state<number | null>(null);
  let size_id = $state<number | null>(null);
  let part_id = $state<number | null>(null);
  let part_number_id = $state<number | null>(null);

  let model_description = $state('');
  let barcode = $state('');
  let barcodeScannerOpen = $state(false);
  let stocking_unit = $state('BOX');
  let retail_unit = $state('PC');
  let rtu_over_stu = $state(1);

  // Pricing mode and formulas
  let priceType = $state<'markup' | 'selling'>('markup');
  let wtd_ave_cost = $state(0); // Base Cost
  let fixed_price = $state(0); // Fixed Price
  let mark_up_rate = $state(0); // Markup Rate (%)

  let last_highest_in_unit_cost = $state(0);
  let has_empty_case = $state(0);
  let imageBase64 = $state<string | null>(null);
  let isProcessingImage = $state(false);
  let imageProcessingPromise = $state<Promise<void> | null>(null);

  // Comma auto-formatting for pricing inputs
  let costInputStr = $state('');
  let fixedPriceInputStr = $state('');

  function formatInputWithCommas(val: string): string {
    // Remove commas
    let clean = val.replace(/,/g, '');
    // Strip everything else except digits and single dot
    clean = clean.replace(/[^\d.]/g, '');
    
    const dotIndex = clean.indexOf('.');
    if (dotIndex !== -1) {
      let before = clean.substring(0, dotIndex);
      let after = clean.substring(dotIndex + 1).replace(/\./g, ''); // Remove subsequent dots
      
      if (before) {
        const num = parseFloat(before);
        if (!isNaN(num)) {
          before = num.toLocaleString('en-US');
        }
      }
      return before + '.' + after;
    } else {
      if (!clean) return '';
      const num = parseFloat(clean);
      if (isNaN(num)) return '';
      return num.toLocaleString('en-US');
    }
  }

  function handleCostInput(e: Event) {
    const input = e.currentTarget as HTMLInputElement;
    const selectionStart = input.selectionStart;
    const origLen = input.value.length;
    
    const formatted = formatInputWithCommas(input.value);
    costInputStr = formatted;
    
    const numeric = parseFloat(formatted.replace(/,/g, ''));
    wtd_ave_cost = isNaN(numeric) ? 0 : numeric;
    
    setTimeout(() => {
      const newLen = formatted.length;
      if (selectionStart !== null) {
        input.setSelectionRange(selectionStart + (newLen - origLen), selectionStart + (newLen - origLen));
      }
    }, 0);
  }

  function handleFixedPriceInput(e: Event) {
    const input = e.currentTarget as HTMLInputElement;
    const selectionStart = input.selectionStart;
    const origLen = input.value.length;
    
    const formatted = formatInputWithCommas(input.value);
    fixedPriceInputStr = formatted;
    
    const numeric = parseFloat(formatted.replace(/,/g, ''));
    fixed_price = isNaN(numeric) ? 0 : numeric;
    
    setTimeout(() => {
      const newLen = formatted.length;
      if (selectionStart !== null) {
        input.setSelectionRange(selectionStart + (newLen - origLen), selectionStart + (newLen - origLen));
      }
    }, 0);
  }

  let fileInput: HTMLInputElement;

  // Autocomplete lists from API
  type Option = { value: number; label: string };
  let brands = $state<Option[]>([]);
  let sizes = $state<Option[]>([]);
  let vehicleParts = $state<Option[]>([]); // Part Description
  let vehiclePartNumbers = $state<Option[]>([]); // Part Number

  let importsLoaded = $state(false);

  // Video Camera dialog states
  let cameraOpen = $state(false);
  let viewFullImageOpen = $state(false);
  let videoEl = $state<HTMLVideoElement | null>(null);
  let mediaStream = $state<MediaStream | null>(null);
  let cameraFacingMode = $state<'user' | 'environment'>('environment');

  // Fetch all autocomplete imports
  async function loadImports() {
    if (importsLoaded) return;
    const types = [
      { key: 'brand', stateSetter: (data: Option[]) => brands = data },
      { key: 'size', stateSetter: (data: Option[]) => sizes = data },
      { key: 'vehiclePart', stateSetter: (data: Option[]) => vehicleParts = data },
      { key: 'vehiclePartNumber', stateSetter: (data: Option[]) => vehiclePartNumbers = data }
    ];

    try {
      await Promise.all(
        types.map(async ({ key, stateSetter }) => {
          const res = await invokeService<any, any>('/get-item-imports', {
            body: { import_type: key, bol_getone: 0, id: 0, description: '' },
            token
          });
          if ('data' in res && res.data.success) {
            const list = (res.data?.data?.json_data ?? []).map((b: { id: number; description: string }) => ({
              value: b.id,
              label: b.description
            }));
            stateSetter(list);
          }
        })
      );
      importsLoaded = true;
    } catch (err) {
      console.error('Failed to load item imports:', err);
    }
  }

  // Sync state when open changes or item changes
  $effect(() => {
    if (open) {
      currentTab = 'info'; // Reset to first tab on open
      loadImports();
      if (item) {
        console.log(item)
        // Edit mode
        item_category_id = item.item_category_id;
        brand_id = item.brand_id ?? null;
        size_id = item.size_id ?? null;
        part_id = item.part_id ?? null;
        part_number_id = item.part_number_id ?? null;
        
        model_description = item.model_description;
        stocking_unit = item.stocking_unit;
        retail_unit = item.retail_unit;
        rtu_over_stu = item.rtu_over_stu;
        wtd_ave_cost = item.wtd_ave_cost;
        mark_up_rate = item.markup_rate;
        has_empty_case = item.is_empty_case ?? item.has_empty_case ?? 0;
        imageBase64 = item.image ?? null;
        last_highest_in_unit_cost = item.last_highest_in_unit_cost ?? 0.00;

        const barcodeList = item.barcodes || [];
        const scannedBc = barcodeList.find((b: any) => b.barcode_type === 'SCANNED');
        const internalBc = barcodeList[0];
        barcode = scannedBc?.barcode_value || internalBc?.barcode_value || '';
        
        // Setup pricing values
        priceType = 'markup';
        fixed_price = item.selling_price || 0;
        costInputStr = item.wtd_ave_cost ? formatInputWithCommas(String(item.wtd_ave_cost)) : '';
        fixedPriceInputStr = fixed_price ? formatInputWithCommas(String(fixed_price)) : '';
      } else {
        // Add mode
        item_category_id = (activeCategoryId && activeCategoryId !== 0) ? activeCategoryId : (categories[0]?.item_category_id ?? 0);
        brand_id = null;
        size_id = null;
        part_id = null;
        part_number_id = null;
        
        model_description = '';
        stocking_unit = 'BOX';
        retail_unit = 'PC';
        rtu_over_stu = 1;
        wtd_ave_cost = 0;
        fixed_price = 0;
        mark_up_rate = 0;
        has_empty_case = 0;
        imageBase64 = null;
        last_highest_in_unit_cost = 0.00;
        priceType = 'markup';
        barcode = initialBarcode || '';
        costInputStr = '';
        fixedPriceInputStr = '';
      }
    }
  });

  // Automatically clear Fixed Price in markup mode
  $effect(() => {
    if (priceType === 'markup') {
      fixed_price = 0;
      fixedPriceInputStr = '';
    }
  });

  // Calculate selling price reactively based on priceType
  let selling_price = $derived.by(() => {
    if (priceType === 'markup') {
      return Math.round((wtd_ave_cost + (wtd_ave_cost * mark_up_rate / 100)) * 100) / 100;
    } else {
      return Math.round((fixed_price + (fixed_price * mark_up_rate / 100)) * 100) / 100;
    }
  });

  // Suffix helper for No. RTU/STU
  let rtuOverStuSuffix = $derived.by(() => {
    const r = (retail_unit || '').trim();
    const s = (stocking_unit || '').trim();
    if (!r && !s) return 'per unit';
    return `${r || 'units'} per ${s || 'unit'}`;
  });

  // Category options derived
  let categoryOptions = $derived(
    categories.map((c: any) => ({ value: c.item_category_id, label: c.description ?? c.item_category_description ?? '' }))
  );

  // Tab validation logic
  function validateInfoTab(): boolean {
    if (!model_description.trim()) {
      toast.error('Item description / model name is required.');
      return false;
    }
    if (!stocking_unit.trim()) {
      toast.error('Stocking Unit is required.');
      return false;
    }
    if (!retail_unit.trim()) {
      toast.error('Retail Unit is required.');
      return false;
    }
    if (!rtu_over_stu || rtu_over_stu < 1) {
      toast.error('No. RTU/STU ratio must be at least 1.');
      return false;
    }
    return true;
  }

  function handleTabSwitch(tab: 'info' | 'pricing') {
    if (tab === 'pricing') {
      if (!validateInfoTab()) return;
    }
    currentTab = tab;
  }

  // Background removal — executed inside Web Worker (bg-removal.worker.ts)
  // Runs 100% in a separate thread. Never blocks the main UI thread.
  let worker: Worker | null = null;
  let activeToastId: string | number;
  let originalImageSrc = '';
  let resolveProcessing: (() => void) | null = null;

  $effect(() => {
    if (open) {
      import('./bg-removal.worker?worker').then((module) => {
        const BgWorker = module.default;
        worker = new BgWorker();
        
        // Start preloading the model inside the worker
        worker.postMessage({ type: 'preload' });

        // Handle worker responses
        worker.onmessage = (e) => {
          const { type, imageBase64: finalBase64, error } = e.data;
          if (type === 'process-success') {
            imageBase64 = finalBase64;
            toast.success('Background removed!', { id: activeToastId });
            isProcessingImage = false;
            if (resolveProcessing) {
              resolveProcessing();
              resolveProcessing = null;
            }
          } else if (type === 'process-error') {
            console.error('[bg-removal worker] failed:', error);
            imageBase64 = originalImageSrc;
            toast.dismiss(activeToastId);
            isProcessingImage = false;
            if (resolveProcessing) {
              resolveProcessing();
              resolveProcessing = null;
            }
          }
        };
      }).catch(err => console.warn('[bg-removal worker] load failed:', err));
    }

    return () => {
      if (worker) {
        worker.terminate();
        worker = null;
      }
    };
  });

  async function processImageBackground(imageSrc: string) {
    if (!imageSrc) return;
    
    if (!worker) {
      imageBase64 = imageSrc;
      return;
    }

    isProcessingImage = true;
    originalImageSrc = imageSrc;
    activeToastId = toast.loading('Removing background...');

    const promise = new Promise<void>((resolve) => {
      resolveProcessing = resolve;
    });
    imageProcessingPromise = promise;

    // Send the image to the worker
    worker.postMessage({ type: 'process', imageSrc });

    return promise;
  }

  // Image upload handler
  function handleFileChange(e: Event) {
    const target = e.target as HTMLInputElement;
    if (target.files && target.files[0]) {
      const file = target.files[0];
      const reader = new FileReader();
      reader.onload = () => {
        processImageBackground(reader.result as string);
      };
      reader.readAsDataURL(file);
    }
  }

  // Clipboard paste listener handler
  function handlePaste(e: ClipboardEvent) {
    if (!open || isProcessingImage) return;
    const items = e.clipboardData?.items;
    if (!items) return;
    for (let i = 0; i < items.length; i++) {
      if (items[i].type.indexOf('image') !== -1) {
        const file = items[i].getAsFile();
        if (file) {
          const reader = new FileReader();
          reader.onload = () => {
            toast.success('Image pasted from clipboard.');
            processImageBackground(reader.result as string);
          };
          reader.readAsDataURL(file);
        }
        break;
      }
    }
  }

  $effect(() => {
    if (open) {
      window.addEventListener('paste', handlePaste);
    }
    return () => {
      window.removeEventListener('paste', handlePaste);
    };
  });

  // HTML5 Webcam Capture functions
  let hasTorch = $state(false);
  let torchOn = $state(false);

  function detectTorchSupport() {
    if (!mediaStream) return;
    const track = mediaStream.getVideoTracks()[0];
    if (track) {
      try {
        const capabilities = track.getCapabilities() as any;
        hasTorch = !!capabilities.torch;
      } catch (e) {
        hasTorch = false;
      }
    }
  }

  async function toggleTorch() {
    if (!mediaStream) return;
    const track = mediaStream.getVideoTracks()[0];
    if (!track) return;
    try {
      torchOn = !torchOn;
      await track.applyConstraints({
        advanced: [{ torch: torchOn }]
      } as any);
    } catch (err) {
      console.warn("Failed to toggle torch:", err);
      toast.error("Flashlight is not supported on this camera.");
      torchOn = false;
    }
  }

  async function startCamera() {
    cameraOpen = true;
    hasTorch = false;
    torchOn = false;
    try {
      setTimeout(async () => {
        mediaStream = await navigator.mediaDevices.getUserMedia({
          video: { width: { ideal: 1920 }, height: { ideal: 1080 }, facingMode: { ideal: cameraFacingMode } }
        });
        if (videoEl) {
          videoEl.srcObject = mediaStream;
          videoEl.play();
          detectTorchSupport();
        }
      }, 100);
    } catch (err) {
      console.error('Failed to open camera:', err);
      toast.error('Could not access camera. Please check permissions.');
      cameraOpen = false;
    }
  }

  async function toggleCameraFacingMode() {
    cameraFacingMode = cameraFacingMode === 'user' ? 'environment' : 'user';
    hasTorch = false;
    torchOn = false;
    if (mediaStream) {
      mediaStream.getTracks().forEach(track => track.stop());
      mediaStream = null;
      try {
        mediaStream = await navigator.mediaDevices.getUserMedia({
          video: { width: { ideal: 1920 }, height: { ideal: 1080 }, facingMode: { ideal: cameraFacingMode } }
        });
        if (videoEl) {
          videoEl.srcObject = mediaStream;
          videoEl.play();
          detectTorchSupport();
        }
        toast.success(`Switched to ${cameraFacingMode === 'user' ? 'front' : 'back'} camera.`);
      } catch (err) {
        console.error('Failed to switch camera facing mode:', err);
        toast.error('Could not switch camera. Check if device supports it.');
        cameraFacingMode = cameraFacingMode === 'user' ? 'environment' : 'user';
      }
    }
  }

  function stopCamera() {
    if (mediaStream) {
      mediaStream.getTracks().forEach(track => track.stop());
      mediaStream = null;
    }
    cameraOpen = false;
    hasTorch = false;
    torchOn = false;
  }

  $effect(() => {
    if (!cameraOpen && mediaStream) {
      stopCamera();
    }
  });

  function capturePhoto() {
    if (!videoEl) return;
    const canvas = document.createElement('canvas');
    canvas.width = videoEl.videoWidth || 640;
    canvas.height = videoEl.videoHeight || 480;
    const ctx = canvas.getContext('2d');
    if (ctx) {
      ctx.drawImage(videoEl, 0, 0, canvas.width, canvas.height);
      const photoBase64 = canvas.toDataURL('image/jpeg');
      toast.success('Photo captured successfully.');
      processImageBackground(photoBase64);
    }
    stopCamera();
  }

  async function generateRandomBarcode() {
    const toastId = toast.loading('Generating unique barcode...');
    try {
      const res = await invokeService<any, any>('/get-inventory-item', {
        body: { 
          bol_getone: 0, 
          item_category_id: 0, 
          item_id: 0, 
          item_description: '',
          bypass_image_filter: true
        },
        token
      });

      const existingBarcodes = new Set<string>();
      if ('data' in res && res.data.success) {
        const dbItems = res.data.data?.json_data || [];
        dbItems.forEach((dbItem: any) => {
          if (dbItem.barcode) {
            existingBarcodes.add(dbItem.barcode.trim());
          }
          if (dbItem.barcodes) {
            dbItem.barcodes.forEach((b: any) => {
              if (b.barcode_value) {
                existingBarcodes.add(b.barcode_value.trim());
              }
            });
          }
        });
      }

      const generateRandom13 = () => {
        let code = '';
        for (let i = 0; i < 13; i++) {
          code += Math.floor(Math.random() * 10).toString();
        }
        return code;
      };

      const isPatternNumber = (code: string): boolean => {
        if (/^(\d)\1+$/.test(code)) return true;

        const ascending = '01234567890123456789';
        if (ascending.includes(code)) return true;
        const descending = '98765432109876543210';
        if (descending.includes(code)) return true;

        for (let len = 2; len <= 4; len++) {
          const chunk = code.substring(0, len);
          let match = true;
          for (let i = 0; i < code.length; i += len) {
            const part = code.substring(i, Math.min(i + len, code.length));
            if (!chunk.startsWith(part)) {
              match = false;
              break;
            }
          }
          if (match) return true;
        }

        return false;
      };

      let newBarcode = '';
      let attempts = 0;
      const maxAttempts = 1000;
      do {
        newBarcode = generateRandom13();
        attempts++;
      } while ((isPatternNumber(newBarcode) || existingBarcodes.has(newBarcode)) && attempts < maxAttempts);

      if (attempts >= maxAttempts) {
        throw new Error('Could not generate a unique barcode. Please try again.');
      }

      barcode = newBarcode;
      toast.success(`Generated unique barcode: ${newBarcode}`, { id: toastId });
    } catch (err: any) {
      console.error('Failed to generate unique barcode:', err);
      toast.error(err.message || 'Failed to generate unique barcode', { id: toastId });
    }
  }

  async function triggerSubmit(e: Event) {
    e.preventDefault();
    if (!validateInfoTab()) return;

    if (isProcessingImage && imageProcessingPromise) {
      const waitToastId = toast.loading('Finishing background removal...');
      try {
        await imageProcessingPromise;
      } catch (err) {
        console.warn('Awaiting background removal failed, saving anyway:', err);
      } finally {
        toast.dismiss(waitToastId);
      }
    }

    onsave({
      item_id: item ? item.item_id : 0,
      item_category_id,
      brand_id,
      size_id,
      part_id,
      part_number_id,
      valve_id: null,
      ratio_id: null,
      pattern_id: null,
      model_description,
      stocking_unit,
      retail_unit,
      rtu_over_stu,
      wtd_ave_cost: priceType === 'markup' ? wtd_ave_cost : 0,
      mark_up_rate,
      selling_price,
      has_empty_case,
      last_highest_in_unit_cost,
      image: imageBase64,
      barcode: barcode.trim() || null
    });
  }
</script>

<Dialog.Root bind:open>
  <Dialog.Content
    onInteractOutside={(e) => e.preventDefault()}
    onEscapeKeydown={(e) => {
      if (viewFullImageOpen) {
        viewFullImageOpen = false;
        e.preventDefault();
      } else if (cameraOpen) {
        stopCamera();
        e.preventDefault();
      } else {
        e.preventDefault();
      }
    }}
    class="sm:max-w-[650px] max-h-[90vh] overflow-y-auto bg-card border rounded-2xl shadow-2xl p-0 flex flex-col"
  >
    <!-- Header -->
    <div class="bg-primary/5 border-b px-6 py-4 shrink-0">
      <Dialog.Header>
        <Dialog.Title class="text-xl font-bold font-playfair text-primary">
          {item ? 'Edit Inventory Item' : 'Add New Inventory Item'}
        </Dialog.Title>
        <Dialog.Description class="text-xs text-muted-foreground mt-0.5">
          Provide complete details below. Step 1 handles basic specifications, Step 2 handles pricing.
        </Dialog.Description>
      </Dialog.Header>
    </div>

    <!-- Step Tabs Header -->
    <div class="flex border-b border-border bg-muted/40 p-1.5 gap-2 shrink-0">
      <button
        type="button"
        onclick={() => handleTabSwitch('info')}
        class="flex-1 py-2.5 text-xs font-bold uppercase tracking-wider rounded-xl transition-all flex items-center justify-center gap-1.5
          {currentTab === 'info' ? 'bg-background shadow-md text-primary font-extrabold border border-border/10' : 'text-muted-foreground hover:text-foreground hover:bg-background/20'}"
      >
        <Icon icon="mdi:form-select" width="16" />
        1. General Info
      </button>
      <button
        type="button"
        onclick={() => handleTabSwitch('pricing')}
        class="flex-1 py-2.5 text-xs font-bold uppercase tracking-wider rounded-xl transition-all flex items-center justify-center gap-1.5
          {currentTab === 'pricing' ? 'bg-background shadow-md text-primary font-extrabold border border-border/10' : 'text-muted-foreground hover:text-foreground hover:bg-background/20'}"
      >
        <Icon icon="mdi:finance" width="16" />
        2. Pricing & Valuation
      </button>
    </div>

    <!-- Scrollable Form Body -->
    <form onsubmit={triggerSubmit} class="p-6 space-y-6 overflow-y-auto flex-1">
      {#if currentTab === 'info'}
        <!-- ─── GENERAL INFO TAB ─── -->

        <!-- Media Section: Rectangular Upload and Webcam Button -->
        <div class="flex flex-col items-center justify-center gap-3 pb-6 border-b">
          <div class="relative">
            <div
              role="button"
              tabindex="0"
              onclick={() => fileInput.click()}
              onkeydown={(e) => e.key === 'Enter' && fileInput.click()}
              class="w-48 h-32 rounded-xl border-2 border-dashed border-primary/40 hover:border-primary transition-all overflow-hidden flex items-center justify-center cursor-pointer bg-muted/40 relative group shadow-sm"
              title="Click to upload image or paste image (Ctrl+V)"
            >
              {#if imageBase64}
                <img src={imageBase64} alt="Preview" class="w-full h-full object-contain p-1 {isProcessingImage ? 'opacity-40' : ''}" />
                <div class="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 flex items-center justify-center transition-opacity text-white text-[10px] font-bold">
                  Change Photo
                </div>
              {:else}
                <div class="text-center p-2 text-muted-foreground {isProcessingImage ? 'opacity-40' : ''}">
                  <Icon icon="mdi:camera-plus-outline" width="26" class="mx-auto mb-1 text-primary/60" />
                  <span class="text-[9px] font-bold block uppercase tracking-wider">Upload / Paste</span>
                </div>
              {/if}
              {#if isProcessingImage}
                <div class="absolute inset-0 bg-black/20 flex flex-col items-center justify-center gap-1.5 z-10 rounded-xl">
                  <Icon icon="mdi:loading" class="animate-spin text-primary" width="28" />
                  <span class="text-[9px] font-black uppercase tracking-wider text-slate-800 dark:text-slate-200 bg-white/70 dark:bg-slate-900/70 px-1.5 py-0.5 rounded">AI Processing...</span>
                </div>
              {/if}
            </div>
            {#if imageBase64}
              <button
                type="button"
                onclick={() => imageBase64 = null}
                class="absolute -top-1 -right-1 bg-rose-500 hover:bg-rose-600 text-white rounded-full p-1 shadow-md transition-colors"
                title="Remove photo"
              >
                <Icon icon="mdi:close" width="12" />
              </button>
              <button
                type="button"
                onclick={(e) => { e.stopPropagation(); viewFullImageOpen = true; }}
                class="absolute bottom-1 right-1 bg-black/60 hover:bg-black/85 text-white rounded-lg p-1.5 shadow-md transition-colors flex items-center justify-center"
                title="View full image"
              >
                <Icon icon="mdi:eye" width="14" />
              </button>
            {/if}
          </div>
          <div class="flex gap-2">
            <Button type="button" variant="outline" size="sm" class="h-8 text-xs flex items-center gap-1.5" onclick={() => fileInput.click()}>
              <Icon icon="mdi:upload" width="15" />
              Upload File
            </Button>
            <Button type="button" variant="outline" size="sm" class="h-8 text-xs flex items-center gap-1.5 text-teal-600 hover:text-teal-700 hover:bg-teal-50 border-teal-200 shadow-sm" onclick={startCamera}>
              <Icon icon="mdi:camera" width="15" />
              Take Photo
            </Button>
          </div>
          <input
            type="file"
            bind:this={fileInput}
            accept="image/*"
            onchange={handleFileChange}
            class="hidden"
          />
        </div>

        <!-- Specifications Autocompletes -->
        <div class="bg-muted/20 border rounded-xl p-4 space-y-4">
          <h3 class="text-xs font-bold uppercase tracking-wider text-primary">Category & Specifications</h3>
          <div class="grid grid-cols-2 gap-4">
            <!-- Category (Pre-populated & Disabled when editing) -->
            <div class="flex flex-col gap-1.5">
              <Label class="text-xs font-semibold text-muted-foreground">Category *</Label>
              <SearchCombobox
                options={categoryOptions}
                bind:value={item_category_id}
                placeholder="Select category..."
                searchPlaceholder="Search category..."
                disabled={item !== null}
              />
            </div>

            <!-- Brand (Optional) -->
            <div class="flex flex-col gap-1.5">
              <Label class="text-xs font-semibold text-muted-foreground">Brand</Label>
              <SearchCombobox
                options={brands}
                bind:value={brand_id}
                placeholder="Select brand..."
                searchPlaceholder="Search brand..."
              />
            </div>

            <!-- Size (Optional) -->
            <div class="flex flex-col gap-1.5">
              <Label class="text-xs font-semibold text-muted-foreground">Size</Label>
              <SearchCombobox
                options={sizes}
                bind:value={size_id}
                placeholder="Select size..."
                searchPlaceholder="Search size..."
              />
            </div>

            <!-- Part Description (Optional) -->
            <div class="flex flex-col gap-1.5">
              <Label class="text-xs font-semibold text-muted-foreground">Part Description</Label>
              <SearchCombobox
                options={vehicleParts}
                bind:value={part_id}
                placeholder="Select part desc..."
                searchPlaceholder="Search part desc..."
              />
            </div>

            <!-- Part Number (Optional) -->
            <div class="flex flex-col gap-1.5 flex-1 min-w-0">
              <Label class="text-xs font-semibold text-muted-foreground">Part Number</Label>
              <SearchCombobox
                options={vehiclePartNumbers}
                bind:value={part_number_id}
                placeholder="Select part number..."
                searchPlaceholder="Search part number..."
              />
            </div>
          </div>
        </div>

        <!-- Core Details -->
        <div class="space-y-4">
          <!-- Barcode Field -->
          <div class="flex flex-col gap-1.5">
            <Label for="barcode" class="text-xs font-bold uppercase tracking-wider text-muted-foreground">Barcode / UPC</Label>
            <div class="flex gap-2">
              <Input
                type="text"
                id="barcode"
                placeholder="Scan or enter barcode value (optional)"
                bind:value={barcode}
                class="h-10 text-sm font-semibold"
              />
              <Button type="button" onclick={generateRandomBarcode} class="bg-teal-500/10 hover:bg-teal-500/20 text-teal-600 dark:text-teal-400 flex items-center gap-1.5 shrink-0">
                <Icon icon="mdi:generator-portable" width="18" />
                Generate
              </Button>
              <Button type="button" onclick={() => barcodeScannerOpen = true} class="bg-primary/10 hover:bg-primary/20 text-primary flex items-center gap-1.5 shrink-0">
                <Icon icon="mdi:barcode-scan" width="18" />
                Scan
              </Button>
            </div>
          </div>

          <div class="flex flex-col gap-1.5">
            <Label for="model" class="text-xs font-bold uppercase tracking-wider text-muted-foreground">Item Description / Model Name *</Label>
            <Input
              type="text"
              id="model"
              placeholder="e.g. Michelin Pilot Sport 4"
              bind:value={model_description}
              required
              class="h-10 text-sm font-semibold"
            />
          </div>

          <div class="grid grid-cols-3 gap-4">
            <!-- Stocking Unit -->
            <div class="flex flex-col gap-1.5">
              <Label for="stocking_unit" class="text-xs font-semibold text-muted-foreground">Stocking Unit *</Label>
              <Input
                type="text"
                id="stocking_unit"
                placeholder="e.g. BOX, CASE"
                bind:value={stocking_unit}
                required
              />
            </div>

            <!-- Retail Unit -->
            <div class="flex flex-col gap-1.5">
              <Label for="retail_unit" class="text-xs font-semibold text-muted-foreground">Retail Unit *</Label>
              <Input
                type="text"
                id="retail_unit"
                placeholder="e.g. PC, BOTTLE"
                bind:value={retail_unit}
                required
              />
            </div>

            <!-- Ratio Qty -->
            <div class="flex flex-col gap-1.5">
              <Label for="rtu_over_stu" class="text-xs font-semibold text-muted-foreground">No. RTU/STU *</Label>
              <div class="relative flex items-center min-w-0">
                <Input
                  type="number"
                  id="rtu_over_stu"
                  min="1"
                  bind:value={rtu_over_stu}
                  required
                  class="pr-28"
                />
                <span class="absolute right-3 text-[10px] font-bold text-muted-foreground pointer-events-none select-none bg-background px-1 truncate max-w-[95px]">
                  {rtuOverStuSuffix}
                </span>
              </div>
            </div>
          </div>

          <!-- Has Empty Case and Checkbox -->
          <div class="flex items-center gap-2 pt-2">
            <input
                type="checkbox"
                id="has_empty_case"
                checked={has_empty_case > 0}
                onchange={(e) => has_empty_case = e.currentTarget.checked ? 1 : 0}
                class="size-4 rounded border-border text-primary focus:ring-primary cursor-pointer"
              />
            <Label for="has_empty_case" class="text-xs font-semibold text-muted-foreground cursor-pointer select-none">Has Empty Case / Shell</Label>
          </div>
        </div>

        <!-- Footer Actions for Info Tab -->
        <div class="flex justify-end gap-2 pt-4 border-t shrink-0">
          <Button type="button" variant="outline" onclick={() => open = false}>Cancel</Button>
          <Button type="button" class="bg-primary hover:bg-primary/95 text-white flex items-center gap-1.5" onclick={() => handleTabSwitch('pricing')}>
            Next: Pricing & Valuation
            <Icon icon="mdi:arrow-right" width="16" />
          </Button>
        </div>

      {:else if currentTab === 'pricing'}
        <!-- ─── PRICING TAB ─── -->

        <div class="bg-muted/20 border rounded-xl p-6 space-y-6">
          <div class="flex items-center justify-between border-b pb-3">
            <h3 class="text-xs font-bold uppercase tracking-wider text-primary">Pricing & Financials</h3>
            <div class="flex items-center gap-1 bg-muted p-0.5 rounded-lg border text-xs">
              <button
                type="button"
                onclick={() => priceType = 'markup'}
                class="px-3 py-1.5 rounded-md transition-all font-semibold {priceType === 'markup' ? 'bg-background shadow text-primary' : 'text-muted-foreground'}"
              >
                Markup mode
              </button>
              <button
                type="button"
                onclick={() => priceType = 'selling'}
                class="px-3 py-1.5 rounded-md transition-all font-semibold {priceType === 'selling' ? 'bg-background shadow text-primary' : 'text-muted-foreground'}"
              >
                Selling mode
              </button>
            </div>
          </div>

          <div class="grid grid-cols-2 gap-4">
            <!-- Base Cost -->
            <div class="flex flex-col gap-1.5">
              <Label for="cost" class="text-xs font-semibold text-muted-foreground">Base Cost (₱) *</Label>
              <Input
                type="text"
                id="cost"
                placeholder="0.00"
                value={costInputStr}
                oninput={handleCostInput}
                disabled={priceType === 'selling'}
                required
              />
            </div>

            <!-- Fixed Selling Price -->
            <div class="flex flex-col gap-1.5">
              <Label for="fixed_price" class="text-xs font-semibold text-muted-foreground">Fixed Price (₱) *</Label>
              <Input
                type="text"
                id="fixed_price"
                placeholder="0.00"
                value={fixedPriceInputStr}
                oninput={handleFixedPriceInput}
                disabled={priceType === 'markup'}
                required
              />
            </div>

            <!-- Markup rate percentage -->
            <div class="flex flex-col gap-1.5">
              <Label for="markup" class="text-xs font-semibold text-muted-foreground">Markup Rate (%) *</Label>
              <Input
                type="number"
                id="markup"
                step="0.01"
                min="0"
                bind:value={mark_up_rate}
                required
              />
            </div>

            <!-- Calculated read-only Selling Price -->
            <div class="flex flex-col gap-1.5">
              <Label for="price" class="text-xs font-semibold text-muted-foreground font-bold text-primary">Final Price (₱)</Label>
              <Input
                type="text"
                id="price"
                value={selling_price ? selling_price.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) : '0.00'}
                class="bg-teal-50 border-teal-200 font-mono font-bold text-teal-700"
                readonly
              />
            </div>

            <!-- Last Highest In-Unit Cost -->
            <div class="flex flex-col gap-1.5">
              <Label for="last_highest_cost" class="text-xs font-semibold text-muted-foreground">Last Highest In-Unit Cost (₱)</Label>
              <Input
                type="text"
                id="last_highest_cost"
                value={last_highest_in_unit_cost ? last_highest_in_unit_cost.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) : '0.00'}
                class="bg-muted font-mono font-bold text-foreground/70"
                readonly
              />
            </div>
          </div>
        </div>

        <!-- Footer Actions for Pricing Tab -->
        <div class="flex justify-end gap-2 pt-4 border-t shrink-0">
          <Button type="button" variant="outline" onclick={() => handleTabSwitch('info')} class="flex items-center gap-1.5">
            <Icon icon="mdi:arrow-left" width="16" />
            Back to Info
          </Button>
          <Button type="submit" variant="default" class="bg-primary hover:bg-primary/95 text-white flex items-center gap-1.5">
            {#if isProcessingImage}
              <Icon icon="mdi:loading" class="animate-spin" width="18" />
              Processing Image...
            {:else}
              <Icon icon="mdi:check" width="18" />
              Save Item
            {/if}
          </Button>
        </div>
      {/if}
    </form>

    <!-- Camera Dialog Overlay -->
    {#if cameraOpen}
      <div 
        class="fixed inset-0 z-[200] flex flex-col bg-black animate-in fade-in"
        onpointerdown={(e) => e.stopPropagation()}
      >
        <!-- Viewfinder video -->
        <div class="absolute inset-0 w-full h-full overflow-hidden bg-black">
          <!-- svelte-ignore a11y_media_has_caption -->
          <video
            bind:this={videoEl}
            class="w-full h-full object-cover"
            autoplay
            playsinline
          ></video>

          {#if !mediaStream}
            <div class="absolute inset-0 flex flex-col items-center justify-center text-white/80 gap-2 bg-black">
              <Icon icon="mdi:loading" class="animate-spin text-primary" width="40" />
              <span class="text-xs font-semibold tracking-wider">Starting camera viewfinder...</span>
            </div>
          {/if}
        </div>

        <!-- Top HUD (Heads Up Display) overlay -->
        <div class="absolute top-0 left-0 right-0 p-6 flex items-center justify-between bg-gradient-to-b from-black/75 to-transparent z-10">
          <button 
            type="button" 
            onclick={stopCamera} 
            class="w-11 h-11 rounded-full bg-black/20 text-white flex items-center justify-center hover:bg-black/40 transition-all cursor-pointer"
            title="Close Camera"
          >
            <Icon icon="mdi:close" width="28" />
          </button>
          
          <div class="flex items-center gap-4">
            {#if hasTorch}
              <button
                type="button"
                onclick={toggleTorch}
                class="w-11 h-11 rounded-full bg-black/20 text-white flex items-center justify-center hover:bg-black/40 active:scale-95 transition-all cursor-pointer"
                title="Toggle Flash"
              >
                <Icon icon={torchOn ? "mdi:flash" : "mdi:flash-off"} width="24" />
              </button>
            {/if}
            <button 
              type="button" 
              class="w-11 h-11 rounded-full bg-black/20 text-white flex items-center justify-center opacity-60 pointer-events-none"
            >
              <Icon icon="mdi:aspect-ratio" width="22" />
            </button>
          </div>
        </div>

        <!-- Target Grid overlay to guide photo alignment -->
        <div class="absolute inset-0 flex items-center justify-center pointer-events-none z-10 opacity-30">
          <div class="w-72 h-72 border border-dashed border-white/50 rounded-3xl relative">
            <div class="absolute -top-1 -left-1 w-6 h-6 border-t-2 border-l-2 border-white rounded-tl-lg"></div>
            <div class="absolute -top-1 -right-1 w-6 h-6 border-t-2 border-r-2 border-white rounded-tr-lg"></div>
            <div class="absolute -bottom-1 -left-1 w-6 h-6 border-b-2 border-l-2 border-white rounded-bl-lg"></div>
            <div class="absolute -bottom-1 -right-1 w-6 h-6 border-b-2 border-r-2 border-white rounded-br-lg"></div>
          </div>
        </div>

        <!-- Bottom Mode Selector Row -->
        <div class="absolute bottom-36 left-0 right-0 flex justify-center items-center gap-6 text-[11px] font-bold uppercase tracking-wider text-white z-10">
          <span class="opacity-45">TEXT</span>
          <div class="flex flex-col items-center gap-1">
            <span class="text-white font-extrabold tracking-widest">NORMAL</span>
            <span class="w-1 h-1 rounded-full bg-white"></span>
          </div>
          <span class="opacity-45">VIDEO</span>
        </div>

        <!-- Bottom Controls Bar overlay -->
        <div class="absolute bottom-0 left-0 right-0 p-8 pb-12 flex items-center justify-between bg-gradient-to-t from-black/80 via-black/40 to-transparent z-10">
          <!-- Gallery Thumbnail (Left) -->
          <div class="w-14 h-14 flex items-center justify-center">
            {#if imageBase64}
              <button
                type="button"
                onclick={() => {
                  viewFullImageOpen = true;
                }}
                class="w-12 h-12 rounded-lg overflow-hidden border-2 border-white/40 bg-black/45 backdrop-blur-md flex items-center justify-center p-0.5 active:scale-95 transition-all cursor-pointer shadow-lg"
                title="View captured photo"
              >
                <img src={imageBase64} alt="Captured thumbnail" class="w-full h-full object-cover rounded" />
              </button>
            {:else}
              <div class="w-12 h-12 rounded-lg border-2 border-white/20 bg-white/5 backdrop-blur-md flex items-center justify-center text-white/40">
                <Icon icon="mdi:image-outline" width="22" />
              </div>
            {/if}
          </div>

          <!-- Shutter Button (Center) -->
          <button
            type="button"
            onclick={capturePhoto}
            disabled={!mediaStream}
            class="w-20 h-20 rounded-full border-4 border-white flex items-center justify-center bg-transparent active:scale-90 disabled:opacity-40 disabled:pointer-events-none transition-all cursor-pointer relative shadow-2xl"
            title="Capture Photo"
          >
            <span class="absolute w-15 h-15 rounded-full bg-white shadow-inner active:bg-white/85 transition-colors"></span>
          </button>

          <!-- Switch Camera Button (Right) -->
          <button
            type="button"
            onclick={toggleCameraFacingMode}
            disabled={!mediaStream}
            class="w-12 h-12 rounded-full bg-black/40 backdrop-blur-md text-white flex items-center justify-center border border-white/15 hover:bg-black/60 active:scale-90 disabled:opacity-40 disabled:pointer-events-none transition-all cursor-pointer shadow-lg"
            title="Switch Camera"
          >
            <Icon icon="mdi:camera-flip-outline" width="24" />
          </button>
        </div>
      </div>
    {/if}

    <!-- Full Screen Image Viewer Overlay -->
    {#if viewFullImageOpen && imageBase64}
      <div 
        class="fixed inset-0 z-[110] flex items-center justify-center bg-black/80 backdrop-blur-sm p-4 animate-in fade-in viewer-backdrop rounded-2xl"
        onpointerdown={(e) => e.stopPropagation()}
        onclick={() => viewFullImageOpen = false}
      >
        <div class="relative max-w-4xl max-h-[90vh] bg-card rounded-2xl overflow-hidden shadow-2xl p-2 flex flex-col items-center" onclick={(e) => e.stopPropagation()}>
          <button
            type="button"
            onclick={() => viewFullImageOpen = false}
            class="absolute top-4 right-4 bg-black/50 hover:bg-black/75 text-white rounded-full p-2 transition-colors z-10 viewer-close-btn"
            title="Close viewer"
          >
            <Icon icon="mdi:close" width="20" />
          </button>
          <img src={imageBase64} alt="Full view" class="max-w-full max-h-[85vh] object-contain rounded-xl viewer-image" />
        </div>
      </div>
    {/if}
  </Dialog.Content>
</Dialog.Root>

<BarcodeScanner bind:open={barcodeScannerOpen} onscan={(code) => {
  const cleanCode = code.endsWith('-CASE') ? code.slice(0, -5) : code;
  barcode = cleanCode;
  toast.success(`Barcode scanned: ${cleanCode}`);
}} />

