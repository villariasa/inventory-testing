export function getItemImportListQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getItemImportList('${jsonParam}')`;
}

export function getItemImportsQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getItemImports('${jsonParam}')`;
}

export function getImportItemsQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getImportItems('${jsonParam}')`;
}

export function postItemImportsQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.postItemImports('${jsonParam}')`;
}
