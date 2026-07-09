export function getInventoryUnitQuery(jsonParam: string): string {
  const params = JSON.parse(jsonParam);
  const bolGetOne = params.bol_getone;
  const intUnitId = params.unit_id ? Number(params.unit_id) : null;
  const charDescription = params.description || '';

  let whereCredentials = '';
  if (bolGetOne) {
    whereCredentials = `WHERE aa.unit_id = ${intUnitId}`;
  } else if (charDescription !== '') {
    const escapedDesc = charDescription.replace(/'/g, "''");
    whereCredentials = `WHERE LOWER(aa.unit) LIKE '%${escapedDesc.toLowerCase()}%'`;
  }

  return `
    SELECT JSON_OBJECT(
        'success', TRUE,
        'message', 'Inventory unit retrieved successfully.',
        'json_data', JSON_ARRAYAGG(
            JSON_OBJECT(
                'unit_id', aa.unit_id,
                'unit', aa.unit,
                'warehouse', aa.warehouse,
                'is_warehouse', aa.is_warehouse,
                'person_in_charge_id', aa.person_in_charge_id,
                'person_in_charge', aa.person_in_charge
            ) ORDER BY aa.unit
        )
    ) AS response
    FROM (
        SELECT 
            iu.unit_id,
            u.description AS unit,
            iu.warehouse,
            IF(iu.warehouse, 'Yes', 'No') AS is_warehouse,
            iu.person_in_charge AS person_in_charge_id,
            IF(!ISNULL(en.entity_name), en.entity_name, iu.person_name) AS person_in_charge
        FROM 
            inventory.inventory_units iu
        INNER JOIN 
            subscriber_common_tables.units u 
        ON 
            iu.unit_id = u.unit_id
        LEFT JOIN 
            employees_profile.employees e 
        ON 
            iu.person_in_charge = e.employee_id
        LEFT JOIN 
            entities_udf_and_views.entity_name en 
        ON 
            e.entity_id = en.entity_id
    ) AS aa
    ${whereCredentials}
  `;
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
