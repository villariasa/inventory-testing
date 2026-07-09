export function getItemForAdjustmentQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getItemForAdjustment('${jsonParam}')`;
}

export function getInventoryItemAdjustmentQuery(jsonParam: string): string {
  const params = JSON.parse(jsonParam);
  const bolGetOne = params.bol_getone;
  const intAdjustmentId = params.adjustment_id ? Number(params.adjustment_id) : null;
  const dteDateFrom = params.date_from || '';
  const dteDateTo = params.date_to || '';

  let whereCredentials = '';
  if (bolGetOne) {
    whereCredentials = `WHERE ia.adjustment_id = ${intAdjustmentId}`;
  } else {
    whereCredentials = `WHERE DATE(ia.adjustment_date) BETWEEN '${dteDateFrom}' AND '${dteDateTo}'`;
  }

  return `
    SELECT JSON_OBJECT(
        'success', TRUE,
        'message', 'Inventory item adjustments retrieved successfully.',
        'json_data', JSON_ARRAYAGG(
            JSON_OBJECT(
                'adjustment_id', ia.adjustment_id,
                'adjustment_date', ia.adjustment_date,
                'frmt_adjustment_date', DATE_FORMAT(ia.adjustment_date, '%Y %b %d %a'),
                'template_id', ia.template_id,
                'template', iat.description,
                'destination_id', ia.destination_id,
                'destination_unit', u.description,
                'source_id', ia.source_id,
                'source_unit', u2.description,
                'item_id', ia.item_id,
                'item_description', iic.item_description,
                'quantity', FORMAT(ia.quantity, 2),
                'unit_cost', FORMAT(ia.unit_cost, 2),
                'total_cost', FORMAT((ia.unit_cost * ia.quantity), 2),
                'remarks', ia.remarks,
                'created_by', ia.created_by,
                'datetime_created', ia.datetime_created,
                'batch_id', ia.batch_id
            ) ORDER BY ia.adjustment_date
        )
    ) AS response
    FROM 
        inventory.items_adjustments ia
    INNER JOIN 
        inventory.items_adjustments_templates iat 
    ON 
        ia.template_id = iat.template_id
    LEFT JOIN 
        inventory.inventory_units_items iui 
    ON 
        ia.destination_id = iui.unit_item_id
    LEFT JOIN 
        subscriber_common_tables.units u 
    ON 
        iui.unit_id = u.unit_id
    LEFT JOIN 
        inventory.inventory_units_items iui2 
    ON 
        ia.source_id = iui2.unit_item_id
    LEFT JOIN 
        subscriber_common_tables.units u2 
    ON 
        iui2.unit_id = u2.unit_id
    LEFT JOIN 
        inventory_udf_and_views.inventory_item_concat iic 
    ON 
        ia.item_id = iic.item_id
    ${whereCredentials}
  `;
}

export function getInventoryItemAdjustmentTemplateQuery(jsonParam: string): string {
  const params = JSON.parse(jsonParam);
  const bolGetOne = params.bol_getone;
  const intTemplateId = params.template_id ? Number(params.template_id) : null;
  const charDescription = params.description || '';

  let whereCredentials = '';
  if (bolGetOne) {
    whereCredentials = `WHERE iat.template_id = ${intTemplateId}`;
  } else if (charDescription !== '') {
    const escapedDesc = charDescription.replace(/'/g, "''");
    whereCredentials = `WHERE LOWER(iat.description) LIKE '%${escapedDesc.toLowerCase()}%'`;
  }

  return `
    SELECT JSON_OBJECT(
        'success', TRUE,
        'message', 'Inventory item adjustment templates retrieved successfully.',
        'json_data', JSON_ARRAYAGG(
            JSON_OBJECT(
                'deleteable', ISNULL(ia.adjustment_id),
                'template_id', iat.template_id,
                'template_ind', CASE WHEN iat.add_to_quantity AND iat.require_destination_and_source THEN 0 WHEN iat.add_to_quantity AND !iat.require_destination_and_source THEN 1 WHEN !iat.add_to_quantity AND !iat.require_destination_and_source THEN 2 ELSE 99 END,
                'description', iat.description,
                'add_to_quantity', iat.add_to_quantity,
                'add_to_quantity_desc', IF(iat.add_to_quantity, 'Yes', 'No'),
                'require_destination_and_source', iat.require_destination_and_source,
                'require_destination_and_source_desc', IF(iat.require_destination_and_source, 'Yes', 'No'),
                'created_by', iat.created_by,
                'creator', au.user_login_name,
                'datetime_created', iat.datetime_created,
                'frmt_datetime_created', DATE_FORMAT(iat.datetime_created, '%Y %b %d %a'),
                'modified_by', iat.modified_by,
                'modifier', au2.user_login_name,
                'datetime_modified', iat.datetime_modified,
                'frmt_datetime_modified', DATE_FORMAT(iat.datetime_modified , '%Y %b %d %a')
            ) ORDER BY iat.datetime_created ,iat.description
        )
    ) AS response
    FROM 
        inventory.items_adjustments_templates iat
    INNER JOIN 
        application_users_inventory.application_users au 
    ON 
        iat.created_by = au.user_id
    LEFT JOIN 
        application_users_inventory.application_users au2 
    ON 
        iat.modified_by = au2.user_id
    LEFT JOIN (
        SELECT 
            ia.template_id,
            ia.adjustment_id
        FROM 
            inventory.items_adjustments ia
        GROUP BY 
            ia.template_id
    ) AS ia
    ON 
        iat.template_id = ia.template_id
    ${whereCredentials}
  `;
}

export function postInventoryItemAdjustmentQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.postInventoryItemAdjustment('${jsonParam}')`;
}

export function postInventoryItemAdjustmentTemplateQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.postInventoryItemAdjustmentTemplate('${jsonParam}')`;
}
