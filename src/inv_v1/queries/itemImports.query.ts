export function getItemImportListQuery(jsonParam: string): string {
  return `
    SELECT JSON_OBJECT(
        'success', TRUE,
        'message', 'Item import list retrieved successfully.',
        'json_data', JSON_ARRAY(
            JSON_OBJECT('import_name', 'Brand', 'import_type', 'brand'),
            JSON_OBJECT('import_name', 'Size', 'import_type', 'size'),
            JSON_OBJECT('import_name', 'Part Description', 'import_type', 'vehiclePart'),
            JSON_OBJECT('import_name', 'Part Number', 'import_type', 'vehiclePartNumber')
        )
    ) AS response
  `;
}

export function getItemImportsQuery(jsonParam: string): string {
  const params = JSON.parse(jsonParam);
  const charImportType = params.import_type;
  const bolGetOne = params.bol_getone;
  const intId = params.id ? Number(params.id) : 0;
  const charDescription = params.description || '';

  let charImportId = '';
  let charImportTable = '';

  if (charImportType === 'brand') {
    charImportId = 'brand_id';
    charImportTable = 'brands';
  } else if (charImportType === 'ratio') {
    charImportId = 'ratio_id';
    charImportTable = 'ratios';
  } else if (charImportType === 'size') {
    charImportId = 'size_id';
    charImportTable = 'sizes';
  } else if (charImportType === 'threadPattern') {
    charImportId = 'pattern_id';
    charImportTable = 'thread_patterns';
  } else if (charImportType === 'valveType') {
    charImportId = 'valve_id';
    charImportTable = 'valve_types';
  } else if (charImportType === 'vehiclePart') {
    charImportId = 'part_id';
    charImportTable = 'vehicle_parts';
  } else if (charImportType === 'vehiclePartNumber') {
    charImportId = 'part_number_id';
    charImportTable = 'vehicle_part_numbers';
  } else {
    // Default fallback to prevent crash, returns empty envelope
    return `SELECT JSON_OBJECT('success', FALSE, 'message', 'Invalid JSON parameter.', 'json_data', NULL) AS response`;
  }

  let whereCredentials = '';
  if (bolGetOne) {
    whereCredentials = `WHERE ${charImportId} = ${intId}`;
  } else if (charDescription !== '') {
    const escapedDesc = charDescription.replace(/'/g, "''");
    whereCredentials = `WHERE LOWER(description) LIKE '%${escapedDesc.toLowerCase()}%'`;
  }

  return `
    SELECT JSON_OBJECT(
        'success', TRUE,
        'message', 'Item imports retrieved successfully.',
        'json_data', JSON_ARRAYAGG(
            JSON_OBJECT(
                'id', ${charImportId},
                'description', description
            ) ORDER BY description
        )
    ) AS response
    FROM inventory.${charImportTable}
    ${whereCredentials}
  `;
}

export function getImportItemsQuery(jsonParam: string): string {
  const params = JSON.parse(jsonParam);
  const charItemDescription = params.item_description || '';
  const intUnitId = params.unit_id ? Number(params.unit_id) : 0;

  let whereCredentials = '';
  if (charItemDescription !== '') {
    const escapedDesc = charItemDescription.replace(/'/g, "''");
    whereCredentials = `AND LOWER(iic.item_description) LIKE '%${escapedDesc.toLowerCase()}%'`;
  }

  return `
    SELECT 
        JSON_OBJECT(
            'success', TRUE,
            'message', 'Records retrieved successfully.',
            'json_data', JSON_ARRAYAGG(
                JSON_OBJECT(
                    'item_id', iic.item_id,
                    'unit_item_id', aa.unit_item_id,
                    'unit', aa.unit,
                    'item_description', iic.item_description
                ) ORDER BY iic.item_description
            )
        ) AS response
    FROM 
        inventory_udf_and_views.inventory_item_concat iic
    LEFT JOIN (
        SELECT 
            iui.item_id,
            iui.unit_item_id,
            IF(COALESCE(iu.warehouse, FALSE), ii.stocking_unit, ii.retail_unit) AS unit
        FROM 
            inventory.inventory_units_items iui
        INNER JOIN
            inventory.inventory_units iu
        ON
            iui.unit_id = iu.unit_id
        INNER JOIN
            inventory.inventory_items ii
        ON
            iui.item_id = ii.item_id
        WHERE 
            iui.unit_id = ${intUnitId}
    ) AS aa
    ON
        iic.item_id = aa.item_id
    LEFT JOIN 
        inventory.inventory_empty_cases iec 
    ON 
        iec.empty_item_id = iic.item_id
    WHERE 1=1
        ${whereCredentials}
  `;
}

export function postItemImportsQuery(jsonParam: string): string[] {
  const params = JSON.parse(jsonParam);
  const processType = Number(params.process_type);
  const importType = params.import_type || '';
  const description = params.description ? params.description.replace(/'/g, "''") : '';
  const id = Number(params.id || 0);
  const userId = Number(params.user_id || 0);

  // Map importType to table name, ID column name, and display name
  const importMap: Record<string, { table: string; idCol: string; name: string }> = {
    brand:             { table: 'brands',               idCol: 'brand_id',       name: 'Brand' },
    ratio:             { table: 'ratios',                idCol: 'ratio_id',       name: 'Ply Rating' },
    size:              { table: 'sizes',                 idCol: 'size_id',        name: 'Size' },
    threadPattern:     { table: 'thread_patterns',       idCol: 'pattern_id',     name: 'Thread Pattern' },
    valveType:         { table: 'valve_types',           idCol: 'valve_id',       name: 'Valve Type' },
    vehiclePart:       { table: 'vehicle_parts',         idCol: 'part_id',        name: 'Vehicle Part' },
    vehiclePartNumber: { table: 'vehicle_part_numbers',  idCol: 'part_number_id', name: 'Vehicle Part Number' },
  };

  const mapping = importMap[importType];
  if (!mapping) {
    return [`SELECT JSON_OBJECT('success', FALSE, 'message', 'Invalid import type!', 'json_data', NULL) AS response`];
  }

  const { table, idCol, name } = mapping;
  const queries: string[] = [];

  if (processType === 0) {
    // Add
    queries.push(`START TRANSACTION`);
    queries.push(`INSERT INTO inventory.${table} (description, created_by) VALUES ('${description}', ${userId})`);
    queries.push(`COMMIT`);
    queries.push(`SELECT JSON_OBJECT('success', TRUE, 'message', '${name} Successfully Saved!', 'json_data', LAST_INSERT_ID()) AS response`);
  } else if (processType === 1) {
    // Edit
    queries.push(`START TRANSACTION`);
    queries.push(`
      UPDATE inventory.${table} SET
        description = '${description}',
        modified_by = ${userId},
        datetime_modified = NOW()
      WHERE ${idCol} = ${id}
    `);
    queries.push(`COMMIT`);
    queries.push(`SELECT JSON_OBJECT('success', TRUE, 'message', '${name} Successfully Updated!', 'json_data', ${id}) AS response`);
  } else if (processType === 2) {
    // Delete
    queries.push(`START TRANSACTION`);
    queries.push(`DELETE FROM inventory.${table} WHERE ${idCol} = ${id}`);
    queries.push(`COMMIT`);
    queries.push(`SELECT JSON_OBJECT('success', TRUE, 'message', '${name} Successfully Deleted!', 'json_data', ${id}) AS response`);
  }

  return queries;
}
