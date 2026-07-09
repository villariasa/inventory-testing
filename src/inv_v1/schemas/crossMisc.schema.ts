import { z } from '@hono/zod-openapi';
import { StandardResponseSchema } from './common.schema.js';

export const EmployeeNameRequestSchema = z.object({
  bol_getone: z.union([z.boolean(), z.number()]),
  employee_id: z.number(),
  employee_name: z.string()
}).openapi('EmployeeNameRequest');

export const NotificationRequestSchema = z.object({}).openapi('NotificationRequest');

export { StandardResponseSchema };
