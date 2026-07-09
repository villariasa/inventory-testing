import { OpenAPIHono, createRoute } from '@hono/zod-openapi';
import {
  ItemForAdjustmentRequestSchema,
  InventoryItemAdjustmentRequestSchema,
  InventoryItemAdjustmentTemplateRequestSchema,
  PostInventoryItemAdjustmentRequestSchema,
  PostInventoryItemAdjustmentTemplateRequestSchema,
  StandardResponseSchema
} from '../schemas/adjustment.schema.js';
import {
  getItemForAdjustmentHandler,
  getInventoryItemAdjustmentHandler,
  getInventoryItemAdjustmentTemplateHandler,
  postInventoryItemAdjustmentHandler,
  postInventoryItemAdjustmentTemplateHandler
} from '../handlers/adjustment.handler.js';

export const adjustmentRoute = new OpenAPIHono();

const getItemForAdjustmentRoute = createRoute({
  method: 'post',
  path: '/get-item-for-adjustment',
  tags: ['Adjustment'],
  summary: 'Get item(s) eligible for adjustment',
  request: {
    body: {
      content: {
        'application/json': {
          schema: ItemForAdjustmentRequestSchema,
          example: { template_id: 1, source_unit_id: 1, destination_unit_id: 1, item_description: '' }
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.getItemForAdjustment — Items for adjustment retrieved'
    }
  }
});
adjustmentRoute.openapi(getItemForAdjustmentRoute, getItemForAdjustmentHandler as never);

const getInventoryItemAdjustmentRoute = createRoute({
  method: 'post',
  path: '/get-inventory-item-adjustment',
  tags: ['Adjustment'],
  summary: 'Get inventory item adjustment(s)',
  request: {
    body: {
      content: {
        'application/json': {
          schema: InventoryItemAdjustmentRequestSchema,
          example: { bol_getone: 0, adjustment_id: 0, date_from: '', date_to: '' }
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.getInventoryItemAdjustment — Inventory item adjustments retrieved'
    }
  }
});
adjustmentRoute.openapi(getInventoryItemAdjustmentRoute, getInventoryItemAdjustmentHandler as never);

const getInventoryItemAdjustmentTemplateRoute = createRoute({
  method: 'post',
  path: '/get-inventory-item-adjustment-template',
  tags: ['Adjustment'],
  summary: 'Get inventory item adjustment template(s)',
  request: {
    body: {
      content: {
        'application/json': {
          schema: InventoryItemAdjustmentTemplateRequestSchema,
          example: { bol_getone: 0, template_id: 0, description: '' }
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.getInventoryItemAdjustmentTemplate — Adjustment templates retrieved'
    }
  }
});
adjustmentRoute.openapi(getInventoryItemAdjustmentTemplateRoute, getInventoryItemAdjustmentTemplateHandler as never);

const postInventoryItemAdjustmentRoute = createRoute({
  method: 'post',
  path: '/post-inventory-item-adjustment',
  tags: ['Adjustment'],
  summary: 'Apply an inventory item adjustment',
  request: {
    body: {
      content: {
        'application/json': {
          schema: PostInventoryItemAdjustmentRequestSchema,
          example: {
            template_id: 1,
            source_unit_id: 1,
            destination_unit_id: 1,
            item_id: 1,
            quantity: 120.00,
            unit_cost: 100.00,
            remarks: 'Remarks here',
            user_id: 1
          }
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.postInventoryItemAdjustment — Inventory item adjustment processed'
    }
  }
});
adjustmentRoute.openapi(postInventoryItemAdjustmentRoute, postInventoryItemAdjustmentHandler as never);

const postInventoryItemAdjustmentTemplateRoute = createRoute({
  method: 'post',
  path: '/post-inventory-item-adjustment-template',
  tags: ['Adjustment'],
  summary: 'Save / update / delete inventory item adjustment template',
  request: {
    body: {
      content: {
        'application/json': {
          schema: PostInventoryItemAdjustmentTemplateRequestSchema,
          example: {
            process_type: 0,
            description: 'Stock Transfer',
            require_destination_and_source: 1,
            add_to_quantity: 1,
            user_id: 1,
            template_id: 0
          }
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.postInventoryItemAdjustmentTemplate — Adjustment template processed'
    }
  }
});
adjustmentRoute.openapi(postInventoryItemAdjustmentTemplateRoute, postInventoryItemAdjustmentTemplateHandler as never);
