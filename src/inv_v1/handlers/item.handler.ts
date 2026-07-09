import type { Context } from 'hono';
import { createStandardDBProcessor } from '../lib/database-factory.js';
import { ErrorLogger } from '../lib/errorlogger.js';
import {
  getInventoryItemQuery,
  getInventoryItemNoUnitQuery,
  getItemImageQuery,
  getEmptyUnitBinQuery,
  postInventoryItemQuery,
  postItemToUnitsQuery
} from '../queries/item.query.js';
import type {
  InventoryItemRequest,
  InventoryItemNoUnitRequest,
  ItemImageRequest,
  EmptyUnitBinRequest,
  PostInventoryItemRequest,
  PostItemToUnitsRequest,
  ScanInventoryItemRequest
} from '../interfaces/item.interface.js';

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

export async function getInventoryItemHandler(c: Context): Promise<Response> {
  let result = {
    success: false,
    http_code: 500,
    message: 'Failed to retrieve inventory item',
    data: {} as unknown
  };

  try {
    const body = await c.req.json() as InventoryItemRequest;

    const db = createStandardDBProcessor();
    await db.setQueries(getInventoryItemQuery(JSON.stringify(body)));
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
          message: 'Inventory item retrieved successfully',
          data: spEnvelope
        };
      } else {
        result = {
          success: true,
          http_code: 200,
          message: 'Inventory item retrieved successfully',
          data: [{}]
        };
      }
    } else if (success) {
      result = {
        success: true,
        http_code: 200,
        message: 'Inventory item retrieved successfully',
        data: [{}]
      };
    }
  } catch (error) {
    await errorLogger.logError(error, 'getInventoryItemHandler');
  }

  return c.json(result, result.http_code as 200 | 500);
}

export async function getInventoryItemNoUnitHandler(c: Context): Promise<Response> {
  let result = {
    success: false,
    http_code: 500,
    message: 'Failed to retrieve inventory item (no unit)',
    data: {} as unknown
  };

  try {
    const body = await c.req.json() as InventoryItemNoUnitRequest;

    const db = createStandardDBProcessor();
    await db.setQueries(getInventoryItemNoUnitQuery(JSON.stringify(body)));
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
          message: 'Inventory item (no unit) retrieved successfully',
          data: spEnvelope
        };
      } else {
        result = {
          success: true,
          http_code: 200,
          message: 'Inventory item (no unit) retrieved successfully',
          data: [{}]
        };
      }
    } else if (success) {
      result = {
        success: true,
        http_code: 200,
        message: 'Inventory item (no unit) retrieved successfully',
        data: [{}]
      };
    }
  } catch (error) {
    await errorLogger.logError(error, 'getInventoryItemNoUnitHandler');
  }

  return c.json(result, result.http_code as 200 | 500);
}

export async function getItemImageHandler(c: Context): Promise<Response> {
  let result = {
    success: false,
    http_code: 500,
    message: 'Failed to retrieve item image',
    data: {} as unknown
  };

  try {
    const body = await c.req.json() as ItemImageRequest;

    const db = createStandardDBProcessor();
    await db.setQueries(getItemImageQuery(JSON.stringify(body)));
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
          message: 'Item image retrieved successfully',
          data: spEnvelope
        };
      } else {
        result = {
          success: true,
          http_code: 200,
          message: 'Item image retrieved successfully',
          data: [{}]
        };
      }
    } else if (success) {
      result = {
        success: true,
        http_code: 200,
        message: 'Item image retrieved successfully',
        data: [{}]
      };
    }
  } catch (error) {
    await errorLogger.logError(error, 'getItemImageHandler');
  }

  return c.json(result, result.http_code as 200 | 500);
}

export async function getEmptyUnitBinHandler(c: Context): Promise<Response> {
  let result = {
    success: false,
    http_code: 500,
    message: 'Failed to retrieve empty unit bin',
    data: {} as unknown
  };

  try {
    const body = await c.req.json() as EmptyUnitBinRequest;

    const db = createStandardDBProcessor();
    await db.setQueries(getEmptyUnitBinQuery(JSON.stringify(body)));
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
          message: 'Empty unit bin retrieved successfully',
          data: spEnvelope
        };
      } else {
        result = {
          success: true,
          http_code: 200,
          message: 'Empty unit bin retrieved successfully',
          data: [{}]
        };
      }
    } else if (success) {
      result = {
        success: true,
        http_code: 200,
        message: 'Empty unit bin retrieved successfully',
        data: [{}]
      };
    }
  } catch (error) {
    await errorLogger.logError(error, 'getEmptyUnitBinHandler');
  }

  return c.json(result, result.http_code as 200 | 500);
}

export async function postInventoryItemHandler(c: Context): Promise<Response> {
  let result = {
    success: false,
    http_code: 500,
    message: 'Failed to process inventory item',
    data: {} as unknown
  };

  try {
    const body = await c.req.json() as PostInventoryItemRequest;

    const db = createStandardDBProcessor();
    await db.setQueries(postInventoryItemQuery(JSON.stringify(body)));
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
    await errorLogger.logError(error, 'postInventoryItemHandler');
  }

  return c.json(result, result.http_code as 200 | 500);
}

export async function postItemToUnitsHandler(c: Context): Promise<Response> {
  let result = {
    success: false,
    http_code: 500,
    message: 'Failed to add item to units',
    data: {} as unknown
  };

  try {
    const body = await c.req.json() as PostItemToUnitsRequest;

    const db = createStandardDBProcessor();
    await db.setQueries(postItemToUnitsQuery(JSON.stringify(body)));
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
    await errorLogger.logError(error, 'postItemToUnitsHandler');
  }

  return c.json(result, result.http_code as 200 | 500);
}

export async function scanInventoryItemHandler(c: Context): Promise<Response> {
  let result = {
    success: false,
    http_code: 500,
    message: 'Failed to scan inventory item',
    data: {} as unknown
  };

  try {
    const body = await c.req.json() as ScanInventoryItemRequest;

    const db = createStandardDBProcessor();
    const queryParam = JSON.stringify({
      bol_getone: 0,
      barcode: body.barcode
    });
    await db.setQueries(getInventoryItemQuery(queryParam));
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
          message: 'Inventory item retrieved successfully',
          data: spEnvelope
        };
      } else {
        result = {
          success: true,
          http_code: 200,
          message: 'Inventory item retrieved successfully',
          data: { success: true, message: 'No item found', json_data: [] }
        };
      }
    } else if (success) {
      result = {
        success: true,
        http_code: 200,
        message: 'Inventory item retrieved successfully',
        data: { success: true, message: 'No item found', json_data: [] }
      };
    }
  } catch (error) {
    await errorLogger.logError(error, 'scanInventoryItemHandler');
  }

  return c.json(result, result.http_code as 200 | 500);
}
