import { OpenAPIHono, createRoute } from '@hono/zod-openapi';
import {
  UnitNameRequestSchema,
  UserUnitRequestSchema,
  UserUnitArrayRequestSchema,
  UserDesignatedUnitRequestSchema,
  AdjustmentUserUnitRequestSchema,
  SelectableAccountsRequestSchema,
  StandardResponseSchema
} from '../schemas/common.schema.js';
import {
  getUnitNameHandler,
  getUserUnitHandler,
  getUserUnitArrayHandler,
  getUserDesignatedUnitHandler,
  getAdjustmentUserUnitHandler,
  getSelectableAccountsConcatenatedHandler
} from '../handlers/common.handler.js';

export const commonRoute = new OpenAPIHono();

const unitNameRoute = createRoute({
  method: 'post',
  path: '/get-unit-name',
  tags: ['Common & Dropdowns'],
  summary: 'Get unit name(s) for dropdown',
  request: {
    body: {
      content: { 'application/json': { schema: UnitNameRequestSchema, example: { unit_id: 1 } } },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.getUnitName — Unit name retrieved'
    }
  }
});
commonRoute.openapi(unitNameRoute, getUnitNameHandler as never);

const userUnitRoute = createRoute({
  method: 'post',
  path: '/get-user-unit',
  tags: ['Common & Dropdowns'],
  summary: 'Get unit assignments for a user',
  request: {
    body: {
      content: { 'application/json': { schema: UserUnitRequestSchema, example: { user_id: 1, exclude_head_office: 0 } } },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.getUserUnit — User unit retrieved'
    }
  }
});
commonRoute.openapi(userUnitRoute, getUserUnitHandler as never);

const userUnitArrayRoute = createRoute({
  method: 'post',
  path: '/get-user-unit-array',
  tags: ['Common & Dropdowns'],
  summary: 'Get array of unit assignments for a user',
  request: {
    body: {
      content: { 'application/json': { schema: UserUnitArrayRequestSchema, example: { user_id: 1 } } },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.getUserUnitArray — User unit array retrieved'
    }
  }
});
commonRoute.openapi(userUnitArrayRoute, getUserUnitArrayHandler as never);

const userDesignatedUnitRoute = createRoute({
  method: 'post',
  path: '/get-user-designated-unit',
  tags: ['Common & Dropdowns'],
  summary: 'Get designated unit(s) for a user',
  request: {
    body: {
      content: { 'application/json': { schema: UserDesignatedUnitRequestSchema, example: { user_id: 1 } } },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.getUserDesignatedUnit — User designated unit retrieved'
    }
  }
});
commonRoute.openapi(userDesignatedUnitRoute, getUserDesignatedUnitHandler as never);

const adjustmentUserUnitRoute = createRoute({
  method: 'post',
  path: '/get-adjustment-user-unit',
  tags: ['Common & Dropdowns'],
  summary: 'Get adjustment unit assignments for a user',
  request: {
    body: {
      content: { 'application/json': { schema: AdjustmentUserUnitRequestSchema, example: { user_id: 1 } } },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.getAdjustmentUserUnit — Adjustment user unit retrieved'
    }
  }
});
commonRoute.openapi(adjustmentUserUnitRoute, getAdjustmentUserUnitHandler as never);

const selectableAccountsRoute = createRoute({
  method: 'post',
  path: '/get-selectable-accounts',
  tags: ['Common & Dropdowns'],
  summary: 'Get selectable accounts for dropdown',
  request: {
    body: {
      content: { 'application/json': { schema: SelectableAccountsRequestSchema, example: { glsl_id: 0, account_description: '' } } },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_accounting.getSelectableAccountsConcatenated — Selectable accounts retrieved'
    }
  }
});
commonRoute.openapi(selectableAccountsRoute, getSelectableAccountsConcatenatedHandler as never);
