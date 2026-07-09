import type { Context } from 'hono';
import { createStandardDBProcessor } from '../lib/database-factory.js';
import { ErrorLogger } from '../lib/errorlogger.js';
import {
  getEmployeeNameQuery,
  getNotificationQuery
} from '../queries/crossMisc.query.js';
import type {
  EmployeeNameRequest
} from '../interfaces/crossMisc.interface.js';

const errorLogger = ErrorLogger.getInstance();

function parseSpEnvelope(firstVal: unknown): { success: boolean; message: string; json_data: unknown } | null {
  if (firstVal === null || firstVal === undefined) return null;
  let raw: unknown = firstVal;
  if (Buffer.isBuffer(firstVal)) {
    raw = (firstVal as Buffer).toString('utf8');
  } else if (
    typeof firstVal === 'object' && firstVal !== null &&
    (firstVal as Record<string, unknown>).type === 'Buffer' &&
    Array.isArray((firstVal as Record<string, unknown>).data)
  ) {
    raw = Buffer.from((firstVal as { type: string; data: number[] }).data).toString('utf8');
  }
  const parsed = (typeof raw === 'string' ? JSON.parse(raw) : raw) as { success: boolean; message: string; json_data: unknown };
  if (typeof parsed.json_data === 'string') {
    try { parsed.json_data = JSON.parse(parsed.json_data); } catch { /* leave as-is */ }
  }
  return parsed;
}

export async function getEmployeeNameHandler(c: Context): Promise<Response> {
  let result = {
    success: false,
    http_code: 500,
    message: 'Failed to retrieve employee name',
    data: {} as unknown
  };

  try {
    const body = await c.req.json() as EmployeeNameRequest;

    const db = createStandardDBProcessor();
    await db.setQueries(getEmployeeNameQuery(JSON.stringify(body)));
    const success = await db.executeQueries();

    if (success && Array.isArray(db.queryResults[0]) && db.queryResults[0].length > 0) {
      const resultSet = Array.isArray(db.queryResults[0][0]) ? db.queryResults[0][0] as unknown[] : db.queryResults[0];
      const row = resultSet[0] as Record<string, unknown>;
      const firstVal = Object.values(row)[0];
      const spEnvelope = parseSpEnvelope(firstVal);

      if (spEnvelope !== null) {
        result = {
          success: true,
          http_code: 200,
          message: 'Employee name retrieved successfully',
          data: spEnvelope
        };
      } else {
        result = {
          success: true,
          http_code: 200,
          message: 'Employee name retrieved successfully',
          data: [{}]
        };
      }
    } else if (success) {
      result = {
        success: true,
        http_code: 200,
        message: 'Employee name retrieved successfully',
        data: [{}]
      };
    }
  } catch (error) {
    await errorLogger.logError(error, 'getEmployeeNameHandler');
  }

  return c.json(result, result.http_code as 200 | 500);
}

export async function getNotificationHandler(c: Context): Promise<Response> {
  let result = {
    success: false,
    http_code: 500,
    message: 'Failed to retrieve notifications',
    data: {} as unknown
  };

  try {
    const db = createStandardDBProcessor();
    await db.setQueries(getNotificationQuery());
    const success = await db.executeQueries();

    if (success && Array.isArray(db.queryResults[0]) && db.queryResults[0].length > 0) {
      const resultSet = Array.isArray(db.queryResults[0][0]) ? db.queryResults[0][0] as unknown[] : db.queryResults[0];
      const row = resultSet[0] as Record<string, unknown>;
      const firstVal = Object.values(row)[0];
      const spEnvelope = parseSpEnvelope(firstVal);

      if (spEnvelope !== null) {
        result = {
          success: true,
          http_code: 200,
          message: 'Notifications retrieved successfully',
          data: spEnvelope
        };
      } else {
        result = {
          success: true,
          http_code: 200,
          message: 'Notifications retrieved successfully',
          data: [{}]
        };
      }
    } else if (success) {
      result = {
        success: true,
        http_code: 200,
        message: 'Notifications retrieved successfully',
        data: [{}]
      };
    }
  } catch (error) {
    await errorLogger.logError(error, 'getNotificationHandler');
  }

  return c.json(result, result.http_code as 200 | 500);
}
