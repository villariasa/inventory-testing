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

export function postItemImportsQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.postItemImports('${jsonParam}')`;
}
