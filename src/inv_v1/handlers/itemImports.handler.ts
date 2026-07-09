import type { Context } from 'hono';
import { createStandardDBProcessor } from '../lib/database-factory.js';
import { ErrorLogger } from '../lib/errorlogger.js';
import {
  getItemImportListQuery,
  getItemImportsQuery,
  getImportItemsQuery,
  postItemImportsQuery
} from '../queries/itemImports.query.js';
import type {
  ItemImportListRequest,
  ItemImportsRequest,
  ImportItemsRequest,
  PostItemImportsRequest
} from '../interfaces/itemImports.interface.js';

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

export async function getItemImportListHandler(c: Context): Promise<Response> {
  let result = {
    success: false,
    http_code: 500,
    message: 'Failed to retrieve item import list',
    data: {} as unknown
  };

  try {
    const body = await c.req.json() as ItemImportListRequest;

    const db = createStandardDBProcessor();
    await db.setQueries(getItemImportListQuery(JSON.stringify(body)));
    const success = await db.executeQueries();

    if (success && Array.isArray(db.queryResults[0]) && db.queryResults[0].length > 0) {
      const resultSet = Array.isArray(db.queryResults[0][0]) ? db.queryResults[0][0] as unknown[] : db.queryResults[0];
      const row = resultSet[0] as Record<string, unknown>;
      const firstVal = Object.values(row)[0];
      const spEnvelope = parseSpEnvelope(firstVal);

      if (spEnvelope !== null) {
        const isArray = Array.isArray(spEnvelope);
        const finalData = isArray ? { success: true, message: 'ok', json_data: spEnvelope } : spEnvelope;
        result = {
          success: true,
          http_code: 200,
          message: 'Item import list retrieved successfully',
          data: finalData
        };
      } else {
        result = {
          success: true,
          http_code: 200,
          message: 'Item import list retrieved successfully',
          data: [{}]
        };
      }
    } else if (success) {
      result = {
        success: true,
        http_code: 200,
        message: 'Item import list retrieved successfully',
        data: [{}]
      };
    }
  } catch (error) {
    await errorLogger.logError(error, 'getItemImportListHandler');
  }

  return c.json(result, result.http_code as 200 | 500);
}

export async function getItemImportsHandler(c: Context): Promise<Response> {
  let result = {
    success: false,
    http_code: 500,
    message: 'Failed to retrieve item imports',
    data: {} as unknown
  };

  try {
    const body = await c.req.json() as ItemImportsRequest;

    const db = createStandardDBProcessor();
    await db.setQueries(getItemImportsQuery(JSON.stringify(body)));
    const success = await db.executeQueries();

    if (success && Array.isArray(db.queryResults[0]) && db.queryResults[0].length > 0) {
      const resultSet = Array.isArray(db.queryResults[0][0]) ? db.queryResults[0][0] as unknown[] : db.queryResults[0];
      const row = resultSet[0] as Record<string, unknown>;
      const firstVal = Object.values(row)[0];
      const spEnvelope = parseSpEnvelope(firstVal);

      if (spEnvelope !== null) {
        const isArray = Array.isArray(spEnvelope);
        const finalData = isArray ? { success: true, message: 'ok', json_data: spEnvelope } : spEnvelope;
        result = {
          success: true,
          http_code: 200,
          message: 'Item imports retrieved successfully',
          data: finalData
        };
      } else {
        result = {
          success: true,
          http_code: 200,
          message: 'Item imports retrieved successfully',
          data: [{}]
        };
      }
    } else if (success) {
      result = {
        success: true,
        http_code: 200,
        message: 'Item imports retrieved successfully',
        data: [{}]
      };
    }
  } catch (error) {
    await errorLogger.logError(error, 'getItemImportsHandler');
  }

  return c.json(result, result.http_code as 200 | 500);
}

export async function getImportItemsHandler(c: Context): Promise<Response> {
  let result = {
    success: false,
    http_code: 500,
    message: 'Failed to retrieve import items',
    data: {} as unknown
  };

  try {
    const body = await c.req.json() as ImportItemsRequest;

    const db = createStandardDBProcessor();
    await db.setQueries(getImportItemsQuery(JSON.stringify(body)));
    const success = await db.executeQueries();

    if (success && Array.isArray(db.queryResults[0]) && db.queryResults[0].length > 0) {
      const resultSet = Array.isArray(db.queryResults[0][0]) ? db.queryResults[0][0] as unknown[] : db.queryResults[0];
      const row = resultSet[0] as Record<string, unknown>;
      const firstVal = Object.values(row)[0];
      const spEnvelope = parseSpEnvelope(firstVal);

      if (spEnvelope !== null) {
        const isArray = Array.isArray(spEnvelope);
        const finalData = isArray ? { success: true, message: 'ok', json_data: spEnvelope } : spEnvelope;
        result = {
          success: true,
          http_code: 200,
          message: 'Import items retrieved successfully',
          data: finalData
        };
      } else {
        result = {
          success: true,
          http_code: 200,
          message: 'Import items retrieved successfully',
          data: [{}]
        };
      }
    } else if (success) {
      result = {
        success: true,
        http_code: 200,
        message: 'Import items retrieved successfully',
        data: [{}]
      };
    }
  } catch (error) {
    await errorLogger.logError(error, 'getImportItemsHandler');
  }

  return c.json(result, result.http_code as 200 | 500);
}

export async function postItemImportsHandler(c: Context): Promise<Response> {
  let result = {
    success: false,
    http_code: 500,
    message: 'Failed to process item import',
    data: {} as unknown
  };

  try {
    const body = await c.req.json() as PostItemImportsRequest;

    const db = createStandardDBProcessor();
    await db.setQueries(postItemImportsQuery(JSON.stringify(body)));
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
    await errorLogger.logError(error, 'postItemImportsHandler');
  }

  return c.json(result, result.http_code as 200 | 500);
}
