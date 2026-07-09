import { z } from '@hono/zod-openapi';
import { StandardResponseSchema } from './common.schema.js';

export const InventoryItemRequestSchema = z.object({
  bol_getone: z.union([z.boolean(), z.number()]),
  item_category_id: z.number(),
  item_id: z.number(),
  item_description: z.string()
}).openapi('InventoryItemRequest');

export const InventoryItemNoUnitRequestSchema = z.object({
  unit_id: z.number(),
  item_category_id: z.number(),
  item_description: z.string()
}).openapi('InventoryItemNoUnitRequest');

export const ItemImageRequestSchema = z.object({
  item_id: z.number()
}).openapi('ItemImageRequest');

export const EmptyUnitBinRequestSchema = z.object({
  bol_getone: z.union([z.boolean(), z.number()]),
  bin_id: z.number(),
  unit_id: z.number(),
  description: z.string()
}).openapi('EmptyUnitBinRequest');

export const PostInventoryItemRequestSchema = z.object({
  process_type: z.number(),
  item_category_id: z.number(),
  brand_id: z.number().nullable(),
  model_description: z.string(),
  part_id: z.number().nullable(),
  part_number_id: z.number().nullable(),
  size_id: z.number().nullable(),
  valve_id: z.number().nullable(),
  ratio_id: z.number().nullable(),
  pattern_id: z.number().nullable(),
  stocking_unit: z.string(),
  retail_unit: z.string(),
  rtu_over_stu: z.number(),
  wtd_ave_cost: z.number(),
  mark_up_rate: z.number(),
  selling_price: z.number().nullable(),
  user_id: z.number(),
  has_empty_case: z.number(),
  image: z.string().nullable(),
  item_id: z.number(),
  barcode: z.string().nullable().optional()
}).openapi('PostInventoryItemRequest');

export const ScanInventoryItemRequestSchema = z.object({
  barcode: z.string()
}).openapi('ScanInventoryItemRequest');

export const PostItemToUnitsRequestSchema = z.object({
  item_id: z.number(),
  user_id: z.number(),
  units: z.array(z.object({
    unit_id: z.number(),
    bin_id: z.number()
  }))
}).openapi('PostItemToUnitsRequest');

export { StandardResponseSchema };
