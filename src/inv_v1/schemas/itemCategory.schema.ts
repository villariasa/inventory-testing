import { z } from '@hono/zod-openapi';
import { StandardResponseSchema } from './common.schema.js';

export const InventoryItemCategoryRequestSchema = z.object({
  bol_getone: z.union([z.boolean(), z.number()]).optional(),
  item_category_id: z.union([z.string(), z.number()]).optional(),
  description: z.string().optional()
}).openapi('InventoryItemCategoryRequest');

export const PostInventoryItemCategoryRequestSchema = z.object({
  process_type: z.union([z.string(), z.number()]),
  description: z.string().optional(),
  glsl_id: z.union([z.string(), z.number()]).optional(),
  user_id: z.union([z.string(), z.number()]).optional(),
  item_category_id: z.union([z.string(), z.number()]).optional()
}).openapi('PostInventoryItemCategoryRequest');

export { StandardResponseSchema };
