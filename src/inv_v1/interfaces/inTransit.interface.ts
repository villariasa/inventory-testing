export interface InstransitReportRequest {
  search: string;
}

export type InTransitReportRequest = Record<string, never>;

export interface InTransitItemsInvoicesRequest {
  bol_getone: boolean | number;
  invoice_id: number;
  user_id: number;
  invoice_reference: string;
}

export interface InTransitItem {
  in_transit_id: number;
  quanttiy_confirmed: number;
}

export interface PostConfirmInTransitItemsRequest {
  user_id: number;
  invoice_id: number;
  in_transit_items: InTransitItem[];
}
