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

export function postInventoryItemCategoryQuery(jsonParam: string): string[] {
  const params = JSON.parse(jsonParam);
  const processType = Number(params.process_type);
  const itemCategoryId = Number(params.item_category_id || 0);
  const description = params.description ? params.description.replace(/'/g, "''") : '';
  const glslId = params.glsl_id !== null && params.glsl_id !== undefined ? Number(params.glsl_id) : null;
  const userId = Number(params.user_id || 0);

  const queries: string[] = [];

  if (processType === 0) {
    // Add
    queries.push(`START TRANSACTION`);
    queries.push(`
      INSERT INTO inventory.items_categories (description, created_by)
      VALUES ('${description}', ${userId})
    `);
    // __FIRST_INSERT_ID__ is substituted by dbconn.ts with the newly created category ID
    if (glslId !== null) {
      queries.push(`
        INSERT INTO inventory.item_category_glsl_item (item_category_id, glsl_item)
        VALUES (__FIRST_INSERT_ID__, ${glslId})
      `);
    }
    queries.push(`COMMIT`);
    queries.push(`SELECT JSON_OBJECT('success', TRUE, 'message', 'Item Category Successfully Saved!', 'json_data', __FIRST_INSERT_ID__) AS response`);
  } else if (processType === 1) {
    // Edit
    queries.push(`START TRANSACTION`);
    queries.push(`
      UPDATE inventory.items_categories SET
        description = '${description}',
        modified_by = ${userId},
        datetime_modified = NOW()
      WHERE item_category_id = ${itemCategoryId}
    `);
    queries.push(`DELETE FROM inventory.item_category_glsl_item WHERE item_category_id = ${itemCategoryId}`);
    if (glslId !== null) {
      queries.push(`
        INSERT INTO inventory.item_category_glsl_item (item_category_id, glsl_item)
        VALUES (${itemCategoryId}, ${glslId})
      `);
    }
    queries.push(`COMMIT`);
    queries.push(`SELECT JSON_OBJECT('success', TRUE, 'message', 'Item Category Successfully Updated!', 'json_data', ${itemCategoryId}) AS response`);
  } else if (processType === 2) {
    // Delete
    queries.push(`START TRANSACTION`);
    queries.push(`DELETE FROM inventory.item_category_glsl_item WHERE item_category_id = ${itemCategoryId}`);
    queries.push(`DELETE FROM inventory.items_categories WHERE item_category_id = ${itemCategoryId}`);
    queries.push(`COMMIT`);
    queries.push(`SELECT JSON_OBJECT('success', TRUE, 'message', 'Item Category Successfully Deleted!', 'json_data', ${itemCategoryId}) AS response`);
  }

  return queries;
}
