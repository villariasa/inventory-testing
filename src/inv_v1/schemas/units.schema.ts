import { z } from '@hono/zod-openapi';

export { StandardResponseSchema } from './common.schema.js';

export const InventoryUnitRequestSchema = z.object({
  bol_getone: z.union([z.boolean(), z.number()]),
  unit_id: z.number(),
  description: z.string()
}).openapi('InventoryUnitRequest');

export const UnitRequestSchema = z.object({
  unit_id: z.number().optional()
}).openapi('UnitRequest');

export const PostInventoryUnitRequestSchema = z.object({
  unit_id: z.number(),
  bol_warehouse: z.union([z.boolean(), z.number()]),
  bol_employee: z.union([z.boolean(), z.number()]),
  person_in_charge: z.number(),
  person_name: z.string()
}).openapi('PostInventoryUnitRequest');

export const PostUpdateInventoryUnitRequestSchema = z.object({}).openapi('PostUpdateInventoryUnitRequest');

