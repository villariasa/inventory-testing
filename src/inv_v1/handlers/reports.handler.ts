import type { Context } from 'hono';
import { createStandardDBProcessor } from '../lib/database-factory.js';
import { ErrorLogger } from '../lib/errorlogger.js';
import {
  getPurchasesReportQuery,
  getClientNameQuery,
  getInternalStocksMovementsReportQuery,
  getDeliveriesReportQuery,
  getSalesReceivablesCollectionsJSONQuery,
  getSalesReportQuery,
  getClientLedgerQuery,
  getExpiriesAndPastDueQuery,
  getJSONStockCardQuery,
  getInventoryListQuery,
  getJSONPayablesAndTransactionsWithSuppliersQuery,
  getPayablesToSuppliersJSONQuery,
  getCustomerInactivityQuery
} from '../queries/reports.query.js';
import type {
  PurchasesReportRequest,
  ClientNameRequest,
  InternalStocksMovementsReportRequest,
  DeliveriesReportRequest,
  SalesReceivablesCollectionsRequest,
  SalesReportRequest,
  ClientLedgerRequest,
  ExpiriesAndPastDueRequest,
  JSONStockCardRequest,
  InventoryListRequest,
  PayablesAndTransactionsWithSuppliersRequest,
  PayablesToSuppliersRequest,
  CustomerInactivityRequest
} from '../interfaces/reports.interface.js';

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

export async function getPurchasesReportHandler(c: Context): Promise<Response> {
  let result = {
    success: false,
    http_code: 500,
    message: 'Failed to retrieve purchases report',
    data: {} as unknown
  };

  try {
    const body = await c.req.json() as PurchasesReportRequest;

    const db = createStandardDBProcessor();
    await db.setQueries(getPurchasesReportQuery(JSON.stringify(body)));
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
          message: 'Purchases report retrieved successfully',
          data: spEnvelope
        };
      } else {
        result = {
          success: true,
          http_code: 200,
          message: 'Purchases report retrieved successfully',
          data: [{}]
        };
      }
    } else if (success) {
      result = {
        success: true,
        http_code: 200,
        message: 'Purchases report retrieved successfully',
        data: [{}]
      };
    }
  } catch (error) {
    await errorLogger.logError(error, 'getPurchasesReportHandler');
  }

  return c.json(result, result.http_code as 200 | 500);
}

export async function getClientNameHandler(c: Context): Promise<Response> {
  let result = {
    success: false,
    http_code: 500,
    message: 'Failed to retrieve client name',
    data: {} as unknown
  };

  try {
    const body = await c.req.json() as ClientNameRequest;

    const db = createStandardDBProcessor();
    await db.setQueries(getClientNameQuery(JSON.stringify(body)));
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
          message: 'Client name retrieved successfully',
          data: spEnvelope
        };
      } else {
        result = {
          success: true,
          http_code: 200,
          message: 'Client name retrieved successfully',
          data: [{}]
        };
      }
    } else if (success) {
      result = {
        success: true,
        http_code: 200,
        message: 'Client name retrieved successfully',
        data: [{}]
      };
    }
  } catch (error) {
    await errorLogger.logError(error, 'getClientNameHandler');
  }

  return c.json(result, result.http_code as 200 | 500);
}

export async function getInternalStocksMovementsReportHandler(c: Context): Promise<Response> {
  let result = {
    success: false,
    http_code: 500,
    message: 'Failed to retrieve internal stocks movements report',
    data: {} as unknown
  };

  try {
    const body = await c.req.json() as InternalStocksMovementsReportRequest;

    const db = createStandardDBProcessor();
    await db.setQueries(getInternalStocksMovementsReportQuery(JSON.stringify(body)));
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
          message: 'Internal stocks movements report retrieved successfully',
          data: spEnvelope
        };
      } else {
        result = {
          success: true,
          http_code: 200,
          message: 'Internal stocks movements report retrieved successfully',
          data: [{}]
        };
      }
    } else if (success) {
      result = {
        success: true,
        http_code: 200,
        message: 'Internal stocks movements report retrieved successfully',
        data: [{}]
      };
    }
  } catch (error) {
    await errorLogger.logError(error, 'getInternalStocksMovementsReportHandler');
  }

  return c.json(result, result.http_code as 200 | 500);
}

export async function getDeliveriesReportHandler(c: Context): Promise<Response> {
  let result = {
    success: false,
    http_code: 500,
    message: 'Failed to retrieve deliveries report',
    data: {} as unknown
  };

  try {
    const body = await c.req.json() as DeliveriesReportRequest;

    const db = createStandardDBProcessor();
    await db.setQueries(getDeliveriesReportQuery(JSON.stringify(body)));
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
          message: 'Deliveries report retrieved successfully',
          data: spEnvelope
        };
      } else {
        result = {
          success: true,
          http_code: 200,
          message: 'Deliveries report retrieved successfully',
          data: [{}]
        };
      }
    } else if (success) {
      result = {
        success: true,
        http_code: 200,
        message: 'Deliveries report retrieved successfully',
        data: [{}]
      };
    }
  } catch (error) {
    await errorLogger.logError(error, 'getDeliveriesReportHandler');
  }

  return c.json(result, result.http_code as 200 | 500);
}

export async function getSalesReceivablesCollectionsJSONHandler(c: Context): Promise<Response> {
  let result = {
    success: false,
    http_code: 500,
    message: 'Failed to retrieve sales receivables collections',
    data: {} as unknown
  };

  try {
    const body = await c.req.json() as SalesReceivablesCollectionsRequest;

    const db = createStandardDBProcessor();
    await db.setQueries(getSalesReceivablesCollectionsJSONQuery(JSON.stringify(body)));
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
          message: 'Sales receivables collections retrieved successfully',
          data: spEnvelope
        };
      } else {
        result = {
          success: true,
          http_code: 200,
          message: 'Sales receivables collections retrieved successfully',
          data: [{}]
        };
      }
    } else if (success) {
      result = {
        success: true,
        http_code: 200,
        message: 'Sales receivables collections retrieved successfully',
        data: [{}]
      };
    }
  } catch (error) {
    await errorLogger.logError(error, 'getSalesReceivablesCollectionsJSONHandler');
  }

  return c.json(result, result.http_code as 200 | 500);
}

export async function getSalesReportHandler(c: Context): Promise<Response> {
  let result = {
    success: false,
    http_code: 500,
    message: 'Failed to retrieve sales report',
    data: {} as unknown
  };

  try {
    const body = await c.req.json() as SalesReportRequest;

    const db = createStandardDBProcessor();
    await db.setQueries(getSalesReportQuery(JSON.stringify(body)));
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
          message: 'Sales report retrieved successfully',
          data: spEnvelope
        };
      } else {
        result = {
          success: true,
          http_code: 200,
          message: 'Sales report retrieved successfully',
          data: [{}]
        };
      }
    } else if (success) {
      result = {
        success: true,
        http_code: 200,
        message: 'Sales report retrieved successfully',
        data: [{}]
      };
    }
  } catch (error) {
    await errorLogger.logError(error, 'getSalesReportHandler');
  }

  return c.json(result, result.http_code as 200 | 500);
}

export async function getClientLedgerHandler(c: Context): Promise<Response> {
  let result = {
    success: false,
    http_code: 500,
    message: 'Failed to retrieve client ledger',
    data: {} as unknown
  };

  try {
    const body = await c.req.json() as ClientLedgerRequest;

    const db = createStandardDBProcessor();
    await db.setQueries(getClientLedgerQuery(JSON.stringify(body)));
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
          message: 'Client ledger retrieved successfully',
          data: spEnvelope
        };
      } else {
        result = {
          success: true,
          http_code: 200,
          message: 'Client ledger retrieved successfully',
          data: [{}]
        };
      }
    } else if (success) {
      result = {
        success: true,
        http_code: 200,
        message: 'Client ledger retrieved successfully',
        data: [{}]
      };
    }
  } catch (error) {
    await errorLogger.logError(error, 'getClientLedgerHandler');
  }

  return c.json(result, result.http_code as 200 | 500);
}

export async function getExpiriesAndPastDueHandler(c: Context): Promise<Response> {
  let result = {
    success: false,
    http_code: 500,
    message: 'Failed to retrieve expiries and past due',
    data: {} as unknown
  };

  try {
    const body = await c.req.json() as ExpiriesAndPastDueRequest;

    const db = createStandardDBProcessor();
    await db.setQueries(getExpiriesAndPastDueQuery(JSON.stringify(body)));
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
          message: 'Expiries and past due retrieved successfully',
          data: spEnvelope
        };
      } else {
        result = {
          success: true,
          http_code: 200,
          message: 'Expiries and past due retrieved successfully',
          data: [{}]
        };
      }
    } else if (success) {
      result = {
        success: true,
        http_code: 200,
        message: 'Expiries and past due retrieved successfully',
        data: [{}]
      };
    }
  } catch (error) {
    await errorLogger.logError(error, 'getExpiriesAndPastDueHandler');
  }

  return c.json(result, result.http_code as 200 | 500);
}

export async function getJSONStockCardHandler(c: Context): Promise<Response> {
  let result = {
    success: false,
    http_code: 500,
    message: 'Failed to retrieve stock card',
    data: {} as unknown
  };

  try {
    const body = await c.req.json() as JSONStockCardRequest;

    const db = createStandardDBProcessor();
    await db.setQueries(getJSONStockCardQuery(JSON.stringify(body)));
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
          message: 'Stock card retrieved successfully',
          data: spEnvelope
        };
      } else {
        result = {
          success: true,
          http_code: 200,
          message: 'Stock card retrieved successfully',
          data: [{}]
        };
      }
    } else if (success) {
      result = {
        success: true,
        http_code: 200,
        message: 'Stock card retrieved successfully',
        data: [{}]
      };
    }
  } catch (error) {
    await errorLogger.logError(error, 'getJSONStockCardHandler');
  }

  return c.json(result, result.http_code as 200 | 500);
}

export async function getInventoryListHandler(c: Context): Promise<Response> {
  let result = {
    success: false,
    http_code: 500,
    message: 'Failed to retrieve inventory list',
    data: {} as unknown
  };

  try {
    const body = await c.req.json() as InventoryListRequest;

    const db = createStandardDBProcessor();
    await db.setQueries(getInventoryListQuery(JSON.stringify(body)));
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
          message: 'Inventory list retrieved successfully',
          data: spEnvelope
        };
      } else {
        result = {
          success: true,
          http_code: 200,
          message: 'Inventory list retrieved successfully',
          data: [{}]
        };
      }
    } else if (success) {
      result = {
        success: true,
        http_code: 200,
        message: 'Inventory list retrieved successfully',
        data: [{}]
      };
    }
  } catch (error) {
    await errorLogger.logError(error, 'getInventoryListHandler');
  }

  return c.json(result, result.http_code as 200 | 500);
}

export async function getJSONPayablesAndTransactionsWithSuppliersHandler(c: Context): Promise<Response> {
  let result = {
    success: false,
    http_code: 500,
    message: 'Failed to retrieve payables and transactions with suppliers',
    data: {} as unknown
  };

  try {
    const body = await c.req.json() as PayablesAndTransactionsWithSuppliersRequest;

    const db = createStandardDBProcessor();
    await db.setQueries(getJSONPayablesAndTransactionsWithSuppliersQuery(JSON.stringify(body)));
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
          message: 'Payables and transactions with suppliers retrieved successfully',
          data: spEnvelope
        };
      } else {
        result = {
          success: true,
          http_code: 200,
          message: 'Payables and transactions with suppliers retrieved successfully',
          data: [{}]
        };
      }
    } else if (success) {
      result = {
        success: true,
        http_code: 200,
        message: 'Payables and transactions with suppliers retrieved successfully',
        data: [{}]
      };
    }
  } catch (error) {
    await errorLogger.logError(error, 'getJSONPayablesAndTransactionsWithSuppliersHandler');
  }

  return c.json(result, result.http_code as 200 | 500);
}

export async function getPayablesToSuppliersJSONHandler(c: Context): Promise<Response> {
  let result = {
    success: false,
    http_code: 500,
    message: 'Failed to retrieve payables to suppliers',
    data: {} as unknown
  };

  try {
    const body = await c.req.json() as PayablesToSuppliersRequest;

    const db = createStandardDBProcessor();
    await db.setQueries(getPayablesToSuppliersJSONQuery(JSON.stringify(body)));
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
          message: 'Payables to suppliers retrieved successfully',
          data: spEnvelope
        };
      } else {
        result = {
          success: true,
          http_code: 200,
          message: 'Payables to suppliers retrieved successfully',
          data: [{}]
        };
      }
    } else if (success) {
      result = {
        success: true,
        http_code: 200,
        message: 'Payables to suppliers retrieved successfully',
        data: [{}]
      };
    }
  } catch (error) {
    await errorLogger.logError(error, 'getPayablesToSuppliersJSONHandler');
  }

  return c.json(result, result.http_code as 200 | 500);
}

export async function getCustomerInactivityHandler(c: Context): Promise<Response> {
  let result = {
    success: false,
    http_code: 500,
    message: 'Failed to retrieve customer inactivity',
    data: {} as unknown
  };

  try {
    const body = await c.req.json() as CustomerInactivityRequest;

    const db = createStandardDBProcessor();
    await db.setQueries(getCustomerInactivityQuery(JSON.stringify(body)));
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
          message: 'Customer inactivity retrieved successfully',
          data: spEnvelope
        };
      } else {
        result = {
          success: true,
          http_code: 200,
          message: 'Customer inactivity retrieved successfully',
          data: [{}]
        };
      }
    } else if (success) {
      result = {
        success: true,
        http_code: 200,
        message: 'Customer inactivity retrieved successfully',
        data: [{}]
      };
    }
  } catch (error) {
    await errorLogger.logError(error, 'getCustomerInactivityHandler');
  }

  return c.json(result, result.http_code as 200 | 500);
}
