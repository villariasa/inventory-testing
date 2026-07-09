import { OpenAPIHono, createRoute } from '@hono/zod-openapi';
import {
  ItemImportListRequestSchema,
  ItemImportsRequestSchema,
  ImportItemsRequestSchema,
  PostItemImportsRequestSchema,
  StandardResponseSchema
} from '../schemas/itemImports.schema.js';
import {
  getItemImportListHandler,
  getItemImportsHandler,
  getImportItemsHandler,
  postItemImportsHandler
} from '../handlers/itemImports.handler.js';

export const itemImportsRoute = new OpenAPIHono();

const getItemImportListRoute = createRoute({
  method: 'post',
  path: '/get-item-import-list',
  tags: ['Item Imports'],
  summary: 'Get item import list (import types)',
  request: {
    body: {
      content: {
        'application/json': {
          schema: ItemImportListRequestSchema,
          example: {}
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.getItemImportList — Item import list retrieved'
    }
  }
});
itemImportsRoute.openapi(getItemImportListRoute, getItemImportListHandler as never);

const getItemImportsRoute = createRoute({
  method: 'post',
  path: '/get-item-imports',
  tags: ['Item Imports'],
  summary: 'Get item import records for an import type',
  request: {
    body: {
      content: {
        'application/json': {
          schema: ItemImportsRequestSchema,
          example: { import_type: 'brand', bol_getone: 0, id: 0, description: '' }
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.getItemImports — Item imports retrieved'
    }
  }
});
itemImportsRoute.openapi(getItemImportsRoute, getItemImportsHandler as never);

const getImportItemsRoute = createRoute({
  method: 'post',
  path: '/get-import-items',
  tags: ['Item Imports'],
  summary: 'Get importable items for a unit',
  request: {
    body: {
      content: {
        'application/json': {
          schema: ImportItemsRequestSchema,
          example: { unit_id: 1, item_description: '' }
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.getImportItems — Import items retrieved'
    }
  }
});
itemImportsRoute.openapi(getImportItemsRoute, getImportItemsHandler as never);

const postItemImportsRoute = createRoute({
  method: 'post',
  path: '/post-item-imports',
  tags: ['Item Imports'],
  summary: 'Save / update / delete an item import record',
  request: {
    body: {
      content: {
        'application/json': {
          schema: PostItemImportsRequestSchema,
          example: { process_type: 0, import_type: 'brand', description: 'Sample', user_id: 1, id: 0 }
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.postItemImports — Item import processed'
    }
  }
});
itemImportsRoute.openapi(postItemImportsRoute, postItemImportsHandler as never);
