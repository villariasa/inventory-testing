export interface InventoryUnitRequest {
  bol_getone: boolean | number;
  unit_id: number;
  description: string;
}

export interface UnitRequest {
  unit_id?: number;
}

export interface PostInventoryUnitRequest {
  unit_id: number;
  bol_warehouse: boolean | number;
  bol_employee: boolean | number;
  person_in_charge: number;
  person_name: string;
}

export interface PostUpdateInventoryUnitRequest {}

