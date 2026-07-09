import { endpoint } from '$lib/config/serviceConfig';

type ApiOptions<TBody> = {
  method?: 'GET' | 'POST';
  body?: TBody;
  headers?: Record<string, string>;
  token?: string;
};

export async function invokeService<TBody = unknown, TResponse = any>(
  path: string,
  options: ApiOptions<TBody> = {}
): Promise<{ data: any; accessToken?: string } | { error: string; raw: string }> {
  const url = endpoint(path);
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    ...(options.headers ?? {})
  };

  if (options.token) {
    headers['SessionAuth'] = options.token;
  }

  try {
    const res = await fetch(url, {
      method: options.method ?? 'POST',
      headers,
      body: options.body ? JSON.stringify(options.body) : undefined
    });

    const text = await res.text();
    console.log(`[invokeService] Raw response from ${url}:`, text);

    try {
      const data: TResponse = JSON.parse(text);
      const accessToken = res.headers.get('x-new-access-token') ?? res.headers.get('accessToken') ?? undefined;
      return { data, accessToken };
    } catch (err) {
      console.error("[invokeService] Failed to parse JSON:", err);
      return { error: "Invalid JSON from backend", raw: text };
    }
  } catch (error) {
    console.error("[invokeService] Fetch error:", error);
    return { error: error instanceof Error ? error.message : "Fetch network error", raw: "" };
  }
}
