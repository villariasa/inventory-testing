<script lang="ts">
  import { onDestroy } from 'svelte';
  import * as Dialog from '$lib/components/ui/dialog/index.js';
  import { Button } from '$lib/components/ui/button/index.js';
  import { toast } from 'svelte-sonner';
  import Icon from '@iconify/svelte';

  let {
    open = $bindable(false),
    onscan = () => {},
  } = $props<{
    open: boolean;
    onscan: (barcode: string) => void;
  }>();

  let html5Qrcode: any = null;
  let loadingScanner = $state(true);
  let scannerError = $state<string | null>(null);

  let activeTab = $state<'camera' | 'upload'>('camera');
  let fileInput: HTMLInputElement;
  let isDragging = $state(false);
  let uploadError = $state<string | null>(null);
  let isProcessingFile = $state(false);
  let filePreviewUrl = $state<string | null>(null);

  let cameraDevices = $state<any[]>([]);
  let selectedCameraId = $state<string>('environment');

  let autoZoomLevel = $state(1.0);
  let autoAdjustTimer: any = null;

  let manualInputVal = $state('');
  let manualInputEl = $state<HTMLInputElement | null>(null);

  function startAutoAdjust(track: MediaStreamTrack) {
    if (!track) return;
    stopAutoAdjust();
    
    try {
      const capabilities = track.getCapabilities() as any;
      if (!capabilities.zoom) {
        return;
      }
      
      const minZoom = capabilities.zoom.min || 1;
      const maxZoom = capabilities.zoom.max || 1;
      if (maxZoom <= minZoom) return;
      
      const baseSteps = [1.0, 1.5, 2.0, 2.5, 3.0, 4.0];
      const availableSteps = baseSteps
        .map(z => Math.max(minZoom, Math.min(z, maxZoom)))
        .filter((val, idx, self) => self.indexOf(val) === idx);
        
      if (availableSteps.length <= 1) return;
      
      let stepIndex = 0;
      autoZoomLevel = availableSteps[stepIndex];
      
      autoAdjustTimer = setInterval(async () => {
        stepIndex = (stepIndex + 1) % availableSteps.length;
        const targetZoom = availableSteps[stepIndex];
        autoZoomLevel = targetZoom;
        
        try {
          await track.applyConstraints({
            advanced: [{ zoom: targetZoom }]
          } as any);
        } catch (e) {
          console.warn("Failed to apply dynamic zoom constraints:", e);
        }
      }, 4000);
    } catch (err) {
      console.warn("Failed to configure auto adjust:", err);
    }
  }

  function stopAutoAdjust() {
    if (autoAdjustTimer) {
      clearInterval(autoAdjustTimer);
      autoAdjustTimer = null;
    }
    autoZoomLevel = 1.0;
  }

  let stopPromise: Promise<void> | null = null;
  let isInitializing = false;

  async function getOrCreateScanner() {
    const { Html5Qrcode } = await import('html5-qrcode');
    const container = document.getElementById("barcode-scanner-viewport");
    if (!container) {
      throw new Error("Viewport container not found in DOM.");
    }
    if (!html5Qrcode) {
      html5Qrcode = new Html5Qrcode("barcode-scanner-viewport");
    }
    return html5Qrcode;
  }

  async function handleCameraChange(deviceId: string) {
    selectedCameraId = deviceId;
    if (html5Qrcode && html5Qrcode.isScanning) {
      loadingScanner = true;
      stopAutoAdjust();
      try {
        await html5Qrcode.stop();
        const cameraConfig = (deviceId === 'environment' || deviceId === 'user')
          ? { facingMode: deviceId }
          : deviceId;

        const videoConstraints: any = {
          width: { min: 640, ideal: 1920, max: 3840 },
          height: { min: 480, ideal: 1080, max: 2160 }
        };

        if (deviceId === 'environment' || deviceId === 'user') {
          videoConstraints.facingMode = { ideal: deviceId };
        } else {
          videoConstraints.deviceId = { exact: deviceId };
        }

        await html5Qrcode.start(
          cameraConfig,
          {
            fps: 20,
            videoConstraints: videoConstraints,
            experimentalFeatures: {
              useBarCodeDetectorIfSupported: true
            }
          },
          (decodedText: string) => {
            onscan(decodedText);
            closeScanner();
          },
          (errorMessage: string) => {}
        );
        
        setTimeout(async () => {
          try {
            if (!html5Qrcode || !html5Qrcode.isScanning) return;
            const track = html5Qrcode.getRunningTrack();
            if (track) {
              const capabilities = track.getCapabilities() as any;
              const advancedConstraints: any = {};
              
              if (capabilities.focusMode && capabilities.focusMode.includes('continuous')) {
                advancedConstraints.focusMode = 'continuous';
                try {
                  await track.applyConstraints({
                    advanced: [advancedConstraints]
                  } as any);
                } catch (constraintsErr) {
                  console.warn("Failed to apply continuous autofocus constraints on switch:", constraintsErr);
                }
              }
              
              startAutoAdjust(track);
            }
          } catch (autoFocusErr) {
            console.warn("Failed to set continuous autofocus and zoom on camera switch after warmup:", autoFocusErr);
          }
        }, 800);
      } catch (err: any) {
        console.error("Failed to switch camera:", err);
        scannerError = err?.message || "Could not switch camera feed.";
      } finally {
        loadingScanner = false;
      }
    }
  }

  async function startScanner() {
    if (isInitializing) return;
    isInitializing = true;
    loadingScanner = true;
    scannerError = null;
    try {
      const { Html5Qrcode } = await import('html5-qrcode');
      
      setTimeout(async () => {
        try {
          const container = document.getElementById("barcode-scanner-viewport");
          if (!container) {
            console.error("Barcode scanner viewport container not found in DOM.");
            loadingScanner = false;
            isInitializing = false;
            return;
          }
          
          await stopScanner();

          const scannerInstance = await getOrCreateScanner();

          try {
            const list = await Html5Qrcode.getCameras();
            cameraDevices = list || [];
            if (cameraDevices.length > 0) {
              if (!selectedCameraId) {
                const backCamera = cameraDevices.find(
                  (cam) => cam.label?.toLowerCase().includes('back') || cam.label?.toLowerCase().includes('rear')
                );
                selectedCameraId = backCamera ? backCamera.id : cameraDevices[0].id;
              }
            } else {
              scannerError = "No camera devices detected.";
              loadingScanner = false;
              isInitializing = false;
              return;
            }
          } catch (camErr) {
            console.warn("Failed to get list of cameras, falling back to facingMode constraint:", camErr);
          }

          if (!open || activeTab !== 'camera') {
            loadingScanner = false;
            isInitializing = false;
            return;
          }

          const deviceIdOrConfig = (selectedCameraId === 'environment' || selectedCameraId === 'user')
            ? { facingMode: selectedCameraId }
            : (selectedCameraId || { facingMode: "environment" });

          const videoConstraints: any = {
            width: { min: 640, ideal: 1920, max: 3840 },
            height: { min: 480, ideal: 1080, max: 2160 }
          };

          if (selectedCameraId === 'environment' || selectedCameraId === 'user') {
            videoConstraints.facingMode = { ideal: selectedCameraId };
          } else if (selectedCameraId) {
            videoConstraints.deviceId = { exact: selectedCameraId };
          } else {
            videoConstraints.facingMode = { ideal: "environment" };
          }

          await scannerInstance.start(
            deviceIdOrConfig,
            {
              fps: 20,
              videoConstraints: videoConstraints,
              experimentalFeatures: {
                useBarCodeDetectorIfSupported: true
              }
            },
            (decodedText: string) => {
              onscan(decodedText);
              closeScanner();
            },
            (errorMessage: string) => {
              // Frame scan failure messages (normal during scanning)
            }
          );
          
          setTimeout(async () => {
            try {
              if (activeTab !== 'camera' || !open) return;
              const track = scannerInstance.getRunningTrack();
              if (track) {
                const capabilities = track.getCapabilities() as any;
                const advancedConstraints: any = {};
                
                if (capabilities.focusMode && capabilities.focusMode.includes('continuous')) {
                  advancedConstraints.focusMode = 'continuous';
                  try {
                    await track.applyConstraints({
                      advanced: [advancedConstraints]
                    } as any);
                  } catch (constraintsErr) {
                    console.warn("Failed to apply continuous autofocus constraints on start:", constraintsErr);
                  }
                }
                
                startAutoAdjust(track);
              }
            } catch (autoFocusErr) {
              console.warn("Failed to set continuous autofocus and zoom on start after warmup:", autoFocusErr);
            }
          }, 800);

          loadingScanner = false;
          isInitializing = false;
        } catch (err: any) {
          console.error("Failed to start scanner instance:", err);
          scannerError = err?.message || "Could not access the camera. Make sure permissions are granted.";
          loadingScanner = false;
          isInitializing = false;
        }
      }, 300);
    } catch (err: any) {
      console.error("Failed to dynamically load html5-qrcode:", err);
      scannerError = "Failed to load scanner engine.";
      loadingScanner = false;
      isInitializing = false;
    }
  }

  async function stopScanner() {
    stopAutoAdjust();
    if (html5Qrcode) {
      try {
        if (!stopPromise) {
          stopPromise = (async () => {
            try {
              if (html5Qrcode.isScanning) {
                await html5Qrcode.stop();
              }
              await html5Qrcode.clear();
            } catch (err) {
              console.error("Error during stop/clear:", err);
            } finally {
              html5Qrcode = null;
            }
          })();
        }
        await stopPromise;
      } catch (err) {
        console.error("Error waiting for scanner stop:", err);
      } finally {
        stopPromise = null;
      }
    } else if (stopPromise) {
      await stopPromise;
    }
  }

  async function handleFileSelect(file: File) {
    if (!file) return;

    if (filePreviewUrl) {
      URL.revokeObjectURL(filePreviewUrl);
      filePreviewUrl = null;
    }

    filePreviewUrl = URL.createObjectURL(file);
    uploadError = null;
    isProcessingFile = true;

    try {
      await stopScanner();
      
      const scannerInstance = await getOrCreateScanner();
      const decodedText = await scannerInstance.scanFile(file, false);
      isProcessingFile = false;
      onscan(decodedText);
      await closeScanner();
    } catch (err: any) {
      console.error("Failed to decode barcode from image file:", err);
      uploadError = "No valid barcode found in this image. Please make sure the barcode is clear and well-lit.";
      isProcessingFile = false;
    }
  }

  function handleFileChange(e: Event) {
    const target = e.target as HTMLInputElement;
    if (target.files && target.files.length > 0) {
      handleFileSelect(target.files[0]);
    }
  }

  function handleDragOver(e: DragEvent) {
    e.preventDefault();
    isDragging = true;
  }

  function handleDragLeave() {
    isDragging = false;
  }

  function handleDrop(e: DragEvent) {
    e.preventDefault();
    isDragging = false;
    if (e.dataTransfer?.files && e.dataTransfer.files.length > 0) {
      handleFileSelect(e.dataTransfer.files[0]);
    }
  }

  function handlePaste(e: ClipboardEvent) {
    if (!open) return;
    const items = e.clipboardData?.items;
    if (!items) return;
    for (let i = 0; i < items.length; i++) {
      if (items[i].type.indexOf('image') !== -1) {
        const file = items[i].getAsFile();
        if (file) {
          activeTab = 'upload';
          handleFileSelect(file);
          toast.success('Barcode image pasted from clipboard.');
        }
        break;
      }
    }
  }

  function handleManualInputKeyDown(e: KeyboardEvent) {
    if (e.key === 'Enter') {
      e.preventDefault();
      submitManualInput();
    }
  }

  function submitManualInput() {
    const val = manualInputVal.trim();
    if (val) {
      onscan(val);
      closeScanner();
    }
  }

  async function closeScanner() {
    await stopScanner();
    if (filePreviewUrl) {
      URL.revokeObjectURL(filePreviewUrl);
      filePreviewUrl = null;
    }
    uploadError = null;
    isProcessingFile = false;
    open = false;
  }

  async function checkCameraAvailability(): Promise<boolean> {
    try {
      if (typeof navigator === 'undefined' || !navigator.mediaDevices || !navigator.mediaDevices.enumerateDevices) {
        return false;
      }
      const devices = await navigator.mediaDevices.enumerateDevices();
      return devices.some(device => device.kind === 'videoinput');
    } catch (e) {
      return false;
    }
  }

  $effect(() => {
    if (open) {
      manualInputVal = '';
      
      checkCameraAvailability().then((hasCamera) => {
        if (!hasCamera) {
          setTimeout(() => {
            if (manualInputEl) {
              manualInputEl.focus();
            }
          }, 150);
        }
      });

      if (activeTab === 'camera') {
        startScanner();
      } else {
        stopScanner();
      }
    } else {
      stopScanner();
    }
  });

  $effect(() => {
    if (open) {
      window.addEventListener('paste', handlePaste);
    } else {
      window.removeEventListener('paste', handlePaste);
    }
    return () => {
      window.removeEventListener('paste', handlePaste);
    };
  });

  onDestroy(() => {
    stopScanner();
    if (filePreviewUrl) {
      URL.revokeObjectURL(filePreviewUrl);
    }
  });
</script>

<Dialog.Root bind:open>
  <Dialog.Content 
    showCloseButton={false}
    onInteractOutside={(e) => e.preventDefault()}
    onEscapeKeydown={(e) => {
      closeScanner();
      e.preventDefault();
    }}
    class="sm:max-w-[500px] bg-card border border-border rounded-2xl shadow-2xl p-0 overflow-hidden flex flex-col z-[150]"
  >
    <!-- Header -->
    <div class="bg-primary/5 border-b px-6 py-4 flex items-center justify-between shrink-0">
      <Dialog.Header>
        <div class="flex items-center gap-2">
          <Icon icon="mdi:barcode-scan" width="20" class="text-primary" />
          <Dialog.Title class="font-bold text-foreground">Barcode Scanner</Dialog.Title>
        </div>
      </Dialog.Header>
      <button type="button" onclick={closeScanner} class="text-muted-foreground hover:text-foreground">
        <Icon icon="mdi:close" width="20" />
      </button>
    </div>

    <!-- Mode Switch Tabs -->
    <div class="flex border-b border-border bg-muted/40 p-1.5 gap-2 shrink-0">
      <button
        type="button"
        onclick={() => activeTab = 'camera'}
        class="flex-grow py-2 text-xs font-bold uppercase tracking-wider rounded-xl transition-all flex items-center justify-center gap-1.5 cursor-pointer
          {activeTab === 'camera' ? 'bg-background shadow-md text-primary font-extrabold border border-border/10' : 'text-muted-foreground hover:text-foreground hover:bg-background/20'}"
      >
        <Icon icon="mdi:camera" width="16" />
        Use Camera
      </button>
      <button
        type="button"
        onclick={() => activeTab = 'upload'}
        class="flex-grow py-2 text-xs font-bold uppercase tracking-wider rounded-xl transition-all flex items-center justify-center gap-1.5 cursor-pointer
          {activeTab === 'upload' ? 'bg-background shadow-md text-primary font-extrabold border border-border/10' : 'text-muted-foreground hover:text-foreground hover:bg-background/20'}"
      >
        <Icon icon="mdi:upload" width="16" />
        Upload Image
      </button>
    </div>

    <!-- Body -->
    <div class="p-6 flex flex-col items-center gap-4 bg-muted/20">
      <!-- Manual Input Area -->
      <div class="flex flex-col gap-1.5 w-full text-left bg-background border border-border p-3.5 rounded-xl shadow-sm">
        <label for="manual-barcode-input" class="text-xs font-bold text-muted-foreground uppercase tracking-wider">Manual Code / Keyboard Scanner</label>
        <div class="flex gap-2">
          <input
            id="manual-barcode-input"
            type="text"
            autocomplete="off"
            placeholder="Type code or use USB scanner here..."
            bind:value={manualInputVal}
            bind:this={manualInputEl}
            onkeydown={handleManualInputKeyDown}
            class="flex-1 h-10 rounded-xl border border-border bg-background px-3 text-sm focus:outline-none focus:ring-1 focus:ring-primary text-foreground"
          />
          <Button 
            type="button" 
            onclick={submitManualInput} 
            disabled={!manualInputVal.trim()} 
            class="h-10 px-4 rounded-xl bg-primary text-white font-bold hover:bg-primary/95 shadow-sm"
          >
            Submit
          </Button>
        </div>
      </div>
      <!-- Camera Selection Dropdown -->
      {#if activeTab === 'camera'}
        <div class="flex flex-col gap-1.5 w-full text-left">
          <label for="scanner-camera-select" class="text-xs font-bold text-muted-foreground uppercase tracking-wider">Select Scanner Source</label>
          <select
            id="scanner-camera-select"
            value={selectedCameraId}
            onchange={(e) => handleCameraChange(e.currentTarget.value)}
            class="w-full h-10 rounded-xl border border-border bg-background px-3 text-sm font-semibold focus:outline-none focus:ring-1 focus:ring-primary text-foreground"
          >
            <option value="environment">Back Camera (Standard)</option>
            <option value="user">Front Camera (Standard)</option>
            {#each cameraDevices as device}
              {#if device.id !== 'environment' && device.id !== 'user'}
                <option value={device.id}>{device.label || `Camera ${cameraDevices.indexOf(device) + 1}`}</option>
              {/if}
            {/each}
          </select>
        </div>
      {/if}

      <!-- Camera Scanner Viewport -->
      <div 
        class="relative w-full aspect-video rounded-xl overflow-hidden bg-black border border-border shadow-inner flex items-center justify-center"
        class:hidden={activeTab !== 'camera'}
      >
        <div id="barcode-scanner-viewport" class="w-full h-full object-cover"></div>
        
        {#if !loadingScanner && !scannerError}
          <div class="absolute top-3 left-3 bg-black/60 backdrop-blur-md text-white text-[10.5px] font-bold px-2.5 py-1 rounded-full flex items-center gap-1.5 border border-white/10 shadow-lg z-10">
            <span class="relative flex h-2 w-2">
              <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
              <span class="relative inline-flex rounded-full h-2 w-2 bg-emerald-500"></span>
            </span>
            <span>AUTO-ZOOM: {autoZoomLevel.toFixed(1)}x</span>
          </div>
        {/if}
        
        {#if loadingScanner}
          <div class="absolute inset-0 flex flex-col items-center justify-center bg-black/90 text-white gap-2">
            <Icon icon="mdi:loading" class="animate-spin text-primary" width="30" />
            <span class="text-xs font-semibold text-muted-foreground">Initializing camera...</span>
          </div>
        {/if}

        {#if scannerError}
          <div class="absolute inset-0 flex flex-col items-center justify-center bg-black/95 text-center p-4 gap-3">
            <div class="w-10 h-10 rounded-full bg-rose-500/10 flex items-center justify-center text-rose-500">
              <Icon icon="mdi:alert-circle-outline" width="24" />
            </div>
            <p class="text-sm font-semibold text-rose-500 max-w-[280px]">{scannerError}</p>
            <p class="text-xs text-muted-foreground max-w-[280px] px-2 leading-relaxed">
              No camera feed. You can still scan codes directly using a USB/Bluetooth hardware scanner, or type manually in the input field above.
            </p>
            <Button type="button" variant="outline" size="sm" class="h-8 border-rose-500/20 text-rose-500 hover:bg-rose-500/10" onclick={startScanner}>
              Retry Camera
            </Button>
          </div>
        {/if}
      </div>

      <!-- File Upload Zone -->
      {#if activeTab === 'upload'}
        <div 
          role="button"
          tabindex="0"
          onclick={() => fileInput.click()}
          onkeydown={(e) => e.key === 'Enter' && fileInput.click()}
          ondragover={handleDragOver}
          ondragleave={handleDragLeave}
          ondrop={handleDrop}
          class="relative w-full aspect-video rounded-xl border-2 border-dashed transition-all flex flex-col items-center justify-center p-6 text-center cursor-pointer select-none bg-muted/30 group shadow-inner
            {isDragging ? 'border-primary bg-primary/5' : 'border-border hover:border-primary/50 hover:bg-muted/40'}"
        >
          <input
            type="file"
            bind:this={fileInput}
            accept="image/*"
            onchange={handleFileChange}
            class="hidden"
          />

          {#if isProcessingFile}
            <div class="flex flex-col items-center gap-2">
              <Icon icon="mdi:loading" class="animate-spin text-primary" width="36" />
              <span class="text-xs font-semibold text-muted-foreground">Decoding barcode image...</span>
            </div>
          {:else if filePreviewUrl}
            <div class="relative w-full h-full flex flex-col items-center justify-center">
              <img src={filePreviewUrl} alt="Barcode Preview" class="max-h-[120px] object-contain rounded-lg border border-border bg-white p-2" />
              {#if uploadError}
                <div class="mt-2 text-rose-500 text-xs font-semibold flex items-center justify-center gap-1">
                  <Icon icon="mdi:alert-circle" width="16" class="shrink-0" />
                  <span>{uploadError}</span>
                </div>
                <Button type="button" size="sm" variant="outline" class="mt-2 h-7 text-xs border-primary/20 text-primary hover:bg-primary/5" onclick={(e) => { e.stopPropagation(); fileInput.click(); }}>
                  Try Another Image
                </Button>
              {/if}
            </div>
          {:else}
            <div class="flex flex-col items-center gap-3">
              <div class="w-12 h-12 rounded-full bg-primary/10 flex items-center justify-center text-primary transition-transform group-hover:scale-105">
                <Icon icon="mdi:cloud-upload-outline" width="28" />
              </div>
              <div>
                <p class="text-sm font-semibold text-foreground">Drag & drop your barcode image here</p>
                <p class="text-xs text-muted-foreground mt-1">or <span class="text-primary font-semibold underline">browse file</span> from your device</p>
              </div>
              <p class="text-[10px] text-muted-foreground leading-normal max-w-[280px]">
                Supports clear images of Barcodes or QR Codes
              </p>
            </div>
          {/if}
        </div>
      {/if}

      <!-- Footer Info -->
      <div class="flex justify-between items-center w-full mt-2 gap-4">
        <span class="text-[11px] text-muted-foreground leading-normal max-w-[280px]">
          {#if activeTab === 'camera'}
            Align the barcode / QR code within the camera frame to scan. Ensure proper lighting.
          {:else}
            Upload or drop an image containing a visible barcode or QR code to decode it.
          {/if}
        </span>
        <Button type="button" variant="outline" onclick={closeScanner} class="h-9 px-4 shrink-0">Cancel</Button>
      </div>
    </div>
  </Dialog.Content>
</Dialog.Root>

<style>
  /* Fix html5-qrcode video layout styling inside our container */
  :global(#barcode-scanner-viewport video) {
    width: 100% !important;
    height: 100% !important;
    object-fit: cover !important;
  }
</style>

