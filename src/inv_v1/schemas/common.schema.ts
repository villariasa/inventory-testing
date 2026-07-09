import { z } from '@hono/zod-openapi';

export const UnitNameRequestSchema = z.object({
  unit_id: z.union([z.string(), z.number()]).optional()
}).openapi('UnitNameRequest');

export const UserUnitRequestSchema = z.object({
  user_id: z.union([z.string(), z.number()]),
  exclude_head_office: z.union([z.string(), z.number()]).optional()
}).openapi('UserUnitRequest');

export const UserUnitArrayRequestSchema = z.object({
  user_id: z.union([z.string(), z.number()])
}).openapi('UserUnitArrayRequest');

export const UserDesignatedUnitRequestSchema = z.object({
  user_id: z.union([z.string(), z.number()]).optional()
}).openapi('UserDesignatedUnitRequest');

export const AdjustmentUserUnitRequestSchema = z.object({
  user_id: z.union([z.string(), z.number()])
}).openapi('AdjustmentUserUnitRequest');

export const SelectableAccountsRequestSchema = z.object({
  glsl_id: z.union([z.string(), z.number()]).optional(),
  account_description: z.string().optional()
}).openapi('SelectableAccountsRequest');

export const SpEnvelopeSchema = z.object({
  success: z.union([z.boolean(), z.number()]),
  message: z.string(),
  json_data: z.unknown()
}).openapi('CommonSpEnvelope');

export const StandardResponseSchema = z.object({
  success: z.boolean(),
  http_code: z.number(),
  message: z.string(),
  data: SpEnvelopeSchema
}).openapi('StandardResponse');
