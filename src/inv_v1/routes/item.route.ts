import { OpenAPIHono, createRoute } from '@hono/zod-openapi';
import {
  InventoryItemRequestSchema,
  InventoryItemNoUnitRequestSchema,
  ItemImageRequestSchema,
  EmptyUnitBinRequestSchema,
  PostInventoryItemRequestSchema,
  PostItemToUnitsRequestSchema,
  ScanInventoryItemRequestSchema,
  StandardResponseSchema
} from '../schemas/item.schema.js';
import {
  getInventoryItemHandler,
  getInventoryItemNoUnitHandler,
  getItemImageHandler,
  getEmptyUnitBinHandler,
  postInventoryItemHandler,
  postItemToUnitsHandler,
  scanInventoryItemHandler
} from '../handlers/item.handler.js';

export const itemRoute = new OpenAPIHono();

const getInventoryItemRoute = createRoute({
  method: 'post',
  path: '/get-inventory-item',
  tags: ['Item'],
  summary: 'Get inventory item(s)',
  request: {
    body: {
      content: {
        'application/json': {
          schema: InventoryItemRequestSchema,
          example: { bol_getone: 0, item_category_id: 0, item_id: 0, item_description: '' }
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.getInventoryItem — Inventory items retrieved'
    }
  }
});
itemRoute.openapi(getInventoryItemRoute, getInventoryItemHandler as never);

const getInventoryItemNoUnitRoute = createRoute({
  method: 'post',
  path: '/get-inventory-item-no-unit',
  tags: ['Item'],
  summary: 'Get inventory items not assigned to a unit',
  request: {
    body: {
      content: {
        'application/json': {
          schema: InventoryItemNoUnitRequestSchema,
          example: { unit_id: 1, item_category_id: 1, item_description: '' }
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.getInventoryItemNoUnit — Inventory items (no unit) retrieved'
    }
  }
});
itemRoute.openapi(getInventoryItemNoUnitRoute, getInventoryItemNoUnitHandler as never);

const getItemImageRoute = createRoute({
  method: 'post',
  path: '/get-item-image',
  tags: ['Item'],
  summary: 'Get item image',
  request: {
    body: {
      content: {
        'application/json': {
          schema: ItemImageRequestSchema,
          example: { item_id: 1 }
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.getItemImage — Item image retrieved'
    }
  }
});
itemRoute.openapi(getItemImageRoute, getItemImageHandler as never);

const getEmptyUnitBinRoute = createRoute({
  method: 'post',
  path: '/get-empty-unit-bin',
  tags: ['Item'],
  summary: 'Get empty unit bin(s)',
  request: {
    body: {
      content: {
        'application/json': {
          schema: EmptyUnitBinRequestSchema,
          example: { bol_getone: 0, bin_id: 0, unit_id: 1, description: '' }
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.getEmptyUnitBin — Empty unit bins retrieved'
    }
  }
});
itemRoute.openapi(getEmptyUnitBinRoute, getEmptyUnitBinHandler as never);

const postInventoryItemRoute = createRoute({
  method: 'post',
  path: '/post-inventory-item',
  tags: ['Item'],
  summary: 'Save / update / delete inventory item',
  request: {
    body: {
      content: {
        'application/json': {
          schema: PostInventoryItemRequestSchema,
          example: {
            process_type: 0,
            item_category_id: 1,
            brand_id: 1,
            model_description: 'Model X',
            part_id: null,
            part_number_id: null,
            size_id: null,
            valve_id: null,
            ratio_id: null,
            pattern_id: null,
            stocking_unit: 'BOX',
            retail_unit: 'PC',
            rtu_over_stu: 12,
            wtd_ave_cost: 100,
            mark_up_rate: 0.2,
            selling_price: 120,
            user_id: 1,
            has_empty_case: 0,
            image: null,
            item_id: 0
          }
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.postInventoryItem — Inventory item processed'
    }
  }
});
itemRoute.openapi(postInventoryItemRoute, postInventoryItemHandler as never);

const postItemToUnitsRoute = createRoute({
  method: 'post',
  path: '/post-item-to-units',
  tags: ['Item'],
  summary: 'Add an item to one or more units',
  request: {
    body: {
      content: {
        'application/json': {
          schema: PostItemToUnitsRequestSchema,
          example: { item_id: 1, user_id: 1, units: [{ unit_id: 1, bin_id: 1 }] }
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.postItemToUnits — Item added to unit(s)'
    }
  }
});
itemRoute.openapi(postItemToUnitsRoute, postItemToUnitsHandler as never);

const scanInventoryItemRoute = createRoute({
  method: 'post',
  path: '/scan',
  tags: ['Item'],
  summary: 'Scan / lookup inventory item by barcode',
  request: {
    body: {
      content: {
        'application/json': {
          schema: ScanInventoryItemRequestSchema,
          example: { barcode: 'INV-000001' }
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.getInventoryItem — Inventory items retrieved by barcode'
    }
  }
});
itemRoute.openapi(scanInventoryItemRoute, scanInventoryItemHandler as never);
