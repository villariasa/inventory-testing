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
  return `CALL udf_and_views_inventory.getItemImage('${jsonParam}')`;
}

export function getEmptyUnitBinQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.getEmptyUnitBin('${jsonParam}')`;
}

export function postInventoryItemQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.postInventoryItem('${jsonParam}')`;
}

export function postItemToUnitsQuery(jsonParam: string): string {
  return `CALL udf_and_views_inventory.postItemToUnits('${jsonParam}')`;
}
