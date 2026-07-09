export type SubscriberDetails = {
  subscribers_id: number;
  subscribers_logo: string;
  name: string;
  address?: any;
  contact?: any;
};

let cachedDetails: SubscriberDetails | null = null;

export async function getSubscriberDetails(): Promise<SubscriberDetails | null> {
  if (cachedDetails) {
    return cachedDetails;
  }

  const domain = 'https://developers.litecloud.ph';
  const subscriber_id = 675;
  const authKey = '9c3ecc86389aa9e54b79fbfe8a974ad718354658a493e07caf8e3aa70fa95f3dotVzMHTwCuHWBlZXy9cfXCJWTtpfMkp5JO0HncUQzHBUHh+RlzvPm3INNS402U5x3848VqaU6347AE6SPrBt+0A2IXa0lCJGGdpjsZsXR5o=';

  const url = `${domain}/Credentials-API/legal/statistics/${subscriber_id}/@myContractAccount?fields=details:subscribers_id;subscribers_logo;name;address;contact&auth_key=${authKey}`;

  try {
    const res = await fetch(url);
    if (!res.ok) {
      throw new Error(`Failed to fetch subscriber details: ${res.statusText}`);
    }
    const data = await res.json();
    let details: any = {};
    if (Array.isArray(data)) {
      details =
        data.length > 2 && data[2].details
          ? data[2].details
          : data[0] && data[0].details
          ? data[0].details
          : {};
    } else if (data && typeof data === 'object') {
      details = data.details || data;
    }

    cachedDetails = {
      subscribers_id: details.subscribers_id || subscriber_id,
      subscribers_logo: details.subscribers_logo || '',
      name: details.name || 'Litecloud Ph',
      address: details.address,
      contact: details.contact
    };

    return cachedDetails;
  } catch (error) {
    console.error('Error fetching subscriber details:', error);
    // Return fallback info on error so report generation does not break
    return {
      subscribers_id: subscriber_id,
      subscribers_logo: '',
      name: 'Litecloud Ph'
    };
  }
}
