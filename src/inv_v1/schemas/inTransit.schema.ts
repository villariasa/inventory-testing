import { z } from '@hono/zod-openapi';
import { StandardResponseSchema } from './common.schema.js';

export { StandardResponseSchema };

export const InstransitReportRequestSchema = z.object({
  search: z.string()
}).openapi('InstransitReportRequest');

export const InTransitReportRequestSchema = z.object({}).openapi('InTransitReportRequest');

export const InTransitItemsInvoicesRequestSchema = z.object({
  bol_getone: z.union([z.boolean(), z.number()]),
  invoice_id: z.number(),
  user_id: z.number(),
  invoice_reference: z.string()
}).openapi('InTransitItemsInvoicesRequest');

export const PostConfirmInTransitItemsRequestSchema = z.object({
  user_id: z.number(),
  invoice_id: z.number(),
  in_transit_items: z.array(z.object({
    in_transit_id: z.number(),
    quanttiy_confirmed: z.number()
  }))
}).openapi('PostConfirmInTransitItemsRequest');
