export function getInventoryUnitBinQuery(jsonParam: string): string {
  const params = JSON.parse(jsonParam);
  const bolGetOne = params.bol_getone;
  const intBinId = params.bin_id ? Number(params.bin_id) : null;
  const intUnitId = params.unit_id ? Number(params.unit_id) : null;
  const charDescription = params.description || '';

  let whereCredentials = '';
  if (bolGetOne) {
    whereCredentials = `WHERE ub.unit_id = ${intUnitId} AND ub.bin_id = ${intBinId}`;
  } else {
    if (charDescription !== '') {
      const escapedDesc = charDescription.replace(/'/g, "''");
      whereCredentials = `WHERE ub.unit_id = ${intUnitId} AND LOWER(ub.description) LIKE '%${escapedDesc.toLowerCase()}%'`;
    } else {
      whereCredentials = `WHERE ub.unit_id = ${intUnitId}`;
    }
  }

  return `
    SELECT JSON_OBJECT(
        'success', TRUE,
        'message', 'Inventory unit bin retrieved successfully.',
        'json_data', JSON_ARRAYAGG(
            JSON_OBJECT(
                'bin_id', ub.bin_id,
                'description', ub.description,
                'unit_id', ub.unit_id,
                'unit', u.description,
                'created_by', ub.created_by,
                'creator', au.user_login_name,
                'datetime_created', ub.datetime_created,
                'frmt_datetime_created', DATE_FORMAT(ub.datetime_created, '%Y %b %d %a'),
                'modified_by', ub.modified_by,
                'modifier', au2.user_login_name,
                'datetime_modified', ub.datetime_modified,
                'frmt_datetime_modified', DATE_FORMAT(ub.datetime_modified, '%Y %b %d %a')
            ) ORDER BY ub.datetime_created, ub.description
        )
    ) AS response
    FROM 
        inventory.unit_bins ub
    INNER JOIN 
        subscriber_common_tables.units u 
    ON 
        ub.unit_id = u.unit_id
    INNER JOIN 
        application_users_inventory.application_users au 
    ON 
        ub.created_by = au.user_id
    LEFT JOIN 
        application_users_inventory.application_users au2 
    ON 
        ub.modified_by = au2.user_id
    ${whereCredentials}
  `;
}

export function getUnitBinExceptOneQuery(jsonParam: string): string {
  const params = JSON.parse(jsonParam);
  const intUnitId = params.unit_id ? Number(params.unit_id) : 0;
  const charDescription = params.description || '';
  const intBinId = params.bin_id ? Number(params.bin_id) : 0;

  const escapedDesc = charDescription.replace(/'/g, "''");

  return `
    SELECT JSON_OBJECT(
        'success', TRUE,
        'message', 'Unit bins retrieved successfully.',
        'json_data', COALESCE(
            JSON_ARRAYAGG(
                JSON_OBJECT(
                    'bin_id', bin_id,
                    'bin', bin
                )
            ),
            JSON_ARRAY()
        )
    ) AS response
    FROM (
        SELECT ub.bin_id, ub.description AS bin
        FROM inventory.unit_bins ub
        WHERE ub.unit_id = ${intUnitId}
          AND ub.description LIKE '%${escapedDesc}%'
          AND ub.bin_id NOT IN (${intBinId})
    ) AS combined
  `;
}

export function postInventoryUnitBinQuery(jsonParam: string): string[] {
  const params = JSON.parse(jsonParam);
  const processType = Number(params.process_type);
  const binId = Number(params.bin_id || 0);
  const unitId = Number(params.unit_id || 0);
  const description = params.description ? params.description.replace(/'/g, "''") : '';
  const userId = Number(params.user_id || 0);

  const queries: string[] = [];

  if (processType === 0) {
    // Add bin
    queries.push(`START TRANSACTION`);
    queries.push(`
      INSERT INTO inventory.unit_bins (unit_id, description, created_by)
      VALUES (${unitId}, '${description}', ${userId})
    `);
    queries.push(`COMMIT`);
    queries.push(`SELECT JSON_OBJECT('success', TRUE, 'message', 'Item Bin Successfully Saved!', 'json_data', LAST_INSERT_ID()) AS response`);
  } else if (processType === 1) {
    // Edit bin
    queries.push(`START TRANSACTION`);
    queries.push(`
      UPDATE inventory.unit_bins SET
        unit_id = ${unitId},
        description = '${description}',
        modified_by = ${userId},
        datetime_modified = NOW()
      WHERE bin_id = ${binId}
    `);
    queries.push(`COMMIT`);
    queries.push(`SELECT JSON_OBJECT('success', TRUE, 'message', 'Item Bin Successfully Updated!', 'json_data', ${binId}) AS response`);
  } else if (processType === 2) {
    // Delete bin
    queries.push(`START TRANSACTION`);
    queries.push(`DELETE FROM inventory.unit_bins WHERE bin_id = ${binId}`);
    queries.push(`COMMIT`);
    queries.push(`SELECT JSON_OBJECT('success', TRUE, 'message', 'Item Bin Successfully Deleted!', 'json_data', ${binId}) AS response`);
  }

  return queries;
}
