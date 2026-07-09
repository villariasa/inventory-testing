export function getInventoryItemQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getInventoryItem('${jsonParam}')`;
}

export function getInventoryItemNoUnitQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getInventoryItemNoUnit('${jsonParam}')`;
}

export function getItemImageQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getItemImage('${jsonParam}')`;
}

export function getEmptyUnitBinQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getEmptyUnitBin('${jsonParam}')`;
}

export function postInventoryItemQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.postInventoryItem('${jsonParam}')`;
}

export function postItemToUnitsQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.postItemToUnits('${jsonParam}')`;
}
