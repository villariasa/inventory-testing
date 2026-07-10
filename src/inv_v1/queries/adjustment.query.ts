export function getItemForAdjustmentQuery(jsonParam: string): string {
  const params = JSON.parse(jsonParam);
  const templateId = Number(params.template_id || 0);
  const sourceUnitId = Number(params.source_unit_id || 0);
  const destinationUnitId = Number(params.destination_unit_id || 0);
  const itemDescription = params.item_description ? params.item_description.replace(/'/g, "''") : '';

  // This replicates the getItemForAdjustment SP for the common case (source unit items)
  return `
    SELECT JSON_OBJECT(
      'success', TRUE,
      'message', 'Items for adjustment retrieved successfully.',
      'json_data', JSON_ARRAYAGG(JSON_OBJECT(
        'item_id', iui.item_id,
        'item_description', iic.item_description,
        'unit', IF(iu.warehouse, ii.stocking_unit, ii.retail_unit),
        'unit_cost', iui.unit_cost,
        'quantity_cap', 1
      ) ORDER BY iic.item_description)
    ) AS response
    FROM inventory.inventory_units_items iui
    INNER JOIN inventory_udf_and_views.inventory_item_concat iic ON iui.item_id = iic.item_id
    INNER JOIN inventory.inventory_items ii ON iic.item_id = ii.item_id
    INNER JOIN inventory.inventory_units iu ON iui.unit_id = iu.unit_id
    WHERE iui.unit_id = ${sourceUnitId !== 0 ? sourceUnitId : destinationUnitId}
      AND LOWER(iic.item_description) LIKE '%${itemDescription.toLowerCase()}%'
      AND iui.ending_quantity > 0
  `;
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

export function postInventoryItemAdjustmentQuery(jsonParam: string): string[] {
  const params = JSON.parse(jsonParam);
  const templateId = Number(params.template_id || 0);
  const sourceUnitId = params.source_unit_id ? Number(params.source_unit_id) : null;
  const destinationUnitId = params.destination_unit_id ? Number(params.destination_unit_id) : null;
  const itemId = Number(params.item_id || 0);
  const quantity = Number(params.quantity || 0);
  const unitCost = Number(params.unit_cost || 0);
  const remarks = params.remarks ? params.remarks.replace(/'/g, "''") : '';
  const userId = Number(params.user_id || 0);
  const totalCost = quantity * unitCost;

  const queries: string[] = [];
  queries.push(`START TRANSACTION`);

  // Deduct from source unit item if source_unit_id is provided
  if (sourceUnitId !== null) {
    queries.push(`
      UPDATE inventory.inventory_units_items
      SET
        quantity_out = quantity_out + ${quantity},
        ending_quantity = ending_quantity - ${quantity},
        cost_out = cost_out + ${totalCost},
        ending_cost = ending_cost - ${totalCost}
      WHERE item_id = ${itemId} AND unit_id = ${sourceUnitId}
      LIMIT 1
    `);
  }

  // Add to destination unit item if destination_unit_id is provided
  if (destinationUnitId !== null) {
    queries.push(`
      UPDATE inventory.inventory_units_items
      SET
        quantity_in = quantity_in + ${quantity},
        ending_quantity = ending_quantity + ${quantity},
        cost_in = cost_in + ${totalCost},
        ending_cost = ending_cost + ${totalCost},
        unit_cost = IF(ending_quantity > 0, ending_cost / ending_quantity, 0),
        last_highest_in_unit_cost = IF(last_highest_in_unit_cost > ${unitCost}, last_highest_in_unit_cost, ${unitCost})
      WHERE item_id = ${itemId} AND unit_id = ${destinationUnitId}
      LIMIT 1
    `);
    // Update item-level cost aggregates
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
        WHERE a.item_id = ${itemId}
        GROUP BY a.item_id
      ) u ON i.item_id = u.item_id
      SET
        i.wtd_ave_cost = u.unit_cost,
        i.last_highest_in_unit_cost = IF(i.last_highest_in_unit_cost > u.last_highest_in_unit_cost, i.last_highest_in_unit_cost, u.last_highest_in_unit_cost),
        i.selling_price = IF(i.last_highest_in_unit_cost > u.last_highest_in_unit_cost, i.selling_price, u.last_highest_in_unit_cost * (1 + i.markup_rate))
      LIMIT 1
    `);
  }

  // Insert audit record
  queries.push(`
    INSERT INTO inventory.items_adjustments
      (adjustment_date, template_id, destination_id, source_id, item_id, quantity, unit_cost, remarks, created_by, datetime_created)
    VALUES
      (NOW(), ${templateId}, ${destinationUnitId !== null ? destinationUnitId : 'NULL'}, ${sourceUnitId !== null ? sourceUnitId : 'NULL'}, ${itemId}, ${quantity}, ${unitCost}, '${remarks}', ${userId}, NOW())
  `);

  queries.push(`COMMIT`);
  queries.push(`SELECT JSON_OBJECT('success', TRUE, 'message', 'The adjustment has been successfully applied.', 'json_data', LAST_INSERT_ID()) AS response`);
  return queries;
}

export function postInventoryItemAdjustmentTemplateQuery(jsonParam: string): string[] {
  const params = JSON.parse(jsonParam);
  const processType = Number(params.process_type);
  const templateId = Number(params.template_id || 0);
  const description = params.description ? params.description.replace(/'/g, "''") : '';
  const addToQuantity = params.add_to_quantity ? 1 : 0;
  const requireDestination = params.require_destination_and_source ? 1 : 0;
  const userId = Number(params.user_id || 0);

  const queries: string[] = [];

  if (processType === 0) {
    queries.push(`START TRANSACTION`);
    queries.push(`
      INSERT INTO inventory.items_adjustments_templates (description, add_to_quantity, require_destination_and_source, created_by)
      VALUES ('${description}', ${addToQuantity}, ${requireDestination}, ${userId})
    `);
    queries.push(`COMMIT`);
    queries.push(`SELECT JSON_OBJECT('success', TRUE, 'message', 'Adjustment template successfully saved!', 'json_data', LAST_INSERT_ID()) AS response`);
  } else if (processType === 1) {
    queries.push(`START TRANSACTION`);
    queries.push(`
      UPDATE inventory.items_adjustments_templates SET
        description = '${description}',
        add_to_quantity = ${addToQuantity},
        require_destination_and_source = ${requireDestination},
        modified_by = ${userId},
        datetime_modified = NOW()
      WHERE template_id = ${templateId}
    `);
    queries.push(`COMMIT`);
    queries.push(`SELECT JSON_OBJECT('success', TRUE, 'message', 'Adjustment template successfully updated!', 'json_data', ${templateId}) AS response`);
  } else if (processType === 2) {
    queries.push(`START TRANSACTION`);
    queries.push(`DELETE FROM inventory.items_adjustments_templates WHERE template_id = ${templateId}`);
    queries.push(`COMMIT`);
    queries.push(`SELECT JSON_OBJECT('success', TRUE, 'message', 'Adjustment template successfully deleted!', 'json_data', ${templateId}) AS response`);
  }

  return queries;
}
