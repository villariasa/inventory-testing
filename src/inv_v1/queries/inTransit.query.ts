export function getInstransitReportQuery(jsonParam: string): string[] {
  const params = JSON.parse(jsonParam);
  const search = params.search ? params.search.replace(/'/g, "''") : '';

  return [
    `DROP TEMPORARY TABLE IF EXISTS purchases_ap.po_in_transits`,
    `CREATE TEMPORARY TABLE purchases_ap.po_in_transits (INDEX po_id (po_id))
    SELECT fd.po_id, pm.supplier_id
    FROM purchases_ap.for_deliveries fd
    INNER JOIN purchases_ap.po_main pm ON fd.po_id = pm.po_id
    LEFT JOIN purchases_ap.deliveries d ON fd.for_delivery_id = d.for_delivery_id
    WHERE fd.confirmed AND ISNULL(d.for_delivery_id)`,
    `SELECT JSON_OBJECT(
      'success', TRUE,
      'message', 'Records retrieved successfully.',
      'json_data', JSON_ARRAYAGG(response)
    ) AS response
    FROM (
      SELECT JSON_OBJECT(
        'po_id', LPAD(pm.po_id, 8, '0'),
        'entity_name', en.entity_name,
        'deliver_to', u.description,
        'item_id', iic.item_id,
        'unit_item_id', iui.unit_item_id,
        'item_description', iic.item_description,
        'date_confirmed', DATE_FORMAT(fd.date_confirmed, '%m/%d/%Y'),
        'quantity', CASE WHEN iu.warehouse THEN CONCAT(fdd.quantity, ' ', ii.stocking_unit) ELSE CONCAT(fdd.quantity, ' ', ii.retail_unit) END,
        'unit_cost', fdd.unit_cost,
        'total_cost', fdd.total_cost
      ) AS response
      FROM purchases_ap.for_deliveries_details fdd
      INNER JOIN purchases_ap.for_deliveries fd ON fdd.for_delivery_id = fd.for_delivery_id
      INNER JOIN purchases_ap.po_details pd ON (fd.po_id, fdd.unit_item_id) = (pd.po_id, pd.unit_item_id)
      INNER JOIN purchases_ap.po_in_transits pm ON fd.po_id = pm.po_id
      INNER JOIN entities_udf_and_views.entity_name en ON pm.supplier_id = en.entity_id
      INNER JOIN inventory.inventory_units_items iui ON fdd.unit_item_id = iui.unit_item_id
      INNER JOIN inventory_udf_and_views.inventory_item_concat iic ON iui.item_id = iic.item_id
      INNER JOIN subscriber_common_tables.units u ON iui.unit_id = u.unit_id
      LEFT JOIN purchases_ap.deliveries d ON fd.for_delivery_id = d.for_delivery_id
      LEFT JOIN inventory.inventory_units iu ON iui.unit_id = iu.unit_id
      LEFT JOIN inventory.inventory_items ii ON iui.item_id = ii.item_id
      WHERE ISNULL(d.for_delivery_id)
      AND ('${search}' = '' OR en.entity_name LIKE '%${search}%' OR iic.item_description LIKE '%${search}%' OR u.description LIKE '%${search}%')
      GROUP BY pm.po_id, en.entity_name, u.description, iic.item_id, iui.unit_item_id, iic.item_description, fd.date_confirmed, fdd.for_delivery_id
      ORDER BY fd.date_confirmed
    ) AS json_data`
  ];
}

export function getInTransitReportQuery(jsonParam: string): string[] {
  return [
    `DROP TEMPORARY TABLE IF EXISTS purchases_ap.po_in_transits`,
    `CREATE TEMPORARY TABLE purchases_ap.po_in_transits (po_id INT, INDEX po_in_transits_po_id (po_id))
    SELECT DISTINCT fd.po_id
    FROM purchases_ap.for_deliveries fd
    LEFT JOIN purchases_ap.deliveries d ON d.for_delivery_id = fd.for_delivery_id
    WHERE ISNULL(d.for_delivery_id)`,
    `SELECT JSON_OBJECT(
      'success', TRUE,
      'message', 'In-transit report retrieved successfully.',
      'json_data', JSON_ARRAYAGG(JSON_OBJECT(
        'po_id', pm.po_id,
        'entity_name', en.entity_name,
        'deliver_to', u.description,
        'item_id', iic.item_id,
        'unit_item_id', iui.unit_item_id,
        'item_description', iic.item_description,
        'date_confirmed', fd.date_confirmed,
        'quantity', fdd.quantity,
        'unit_cost', fdd.unit_cost,
        'total_cost', fdd.total_cost
      ))
    ) AS response
    FROM purchases_ap.for_deliveries_details fdd
    INNER JOIN purchases_ap.for_deliveries fd ON fd.for_delivery_id = fdd.for_delivery_id
    INNER JOIN purchases_ap.po_main pm ON pm.po_id = fd.po_id
    INNER JOIN entities_udf_and_views.entity_name en ON en.entity_id = pm.supplier_id
    INNER JOIN subscriber_common_tables.units u ON u.unit_id = pm.unit_id
    INNER JOIN inventory.inventory_units_items iui ON iui.unit_item_id = fdd.unit_item_id
    INNER JOIN inventory_udf_and_views.inventory_item_concat iic ON iic.item_id = iui.item_id
    LEFT JOIN purchases_ap.deliveries d ON d.for_delivery_id = fd.for_delivery_id
    WHERE ISNULL(d.for_delivery_id)`
  ];
}

export function getInTransitItemsInvoicesQuery(jsonParam: string): string {
  const params = JSON.parse(jsonParam);
  const bolGetOne = params.bol_getone;
  const intInvoiceId = params.invoice_id ? Number(params.invoice_id) : null;
  const intUserId = params.user_id ? Number(params.user_id) : 1;
  const charInvoiceReference = params.invoice_reference || '';

  let whereCredentials = '';
  if (bolGetOne) {
    whereCredentials = `AND pi2.invoice_id = ${intInvoiceId}`;
  } else if (charInvoiceReference !== '') {
    const escapedRef = charInvoiceReference.replace(/'/g, "''");
    whereCredentials = `AND LOWER(invoice_reference) LIKE '%${escapedRef.toLowerCase()}%'`;
  }

  return `
    SELECT JSON_OBJECT(
      'success', TRUE,
      'message', 'In-transit item invoices retrieved successfully.',
      'json_data', JSON_ARRAYAGG(
        JSON_OBJECT(
          'invoice_id', aa.invoice_id,
          'invoice_reference', aa.invoice_reference,
          'in_transit_items', aa.in_transit_items
        ) ORDER BY aa.invoice_reference
      )
    ) AS response
    FROM (
      SELECT
        pi2.invoice_id,
        pi2.invoice_reference,
        JSON_ARRAYAGG(
          JSON_OBJECT(
            'item_id', iic.item_id,
            'unit_item_id', iti.unit_item_id,
            'item_description', iic.item_description,
            'total_running_quantity', iti.running_quantity
          )
        ) AS in_transit_items
      FROM point_of_sales_ar.pos_invoices pi2
      INNER JOIN inventory.in_transit_items iti ON iti.invoice_id = pi2.invoice_id
      INNER JOIN inventory.inventory_units_items iui ON iui.unit_item_id = iti.unit_item_id
      INNER JOIN inventory_udf_and_views.inventory_item_concat iic ON iic.item_id = iui.item_id
      INNER JOIN application_users_inventory.application_users au ON au.user_id = ${intUserId}
      WHERE iti.running_quantity > 0
        AND au.unit_id IN (
          SELECT unit_id FROM application_users_inventory.application_users WHERE user_id = ${intUserId}
        )
        ${whereCredentials}
      GROUP BY pi2.invoice_id, pi2.invoice_reference
    ) aa
  `;
}

export function postConfirmInTransitItemsQuery(jsonParam: string): string[] {
  const params = JSON.parse(jsonParam);
  const userId = Number(params.user_id || 0);
  const items: { item_transit_id: number; quantity_confirmed: number; unit_item_id: number }[] = Array.isArray(params.items) ? params.items : [];

  const queries: string[] = [];
  queries.push(`START TRANSACTION`);

  for (const item of items) {
    const inTransitId = Number(item.item_transit_id);
    const qtyConfirmed = Number(item.quantity_confirmed);
    const unitItemId = Number(item.unit_item_id);

    // Insert confirmed transit record
    queries.push(`
      INSERT INTO inventory.confirmed_transit_items (item_transit_id, quantity_confirmed, confirmed_by)
      VALUES (${inTransitId}, ${qtyConfirmed}, ${userId})
    `);
    // Reduce running quantity in transit
    queries.push(`
      UPDATE inventory.in_transit_items SET
        running_quantity = running_quantity - ${qtyConfirmed}
      WHERE item_transit_id = ${inTransitId}
    `);
    // Move quantity from float to ending (confirmed to inventory)
    queries.push(`
      UPDATE inventory.inventory_units_items SET
        float_cost = float_cost - ((float_cost / NULLIF(float_quantity, 0)) * ${qtyConfirmed}),
        ending_cost = ending_cost + ((float_cost / NULLIF(float_quantity, 0)) * ${qtyConfirmed}),
        float_quantity = float_quantity - ${qtyConfirmed},
        ending_quantity = ending_quantity + ${qtyConfirmed},
        unit_cost = IF((ending_quantity + ${qtyConfirmed}) > 0, (ending_cost + ((float_cost / NULLIF(float_quantity, 0)) * ${qtyConfirmed})) / (ending_quantity + ${qtyConfirmed}), 0)
      WHERE unit_item_id = ${unitItemId}
      LIMIT 1
    `);
  }

  queries.push(`COMMIT`);
  queries.push(`SELECT JSON_OBJECT('success', TRUE, 'message', 'In-transit items successfully confirmed!', 'json_data', 0) AS response`);
  return queries;
}
