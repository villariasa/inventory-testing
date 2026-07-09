export function getUnitNameQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getUnitName('${jsonParam}')`;
}

export function getUserUnitQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getUserUnit('${jsonParam}')`;
}

export function getUserUnitArrayQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getUserUnitArray('${jsonParam}')`;
}

export function getUserDesignatedUnitQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getUserDesignatedUnit('${jsonParam}')`;
}

export function getAdjustmentUserUnitQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getAdjustmentUserUnit('${jsonParam}')`;
}

export function getSelectableAccountsConcatenatedQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getSelectableGlslAccount('${jsonParam}')`;
}
