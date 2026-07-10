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
  // Use SELECT pattern replicating the getUnit procedure result
  return `SELECT JSON_OBJECT('success', TRUE, 'message', 'Unit retrieved.', 'json_data', JSON_ARRAYAGG(JSON_OBJECT('unit_id', unit_id, 'description', description))) AS response FROM subscriber_common_tables.units WHERE 1=1`;
}

export function postInventoryUnitQuery(jsonParam: string): string[] {
  const params = JSON.parse(jsonParam);
  const unitId = Number(params.unit_id || 0);
  const warehouse = params.bol_warehouse ? 1 : 0;
  const bolEmployee = params.bol_employee || false;
  const personInCharge = bolEmployee ? (params.person_in_charge ? Number(params.person_in_charge) : null) : null;
  const personName = !bolEmployee ? (params.person_name ? params.person_name.replace(/'/g, "''") : '') : null;

  const queries: string[] = [];
  queries.push(`START TRANSACTION`);
  queries.push(`
    UPDATE inventory.inventory_units SET
      warehouse = ${warehouse},
      person_in_charge = ${personInCharge},
      person_name = ${personName !== null ? `'${personName}'` : 'NULL'}
    WHERE unit_id = ${unitId}
  `);
  queries.push(`COMMIT`);
  queries.push(`SELECT JSON_OBJECT('success', TRUE, 'message', 'Inventory Unit Successfully Updated!', 'json_data', ${unitId}) AS response`);
  return queries;
}

export function postUpdateInventoryUnitQuery(jsonParam: string): string[] {
  // Same logic as postInventoryUnitQuery — both update the inventory unit
  return postInventoryUnitQuery(jsonParam);
}
