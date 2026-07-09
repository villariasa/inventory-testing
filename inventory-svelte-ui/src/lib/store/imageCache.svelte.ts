import { invokeService } from '$lib/service/invokeService';

class ImageCache {
  // Reactive map holding item_id -> base64 string or null (indicating no image exists)
  cache = $state<Map<number, string | null>>(new Map());

  // Set of item IDs currently being fetched to prevent duplicate parallel fetches
  private fetching = new Set<number>();

  has(itemId: number): boolean {
    return this.cache.has(itemId);
  }

  get(itemId: number): string | null | undefined {
    return this.cache.get(itemId);
  }

  set(itemId: number, image: string | null) {
    const newMap = new Map(this.cache);
    newMap.set(itemId, image);
    this.cache = newMap;
  }

  delete(itemId: number) {
    if (this.cache.has(itemId)) {
      const newMap = new Map(this.cache);
      newMap.delete(itemId);
      this.cache = newMap;
    }
  }

  async fetch(itemId: number, token: string): Promise<string | null> {
    if (this.has(itemId)) {
      return this.get(itemId)!;
    }
    if (this.fetching.has(itemId)) {
      return null;
    }

    this.fetching.add(itemId);
    try {
      const res = await invokeService<any, any>('/get-item-image', {
        body: { item_id: itemId },
        token
      });

      let image: string | null = null;
      if ('data' in res && res.data.success) {
        const imageData = res.data?.data?.json_data;
        if (imageData && imageData.image) {
          image = imageData.image;
        }
      }
      this.set(itemId, image);
      return image;
    } catch (err) {
      console.error(`[ImageCache] Error fetching image for item ${itemId}:`, err);
      this.set(itemId, null);
      return null;
    } finally {
      this.fetching.delete(itemId);
    }
  }
}

export const imageCacheStore = new ImageCache();
