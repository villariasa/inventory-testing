export function getInventoryItemQuery(jsonParam: string): string {
  const params = JSON.parse(jsonParam);
  const bolGetOne = params.bol_getone;
  const intItemCategoryId = params.item_category_id ? Number(params.item_category_id) : null;
  const intItemId = params.item_id ? Number(params.item_id) : null;
  const charItemDescription = params.item_description || '';
  const charBarcode = params.barcode || null;
  const bolBypassImageFilter = params.bypass_image_filter || false;

  let whereCredentials = 'WHERE 1=1';

  if (bolGetOne) {
    whereCredentials = `WHERE ii.item_id = ${intItemId}`;
    if (intItemCategoryId !== null) {
      whereCredentials += ` AND ii.item_category_id = ${intItemCategoryId}`;
    }
  } else {
    if (charBarcode !== null && charBarcode !== 'null' && charBarcode !== '') {
      whereCredentials += ` AND (bc.all_barcodes LIKE '%${charBarcode}%')`;
    }

    if (charItemDescription !== '') {
      const escapedDesc = charItemDescription.replace(/'/g, "''");
      whereCredentials += ` AND LOWER(iic.item_description) LIKE '%${escapedDesc.toLowerCase()}%'`;
    }

    if (intItemCategoryId !== null) {
      whereCredentials += ` AND ii.item_category_id = ${intItemCategoryId}`;
    } else {
      if ((charBarcode === null || charBarcode === '') && charItemDescription === '' && !bolBypassImageFilter) {
        whereCredentials += ` AND (img.item_id IS NULL OR img.image IS NULL OR CAST(img.image AS CHAR) = '')`;
      }
    }
  }

  return `
    SELECT JSON_OBJECT(
        'success', TRUE,
        'message', 'Inventory items retrieved successfully.',
        'json_data', JSON_ARRAYAGG(
            JSON_OBJECT(
                'item_id', ii.item_id,
                'item_description', iic.item_description,
                'item_category_id', ii.item_category_id,
                'item_category', ic.description,
                'brand_id', ii.brand_id,
                'brand', b.description,
                'model_description', ii.model_description,
                'part_id', ii.part_id,
                'vehicle_parts', vp.description,
                'part_number_id', ii.part_number_id,
                'vehicle_part_number', vpn.description,
                'size_id', ii.size_id,
                'size', s.description,
                'valve_id', ii.valve_id,
                'valve_type', vt.description,
                'ratio_id', ii.ratio_id,
                'ratio', r.description,
                'pattern_id', ii.pattern_id,
                'thread_pattern', tp.description,
                'stocking_unit', ii.stocking_unit,
                'retail_unit', ii.retail_unit,
                'rtu_over_stu', ii.rtu_over_stu,
                'wtd_ave_cost', ii.wtd_ave_cost,
                'markup_rate', (ii.markup_rate * 100),
                'selling_price', FORMAT(ii.selling_price, 2),
                'last_highest_in_unit_cost', ii.last_highest_in_unit_cost,
                'whole_quantity', COALESCE(wq.whole_quantity, CONCAT('0.00 ', ii.stocking_unit, ' & 0.00 ', ii.retail_unit)),
                'in_unit_item', !ISNULL(wq.item_id),
                'created_by', ii.created_by,
                'datetime_created', ii.datetime_created,
                'modified_by', ii.modified_by,
                'datetime_modified', ii.datetime_modified,
                'is_empty_case', iec.empty_item_id,
                'image', CAST(img.image AS CHAR),
                'barcodes', bc.barcodes_json
            ) ORDER BY ii.datetime_created DESC, iic.item_description
        )
    ) AS response
    FROM 
        inventory.inventory_items ii
    LEFT JOIN
        inventory_udf_and_views.inventory_item_concat iic 
    ON
        ii.item_id = iic.item_id
    LEFT JOIN
        inventory.items_categories ic
    ON
        ii.item_category_id = ic.item_category_id 
    LEFT JOIN 	
        inventory.brands b 
    ON
        ii.brand_id = b.brand_id 
    LEFT JOIN 	
        inventory.sizes s 
    ON
        ii.size_id = s.size_id 
    LEFT JOIN 
        inventory.ratios r 
    ON
        ii.ratio_id = r.ratio_id 
    LEFT JOIN 
        inventory.thread_patterns tp 
    ON
        ii.pattern_id = tp.pattern_id 
    LEFT JOIN 
        inventory.valve_types vt 
    ON
        ii.valve_id = vt.valve_id 
    LEFT JOIN 
        inventory.vehicle_parts vp 
    ON
        ii.part_id = vp.part_id 
    LEFT JOIN 
        inventory.vehicle_part_numbers vpn 
    ON
        ii.part_number_id = vpn.part_number_id
    LEFT JOIN
        inventory.item_images img
    ON
        ii.item_id = img.item_id
    LEFT JOIN 
        (
            SELECT 
                item_id,
                JSON_ARRAYAGG(JSON_OBJECT('barcode_value', barcode_value, 'barcode_type', barcode_type)) AS barcodes_json,
                GROUP_CONCAT(barcode_value) as all_barcodes
            FROM 
                inventory.inventory_item_barcodes
            GROUP BY 
                item_id
        ) AS bc
    ON 
        ii.item_id = bc.item_id
    LEFT JOIN 
        (
            SELECT 
                iui.item_id,
                CONCAT(FORMAT(SUM(IF(iu.warehouse, COALESCE(iui.ending_quantity, 0), 0)), 2), ' ', ii.stocking_unit, ' & ', FORMAT(SUM(IF(iu.warehouse, 0, COALESCE(iui.ending_quantity, 0))), 2), ' ', ii.retail_unit) AS whole_quantity
            FROM 
                inventory.inventory_units_items iui
            INNER JOIN
                inventory.inventory_items ii 
            ON
                iui.item_id = ii.item_id 
            INNER JOIN
                inventory.inventory_units iu 
            ON
                iui.unit_id = iu.unit_id
            GROUP BY
                iui.item_id
        ) AS wq
    ON
        ii.item_id = wq.item_id
    LEFT JOIN 
        inventory.inventory_empty_cases iec 
    ON 
        iec.empty_item_id = ii.item_id
    ${whereCredentials}
  `;
}

export function getInventoryItemNoUnitQuery(jsonParam: string): string {
  const params = JSON.parse(jsonParam);
  const intUnitId = params.unit_id;
  const intItemCategoryId = params.item_category_id;
  const charItemDescription = params.item_description || '';
  const escapedDesc = charItemDescription.replace(/'/g, "''");

  return `
    SELECT JSON_OBJECT(
      'success', TRUE,
      'message', 'Inventory items without unit retrieved successfully.',
      'json_data', JSON_ARRAYAGG(JSON_OBJECT(
          'item_id', ii.item_id,
          'item_description', iic.item_description,
          'item_category_id', ii.item_category_id
      ) ORDER BY iic.item_description)
    ) AS response
    FROM inventory.inventory_items ii
    INNER JOIN inventory_udf_and_views.inventory_item_concat iic ON ii.item_id = iic.item_id
    WHERE ii.item_category_id = ${intItemCategoryId} 
      AND LOWER(iic.item_description) LIKE '%${escapedDesc.toLowerCase()}%' 
      AND ii.item_id NOT IN (
        SELECT iui.item_id FROM inventory.inventory_units_items iui WHERE unit_id = ${intUnitId}
      );
  `;
}

export function getItemImageQuery(jsonParam: string): string {
  const params = JSON.parse(jsonParam);
  const intItemId = params.item_id ? Number(params.item_id) : 0;

  return `
    SELECT JSON_OBJECT(
        'success', IF(COALESCE(img.image, '') != '', TRUE, FALSE),
        'message', IF(COALESCE(img.image, '') != '', 'Item image retrieved successfully.', 'No image found'),
        'json_data', JSON_OBJECT(
            'item_id', ${intItemId},
            'image', CAST(img.image AS CHAR)
        )
    ) AS response
    FROM (SELECT 1) AS dummy
    LEFT JOIN 
        inventory.item_images img
    ON 
        img.item_id = ${intItemId}
    LIMIT 1;
  `;
}

export function getEmptyUnitBinQuery(jsonParam: string): string {
  const params = JSON.parse(jsonParam);
  const bolGetOne = params.bol_getone;
  const intBinId = params.bin_id ? Number(params.bin_id) : null;
  const intUnitId = params.unit_id ? Number(params.unit_id) : null;
  const charDescription = params.description || '';

  let whereCredentials = '';
  if (bolGetOne) {
    whereCredentials = `WHERE ISNULL(iui.bin_id) AND ub.unit_id = ${intUnitId} AND ub.bin_id = ${intBinId}`;
  } else {
    if (charDescription !== '') {
      const escapedDesc = charDescription.replace(/'/g, "''");
      whereCredentials = `WHERE ISNULL(iui.bin_id) AND ub.unit_id = ${intUnitId} AND LOWER(ub.description) LIKE '%${escapedDesc.toLowerCase()}%'`;
    } else {
      whereCredentials = `WHERE ISNULL(iui.bin_id) AND ub.unit_id = ${intUnitId}`;
    }
  }

  return `
    SELECT 
        JSON_OBJECT(
            'success', TRUE,
            'message', 'Records retrieved successfully.',
            'json_data', JSON_ARRAYAGG(
                JSON_OBJECT(
                    'bin_id', ub.bin_id,
                    'description', ub.description,
                    'unit_id', ub.unit_id,
                    'unit', u.description,
                    'created_by', ub.created_by,
                    'creator', au.user_login_name,
                    'datetime_created', ub.datetime_created,
                    'frmt_datetime_created', DATE_FORMAT(ub.datetime_created, '%Y %b %d %a'),
                    'modified_by', ub.modified_by,
                    'modifier', au2.user_login_name,
                    'datetime_modified', ub.datetime_modified,
                    'frmt_datetime_modified', DATE_FORMAT(ub.datetime_modified , '%Y %b %d %a')
                ) ORDER BY ub.datetime_created, ub.description
            )
        ) AS response
    FROM 
        inventory.unit_bins ub
    INNER JOIN
        subscriber_common_tables.units u 
    ON
        ub.unit_id = u.unit_id
    INNER JOIN 
        application_users_inventory.application_users au 
    ON
        ub.created_by = au.user_id 
    LEFT JOIN 
        application_users_inventory.application_users au2 
    ON
        ub.modified_by = au2.user_id
    LEFT JOIN
        inventory.inventory_units_items iui
    ON
        ub.bin_id = iui.bin_id
    ${whereCredentials}
  `;
}

export function postInventoryItemQuery(jsonParam: string): string[] {
  const params = JSON.parse(jsonParam);
  const processType = Number(params.process_type);
  const itemId = Number(params.item_id || 0);
  const itemCategoryId = Number(params.item_category_id || 0);
  const brandId = params.brand_id !== null ? Number(params.brand_id) : null;
  const modelDescription = params.model_description ? params.model_description.replace(/'/g, "''") : '';
  const partId = params.part_id !== null ? Number(params.part_id) : null;
  const partNumberId = params.part_number_id !== null ? Number(params.part_number_id) : null;
  const sizeId = params.size_id !== null ? Number(params.size_id) : null;
  const valveId = params.valve_id !== null ? Number(params.valve_id) : null;
  const ratioId = params.ratio_id !== null ? Number(params.ratio_id) : null;
  const patternId = params.pattern_id !== null ? Number(params.pattern_id) : null;
  const stockingUnit = params.stocking_unit ? params.stocking_unit.replace(/'/g, "''") : '';
  const retailUnit = params.retail_unit ? params.retail_unit.replace(/'/g, "''") : '';
  const rtuOverStu = Number(params.rtu_over_stu || 0);
  const wtdAveCost = Number(params.wtd_ave_cost || 0);
  const markupRate = Number(params.mark_up_rate || 0);
  const sellingPrice = params.selling_price !== null ? Number(params.selling_price) : 0;
  const userId = Number(params.user_id || 0);
  const hasEmptyCase = Number(params.has_empty_case || 0);
  const barcode = params.barcode ? params.barcode.replace(/'/g, "''") : null;
  const image = params.image ? params.image.replace(/'/g, "''") : null;

  const queries: string[] = [];

  if (processType === 0) {
    // Add Item
    queries.push(`START TRANSACTION`);
    // Main item INSERT - dbconn.ts will capture insertId after this
    queries.push(`
      INSERT INTO inventory.inventory_items (
        item_category_id, brand_id, model_description, part_id, part_number_id,
        size_id, valve_id, ratio_id, pattern_id, stocking_unit, retail_unit,
        rtu_over_stu, wtd_ave_cost, markup_rate, selling_price, created_by
      ) VALUES (
        ${itemCategoryId}, ${brandId}, '${modelDescription}', ${partId}, ${partNumberId},
        ${sizeId}, ${valveId}, ${ratioId}, ${patternId}, '${stockingUnit}', '${retailUnit}',
        ${rtuOverStu}, ${wtdAveCost}, ${markupRate}, ${sellingPrice}, ${userId}
      )
    `);
    // __LAST_INSERT_ID__ is substituted by JS executor with the item's auto-increment ID captured above

    if (barcode) {
      queries.push(`
        INSERT INTO inventory.inventory_item_barcodes (item_id, barcode_value, barcode_type, created_by)
        VALUES (__FIRST_INSERT_ID__, '${barcode}', 'SCANNED', ${userId})
      `);
    } else {
      queries.push(`
        INSERT INTO inventory.inventory_item_barcodes (item_id, barcode_value, barcode_type, created_by)
        VALUES (__FIRST_INSERT_ID__, CONCAT('INV-', LPAD(__FIRST_INSERT_ID__, 6, '0')), 'INTERNAL', ${userId})
      `);
    }

    if (image) {
      queries.push(`
        REPLACE INTO inventory.item_images (item_id, image)
        VALUES (__FIRST_INSERT_ID__, '${image}')
      `);
    }

    if (hasEmptyCase === 1) {
      // Save main item ID before empty case INSERT changes __LAST_INSERT_ID__
      queries.push(`SET @main_item_id := __FIRST_INSERT_ID__`);
      queries.push(`
        INSERT INTO inventory.inventory_items (
          item_category_id, brand_id, model_description, part_id, part_number_id,
          size_id, valve_id, ratio_id, pattern_id, stocking_unit, retail_unit,
          rtu_over_stu, wtd_ave_cost, markup_rate, selling_price, created_by
        ) VALUES (
          ${itemCategoryId}, ${brandId}, CONCAT('${modelDescription}', ' - Case'), ${partId}, ${partNumberId},
          ${sizeId}, ${valveId}, ${ratioId}, ${patternId}, '${stockingUnit}', '${retailUnit}',
          ${rtuOverStu}, 0.00, ${markupRate}, 0.00, ${userId}
        )
      `);
      // After empty case item INSERT, LAST_INSERT_ID() is the empty case item ID
      queries.push(`
        INSERT INTO inventory.inventory_item_barcodes (item_id, barcode_value, barcode_type, created_by)
        VALUES (LAST_INSERT_ID(), CONCAT('INV-', LPAD(LAST_INSERT_ID(), 6, '0'), '-CASE'), 'INTERNAL', ${userId})
      `);
      queries.push(`
        INSERT INTO inventory.inventory_empty_cases (main_item_id, empty_item_id)
        SELECT @main_item_id, item_id FROM inventory.inventory_items
        WHERE model_description = CONCAT('${modelDescription}', ' - Case') AND created_by = ${userId}
        ORDER BY datetime_created DESC LIMIT 1
      `);
    }

    queries.push(`COMMIT`);
    queries.push(`
      SELECT JSON_OBJECT(
        'success', TRUE,
        'message', 'Inventory Item Successfully Saved!',
        'json_data', __FIRST_INSERT_ID__
      ) AS response
    `);
  } else if (processType === 1) {
    // Edit Item
    queries.push(`START TRANSACTION`);
    queries.push(`
      UPDATE inventory.inventory_items SET
        brand_id = ${brandId},
        model_description = '${modelDescription}',
        part_id = ${partId},
        part_number_id = ${partNumberId},
        size_id = ${sizeId},
        valve_id = ${valveId},
        ratio_id = ${ratioId},
        pattern_id = ${patternId},
        stocking_unit = '${stockingUnit}',
        retail_unit = '${retailUnit}',
        rtu_over_stu = ${rtuOverStu},
        wtd_ave_cost = ${wtdAveCost},
        markup_rate = ${markupRate},
        selling_price = ${sellingPrice},
        modified_by = ${userId},
        datetime_modified = NOW()
      WHERE item_id = ${itemId}
    `);

    if (barcode) {
      queries.push(`DELETE FROM inventory.inventory_item_barcodes WHERE item_id = ${itemId}`);
      queries.push(`
        INSERT INTO inventory.inventory_item_barcodes (item_id, barcode_value, barcode_type, created_by)
        VALUES (${itemId}, '${barcode}', 'SCANNED', ${userId})
      `);
    }

    if (image) {
      queries.push(`
        REPLACE INTO inventory.item_images (item_id, image)
        VALUES (${itemId}, '${image}')
      `);
    }

    queries.push(`COMMIT`);
    queries.push(`
      SELECT JSON_OBJECT(
        'success', TRUE,
        'message', 'Inventory Item Successfully Updated!',
        'json_data', ${itemId}
      ) AS response
    `);
  } else if (processType === 2) {
    // Delete Item
    queries.push(`START TRANSACTION`);
    queries.push(`DELETE FROM inventory.inventory_units_items WHERE item_id = ${itemId}`);
    queries.push(`DELETE FROM inventory.item_images WHERE item_id = ${itemId}`);
    queries.push(`DELETE FROM inventory.inventory_empty_cases WHERE main_item_id = ${itemId} OR empty_item_id = ${itemId}`);
    queries.push(`DELETE FROM inventory.inventory_item_barcodes WHERE item_id = ${itemId}`);
    queries.push(`DELETE FROM inventory.inventory_items WHERE item_id = ${itemId}`);
    queries.push(`COMMIT`);
    queries.push(`
      SELECT JSON_OBJECT(
        'success', TRUE,
        'message', 'Inventory Item Successfully Deleted!',
        'json_data', ${itemId}
      ) AS response
    `);
  }

  return queries;
}

export function postItemToUnitsQuery(jsonParam: string): string[] {
  const params = JSON.parse(jsonParam);
  const itemId = Number(params.item_id || 0);
  const userId = Number(params.user_id || 0);
  const units: { unit_id: number; bin_id: number }[] = Array.isArray(params.units) ? params.units : [];

  const queries: string[] = [];
  queries.push(`START TRANSACTION`);

  for (const u of units) {
    const unitId = Number(u.unit_id);
    const binId = Number(u.bin_id);
    queries.push(`
      INSERT INTO inventory.inventory_units_items
        (item_id, unit_id, starting_period, last_entry, starting_quantity, quantity_in, quantity_out, ending_quantity, starting_cost, cost_in, cost_out, ending_cost, unit_cost, last_highest_in_unit_cost, created_by, datetime_created, bin_id)
      SELECT
        ${itemId}, ${unitId}, NOW(), NOW(), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ${userId}, NOW(), ${binId}
      WHERE NOT EXISTS (
        SELECT 1 FROM inventory.inventory_units_items WHERE item_id = ${itemId} AND unit_id = ${unitId}
      )
    `);
    // Also insert for the empty case item if exists
    queries.push(`
      INSERT INTO inventory.inventory_units_items
        (item_id, unit_id, starting_period, last_entry, starting_quantity, quantity_in, quantity_out, ending_quantity, starting_cost, cost_in, cost_out, ending_cost, unit_cost, last_highest_in_unit_cost, created_by, datetime_created, bin_id)
      SELECT
        iec.empty_item_id, ${unitId}, NOW(), NOW(), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ${userId}, NOW(), ${binId}
      FROM inventory.inventory_empty_cases iec
      WHERE iec.main_item_id = ${itemId}
        AND NOT EXISTS (
          SELECT 1 FROM inventory.inventory_units_items WHERE item_id = iec.empty_item_id AND unit_id = ${unitId}
        )
    `);
  }

  queries.push(`COMMIT`);
  const unitCount = units.length;
  queries.push(`
    SELECT JSON_OBJECT(
      'success', TRUE,
      'message', CONCAT('Item Successfully Added To The Unit', IF(${unitCount} > 1, 's', ''), '!'),
      'json_data', ${itemId}
    ) AS response
  `);

  return queries;
}
