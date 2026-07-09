<script lang="ts">
  import { onDestroy } from 'svelte';

  let {
    text = '',
    size = 160
  } = $props<{
    text: string;
    size?: number;
  }>();

  let canvasEl: HTMLCanvasElement = $state() as any;

  $effect(() => {
    if (text && canvasEl) {
      import('qrcode').then((QRCode) => {
        QRCode.toCanvas(canvasEl, text, {
          width: size,
          margin: 1,
          color: {
            dark: '#0f172a', // Slate 900
            light: '#ffffff'
          }
        }, (error) => {
          if (error) {
            console.error('Error rendering QR code:', error);
          }
        });
      }).catch((err) => {
        console.error('Failed to import qrcode library:', err);
      });
    }
  });
</script>

<canvas bind:this={canvasEl} class="rounded-lg shadow-inner max-w-full h-auto bg-white p-1 border border-border"></canvas>
