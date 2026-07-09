import { z } from '@hono/zod-openapi';
import { StandardResponseSchema } from './common.schema.js';

export { StandardResponseSchema };

export const ItemImportListRequestSchema = z
  .object({})
  .openapi('ItemImportListRequest');

export const ItemImportsRequestSchema = z
  .object({
    import_type: z.string(),
    bol_getone: z.union([z.boolean(), z.number()]),
    id: z.number(),
    description: z.string()
  })
  .openapi('ItemImportsRequest');

export const ImportItemsRequestSchema = z
  .object({
    unit_id: z.number(),
    item_description: z.string()
  })
  .openapi('ImportItemsRequest');

export const PostItemImportsRequestSchema = z
  .object({
    process_type: z.number(),
    import_type: z.string(),
    description: z.string(),
    user_id: z.number(),
    id: z.number()
  })
  .openapi('PostItemImportsRequest');
