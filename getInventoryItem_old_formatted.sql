Procedure	sql_mode	Create Procedure	character_set_client	collation_connection	Database Collation
getInventoryItem	IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION	CREATE DEFINER=`developer`@`%` PROCEDURE `getInventoryItem`(
\t\t\tIN jsnInventoryItem JSON
\t\t)
BEGIN
\tDECLARE whereCredentials VARCHAR(250);
\tDECLARE bolProceed BOOLEAN DEFAULT FALSE;

\tDECLARE bolGetOne BOOLEAN;
\tDECLARE intItemCategoryId INT;
\tDECLARE intItemId INT;
\tDECLARE charItemDescription VARCHAR(100);

\tSET @sampleJSON='{
\t\t\t\t\t\t"bol_getone":0,
\t\t\t\t\t\t"item_category_id":1,
\t\t\t\t\t\t"item_id":1,
\t\t\t\t\t\t"item_description":"James"
\t\t\t\t\t}';\t

\tIF JSON_VALID(jsnInventoryItem) THEN
\t\tSET bolProceed = TRUE;
\tEND IF;

\tIF bolProceed THEN
\t\tSET bolGetOne = JSON_VALUE(jsnInventoryItem, '$.bol_getone');
\t\tSET intItemCategoryId = JSON_VALUE(jsnInventoryItem, '$.item_category_id');
\t\tSET intItemId = JSON_VALUE(jsnInventoryItem, '$.item_id');
\t\tSET charItemDescription = JSON_VALUE(jsnInventoryItem, '$.item_description');\t
\t
\t\tIF bolProceed THEN
\t\t\tIF bolGetOne THEN
\t\t\t\tSET whereCredentials = CONCAT("WHERE ii.item_category_id = ",intItemCategoryId," AND ii.item_id = ",intItemId);
\t\t\tELSE
\t\t\t\tIF charItemDescription <> '' THEN
\t\t\t\t\tSET whereCredentials = CONCAT("WHERE ii.item_category_id = ",intItemCategoryId," AND LOWER(iic.item_description) LIKE CONCAT('%',LOWER('",charItemDescription,"'),'%')");
\t\t\t\tELSE
\t\t\t\t\tSET whereCredentials = CONCAT("WHERE ii.item_category_id = ",intItemCategoryId,"");
\t\t\t\tEND IF;
\t\t\tEND IF;
\t\t
\t\t\tSET @sqlCommand =  CONCAT("
\t\t\t\t\t\t\t\tSELECT 
\t\t\t\t\t\t\t\t\tJSON_ARRAYAGG(
\t\t\t\t\t\t\t\t\t    JSON_OBJECT(
\t\t\t\t\t\t\t\t\t    \t'item_id', ii.item_id,
\t\t\t\t\t\t\t\t\t    \t'item_description', iic.item_description,
\t\t\t\t\t\t\t\t\t    \t'item_category_id', ii.item_category_id,
\t\t\t\t\t\t\t\t\t    \t'item_category', ic.description,
\t\t\t\t\t\t\t\t\t    \t'brand_id', ii.brand_id,
\t\t\t\t\t\t\t\t\t    \t'brand', b.description,
\t\t\t\t\t\t\t\t\t    \t'model_description', ii.model_description,
\t\t\t\t\t\t\t\t\t    \t'part_id', ii.part_id,
\t\t\t\t\t\t\t\t\t    \t'vehicle_parts', vp.description,
\t\t\t\t\t\t\t\t\t    \t'part_number_id', ii.part_number_id,
\t\t\t\t\t\t\t\t\t    \t'vehicle_part_number', vpn.description,
\t\t\t\t\t\t\t\t\t    \t'size_id', ii.size_id,
\t\t\t\t\t\t\t\t\t    \t'size', s.description,
\t\t\t\t\t\t\t\t\t    \t'valve_id', ii.valve_id,
\t\t\t\t\t\t\t\t\t    \t'valve_type', vt.description,
\t\t\t\t\t\t\t\t\t    \t'ratio_id', ii.ratio_id,
\t\t\t\t\t\t\t\t\t    \t'ratio', r.description,
\t\t\t\t\t\t\t\t\t    \t'pattern_id', ii.pattern_id,
\t\t\t\t\t\t\t\t\t    \t'thread_pattern', tp.description,
\t\t\t\t\t\t\t\t\t    \t'stocking_unit', ii.stocking_unit,
\t\t\t\t\t\t\t\t\t    \t'retail_unit', ii.retail_unit,
\t\t\t\t\t\t\t\t\t    \t'rtu_over_stu', ii.rtu_over_stu,
\t\t\t\t\t\t\t\t\t    \t'wtd_ave_cost', ii.wtd_ave_cost,
\t\t\t\t\t\t\t\t\t    \t'markup_rate', (ii.markup_rate * 100),
\t\t\t\t\t\t\t\t\t    \t'selling_price', FORMAT(ii.selling_price,2),
\t\t\t\t\t\t\t\t\t    \t'last_highest_in_unit_cost', ii.last_highest_in_unit_cost,
\t\t\t\t\t\t\t\t\t    \t'whole_quantity', COALESCE(wq.whole_quantity,CONCAT('0.00 ',ii.stocking_unit,' & 0.00 ',ii.retail_unit)),
\t\t\t\t\t\t\t\t\t\t\t'in_unit_item', !ISNULL(wq.item_id),
\t\t\t\t\t\t\t\t\t    \t'created_by', ii.created_by,
\t\t\t\t\t\t\t\t\t    \t'datetime_created', ii.datetime_created,
\t\t\t\t\t\t\t\t\t    \t'modified_by', ii.modified_by,
\t\t\t\t\t\t\t\t\t    \t'datetime_modified', ii.datetime_modified,
\t\t\t\t\t\t\t\t\t    \t'is_empty_case', iec.empty_item_id
\t\t\t\t\t\t\t\t\t    ) ORDER BY ii.datetime_created, iic.item_description
\t\t\t\t\t\t\t\t\t) AS response
\t\t\t\t\t\t\t\tFROM 
\t\t\t\t\t\t\t\t\tinventory.inventory_items ii
\t\t\t\t\t\t\t\tLEFT JOIN
\t\t\t\t\t\t\t\t\tinventory_udf_and_views.inventory_item_concat iic 
\t\t\t\t\t\t\t\tON
\t\t\t\t\t\t\t\t\tii.item_id = iic.item_id
\t\t\t\t\t\t\t\tLEFT JOIN
\t\t\t\t\t\t\t\t\tinventory.items_categories ic
\t\t\t\t\t\t\t\tON
\t\t\t\t\t\t\t\t\tii.item_category_id = ic.item_category_id 
\t\t\t\t\t\t\t\tLEFT JOIN \t
\t\t\t\t\t\t\t\t\tinventory.brands b 
\t\t\t\t\t\t\t\tON
\t\t\t\t\t\t\t\t\tii.brand_id = b.brand_id 
\t\t\t\t\t\t\t\tLEFT JOIN \t
\t\t\t\t\t\t\t\t\tinventory.sizes s 
\t\t\t\t\t\t\t\tON
\t\t\t\t\t\t\t\t\tii.size_id = s.size_id 
\t\t\t\t\t\t\t\tLEFT JOIN 
\t\t\t\t\t\t\t\t\tinventory.ratios r 
\t\t\t\t\t\t\t\tON
\t\t\t\t\t\t\t\t\tii.ratio_id = r.ratio_id 
\t\t\t\t\t\t\t\tLEFT JOIN 
\t\t\t\t\t\t\t\t\tinventory.thread_patterns tp 
\t\t\t\t\t\t\t\tON
\t\t\t\t\t\t\t\t\tii.pattern_id = tp.pattern_id 
\t\t\t\t\t\t\t\tLEFT JOIN 
\t\t\t\t\t\t\t\t\tinventory.valve_types vt 
\t\t\t\t\t\t\t\tON
\t\t\t\t\t\t\t\t\tii.valve_id = vt.valve_id 
\t\t\t\t\t\t\t\tLEFT JOIN 
\t\t\t\t\t\t\t\t\tinventory.vehicle_parts vp 
\t\t\t\t\t\t\t\tON
\t\t\t\t\t\t\t\t\tii.part_id = vp.part_id 
\t\t\t\t\t\t\t\tLEFT JOIN 
\t\t\t\t\t\t\t\t\tinventory.vehicle_part_numbers vpn 
\t\t\t\t\t\t\t\tON
\t\t\t\t\t\t\t\t\tii.part_number_id = vpn.part_number_id
\t\t\t\t\t\t\t\tLEFT JOIN 
\t\t\t\t\t\t\t\t\t(
\t\t\t\t\t\t\t\t\t\tSELECT 
\t\t\t\t\t\t\t\t\t\t\tiui.item_id,
\t\t\t\t\t\t\t\t\t\t\tCONCAT(FORMAT(SUM(IF(iu.warehouse,COALESCE(iui.ending_quantity,0),0)),2),' ',ii.stocking_unit,' & ',FORMAT(SUM(IF(iu.warehouse,0,COALESCE(iui.ending_quantity,0))),2),' ',ii.retail_unit) AS whole_quantity
\t\t\t\t\t\t\t\t\t\tFROM 
\t\t\t\t\t\t\t\t\t\t\tinventory.inventory_units_items iui
\t\t\t\t\t\t\t\t\t\tINNER JOIN
\t\t\t\t\t\t\t\t\t\t\tinventory.inventory_items ii 
\t\t\t\t\t\t\t\t\t\tON
\t\t\t\t\t\t\t\t\t\t\tiui.item_id = ii.item_id 
\t\t\t\t\t\t\t\t\t\tINNER JOIN
\t\t\t\t\t\t\t\t\t\t\tinventory.inventory_units iu 
\t\t\t\t\t\t\t\t\t\tON
\t\t\t\t\t\t\t\t\t\t\tiui.unit_id = iu.unit_id
\t\t\t\t\t\t\t\t\t\tGROUP BY
\t\t\t\t\t\t\t\t\t\t\tiui.item_id
\t\t\t\t\t\t\t\t\t) AS wq
\t\t\t\t\t\t\t\tON
\t\t\t\t\t\t\t\t\tii.item_id = wq.item_id
\t\t\t\t\t\t\t\tLEFT JOIN 
\t\t\t\t\t\t\t\t\t\tinventory.inventory_empty_cases iec 
\t\t\t\t\t\t\t\t\tON 
\t\t\t\t\t\t\t\t\t\tiec.empty_item_id = ii.item_id 
\t\t\t\t\t\t\t\t",whereCredentials,";");
\t\t\tPREPARE query_statement FROM @sqlCommand;
\t\t\tEXECUTE query_statement;
\t\t\tDEALLOCATE PREPARE query_statement;
\t\tEND IF;
\tELSE
\t\tSELECT NULL AS response;
\tEND IF;
END	utf8mb4	utf8mb4_general_ci	utf8mb4_unicode_ci
