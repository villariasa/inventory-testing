export function getInventoryItemCategoryQuery(jsonParam: string): string {
  const params = JSON.parse(jsonParam);
  const bolGetOne = params.bol_getone;
  const intItemCategoryId = params.item_category_id ? Number(params.item_category_id) : null;
  const charDescription = params.description || '';

  let whereCredentials = '';
  if (bolGetOne) {
    whereCredentials = `WHERE ic.item_category_id = ${intItemCategoryId}`;
  } else if (charDescription !== '') {
    const escapedDesc = charDescription.replace(/'/g, "''");
    whereCredentials = `WHERE LOWER(ic.description) LIKE '%${escapedDesc.toLowerCase()}%'`;
  } else {
    whereCredentials = "WHERE !ic.predefined";
  }

  return `
    SELECT JSON_OBJECT(
        'success', TRUE,
        'message', 'Inventory item categories retrieved successfully.',
        'json_data', JSON_ARRAYAGG(
            JSON_OBJECT(
                'predefined', ic.predefined,
                'item_category_id', ic.item_category_id,
                'description', ic.description,
                'glsl_id', icgi.glsl_item,
                'glsl_item_elab', sac.account,
                'glsl_item', sac.search_account
            ) ORDER BY ic.predefined DESC, ic.description
        )
    ) AS response
    FROM 
        inventory.items_categories ic
    LEFT JOIN 
        inventory.item_category_glsl_item icgi 
    ON 
        ic.item_category_id = icgi.item_category_id
    LEFT JOIN 
        accounting.selectable_account_concatenated sac 
    ON 
        icgi.glsl_item = sac.glsl_id
    ${whereCredentials}
  `;
}

export function postInventoryItemCategoryQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.postInventoryItemCategory('${jsonParam}')`;
}
