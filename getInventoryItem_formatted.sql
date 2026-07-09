Procedure	sql_mode	Create Procedure	character_set_client	collation_connection	Database Collation
getInventoryItem	STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION	CREATE DEFINER=`developer`@`%` PROCEDURE `getInventoryItem`(
    IN jsnInventoryItem JSON
)
BEGIN
    DECLARE whereCredentials VARCHAR(500);
    DECLARE bolProceed BOOLEAN DEFAULT FALSE;

    DECLARE bolGetOne BOOLEAN;
    DECLARE intItemCategoryId INT;
    DECLARE intItemId INT;
    DECLARE charItemDescription VARCHAR(100);
    DECLARE charBarcode VARCHAR(100) DEFAULT NULL;
    DECLARE bolExactMatchExists BOOLEAN DEFAULT FALSE;
    DECLARE bolBypassImageFilter BOOLEAN DEFAULT FALSE;

    
    
    
    
    
    
    
    

    
    SET SESSION group_concat_max_len = 104857600;

    IF JSON_VALID(jsnInventoryItem) THEN
        SET bolProceed = TRUE;
    END IF;

    IF bolProceed THEN
        SET bolGetOne = JSON_VALUE(jsnInventoryItem, '$.bol_getone');
        
        SET intItemCategoryId = NULLIF(JSON_VALUE(jsnInventoryItem, '$.item_category_id'), 0);
        SET intItemId = JSON_VALUE(jsnInventoryItem, '$.item_id');
        SET charItemDescription = JSON_VALUE(jsnInventoryItem, '$.item_description');\t
        
        
        SET charBarcode = JSON_UNQUOTE(JSON_EXTRACT(jsnInventoryItem, '$.barcode'));
        IF charBarcode = '' OR charBarcode = 'null' THEN SET charBarcode = NULL; END IF;
        
        SET bolBypassImageFilter = COALESCE(JSON_VALUE(jsnInventoryItem, '$.bypass_image_filter'), FALSE);
    
        
        IF bolGetOne THEN
            SET whereCredentials = CONCAT('WHERE ii.item_id = ', intItemId);
            IF intItemCategoryId IS NOT NULL THEN
                SET whereCredentials = CONCAT(whereCredentials, ' AND ii.item_category_id = ', intItemCategoryId);
            END IF;
        ELSE
            
            SET whereCredentials = 'WHERE 1=1';

            IF charBarcode IS NOT NULL THEN
                -- Check if exact match exists in the barcodes table first
                SET bolExactMatchExists = FALSE;
                SELECT EXISTS(
                    SELECT 1 
                    FROM inventory.inventory_item_barcodes 
                    WHERE barcode_value = charBarcode COLLATE utf8mb4_general_ci 
                       OR barcode_value = CONCAT(charBarcode, '-CASE') COLLATE utf8mb4_general_ci
                ) INTO bolExactMatchExists;

                IF bolExactMatchExists THEN
                    SET whereCredentials = CONCAT(whereCredentials, ' AND (bc.all_barcodes LIKE ''%', charBarcode, '%'')');
                ELSE
                    -- Fallback to prefix matching if no exact match is found
                    -- If barcode query is 13 digits (EAN-13), match using 12-digit prefix or exact value
                    IF LENGTH(charBarcode) = 13 THEN
                        SET @barcodePrefix = LEFT(charBarcode, 12);
                        SET whereCredentials = CONCAT(whereCredentials, ' AND (bc.all_barcodes LIKE ''%', charBarcode, '%'' OR bc.all_barcodes LIKE ''%', @barcodePrefix, '%'')');
                    -- If barcode query is 12 digits (UPC), match using 11-digit prefix or exact value
                    ELSEIF LENGTH(charBarcode) = 12 THEN
                        SET @barcodePrefix = LEFT(charBarcode, 11);
                        SET whereCredentials = CONCAT(whereCredentials, ' AND (bc.all_barcodes LIKE ''%', charBarcode, '%'' OR bc.all_barcodes LIKE ''%', @barcodePrefix, '%'')');
                    -- If barcode query is 8 digits (EAN-8), match using 7-digit prefix or exact value
                    ELSEIF LENGTH(charBarcode) = 8 THEN
                        SET @barcodePrefix = LEFT(charBarcode, 7);
                        SET whereCredentials = CONCAT(whereCredentials, ' AND (bc.all_barcodes LIKE ''%', charBarcode, '%'' OR bc.all_barcodes LIKE ''%', @barcodePrefix, '%'')');
                    ELSE
                        SET whereCredentials = CONCAT(whereCredentials, ' AND bc.all_barcodes LIKE ''%', charBarcode, '%''');
                    END IF;
                END IF;
            END IF;

            IF charItemDescription <> '' THEN
                SET whereCredentials = CONCAT(whereCredentials, ' AND LOWER(iic.item_description) LIKE CONCAT(\\'%\\', LOWER(\\'', charItemDescription, '\\'), \\'%\\')');
            END IF;
            
            IF intItemCategoryId IS NOT NULL THEN
                SET whereCredentials = CONCAT(whereCredentials, ' AND ii.item_category_id = ', intItemCategoryId);
            ELSE
                
                IF charBarcode IS NULL AND (charItemDescription IS NULL OR charItemDescription = '') AND NOT bolBypassImageFilter THEN
                    SET whereCredentials = CONCAT(whereCredentials, ' AND (img.item_id IS NULL OR img.image IS NULL OR CAST(img.image AS CHAR) = '''')');
                END IF;
            END IF;
        END IF;
    
        SET @sqlCommand = CONCAT('
            SELECT JSON_OBJECT(
                \\'success\\', TRUE,
                \\'message\\', \\'Inventory items retrieved successfully.\\',
                \\'json_data\\', JSON_ARRAYAGG(
                    JSON_OBJECT(
                        \\'item_id\\', ii.item_id,
                        \\'item_description\\', iic.item_description,
                        \\'item_category_id\\', ii.item_category_id,
                        \\'item_category\\', ic.description,
                        \\'brand_id\\', ii.brand_id,
                        \\'brand\\', b.description,
                        \\'model_description\\', ii.model_description,
                        \\'part_id\\', ii.part_id,
                        \\'vehicle_parts\\', vp.description,
                        \\'part_number_id\\', ii.part_number_id,
                        \\'vehicle_part_number\\', vpn.description,
                        \\'size_id\\', ii.size_id,
                        \\'size\\', s.description,
                        \\'valve_id\\', ii.valve_id,
                        \\'valve_type\\', vt.description,
                        \\'ratio_id\\', ii.ratio_id,
                        \\'ratio\\', r.description,
                        \\'pattern_id\\', ii.pattern_id,
                        \\'thread_pattern\\', tp.description,
                        \\'stocking_unit\\', ii.stocking_unit,
                        \\'retail_unit\\', ii.retail_unit,
                        \\'rtu_over_stu\\', ii.rtu_over_stu,
                        \\'wtd_ave_cost\\', ii.wtd_ave_cost,
                        \\'markup_rate\\', (ii.markup_rate * 100),
                        \\'selling_price\\', FORMAT(ii.selling_price,2),
                        \\'last_highest_in_unit_cost\\', ii.last_highest_in_unit_cost,
                        \\'whole_quantity\\', COALESCE(wq.whole_quantity, CONCAT(\\'0.00 \\', ii.stocking_unit, \\' & 0.00 \\', ii.retail_unit)),
                        \\'in_unit_item\\', !ISNULL(wq.item_id),
                        \\'created_by\\', ii.created_by,
                        \\'datetime_created\\', ii.datetime_created,
                        \\'modified_by\\', ii.modified_by,
                        \\'datetime_modified\\', ii.datetime_modified,
                        \\'is_empty_case\\', iec.empty_item_id,
                        \\'image\\', CAST(img.image AS CHAR),
                        \\'barcodes\\', bc.barcodes_json
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
            LEFT JOIN \t
                inventory.brands b 
            ON
                ii.brand_id = b.brand_id 
            LEFT JOIN \t
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
                        JSON_ARRAYAGG(JSON_OBJECT(\\'barcode_value\\', barcode_value, \\'barcode_type\\', barcode_type)) AS barcodes_json,
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
                        CONCAT(FORMAT(SUM(IF(iu.warehouse, COALESCE(iui.ending_quantity, 0), 0)), 2), \\' \\', ii.stocking_unit, \\' & \\', FORMAT(SUM(IF(iu.warehouse, 0, COALESCE(iui.ending_quantity, 0))), 2), \\' \\', ii.retail_unit) AS whole_quantity
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
            ', whereCredentials, ';'
        );
        
        PREPARE query_statement FROM @sqlCommand;
        EXECUTE query_statement;
        DEALLOCATE PREPARE query_statement;
        
    ELSE
        SELECT JSON_OBJECT(
            'success', FALSE,
            'message', 'Invalid JSON parameter.',
            'json_data', NULL
        ) AS response;
    END IF;
END	utf8mb4	utf8mb4_unicode_ci	utf8mb4_unicode_ci
