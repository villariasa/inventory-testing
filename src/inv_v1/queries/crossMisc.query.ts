export function getEmployeeNameQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getEmployeeName('${jsonParam}')`;
}

export function getNotificationQuery(): string {
  return `CALL udf_and_views_inventory.getNotification()`;
}
