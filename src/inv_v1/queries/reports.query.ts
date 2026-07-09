export function getPurchasesReportQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getPurchasesReport('${jsonParam}')`;
}

export function getClientNameQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getClientName('${jsonParam}')`;
}

export function getInternalStocksMovementsReportQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getInternalStocksMovementsReport('${jsonParam}')`;
}

export function getDeliveriesReportQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getDeliveriesReport('${jsonParam}')`;
}

export function getSalesReceivablesCollectionsJSONQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getSalesReceivablesCollectionsJSON('${jsonParam}')`;
}

export function getSalesReportQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getSalesReport('${jsonParam}')`;
}

export function getClientLedgerQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getClientLedger('${jsonParam}')`;
}

export function getExpiriesAndPastDueQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getExpiriesAndPastDue('${jsonParam}')`;
}

export function getJSONStockCardQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getJSONStockCard('${jsonParam}')`;
}

export function getInventoryListQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getInventoryList('${jsonParam}')`;
}

export function getJSONPayablesAndTransactionsWithSuppliersQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getJSONPayablesAndTransactionsWithSuppliers('${jsonParam}')`;
}

export function getPayablesToSuppliersJSONQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getPayablesToSuppliersJSON('${jsonParam}')`;
}

export function getCustomerInactivityQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getCustomerInactivity('${jsonParam}')`;
}
