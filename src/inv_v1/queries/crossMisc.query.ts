export function getEmployeeNameQuery(jsonParam: string): string {
  const params = JSON.parse(jsonParam);
  const bolGetOne = params.bol_getone;
  const employeeId = params.employee_id ? Number(params.employee_id) : null;
  const employeeName = params.employee_name ? params.employee_name.replace(/'/g, "''") : '';

  let whereCredentials = '';
  if (bolGetOne && employeeId !== null) {
    whereCredentials = `AND a.employee_id = ${employeeId}`;
  } else if (employeeName !== '') {
    whereCredentials = `AND LOWER(a.employee_name) LIKE '%${employeeName.toLowerCase()}%'`;
  }

  return `
    SELECT JSON_OBJECT(
      'success', TRUE,
      'message', 'Employee name retrieved successfully.',
      'json_data', COALESCE(
        JSON_ARRAYAGG(
          JSON_OBJECT('employee_id', employee_id, 'employee_name', employee_name)
          ORDER BY employee_name
        ),
        JSON_ARRAY()
      )
    ) AS response
    FROM (
      SELECT a.employee_id, a.employee_name
      FROM employees_profile_udf_and_views.employee_name a
      INNER JOIN employees_profile.employees_status b ON a.employee_id = b.employee_id
      INNER JOIN employees_profile.employment_status c ON b.status_id = c.status_id
      WHERE c.cessation_status = 0
      ${whereCredentials}
    ) AS combined
  `;
}

export function getNotificationQuery(): string {
  return `
    SELECT JSON_OBJECT(
      'success', TRUE,
      'message', 'Notifications retrieved successfully.',
      'json_data', CAST(COALESCE(
        CONCAT('[', GROUP_CONCAT(
          JSON_OBJECT(
            'transaction_date', DATE_FORMAT(rjr.entry_date, '%m/%d/%Y'),
            'item', 'Journal References',
            'status', IF(rjr.approved_by IS NULL, 'For Approval', 'Approved'),
            'recorded_by', (SELECT su.full_name FROM application_users_accounting.subscribers_applications_user sau INNER JOIN application_users_accounting.subscribers_users su ON su.subscriber_user_id = sau.subscriber_user_id WHERE sau.user_id = rjr.requested_by LIMIT 1),
            'executed_by', IFNULL((SELECT su.full_name FROM application_users_accounting.subscribers_applications_user sau INNER JOIN application_users_accounting.subscribers_users su ON su.subscriber_user_id = sau.subscriber_user_id WHERE sau.user_id = rjr.approved_by LIMIT 1), '-'),
            'datetime_recorded', IFNULL(DATE_FORMAT(rjr.datetime_requested, '%m/%d/%Y %H:%i'), '-'),
            'datetime_executed', IFNULL(DATE_FORMAT(rjr.datetime_approved, '%m/%d/%Y %H:%i'), '-'),
            'transaction_date_executed', IFNULL(DATE_FORMAT(rjr.datetime_approved, '%m/%d/%Y'), '-'),
            'redirect_url', (SELECT f.url FROM application_users_accounting.functionalities f WHERE f.function_id = 9 LIMIT 1),
            'amount', '-',
            'remarks', rjr.brief_remark
          ) ORDER BY rjr.entry_date DESC
        ), ']'),
        '[]'
      ) AS JSON)
    ) AS response
    FROM accounting.request_journal_references rjr
    CROSS JOIN (SELECT fp.transaction_date FROM funds.funds_parms fp LIMIT 1) AS td
    WHERE IF(rjr.approved_by IS NULL, TRUE,
      DATE_FORMAT(rjr.entry_date, '%Y-%m') BETWEEN DATE_FORMAT(td.transaction_date, '%Y-%m') AND DATE_FORMAT(td.transaction_date, '%Y-%m')
    )
    ORDER BY rjr.entry_date DESC
  `;
}
