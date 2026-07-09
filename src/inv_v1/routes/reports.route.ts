import { OpenAPIHono, createRoute } from '@hono/zod-openapi';
import {
  PurchasesReportRequestSchema,
  ClientNameRequestSchema,
  InternalStocksMovementsReportRequestSchema,
  DeliveriesReportRequestSchema,
  SalesReceivablesCollectionsRequestSchema,
  SalesReportRequestSchema,
  ClientLedgerRequestSchema,
  ExpiriesAndPastDueRequestSchema,
  JSONStockCardRequestSchema,
  InventoryListRequestSchema,
  PayablesAndTransactionsWithSuppliersRequestSchema,
  PayablesToSuppliersRequestSchema,
  CustomerInactivityRequestSchema,
  StandardResponseSchema
} from '../schemas/reports.schema.js';
import {
  getPurchasesReportHandler,
  getClientNameHandler,
  getInternalStocksMovementsReportHandler,
  getDeliveriesReportHandler,
  getSalesReceivablesCollectionsJSONHandler,
  getSalesReportHandler,
  getClientLedgerHandler,
  getExpiriesAndPastDueHandler,
  getJSONStockCardHandler,
  getInventoryListHandler,
  getJSONPayablesAndTransactionsWithSuppliersHandler,
  getPayablesToSuppliersJSONHandler,
  getCustomerInactivityHandler
} from '../handlers/reports.handler.js';

export const reportsRoute = new OpenAPIHono();

const getPurchasesReportRoute = createRoute({
  method: 'post',
  path: '/get-purchases-report',
  tags: ['Reports'],
  summary: 'Get purchases report',
  request: {
    body: {
      content: {
        'application/json': {
          schema: PurchasesReportRequestSchema,
          example: { start_date: '2024-01-01', end_date: '2024-12-31', client_id: '0', withCost: false }
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.getPurchasesReport — Purchases report retrieved'
    }
  }
});
reportsRoute.openapi(getPurchasesReportRoute, getPurchasesReportHandler as never);

const getClientNameRoute = createRoute({
  method: 'post',
  path: '/get-client-name',
  tags: ['Reports'],
  summary: 'Get client name(s)',
  request: {
    body: {
      content: {
        'application/json': {
          schema: ClientNameRequestSchema,
          example: { entity_id: 0 }
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.getClientName — Client name(s) retrieved'
    }
  }
});
reportsRoute.openapi(getClientNameRoute, getClientNameHandler as never);

const getInternalStocksMovementsReportRoute = createRoute({
  method: 'post',
  path: '/get-internal-stocks-movements-report',
  tags: ['Reports'],
  summary: 'Get internal stocks movements report',
  request: {
    body: {
      content: {
        'application/json': {
          schema: InternalStocksMovementsReportRequestSchema,
          example: { start_date: '2024-01-01', end_date: '2024-12-31', units: ['0'] }
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.getInternalStocksMovementsReport — Internal stocks movements report retrieved'
    }
  }
});
reportsRoute.openapi(getInternalStocksMovementsReportRoute, getInternalStocksMovementsReportHandler as never);

const getDeliveriesReportRoute = createRoute({
  method: 'post',
  path: '/get-deliveries-report',
  tags: ['Reports'],
  summary: 'Get deliveries report',
  request: {
    body: {
      content: {
        'application/json': {
          schema: DeliveriesReportRequestSchema,
          example: { dateFrom: '2024-01-01', dateTo: '2024-12-31', units: ['0'], withCost: false }
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.getDeliveriesReport — Deliveries report retrieved'
    }
  }
});
reportsRoute.openapi(getDeliveriesReportRoute, getDeliveriesReportHandler as never);

const getSalesReceivablesCollectionsJSONRoute = createRoute({
  method: 'post',
  path: '/get-sales-receivables-collections',
  tags: ['Reports'],
  summary: 'Get sales receivables collections',
  request: {
    body: {
      content: {
        'application/json': {
          schema: SalesReceivablesCollectionsRequestSchema,
          example: { start_date: '2024-01-01', end_date: '2024-12-31', units: ['0'] }
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.getSalesReceivablesCollectionsJSON — Sales receivables collections retrieved'
    }
  }
});
reportsRoute.openapi(getSalesReceivablesCollectionsJSONRoute, getSalesReceivablesCollectionsJSONHandler as never);

const getSalesReportRoute = createRoute({
  method: 'post',
  path: '/get-sales-report',
  tags: ['Reports'],
  summary: 'Get sales report',
  request: {
    body: {
      content: {
        'application/json': {
          schema: SalesReportRequestSchema,
          example: { start_date: '2024-01-01', end_date: '2024-12-31', charUnitList: ['0'] }
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.getSalesReport — Sales report retrieved'
    }
  }
});
reportsRoute.openapi(getSalesReportRoute, getSalesReportHandler as never);

const getClientLedgerRoute = createRoute({
  method: 'post',
  path: '/get-client-ledger',
  tags: ['Reports'],
  summary: 'Get client ledger',
  request: {
    body: {
      content: {
        'application/json': {
          schema: ClientLedgerRequestSchema,
          example: { start_date: '2024-01-01', end_date: '2024-12-31', client_id: 0 }
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.getClientLedger — Client ledger retrieved'
    }
  }
});
reportsRoute.openapi(getClientLedgerRoute, getClientLedgerHandler as never);

const getExpiriesAndPastDueRoute = createRoute({
  method: 'post',
  path: '/get-expiries-and-past-due',
  tags: ['Reports'],
  summary: 'Get expiries and past due',
  request: {
    body: {
      content: {
        'application/json': {
          schema: ExpiriesAndPastDueRequestSchema,
          example: { units: ['1'] }
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.getExpiriesAndPastDue — Expiries and past due retrieved'
    }
  }
});
reportsRoute.openapi(getExpiriesAndPastDueRoute, getExpiriesAndPastDueHandler as never);

const getJSONStockCardRoute = createRoute({
  method: 'post',
  path: '/get-stock-card',
  tags: ['Reports'],
  summary: 'Get stock card',
  request: {
    body: {
      content: {
        'application/json': {
          schema: JSONStockCardRequestSchema,
          example: { unit_id: 1, start_date: '2024-01-01', end_date: '2024-12-31' }
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.getJSONStockCard — Stock card retrieved'
    }
  }
});
reportsRoute.openapi(getJSONStockCardRoute, getJSONStockCardHandler as never);

const getInventoryListRoute = createRoute({
  method: 'post',
  path: '/get-inventory-list',
  tags: ['Reports'],
  summary: 'Get inventory list',
  request: {
    body: {
      content: {
        'application/json': {
          schema: InventoryListRequestSchema,
          example: { units: ['0'], withCost: false }
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.getInventoryList — Inventory list retrieved'
    }
  }
});
reportsRoute.openapi(getInventoryListRoute, getInventoryListHandler as never);

const getJSONPayablesAndTransactionsWithSuppliersRoute = createRoute({
  method: 'post',
  path: '/get-payables-and-transactions-with-suppliers',
  tags: ['Reports'],
  summary: 'Get payables and transactions with suppliers',
  request: {
    body: {
      content: {
        'application/json': {
          schema: PayablesAndTransactionsWithSuppliersRequestSchema,
          example: { supplier_id: 0, start_date: '2024-01-01', end_date: '2024-12-31', onterm: false }
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.getJSONPayablesAndTransactionsWithSuppliers — Payables and transactions with suppliers retrieved'
    }
  }
});
reportsRoute.openapi(getJSONPayablesAndTransactionsWithSuppliersRoute, getJSONPayablesAndTransactionsWithSuppliersHandler as never);

const getPayablesToSuppliersJSONRoute = createRoute({
  method: 'post',
  path: '/get-payables-to-suppliers',
  tags: ['Reports'],
  summary: 'Get payables to suppliers',
  request: {
    body: {
      content: {
        'application/json': {
          schema: PayablesToSuppliersRequestSchema,
          example: { date: '2024-12-31' }
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.getPayablesToSuppliersJSON — Payables to suppliers retrieved'
    }
  }
});
reportsRoute.openapi(getPayablesToSuppliersJSONRoute, getPayablesToSuppliersJSONHandler as never);

const getCustomerInactivityRoute = createRoute({
  method: 'post',
  path: '/get-customer-inactivity',
  tags: ['Reports'],
  summary: 'Get customer inactivity',
  request: {
    body: {
      content: {
        'application/json': {
          schema: CustomerInactivityRequestSchema,
          example: { start_date: '2024-01-01', end_date: '2024-12-31', charUnitList: ['0'] }
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.getCustomerInactivity — Customer inactivity retrieved'
    }
  }
});
reportsRoute.openapi(getCustomerInactivityRoute, getCustomerInactivityHandler as never);
