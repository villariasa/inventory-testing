export function getInventoryUnitItemQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getInventoryUnitItem('${jsonParam}')`;
}

export function getUnitItemInfoByBinQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getUnitItemInfoByBin('${jsonParam}')`;
}

export function postUnitItemBinSwitchQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.postUnitItemBinSwitch('${jsonParam}')`;
}

export function postInventoryUnitItemQuery(jsonParam: string): string {
  return `CALL inventory_udf_and_views.postInventoryUnitItem('${jsonParam}')`;
}

