import { z } from '@hono/zod-openapi';
import { StandardResponseSchema } from './common.schema.js';

export { StandardResponseSchema };

export const PurchasesReportRequestSchema = z.object({
  start_date: z.string(),
  end_date: z.string(),
  client_id: z.string(),
  withCost: z.union([z.boolean(), z.number()])
}).openapi('PurchasesReportRequest');

export const ClientNameRequestSchema = z.object({
  entity_id: z.number().optional()
}).openapi('ClientNameRequest');

export const InternalStocksMovementsReportRequestSchema = z.object({
  start_date: z.string(),
  end_date: z.string(),
  units: z.array(z.union([z.string(), z.number()]))
}).openapi('InternalStocksMovementsReportRequest');

export const DeliveriesReportRequestSchema = z.object({
  dateFrom: z.string(),
  dateTo: z.string(),
  units: z.array(z.union([z.string(), z.number()])),
  withCost: z.union([z.boolean(), z.number()])
}).openapi('DeliveriesReportRequest');

export const SalesReceivablesCollectionsRequestSchema = z.object({
  start_date: z.string(),
  end_date: z.string(),
  units: z.array(z.union([z.string(), z.number()]))
}).openapi('SalesReceivablesCollectionsRequest');

export const SalesReportRequestSchema = z.object({
  start_date: z.string(),
  end_date: z.string(),
  charUnitList: z.array(z.union([z.string(), z.number()]))
}).openapi('SalesReportRequest');

export const ClientLedgerRequestSchema = z.object({
  start_date: z.string(),
  end_date: z.string(),
  client_id: z.number()
}).openapi('ClientLedgerRequest');

export const ExpiriesAndPastDueRequestSchema = z.object({
  units: z.array(z.union([z.string(), z.number()]))
}).openapi('ExpiriesAndPastDueRequest');

export const JSONStockCardRequestSchema = z.object({
  unit_id: z.number(),
  start_date: z.string(),
  end_date: z.string()
}).openapi('JSONStockCardRequest');

export const InventoryListRequestSchema = z.object({
  units: z.array(z.union([z.string(), z.number()])),
  withCost: z.union([z.boolean(), z.number()])
}).openapi('InventoryListRequest');

export const PayablesAndTransactionsWithSuppliersRequestSchema = z.object({
  supplier_id: z.number(),
  start_date: z.string(),
  end_date: z.string(),
  onterm: z.union([z.boolean(), z.number()])
}).openapi('PayablesAndTransactionsWithSuppliersRequest');

export const PayablesToSuppliersRequestSchema = z.object({
  date: z.string()
}).openapi('PayablesToSuppliersRequest');

export const CustomerInactivityRequestSchema = z.object({
  start_date: z.string(),
  end_date: z.string(),
  charUnitList: z.array(z.union([z.string(), z.number()]))
}).openapi('CustomerInactivityRequest');
