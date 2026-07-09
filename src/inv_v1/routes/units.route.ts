import { OpenAPIHono, createRoute } from '@hono/zod-openapi';
import {
  InventoryUnitRequestSchema,
  UnitRequestSchema,
  PostInventoryUnitRequestSchema,
  PostUpdateInventoryUnitRequestSchema,
  StandardResponseSchema
} from '../schemas/units.schema.js';
import {
  getInventoryUnitHandler,
  getUnitHandler,
  postInventoryUnitHandler,
  postUpdateInventoryUnitHandler
} from '../handlers/units.handler.js';

export const unitsRoute = new OpenAPIHono();

const getInventoryUnitRoute = createRoute({
  method: 'post',
  path: '/get-inventory-unit',
  tags: ['Unit'],
  summary: 'Get inventory unit(s)',
  request: {
    body: {
      content: {
        'application/json': {
          schema: InventoryUnitRequestSchema,
          example: { bol_getone: 0, unit_id: 0, description: '' }
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.getInventoryUnit — Inventory units retrieved'
    }
  }
});
unitsRoute.openapi(getInventoryUnitRoute, getInventoryUnitHandler as never);

const getUnitRoute = createRoute({
  method: 'post',
  path: '/get-unit',
  tags: ['Unit'],
  summary: 'Get unit(s)',
  request: {
    body: {
      content: {
        'application/json': {
          schema: UnitRequestSchema,
          example: { unit_id: 1 }
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.getUnit — Units retrieved'
    }
  }
});
unitsRoute.openapi(getUnitRoute, getUnitHandler as never);

const postInventoryUnitRoute = createRoute({
  method: 'post',
  path: '/post-inventory-unit',
  tags: ['Unit'],
  summary: 'Update inventory unit',
  request: {
    body: {
      content: {
        'application/json': {
          schema: PostInventoryUnitRequestSchema,
          example: { unit_id: 1, bol_warehouse: 0, bol_employee: 1, person_in_charge: 1, person_name: '' }
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.postInventoryUnit — Inventory unit processed'
    }
  }
});
unitsRoute.openapi(postInventoryUnitRoute, postInventoryUnitHandler as never);

const postUpdateInventoryUnitRoute = createRoute({
  method: 'post',
  path: '/post-update-inventory-unit',
  tags: ['Unit'],
  summary: 'Refresh inventory units',
  request: {
    body: {
      content: {
        'application/json': {
          schema: PostUpdateInventoryUnitRequestSchema,
          example: {}
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.postUpdateInventoryUnit — Inventory units refreshed'
    }
  }
});
unitsRoute.openapi(postUpdateInventoryUnitRoute, postUpdateInventoryUnitHandler as never);
