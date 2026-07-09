import { OpenAPIHono, createRoute } from '@hono/zod-openapi';
import {
  EmployeeNameRequestSchema,
  NotificationRequestSchema,
  StandardResponseSchema
} from '../schemas/crossMisc.schema.js';
import {
  getEmployeeNameHandler,
  getNotificationHandler
} from '../handlers/crossMisc.handler.js';

export const crossMiscRoute = new OpenAPIHono();

const getEmployeeNameRoute = createRoute({
  method: 'post',
  path: '/get-employee-name',
  tags: ['Cross/Misc'],
  summary: 'Get employee name(s)',
  request: {
    body: {
      content: {
        'application/json': {
          schema: EmployeeNameRequestSchema,
          example: { bol_getone: 0, employee_id: 0, employee_name: '' }
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.getEmployeeName — Employee name(s) retrieved'
    }
  }
});
crossMiscRoute.openapi(getEmployeeNameRoute, getEmployeeNameHandler as never);

const getNotificationRoute = createRoute({
  method: 'post',
  path: '/get-notification',
  tags: ['Cross/Misc'],
  summary: 'Get notifications',
  request: {
    body: {
      content: {
        'application/json': {
          schema: NotificationRequestSchema,
          example: {}
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.getNotification — Notifications retrieved'
    }
  }
});
crossMiscRoute.openapi(getNotificationRoute, getNotificationHandler as never);
