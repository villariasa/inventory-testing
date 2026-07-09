export interface InventoryUnitBinRequest {
  bol_getone: boolean | number;
  bin_id: number;
  unit_id: number;
  description: string;
}

export interface UnitBinExceptOneRequest {
  unit_id: number;
  description: string;
  bin_id: number;
}

export interface PostInventoryUnitBinRequest {
  process_type: number;
  unit_id: number;
  description: string;
  user_id: number;
  bin_id?: number;
}
