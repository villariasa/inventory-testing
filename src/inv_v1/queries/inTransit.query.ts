export function getInstransitReportQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getInstransitReport('${jsonParam}')`;
}

export function getInTransitReportQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getInTransitReport('${jsonParam}')`;
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

export function postConfirmInTransitItemsQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.postConfirmInTransitItems('${jsonParam}')`;
}
