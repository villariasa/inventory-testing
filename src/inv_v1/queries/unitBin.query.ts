export function getInventoryUnitBinQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getInventoryUnitBin('${jsonParam}')`;
}

export function getUnitBinExceptOneQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getUnitBinExceptOne('${jsonParam}')`;
}

export function postInventoryUnitBinQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.postInventoryUnitBin('${jsonParam}')`;
}
