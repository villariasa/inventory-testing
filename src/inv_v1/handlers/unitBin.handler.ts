import type { Context } from 'hono';
import { createStandardDBProcessor } from '../lib/database-factory.js';
import { ErrorLogger } from '../lib/errorlogger.js';
import {
  getInventoryUnitBinQuery,
  getUnitBinExceptOneQuery,
  postInventoryUnitBinQuery
} from '../queries/unitBin.query.js';
import type {
  InventoryUnitBinRequest,
  UnitBinExceptOneRequest,
  PostInventoryUnitBinRequest
} from '../interfaces/unitBin.interface.js';

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

export async function getInventoryUnitBinHandler(c: Context): Promise<Response> {
  let result = {
    success: false,
    http_code: 500,
    message: 'Failed to retrieve inventory unit bin',
    data: {} as unknown
  };

  try {
    const body = await c.req.json() as InventoryUnitBinRequest;

    const db = createStandardDBProcessor();
    await db.setQueries(getInventoryUnitBinQuery(JSON.stringify(body)));
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
          message: 'Inventory unit bin retrieved successfully',
          data: spEnvelope
        };
      } else {
        result = {
          success: true,
          http_code: 200,
          message: 'Inventory unit bin retrieved successfully',
          data: [{}]
        };
      }
    } else if (success) {
      result = {
        success: true,
        http_code: 200,
        message: 'Inventory unit bin retrieved successfully',
        data: [{}]
      };
    }
  } catch (error) {
    await errorLogger.logError(error, 'getInventoryUnitBinHandler');
  }

  return c.json(result, result.http_code as 200 | 500);
}

export async function getUnitBinExceptOneHandler(c: Context): Promise<Response> {
  let result = {
    success: false,
    http_code: 500,
    message: 'Failed to retrieve unit bins',
    data: {} as unknown
  };

  try {
    const body = await c.req.json() as UnitBinExceptOneRequest;

    const db = createStandardDBProcessor();
    await db.setQueries(getUnitBinExceptOneQuery(JSON.stringify(body)));
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
          message: 'Unit bins retrieved successfully',
          data: spEnvelope
        };
      } else {
        result = {
          success: true,
          http_code: 200,
          message: 'Unit bins retrieved successfully',
          data: [{}]
        };
      }
    } else if (success) {
      result = {
        success: true,
        http_code: 200,
        message: 'Unit bins retrieved successfully',
        data: [{}]
      };
    }
  } catch (error) {
    await errorLogger.logError(error, 'getUnitBinExceptOneHandler');
  }

  return c.json(result, result.http_code as 200 | 500);
}

export async function postInventoryUnitBinHandler(c: Context): Promise<Response> {
  let result = {
    success: false,
    http_code: 500,
    message: 'Failed to process unit bin request',
    data: {} as unknown
  };

  try {
    const body = await c.req.json() as PostInventoryUnitBinRequest;

    const db = createStandardDBProcessor();
    await db.setQueries(postInventoryUnitBinQuery(JSON.stringify(body)));
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
          message: 'Unit bin processed successfully',
          data: spEnvelope
        };
      } else {
        result = {
          success: true,
          http_code: 200,
          message: 'Unit bin processed successfully',
          data: [{}]
        };
      }
    } else if (success) {
      result = {
        success: true,
        http_code: 200,
        message: 'Unit bin processed successfully',
        data: [{}]
      };
    }
  } catch (error) {
    await errorLogger.logError(error, 'postInventoryUnitBinHandler');
  }

  return c.json(result, result.http_code as 200 | 500);
}
