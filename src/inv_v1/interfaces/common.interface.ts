export interface UnitNameRequest {
  unit_id?: string | number;
}

export interface UserUnitRequest {
  user_id: string | number;
  exclude_head_office?: string | number;
}

export interface UserUnitArrayRequest {
  user_id: string | number;
}

export interface UserDesignatedUnitRequest {
  user_id?: string | number;
}

export interface AdjustmentUserUnitRequest {
  user_id: string | number;
}

export interface SelectableAccountsRequest {
  glsl_id?: string | number;
  account_description?: string;
}
