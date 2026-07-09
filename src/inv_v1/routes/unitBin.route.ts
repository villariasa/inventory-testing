import { OpenAPIHono, createRoute } from '@hono/zod-openapi';
import {
  InventoryUnitBinRequestSchema,
  UnitBinExceptOneRequestSchema,
  PostInventoryUnitBinRequestSchema,
  StandardResponseSchema
} from '../schemas/unitBin.schema.js';
import {
  getInventoryUnitBinHandler,
  getUnitBinExceptOneHandler,
  postInventoryUnitBinHandler
} from '../handlers/unitBin.handler.js';

export const unitBinRoute = new OpenAPIHono();

const getInventoryUnitBinRoute = createRoute({
  method: 'post',
  path: '/get-inventory-unit-bin',
  tags: ['Unit Bin'],
  summary: 'Get inventory unit bin(s)',
  request: {
    body: {
      content: {
        'application/json': {
          schema: InventoryUnitBinRequestSchema,
          example: { bol_getone: 0, bin_id: 0, unit_id: 1, description: '' }
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.getInventoryUnitBin — Inventory unit bin retrieved'
    }
  }
});
unitBinRoute.openapi(getInventoryUnitBinRoute, getInventoryUnitBinHandler as never);

const getUnitBinExceptOneRoute = createRoute({
  method: 'post',
  path: '/get-unit-bin-except-one',
  tags: ['Unit Bin'],
  summary: 'Get unit bins except a specified one',
  request: {
    body: {
      content: {
        'application/json': {
          schema: UnitBinExceptOneRequestSchema,
          example: { unit_id: 1, description: '', bin_id: 1 }
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.getUnitBinExceptOne — Unit bins retrieved'
    }
  }
});
unitBinRoute.openapi(getUnitBinExceptOneRoute, getUnitBinExceptOneHandler as never);

const postInventoryUnitBinRoute = createRoute({
  method: 'post',
  path: '/post-inventory-unit-bin',
  tags: ['Unit Bin'],
  summary: 'Save / update / delete inventory unit bin',
  request: {
    body: {
      content: {
        'application/json': {
          schema: PostInventoryUnitBinRequestSchema,
          example: { process_type: 0, unit_id: 1, description: 'Bin A', user_id: 1 }
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.postInventoryUnitBin — Unit bin processed'
    }
  }
});
unitBinRoute.openapi(postInventoryUnitBinRoute, postInventoryUnitBinHandler as never);
