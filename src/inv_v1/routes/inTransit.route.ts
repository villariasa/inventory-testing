import { OpenAPIHono, createRoute } from '@hono/zod-openapi';
import {
  InstransitReportRequestSchema,
  InTransitReportRequestSchema,
  InTransitItemsInvoicesRequestSchema,
  PostConfirmInTransitItemsRequestSchema,
  StandardResponseSchema
} from '../schemas/inTransit.schema.js';
import {
  getInstransitReportHandler,
  getInTransitReportHandler,
  getInTransitItemsInvoicesHandler,
  postConfirmInTransitItemsHandler
} from '../handlers/inTransit.handler.js';

export const inTransitRoute = new OpenAPIHono();

const getInstransitReportRoute = createRoute({
  method: 'post',
  path: '/get-instransit-report',
  tags: ['In-Transit'],
  summary: 'Get in-transit report',
  request: {
    body: {
      content: {
        'application/json': {
          schema: InstransitReportRequestSchema,
          example: { search: '' }
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.getInstransitReport — In-transit report retrieved'
    }
  }
});
inTransitRoute.openapi(getInstransitReportRoute, getInstransitReportHandler as never);

const getInTransitReportRoute = createRoute({
  method: 'post',
  path: '/get-in-transit-report',
  tags: ['In-Transit'],
  summary: 'Get in-transit report (no input)',
  request: {
    body: {
      content: {
        'application/json': {
          schema: InTransitReportRequestSchema,
          example: {}
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.getInTransitReport — In-transit report retrieved'
    }
  }
});
inTransitRoute.openapi(getInTransitReportRoute, getInTransitReportHandler as never);

const getInTransitItemsInvoicesRoute = createRoute({
  method: 'post',
  path: '/get-in-transit-items-invoices',
  tags: ['In-Transit'],
  summary: 'Get in-transit items invoices',
  request: {
    body: {
      content: {
        'application/json': {
          schema: InTransitItemsInvoicesRequestSchema,
          example: { bol_getone: 0, invoice_id: 0, user_id: 1, invoice_reference: '' }
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.getInTransitItemsInvoices — In-transit items invoices retrieved'
    }
  }
});
inTransitRoute.openapi(getInTransitItemsInvoicesRoute, getInTransitItemsInvoicesHandler as never);

const postConfirmInTransitItemsRoute = createRoute({
  method: 'post',
  path: '/post-confirm-in-transit-items',
  tags: ['In-Transit'],
  summary: 'Confirm in-transit items',
  request: {
    body: {
      content: {
        'application/json': {
          schema: PostConfirmInTransitItemsRequestSchema,
          example: { user_id: 1, invoice_id: 1, in_transit_items: [{ in_transit_id: 1, quanttiy_confirmed: 1 }] }
        }
      },
      required: true
    }
  },
  responses: {
    200: {
      content: { 'application/json': { schema: StandardResponseSchema } },
      description: 'SP: udf_and_views_inventory.postConfirmInTransitItems — In-transit items confirmed'
    }
  }
});
inTransitRoute.openapi(postConfirmInTransitItemsRoute, postConfirmInTransitItemsHandler as never);
