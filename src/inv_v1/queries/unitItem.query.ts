export function getInventoryUnitItemQuery(jsonParam: string): string {
  const params = JSON.parse(jsonParam);
  const bolGetOne = params.bol_getone;
  const intUnitId = params.unit_id ? Number(params.unit_id) : null;
  const intItemCategoryId = params.item_category_id ? Number(params.item_category_id) : null;
  const intUnitItemId = params.unit_item_id ? Number(params.unit_item_id) : null;
  const charItemDescription = params.item_description || '';

  let whereCredentials = '';
  const conditions: string[] = [];

  if (intUnitId !== null && intUnitId !== 0) {
    conditions.push(`u.unit_id = ${intUnitId}`);
  }
  if (intItemCategoryId !== null && intItemCategoryId !== 0) {
    conditions.push(`ii.item_category_id = ${intItemCategoryId}`);
  }

  if (bolGetOne) {
    conditions.push(`iui.unit_item_id = ${intUnitItemId}`);
    whereCredentials = `WHERE ` + conditions.join(' AND ');
  } else {
    if (charItemDescription !== '') {
      const escapedDesc = charItemDescription.replace(/'/g, "''");
      conditions.push(`LOWER(iic.item_description) LIKE '%${escapedDesc.toLowerCase()}%'`);
    }
    whereCredentials = conditions.length > 0 ? `WHERE ` + conditions.join(' AND ') : '';
  }

  return `
    SELECT JSON_OBJECT(
        'success', TRUE, 
        'message', 'Inventory unit item retrieved successfully.', 
        'json_data', JSON_ARRAYAGG(
            JSON_OBJECT(
                'unit_item_id', iui.unit_item_id, 
                'is_used', IF(uic.unit_item_id IS NOT NULL, 1, 0), 
                'item_id', iui.item_id, 
                'item_description', iic.item_description, 
                'item_category_id', ii.item_category_id, 
                'item_category', ic.description, 
                'unit_id', iui.unit_id, 
                'unit', u.description, 
                'bin_id', ub.bin_id, 
                'bin', ub.description, 
                'starting_period', iui.starting_period, 
                'last_entry', iui.last_entry, 
                'starting_quantity', FORMAT(iui.starting_quantity, 2), 
                'quantity_in', FORMAT(iui.quantity_in, 2), 
                'quantity_out', FORMAT(iui.quantity_out, 2), 
                'ending_quantity', FORMAT(iui.ending_quantity, 2), 
                'starting_cost', FORMAT(iui.starting_cost, 2), 
                'cost_in', FORMAT(iui.cost_in, 2), 
                'cost_out', FORMAT(iui.cost_out, 2), 
                'ending_cost', FORMAT(iui.ending_cost, 2), 
                'unit_cost', FORMAT(iui.unit_cost, 2), 
                'last_highest_in_unit_cost', FORMAT(iui.last_highest_in_unit_cost, 2), 
                'created_by', iui.created_by, 
                'datetime_created', iui.datetime_created, 
                'modified_by', iui.modified_by, 
                'datetime_modified', iui.datetime_modified
            ) ORDER BY iui.datetime_created, u.description, iic.item_description
        )
    ) AS response 
    FROM 
        inventory.inventory_units_items iui 
    INNER JOIN 
        subscriber_common_tables.units u 
    ON 
        iui.unit_id = u.unit_id 
    INNER JOIN 
        inventory_udf_and_views.inventory_item_concat iic 
    ON 
        iui.item_id = iic.item_id 
    INNER JOIN 
        inventory.inventory_items ii 
    ON 
        iui.item_id = ii.item_id 
    INNER JOIN 
        inventory.items_categories ic 
    ON 
        ii.item_category_id = ic.item_category_id 
    INNER JOIN 
        inventory.unit_bins ub 
    ON 
        iui.bin_id = ub.bin_id 
    LEFT JOIN 
        inventory_udf_and_views.unit_item_checking uic 
    ON 
        iui.unit_item_id = uic.unit_item_id 
    LEFT JOIN 
        inventory.inventory_empty_cases iec 
    ON 
        iec.empty_item_id = ii.item_id
    ${whereCredentials}
  `;
}

export function getUnitItemInfoByBinQuery(jsonParam: string): string {
  const params = JSON.parse(jsonParam);
  const intBinId = params.bin_id ? Number(params.bin_id) : 0;

  return `
    SELECT JSON_OBJECT(
        'success', TRUE,
        'message', 'Unit item info retrieved successfully.',
        'json_data', COALESCE(
            JSON_ARRAYAGG(
                JSON_OBJECT(
                    'unit_item_id', unit_item_id,
                    'item_description', item_description,
                    'from_bin_id', from_bin_id,
                    'from_bin', from_bin
                )
            ),
            JSON_ARRAY()
        )
    ) AS response
    FROM (
        SELECT
            uii.unit_item_id,
            iic.item_description,
            ub.bin_id AS from_bin_id,
            ub.description AS from_bin
        FROM 
            inventory.inventory_units_items uii
        INNER JOIN 
            inventory_udf_and_views.inventory_item_concat iic 
        ON 
            iic.item_id = uii.item_id
        INNER JOIN 
            inventory.unit_bins ub 
        ON 
            ub.bin_id = uii.bin_id
        WHERE 
            ub.bin_id = ${intBinId}
    ) AS combined
  `;
}

export function postUnitItemBinSwitchQuery(jsonParam: string): string[] {
  const params = JSON.parse(jsonParam);
  const userId = Number(params.user_id || 0);
  const switches: { unit_item_id: number; from_bin_id: number; to_bin_id: number }[] = Array.isArray(params.switches) ? params.switches : [];

  const queries: string[] = [];
  queries.push(`START TRANSACTION`);

  for (const s of switches) {
    queries.push(`
      UPDATE inventory.inventory_units_items SET
        bin_id = ${Number(s.to_bin_id)},
        modified_by = ${userId},
        datetime_modified = NOW()
      WHERE unit_item_id = ${Number(s.unit_item_id)}
    `);
  }

  queries.push(`COMMIT`);
  queries.push(`SELECT JSON_OBJECT('success', TRUE, 'message', 'Items\' Bins Successfully Updated!', 'json_data', NULL) AS response`);
  return queries;
}

export function postInventoryUnitItemQuery(jsonParam: string): string[] {
  const params = JSON.parse(jsonParam);
  const processType = Number(params.process_type);
  const unitItemId = Number(params.unit_item_id || 0);
  const itemId = Number(params.item_id || 0);
  const unitId = Number(params.unit_id || 0);
  const startingPeriod = params.starting_period ? `'${params.starting_period}'` : 'NOW()';
  const startingQty = Number(params.starting_quantity || 0);
  const qtyIn = Number(params.quantity_in || 0);
  const qtyOut = Number(params.quantity_out || 0);
  const endingQty = startingQty + qtyIn - qtyOut;
  const unitCost = Number(params.unit_cost || 0);
  const startingCost = unitCost * startingQty;
  const costIn = unitCost * qtyIn;
  const costOut = unitCost * qtyOut;
  const endingCost = unitCost * endingQty;
  const lastHighestInUnitCost = Number(params.last_highest_in_unit_cost || 0);
  const binId = Number(params.bin_id || 0);
  const userId = Number(params.user_id || 0);

  const queries: string[] = [];

  if (processType === 0) {
    // Add unit item
    queries.push(`START TRANSACTION`);
    queries.push(`
      INSERT INTO inventory.inventory_units_items
        (item_id, unit_id, starting_period, last_entry, starting_quantity, quantity_in, quantity_out,
         ending_quantity, starting_cost, cost_in, cost_out, ending_cost, unit_cost,
         last_highest_in_unit_cost, bin_id, created_by)
      VALUES
        (${itemId}, ${unitId}, ${startingPeriod}, NOW(), ${startingQty}, ${qtyIn}, ${qtyOut},
         ${endingQty}, ${startingCost}, ${costIn}, ${costOut}, ${endingCost}, ${unitCost},
         ${lastHighestInUnitCost}, ${binId}, ${userId})
    `);
    queries.push(`SET @unit_item_id := LAST_INSERT_ID()`);
    // __FIRST_INSERT_ID__ is tracked by dbconn.ts after the INSERT above
    // Update wtd_ave_cost and last_highest_in_unit_cost on inventory_items
    queries.push(`
      UPDATE inventory.inventory_items i
      JOIN (
        SELECT
          a.item_id,
          IFNULL(SUM(iui.ending_cost) / NULLIF(SUM(IF(iu.warehouse, iui.ending_quantity * ii.rtu_over_stu, iui.ending_quantity)), 0), 0) AS unit_cost,
          MAX(IF(iu.warehouse, (iui.last_highest_in_unit_cost / ii.rtu_over_stu), iui.last_highest_in_unit_cost)) AS last_highest_in_unit_cost
        FROM inventory.inventory_units_items a
        INNER JOIN inventory.inventory_units_items iui ON iui.item_id = a.item_id
        INNER JOIN inventory.inventory_items ii ON iui.item_id = ii.item_id
        INNER JOIN inventory.inventory_units iu ON iui.unit_id = iu.unit_id
        WHERE a.unit_item_id = __FIRST_INSERT_ID__
        GROUP BY a.item_id
      ) u ON i.item_id = u.item_id
      SET
        i.wtd_ave_cost = IFNULL(u.unit_cost, 0),
        i.last_highest_in_unit_cost = IF(i.last_highest_in_unit_cost > IFNULL(u.last_highest_in_unit_cost, 0), i.last_highest_in_unit_cost, IFNULL(u.last_highest_in_unit_cost, 0))
      LIMIT 1
    `);
    queries.push(`COMMIT`);
    queries.push(`SELECT JSON_OBJECT('success', TRUE, 'message', 'Inventory Unit Item Successfully Saved!', 'json_data', __FIRST_INSERT_ID__) AS response`);
  } else if (processType === 1) {
    // Edit unit item
    queries.push(`START TRANSACTION`);
    queries.push(`
      UPDATE inventory.inventory_units_items SET
        starting_period = ${startingPeriod},
        last_entry = NOW(),
        starting_quantity = ${startingQty},
        quantity_in = ${qtyIn},
        quantity_out = ${qtyOut},
        ending_quantity = ${endingQty},
        starting_cost = ${startingCost},
        cost_in = ${costIn},
        cost_out = ${costOut},
        ending_cost = ${endingCost},
        unit_cost = ${unitCost},
        last_highest_in_unit_cost = IF(${unitCost} > last_highest_in_unit_cost, ${unitCost}, last_highest_in_unit_cost),
        bin_id = ${binId},
        modified_by = ${userId},
        datetime_modified = NOW()
      WHERE unit_item_id = ${unitItemId}
    `);
    // Update item-level cost aggregations
    queries.push(`
      UPDATE inventory.inventory_items i
      JOIN (
        SELECT
          a.item_id,
          IFNULL(SUM(iui.ending_cost) / NULLIF(SUM(IF(iu.warehouse, iui.ending_quantity * ii.rtu_over_stu, iui.ending_quantity)), 0), 0) AS unit_cost,
          MAX(IF(iu.warehouse, (iui.last_highest_in_unit_cost / ii.rtu_over_stu), iui.last_highest_in_unit_cost)) AS last_highest_in_unit_cost
        FROM inventory.inventory_units_items a
        INNER JOIN inventory.inventory_units_items iui ON iui.item_id = a.item_id
        INNER JOIN inventory.inventory_items ii ON iui.item_id = ii.item_id
        INNER JOIN inventory.inventory_units iu ON iui.unit_id = iu.unit_id
        WHERE a.unit_item_id = ${unitItemId}
        GROUP BY a.item_id
      ) u ON i.item_id = u.item_id
      SET
        i.wtd_ave_cost = IFNULL(u.unit_cost, 0),
        i.last_highest_in_unit_cost = IF(i.last_highest_in_unit_cost > IFNULL(u.last_highest_in_unit_cost, 0), i.last_highest_in_unit_cost, IFNULL(u.last_highest_in_unit_cost, 0))
      LIMIT 1
    `);
    queries.push(`COMMIT`);
    queries.push(`SELECT JSON_OBJECT('success', TRUE, 'message', 'Inventory Unit Item Successfully Updated!', 'json_data', ${unitItemId}) AS response`);
  } else if (processType === 2) {
    // Delete unit item
    queries.push(`START TRANSACTION`);
    queries.push(`DELETE FROM inventory.inventory_units_items WHERE unit_item_id = ${unitItemId}`);
    queries.push(`COMMIT`);
    queries.push(`SELECT JSON_OBJECT('success', TRUE, 'message', 'Inventory Unit Item Successfully Deleted!', 'json_data', ${unitItemId}) AS response`);
  }

  return queries;
}
