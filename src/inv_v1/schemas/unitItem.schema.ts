import { z } from '@hono/zod-openapi';

export { StandardResponseSchema } from './common.schema.js';

export const InventoryUnitItemRequestSchema = z.object({
  bol_getone: z.union([z.boolean(), z.number()]),
  unit_id: z.number().nullable(),
  item_category_id: z.number().nullable(),
  unit_item_id: z.number(),
  item_description: z.string()
}).openapi('InventoryUnitItemRequest');

export const UnitItemInfoByBinRequestSchema = z.object({
  bin_id: z.number()
}).openapi('UnitItemInfoByBinRequest');

export const PostUnitItemBinSwitchRequestSchema = z.object({
  user_id: z.number(),
  swapped_items: z.array(z.object({
    unit_item_id: z.number(),
    from_bin_id: z.number(),
    to_bin_id: z.number()
  }))
}).openapi('PostUnitItemBinSwitchRequest');

export const PostInventoryUnitItemRequestSchema = z.object({
  process_type: z.number(),
  unit_item_id: z.number(),
  item_id: z.number().nullable(),
  unit_id: z.number(),
  starting_period: z.string(),
  starting_quantity: z.number(),
  quantity_in: z.number(),
  quantity_out: z.number(),
  unit_cost: z.number(),
  last_highest_in_unit_cost: z.number(),
  bin_id: z.number().nullable(),
  user_id: z.number()
}).openapi('PostInventoryUnitItemRequest');

