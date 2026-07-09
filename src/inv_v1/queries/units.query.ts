export function getInventoryUnitQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getInventoryUnit('${jsonParam}')`;
}

export function getUnitQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getUnit('${jsonParam}')`;
}

export function postInventoryUnitQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.postInventoryUnit('${jsonParam}')`;
}

export function postUpdateInventoryUnitQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.postUpdateInventoryUnit('${jsonParam}')`;
}

