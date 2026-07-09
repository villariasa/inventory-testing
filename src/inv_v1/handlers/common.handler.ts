import type { Context } from 'hono';
import { createStandardDBProcessor } from '../lib/database-factory.js';
import { ErrorLogger } from '../lib/errorlogger.js';
import {
  getUnitNameQuery,
  getUserUnitQuery,
  getUserUnitArrayQuery,
  getUserDesignatedUnitQuery,
  getAdjustmentUserUnitQuery,
  getSelectableAccountsConcatenatedQuery
} from '../queries/common.query.js';
import type {
  UnitNameRequest,
  UserUnitRequest,
  UserUnitArrayRequest,
  UserDesignatedUnitRequest,
  AdjustmentUserUnitRequest,
  SelectableAccountsRequest
} from '../interfaces/common.interface.js';

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

export async function getUnitNameHandler(c: Context): Promise<Response> {
  let result = {
    success: false,
    http_code: 500,
    message: 'Failed to retrieve unit name',
    data: {} as unknown
  };

  try {
    const body = await c.req.json() as UnitNameRequest;

    const db = createStandardDBProcessor();
    await db.setQueries(getUnitNameQuery(JSON.stringify(body)));
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
          message: 'Unit name retrieved successfully',
          data: spEnvelope
        };
      } else {
        result = {
          success: true,
          http_code: 200,
          message: 'Unit name retrieved successfully',
          data: [{}]
        };
      }
    } else if (success) {
      result = {
        success: true,
        http_code: 200,
        message: 'Unit name retrieved successfully',
        data: [{}]
      };
    }
  } catch (error) {
    await errorLogger.logError(error, 'getUnitNameHandler');
  }

  return c.json(result, result.http_code as 200 | 500);
}

export async function getUserUnitHandler(c: Context): Promise<Response> {
  let result = {
    success: false,
    http_code: 500,
    message: 'Failed to retrieve user unit',
    data: {} as unknown
  };

  try {
    const body = await c.req.json() as UserUnitRequest;

    const db = createStandardDBProcessor();
    await db.setQueries(getUserUnitQuery(JSON.stringify(body)));
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
          message: 'User unit retrieved successfully',
          data: spEnvelope
        };
      } else {
        result = {
          success: true,
          http_code: 200,
          message: 'User unit retrieved successfully',
          data: [{}]
        };
      }
    } else if (success) {
      result = {
        success: true,
        http_code: 200,
        message: 'User unit retrieved successfully',
        data: [{}]
      };
    }
  } catch (error) {
    await errorLogger.logError(error, 'getUserUnitHandler');
  }

  return c.json(result, result.http_code as 200 | 500);
}

export async function getUserUnitArrayHandler(c: Context): Promise<Response> {
  let result = {
    success: false,
    http_code: 500,
    message: 'Failed to retrieve user unit array',
    data: {} as unknown
  };

  try {
    const body = await c.req.json() as UserUnitArrayRequest;

    const db = createStandardDBProcessor();
    await db.setQueries(getUserUnitArrayQuery(JSON.stringify(body)));
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
          message: 'User unit array retrieved successfully',
          data: spEnvelope
        };
      } else {
        result = {
          success: true,
          http_code: 200,
          message: 'User unit array retrieved successfully',
          data: [{}]
        };
      }
    } else if (success) {
      result = {
        success: true,
        http_code: 200,
        message: 'User unit array retrieved successfully',
        data: [{}]
      };
    }
  } catch (error) {
    await errorLogger.logError(error, 'getUserUnitArrayHandler');
  }

  return c.json(result, result.http_code as 200 | 500);
}

export async function getUserDesignatedUnitHandler(c: Context): Promise<Response> {
  let result = {
    success: false,
    http_code: 500,
    message: 'Failed to retrieve user designated unit',
    data: {} as unknown
  };

  try {
    const body = await c.req.json() as UserDesignatedUnitRequest;

    const db = createStandardDBProcessor();
    await db.setQueries(getUserDesignatedUnitQuery(JSON.stringify(body)));
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
          message: 'User designated unit retrieved successfully',
          data: spEnvelope
        };
      } else {
        result = {
          success: true,
          http_code: 200,
          message: 'User designated unit retrieved successfully',
          data: [{}]
        };
      }
    } else if (success) {
      result = {
        success: true,
        http_code: 200,
        message: 'User designated unit retrieved successfully',
        data: [{}]
      };
    }
  } catch (error) {
    await errorLogger.logError(error, 'getUserDesignatedUnitHandler');
  }

  return c.json(result, result.http_code as 200 | 500);
}

export async function getAdjustmentUserUnitHandler(c: Context): Promise<Response> {
  let result = {
    success: false,
    http_code: 500,
    message: 'Failed to retrieve adjustment user unit',
    data: {} as unknown
  };

  try {
    const body = await c.req.json() as AdjustmentUserUnitRequest;

    const db = createStandardDBProcessor();
    await db.setQueries(getAdjustmentUserUnitQuery(JSON.stringify(body)));
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
          message: 'Adjustment user unit retrieved successfully',
          data: spEnvelope
        };
      } else {
        result = {
          success: true,
          http_code: 200,
          message: 'Adjustment user unit retrieved successfully',
          data: [{}]
        };
      }
    } else if (success) {
      result = {
        success: true,
        http_code: 200,
        message: 'Adjustment user unit retrieved successfully',
        data: [{}]
      };
    }
  } catch (error) {
    await errorLogger.logError(error, 'getAdjustmentUserUnitHandler');
  }

  return c.json(result, result.http_code as 200 | 500);
}

export async function getSelectableAccountsConcatenatedHandler(c: Context): Promise<Response> {
  let result = {
    success: false,
    http_code: 500,
    message: 'Failed to retrieve selectable accounts',
    data: {} as unknown
  };

  try {
    const body = await c.req.json() as SelectableAccountsRequest;

    const db = createStandardDBProcessor();
    await db.setQueries(getSelectableAccountsConcatenatedQuery(JSON.stringify(body)));
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
          message: 'Selectable accounts retrieved successfully',
          data: spEnvelope
        };
      } else {
        result = {
          success: true,
          http_code: 200,
          message: 'Selectable accounts retrieved successfully',
          data: [{}]
        };
      }
    } else if (success) {
      result = {
        success: true,
        http_code: 200,
        message: 'Selectable accounts retrieved successfully',
        data: [{}]
      };
    }
  } catch (error) {
    await errorLogger.logError(error, 'getSelectableAccountsConcatenatedHandler');
  }

  return c.json(result, result.http_code as 200 | 500);
}
