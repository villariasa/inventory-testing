export function getItemForAdjustmentQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getItemForAdjustment('${jsonParam}')`;
}

export function getInventoryItemAdjustmentQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getInventoryItemAdjustment('${jsonParam}')`;
}

export function getInventoryItemAdjustmentTemplateQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getInventoryItemAdjustmentTemplate('${jsonParam}')`;
}

export function postInventoryItemAdjustmentQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.postInventoryItemAdjustment('${jsonParam}')`;
}

export function postInventoryItemAdjustmentTemplateQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.postInventoryItemAdjustmentTemplate('${jsonParam}')`;
}
