import type { Context } from 'hono';
import { createStandardDBProcessor } from '../lib/database-factory.js';
import { ErrorLogger } from '../lib/errorlogger.js';
import {
  getInventoryItemCategoryQuery,
  postInventoryItemCategoryQuery
} from '../queries/itemCategory.query.js';
import type {
  InventoryItemCategoryRequest,
  PostInventoryItemCategoryRequest
} from '../interfaces/itemCategory.interface.js';

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

export async function getInventoryItemCategoryHandler(c: Context): Promise<Response> {
  let result = {
    success: false,
    http_code: 500,
    message: 'Failed to retrieve inventory item categories',
    data: {} as unknown
  };

  try {
    const body = await c.req.json() as InventoryItemCategoryRequest;

    const db = createStandardDBProcessor();
    await db.setQueries(getInventoryItemCategoryQuery(JSON.stringify(body)));
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
          message: 'Inventory item categories retrieved successfully',
          data: spEnvelope
        };
      } else {
        result = {
          success: true,
          http_code: 200,
          message: 'Inventory item categories retrieved successfully',
          data: [{}]
        };
      }
    } else if (success) {
      result = {
        success: true,
        http_code: 200,
        message: 'Inventory item categories retrieved successfully',
        data: [{}]
      };
    }
  } catch (error) {
    await errorLogger.logError(error, 'getInventoryItemCategoryHandler');
  }

  return c.json(result, result.http_code as 200 | 500);
}

export async function postInventoryItemCategoryHandler(c: Context): Promise<Response> {
  let result = {
    success: false,
    http_code: 500,
    message: 'Failed to process inventory item category',
    data: {} as unknown
  };

  try {
    const body = await c.req.json() as PostInventoryItemCategoryRequest;

    const db = createStandardDBProcessor();
    await db.setQueries(postInventoryItemCategoryQuery(JSON.stringify(body)));
    const success = await db.executeQueries();

    if (success && Array.isArray(db.queryResults[0]) && db.queryResults[0].length > 0) {
      const resultSet = Array.isArray(db.queryResults[0][0]) ? db.queryResults[0][0] as unknown[] : db.queryResults[0];
      const row = resultSet[0] as Record<string, unknown>;
      const firstVal = Object.values(row)[0];
      const spEnvelope = parseSpEnvelope(firstVal);

      if (spEnvelope !== null) {
        result = {
          success: Boolean(spEnvelope.success),
          http_code: 200,
          message: spEnvelope.message,
          data: spEnvelope
        };
      } else {
        result = {
          success: true,
          http_code: 200,
          message: 'Operation completed',
          data: {}
        };
      }
    } else if (success) {
      result = {
        success: true,
        http_code: 200,
        message: 'Operation completed',
        data: {}
      };
    }
  } catch (error) {
    await errorLogger.logError(error, 'postInventoryItemCategoryHandler');
  }

  return c.json(result, result.http_code as 200 | 500);
}
