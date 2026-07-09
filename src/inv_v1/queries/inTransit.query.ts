export function getInstransitReportQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getInstransitReport('${jsonParam}')`;
}

export function getInTransitReportQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getInTransitReport('${jsonParam}')`;
}

export function getInTransitItemsInvoicesQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getInTransitItemsInvoices('${jsonParam}')`;
}

export function postConfirmInTransitItemsQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.postConfirmInTransitItems('${jsonParam}')`;
}
