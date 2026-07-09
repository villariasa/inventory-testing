Procedure	sql_mode	Create Procedure	character_set_client	collation_connection	Database Collation
getItemImage	STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION	CREATE DEFINER=`developer`@`%` PROCEDURE `getItemImage`(
\t\tIN jsnItemImage JSON
\t)
BEGIN
\tDECLARE bolProceed BOOLEAN DEFAULT TRUE;
\tDECLARE intItemId INT;
\tDECLARE strImage LONGTEXT;
\tIF JSON_VALID(jsnItemImage) = 0 THEN
\t\tSET bolProceed = FALSE;
\t\tSELECT JSON_OBJECT('success', FALSE, 'message', 'Invalid JSON format', 'json_data', NULL) AS response;
\tEND IF;
\tIF bolProceed THEN
\t\tSET intItemId = JSON_VALUE(jsnItemImage, '$.item_id');
\t\tIF intItemId IS NULL OR intItemId = 0 THEN
\t\t\tSET bolProceed = FALSE;
\t\t\tSELECT JSON_OBJECT('success', FALSE, 'message', 'item_id is required', 'json_data', NULL) AS response;
\t\tEND IF;
\tEND IF;
\tIF bolProceed THEN
\t\tSELECT image INTO strImage FROM inventory.item_images WHERE item_id = intItemId LIMIT 1;
\t\tIF strImage IS NOT NULL AND strImage != '' THEN
\t\t\tSELECT JSON_OBJECT('success', TRUE, 'message', 'Item image retrieved successfully.', 'json_data', JSON_OBJECT('item_id', intItemId, 'image', CAST(strImage AS CHAR))) AS response;
\t\tELSE
\t\t\tSELECT JSON_OBJECT('success', FALSE, 'message', 'No image found', 'json_data', JSON_OBJECT('item_id', intItemId)) AS response;
\t\tEND IF;
\tEND IF;
END	utf8mb4	utf8mb4_unicode_ci	utf8mb4_unicode_ci
