import { AutoModel, AutoProcessor, RawImage, env } from '@huggingface/transformers';

env.allowLocalModels = false;

let bgModel: any = null;
let bgProcessor: any = null;

async function initModel() {
  if (!bgModel || !bgProcessor) {
    [bgModel, bgProcessor] = await Promise.all([
      AutoModel.from_pretrained('briaai/RMBG-1.4', {
        config: { model_type: 'custom' } as any,
        device: 'wasm',
        dtype: 'q8'
      }),
      AutoProcessor.from_pretrained('briaai/RMBG-1.4', {
        config: {
          do_normalize: true,
          do_pad: false,
          do_rescale: true,
          do_resize: true,
          image_mean: [0.5, 0.5, 0.5],
          feature_extractor_type: 'ImageFeatureExtractor',
          image_std: [1, 1, 1],
          resample: 2,
          rescale_factor: 0.00392156862745098,
          size: { width: 512, height: 512 }
        }
      })
    ]);
  }
}

function dataURLtoBlob(dataURL: string): Blob {
  const [header, base64] = dataURL.split(',');
  const mime = header.match(/:(.*?);/)?.[1] ?? 'image/png';
  const binary = atob(base64);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }
  return new Blob([bytes], { type: mime });
}

self.onmessage = async (e: MessageEvent) => {
  const { type, imageSrc } = e.data;

  if (type === 'preload') {
    try {
      await initModel();
      self.postMessage({ type: 'preload-success' });
    } catch (err) {
      self.postMessage({ type: 'preload-error', error: String(err) });
    }
    return;
  }

  if (type === 'process') {
    try {
      await initModel();

      const blob = dataURLtoBlob(imageSrc);
      const imgBitmap = await createImageBitmap(blob);
      const width = imgBitmap.width;
      const height = imgBitmap.height;

      // Draw original image on an OffscreenCanvas to retrieve ImageData
      const canvas = new OffscreenCanvas(width, height);
      const ctx = canvas.getContext('2d')!;
      ctx.drawImage(imgBitmap, 0, 0);
      const imgData = ctx.getImageData(0, 0, width, height);

      // Construct RawImage for Hugging Face Transformers from pixel buffer
      const rawImage = new RawImage(imgData.data, width, height, 4);

      // Run processor and RMBG-1.4 inference
      const { pixel_values } = await bgProcessor(rawImage);
      const { output } = await bgModel({ input: pixel_values });
      const mask = await RawImage.fromTensor(output[0].mul(255).to('uint8'))
        .resize(width, height);

      // Set output alpha channel to mask values
      for (let i = 0; i < mask.data.length; i++) {
        imgData.data[i * 4 + 3] = mask.data[i];
      }
      ctx.putImageData(imgData, 0, 0);

      // Draw onto final canvas with a white background
      const finalCanvas = new OffscreenCanvas(width, height);
      const fCtx = finalCanvas.getContext('2d')!;
      fCtx.fillStyle = '#ffffff';
      fCtx.fillRect(0, 0, width, height);
      fCtx.drawImage(canvas, 0, 0);

      // Export composite image as jpeg
      const finalBlob = await finalCanvas.convertToBlob({ type: 'image/jpeg', quality: 0.92 });
      
      const reader = new FileReader();
      const base64Promise = new Promise<string>((resolve) => {
        reader.onload = () => resolve(reader.result as string);
        reader.readAsDataURL(finalBlob);
      });
      const finalBase64 = await base64Promise;

      self.postMessage({ type: 'process-success', imageBase64: finalBase64 });
    } catch (err) {
      self.postMessage({ type: 'process-error', error: String(err) });
    }
  }
};
