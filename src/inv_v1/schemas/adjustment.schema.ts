import { z } from '@hono/zod-openapi';
import { StandardResponseSchema } from './common.schema.js';

export { StandardResponseSchema };

export const ItemForAdjustmentRequestSchema = z.object({
  template_id: z.number(),
  source_unit_id: z.number().nullable().optional(),
  destination_unit_id: z.number().nullable().optional(),
  item_description: z.string()
}).openapi('ItemForAdjustmentRequest');

export const InventoryItemAdjustmentRequestSchema = z.object({
  bol_getone: z.union([z.boolean(), z.number()]),
  adjustment_id: z.number(),
  date_from: z.string(),
  date_to: z.string()
}).openapi('InventoryItemAdjustmentRequest');

export const InventoryItemAdjustmentTemplateRequestSchema = z.object({
  bol_getone: z.union([z.boolean(), z.number()]),
  template_id: z.number(),
  description: z.string()
}).openapi('InventoryItemAdjustmentTemplateRequest');

export const PostInventoryItemAdjustmentRequestSchema = z.object({
  template_id: z.number(),
  source_unit_id: z.number().nullable().optional(),
  destination_unit_id: z.number().nullable().optional(),
  item_id: z.number(),
  quantity: z.number(),
  unit_cost: z.number(),
  remarks: z.string(),
  user_id: z.number()
}).openapi('PostInventoryItemAdjustmentRequest');

export const PostInventoryItemAdjustmentTemplateRequestSchema = z.object({
  process_type: z.number(),
  description: z.string(),
  require_destination_and_source: z.union([z.boolean(), z.number()]),
  add_to_quantity: z.union([z.boolean(), z.number()]),
  user_id: z.number(),
  template_id: z.number()
}).openapi('PostInventoryItemAdjustmentTemplateRequest');
