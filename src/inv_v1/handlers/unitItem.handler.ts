import type { Context } from 'hono';
import { createStandardDBProcessor } from '../lib/database-factory.js';
import { ErrorLogger } from '../lib/errorlogger.js';
import {
  getInventoryUnitItemQuery,
  getUnitItemInfoByBinQuery,
  postUnitItemBinSwitchQuery,
  postInventoryUnitItemQuery
} from '../queries/unitItem.query.js';
import type {
  InventoryUnitItemRequest,
  UnitItemInfoByBinRequest,
  PostUnitItemBinSwitchRequest,
  PostInventoryUnitItemRequest
} from '../interfaces/unitItem.interface.js';

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

export async function getInventoryUnitItemHandler(c: Context): Promise<Response> {
  let result = {
    success: false,
    http_code: 500,
    message: 'Failed to retrieve inventory unit item',
    data: {} as unknown
  };

  try {
    const body = await c.req.json() as InventoryUnitItemRequest;

    const db = createStandardDBProcessor();
    await db.setQueries(getInventoryUnitItemQuery(JSON.stringify(body)));
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
          message: 'Inventory unit item retrieved successfully',
          data: spEnvelope
        };
      } else {
        result = {
          success: true,
          http_code: 200,
          message: 'Inventory unit item retrieved successfully',
          data: [{}]
        };
      }
    } else if (success) {
      result = {
        success: true,
        http_code: 200,
        message: 'Inventory unit item retrieved successfully',
        data: [{}]
      };
    }
  } catch (error) {
    await errorLogger.logError(error, 'getInventoryUnitItemHandler');
  }

  return c.json(result, result.http_code as 200 | 500);
}

export async function getUnitItemInfoByBinHandler(c: Context): Promise<Response> {
  let result = {
    success: false,
    http_code: 500,
    message: 'Failed to retrieve unit item info by bin',
    data: {} as unknown
  };

  try {
    const body = await c.req.json() as UnitItemInfoByBinRequest;

    const db = createStandardDBProcessor();
    await db.setQueries(getUnitItemInfoByBinQuery(JSON.stringify(body)));
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
          message: 'Unit item info retrieved successfully',
          data: spEnvelope
        };
      } else {
        result = {
          success: true,
          http_code: 200,
          message: 'Unit item info retrieved successfully',
          data: [{}]
        };
      }
    } else if (success) {
      result = {
        success: true,
        http_code: 200,
        message: 'Unit item info retrieved successfully',
        data: [{}]
      };
    }
  } catch (error) {
    await errorLogger.logError(error, 'getUnitItemInfoByBinHandler');
  }

  return c.json(result, result.http_code as 200 | 500);
}

export async function postUnitItemBinSwitchHandler(c: Context): Promise<Response> {
  let result = {
    success: false,
    http_code: 500,
    message: 'Failed to switch unit item bin',
    data: {} as unknown
  };

  try {
    const body = await c.req.json() as PostUnitItemBinSwitchRequest;

    const db = createStandardDBProcessor();
    await db.setQueries(postUnitItemBinSwitchQuery(JSON.stringify(body)));
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
    await errorLogger.logError(error, 'postUnitItemBinSwitchHandler');
  }

  return c.json(result, result.http_code as 200 | 500);
}

export async function postInventoryUnitItemHandler(c: Context): Promise<Response> {
  let result = {
    success: false,
    http_code: 500,
    message: 'Failed to process inventory unit item',
    data: {} as unknown
  };

  try {
    const body = await c.req.json() as PostInventoryUnitItemRequest;

    const db = createStandardDBProcessor();
    await db.setQueries(postInventoryUnitItemQuery(JSON.stringify(body)));
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
    await errorLogger.logError(error, 'postInventoryUnitItemHandler');
  }

  return c.json(result, result.http_code as 200 | 500);
}

