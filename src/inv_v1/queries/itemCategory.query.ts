export function getInventoryItemCategoryQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getInventoryItemCategory('${jsonParam}')`;
}

export function postInventoryItemCategoryQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.postInventoryItemCategory('${jsonParam}')`;
}
