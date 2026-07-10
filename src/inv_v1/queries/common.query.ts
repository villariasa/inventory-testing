export function getUnitNameQuery(jsonParam: string): string {
  const params = JSON.parse(jsonParam);
  const unitId = params.unit_id !== null && params.unit_id !== undefined ? Number(params.unit_id) : null;

  const where = unitId !== null ? `AND u.unit_id = ${unitId}` : '';
  return `
    SELECT JSON_OBJECT(
      'success', TRUE,
      'message', 'Unit name retrieved successfully.',
      'json_data', COALESCE(
        JSON_ARRAYAGG(JSON_OBJECT('unit_id', unit_id, 'description', description)),
        JSON_ARRAY()
      )
    ) AS response
    FROM (
      SELECT u.unit_id, u.description
      FROM subscriber_common_tables.units u
      WHERE 1 = 1 ${where}
    ) AS combined_units
  `;
}

export function getUserUnitQuery(jsonParam: string): string {
  const params = JSON.parse(jsonParam);
  const userId = Number(params.user_id || 0);
  const excludeHeadOffice = params.exclude_head_office ? 1 : 0;

  const headOfficeWhere = excludeHeadOffice ? 'AND !u.head_office' : '';
  return `
    SELECT JSON_OBJECT(
      'success', TRUE,
      'message', 'User unit retrieved successfully.',
      'json_data', COALESCE(
        JSON_ARRAYAGG(JSON_OBJECT('unit_id', u.unit_id, 'description', u.description)),
        JSON_ARRAY()
      )
    ) AS response
    FROM subscriber_common_tables.units u
    WHERE u.unit_id = (
      SELECT COALESCE(au.unit_id, 0)
      FROM application_users_accounting.application_users au
      INNER JOIN subscriber_common_tables.units u2 ON u2.unit_id = au.unit_id
      WHERE au.user_id = ${userId} ${headOfficeWhere}
      LIMIT 1
    )
  `;
}

export function getUserUnitArrayQuery(jsonParam: string): string {
  const params = JSON.parse(jsonParam);
  const userId = Number(params.user_id || 0);

  // Returns units filtered to user's unit from inventory application_users
  return `
    SELECT JSON_OBJECT(
      'success', TRUE,
      'message', 'User unit array retrieved successfully.',
      'json_data', COALESCE(
        JSON_ARRAYAGG(JSON_OBJECT('unit_id', u.unit_id, 'description', u.description)),
        JSON_ARRAY()
      )
    ) AS response
    FROM subscriber_common_tables.units u
    WHERE u.unit_id = COALESCE((
      SELECT au.unit_id
      FROM application_users_inventory.application_users au
      INNER JOIN subscriber_common_tables.units u2 ON u2.unit_id = au.unit_id
      WHERE au.user_id = ${userId} AND !u2.head_office
      LIMIT 1
    ), 0)
  `;
}

export function getUserDesignatedUnitQuery(jsonParam: string): string {
  const params = JSON.parse(jsonParam);
  const userId = params.user_id !== null && params.user_id !== undefined ? Number(params.user_id) : null;

  const userWhere = userId !== null ? `WHERE au.user_id = ${userId}` : '';
  return `
    SELECT JSON_OBJECT(
      'success', TRUE,
      'message', 'User designated unit retrieved successfully.',
      'json_data', COALESCE(
        JSON_ARRAYAGG(JSON_OBJECT(
          'user_id', au.user_id,
          'unit', u.description,
          'head_office', u.head_office,
          'unit_id', u.unit_id
        )),
        JSON_ARRAY()
      )
    ) AS response
    FROM subscriber_common_tables.units u
    INNER JOIN application_users_inventory.application_users au ON au.unit_id = u.unit_id
    ${userWhere}
  `;
}

export function getAdjustmentUserUnitQuery(jsonParam: string): string {
  const params = JSON.parse(jsonParam);
  const userId = Number(params.user_id || 0);

  return `
    SELECT JSON_OBJECT(
      'success', TRUE,
      'message', 'Records retrieved successfully.',
      'json_data', JSON_ARRAYAGG(JSON_OBJECT('unit_id', u.unit_id, 'description', u.description) ORDER BY u.description)
    ) AS response
    FROM subscriber_common_tables.units u
    WHERE u.unit_id = (
      SELECT COALESCE(au.unit_id, 0)
      FROM application_users_inventory.application_users au
      INNER JOIN subscriber_common_tables.units u2 ON au.unit_id = u2.unit_id
      WHERE au.user_id = ${userId}
      LIMIT 1
    )
  `;
}

export function getSelectableAccountsConcatenatedQuery(jsonParam: string): string {
  const params = JSON.parse(jsonParam);
  const glslId = params.glsl_id ? Number(params.glsl_id) : 0;
  const accountDesc = params.account_description ? params.account_description.replace(/'/g, "''") : null;

  let extraWhere = '';
  if (glslId > 0) {
    extraWhere = `AND glsl_id = ${glslId}`;
  } else if (accountDesc) {
    extraWhere = `AND search_account LIKE '%${accountDesc}%'`;
  }

  return `
    SELECT JSON_OBJECT(
      'success', TRUE,
      'message', 'Selectable accounts fetched successfully.',
      'json_data', IFNULL(JSON_ARRAYAGG(JSON_OBJECT('glsl_id', glsl_id, 'account', account) ORDER BY glsl_id), JSON_ARRAY())
    ) AS response
    FROM accounting.selectable_account_concatenated
    WHERE glsl_id <> (SELECT IFNULL(cash_account, 0) FROM funds.funds_parms LIMIT 1)
    ${extraWhere}
  `;
}
