import { z } from '@hono/zod-openapi';
import { StandardResponseSchema } from './common.schema.js';

export const InventoryUnitBinRequestSchema = z.object({
  bol_getone: z.union([z.boolean(), z.number()]),
  bin_id: z.number(),
  unit_id: z.number(),
  description: z.string()
}).openapi('InventoryUnitBinRequest');

export const UnitBinExceptOneRequestSchema = z.object({
  unit_id: z.number(),
  description: z.string(),
  bin_id: z.number()
}).openapi('UnitBinExceptOneRequest');

export const PostInventoryUnitBinRequestSchema = z.object({
  process_type: z.number(),
  unit_id: z.number(),
  description: z.string(),
  user_id: z.number(),
  bin_id: z.number().optional()
}).openapi('PostInventoryUnitBinRequest');

export { StandardResponseSchema };
