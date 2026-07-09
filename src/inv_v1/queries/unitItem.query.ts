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

export function postUnitItemBinSwitchQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.postUnitItemBinSwitch('${jsonParam}')`;
}

export function postInventoryUnitItemQuery(jsonParam: string): string {
  return `CALL inventory_udf_and_views.postInventoryUnitItem('${jsonParam}')`;
}
