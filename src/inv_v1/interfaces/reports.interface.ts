export interface PurchasesReportRequest {
  start_date: string;
  end_date: string;
  client_id: string;
  withCost: boolean | number;
}

export interface ClientNameRequest {
  entity_id?: number;
}

export interface InternalStocksMovementsReportRequest {
  start_date: string;
  end_date: string;
  units: Array<string | number>;
}

export interface DeliveriesReportRequest {
  dateFrom: string;
  dateTo: string;
  units: Array<string | number>;
  withCost: boolean | number;
}

export interface SalesReceivablesCollectionsRequest {
  start_date: string;
  end_date: string;
  units: Array<string | number>;
}

export interface SalesReportRequest {
  start_date: string;
  end_date: string;
  charUnitList: Array<string | number>;
}

export interface ClientLedgerRequest {
  start_date: string;
  end_date: string;
  client_id: number;
}

export interface ExpiriesAndPastDueRequest {
  units: Array<string | number>;
}

export interface JSONStockCardRequest {
  unit_id: number;
  start_date: string;
  end_date: string;
}

export interface InventoryListRequest {
  units: Array<string | number>;
  withCost: boolean | number;
}

export interface PayablesAndTransactionsWithSuppliersRequest {
  supplier_id: number;
  start_date: string;
  end_date: string;
  onterm: boolean | number;
}

export interface PayablesToSuppliersRequest {
  date: string;
}

export interface CustomerInactivityRequest {
  start_date: string;
  end_date: string;
  charUnitList: Array<string | number>;
}
