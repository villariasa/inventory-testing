import { OpenAPIHono, createRoute } from '@hono/zod-openapi';
import {
  InventoryUnitItemRequestSchema,
  UnitItemInfoByBinRequestSchema,
  PostUnitItemBinSwitchRequestSchema,
  PostInventoryUnitItemRequestSchema,
  StandardResponseSchema
} from '../schemas/unitItem.schema.js';
import {
  getInventoryUnitItemHandler,
  getUnitItemInfoByBinHandler,
  postUnitItemBinSwitchHandler,
  postInventoryUnitItemHandler
} from '../handlers/unitItem.handler.js';

export const unitItemRoute = new OpenAPIHono();

const getInventoryUnitItemRoute = createRoute({
  method: 'post',
  path: '/get-inventory-unit-item',
  tags: ['Unit Item'],
  summary: 'Get inventory unit item(s)',
  request: {
    body: {
      content: {
        'application/json': {
          schema: InventoryUnitItemRequestSchema,
          example: { bol_getone: 0, unit_id: 1, item_category_id: 1, unit_item_id: 0, item_description: '' }
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.getInventoryUnitItem — Inventory unit items retrieved'
    }
  }
});
unitItemRoute.openapi(getInventoryUnitItemRoute, getInventoryUnitItemHandler as never);

const getUnitItemInfoByBinRoute = createRoute({
  method: 'post',
  path: '/get-unit-item-info-by-bin',
  tags: ['Unit Item'],
  summary: 'Get unit item info by bin',
  request: {
    body: {
      content: {
        'application/json': {
          schema: UnitItemInfoByBinRequestSchema,
          example: { bin_id: 1 }
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.getUnitItemInfoByBin — Unit item info retrieved'
    }
  }
});
unitItemRoute.openapi(getUnitItemInfoByBinRoute, getUnitItemInfoByBinHandler as never);

const postUnitItemBinSwitchRoute = createRoute({
  method: 'post',
  path: '/post-unit-item-bin-switch',
  tags: ['Unit Item'],
  summary: 'Switch the bin(s) of unit item(s)',
  request: {
    body: {
      content: {
        'application/json': {
          schema: PostUnitItemBinSwitchRequestSchema,
          example: { user_id: 1, swapped_items: [{ unit_item_id: 1, from_bin_id: 1, to_bin_id: 2 }] }
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.postUnitItemBinSwitch — Unit item bin(s) switched'
    }
  }
});
unitItemRoute.openapi(postUnitItemBinSwitchRoute, postUnitItemBinSwitchHandler as never);

const postInventoryUnitItemRoute = createRoute({
  method: 'post',
  path: '/post-inventory-unit-item',
  tags: ['Unit Item'],
  summary: 'Save, update or delete an inventory unit item relationship',
  request: {
    body: {
      content: {
        'application/json': {
          schema: PostInventoryUnitItemRequestSchema,
          example: {
            process_type: 0,
            unit_item_id: 0,
            item_id: 1,
            unit_id: 1,
            starting_period: '2026-06-01',
            starting_quantity: 10,
            quantity_in: 0,
            quantity_out: 0,
            unit_cost: 100,
            last_highest_in_unit_cost: 100,
            bin_id: 1,
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
      description: 'SP: inventory_udf_and_views.postInventoryUnitItem — Inventory unit item processed'
    }
  }
});
unitItemRoute.openapi(postInventoryUnitItemRoute, postInventoryUnitItemHandler as never);

