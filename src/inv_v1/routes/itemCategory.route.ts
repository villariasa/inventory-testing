import { OpenAPIHono, createRoute } from '@hono/zod-openapi';
import {
  InventoryItemCategoryRequestSchema,
  PostInventoryItemCategoryRequestSchema,
  StandardResponseSchema
} from '../schemas/itemCategory.schema.js';
import {
  getInventoryItemCategoryHandler,
  postInventoryItemCategoryHandler
} from '../handlers/itemCategory.handler.js';

export const itemCategoryRoute = new OpenAPIHono();

const getInventoryItemCategoryRoute = createRoute({
  method: 'post',
  path: '/get-inventory-item-category',
  tags: ['Item Category'],
  summary: 'Get inventory item category(ies)',
  request: {
    body: {
      content: {
        'application/json': {
          schema: InventoryItemCategoryRequestSchema,
          example: { bol_getone: 0, item_category_id: 0, description: '' }
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.getInventoryItemCategory — Inventory item categories retrieved'
    }
  }
});
itemCategoryRoute.openapi(getInventoryItemCategoryRoute, getInventoryItemCategoryHandler as never);

const postInventoryItemCategoryRoute = createRoute({
  method: 'post',
  path: '/post-inventory-item-category',
  tags: ['Item Category'],
  summary: 'Save / update / delete inventory item category',
  request: {
    body: {
      content: {
        'application/json': {
          schema: PostInventoryItemCategoryRequestSchema,
          example: { process_type: 0, description: 'Office Supplies', glsl_id: 1, user_id: 1, item_category_id: 0 }
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.postInventoryItemCategory — Inventory item category processed'
    }
  }
});
itemCategoryRoute.openapi(postInventoryItemCategoryRoute, postInventoryItemCategoryHandler as never);
