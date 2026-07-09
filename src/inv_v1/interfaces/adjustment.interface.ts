export interface ItemForAdjustmentRequest {
  template_id: number;
  source_unit_id: number | null;
  destination_unit_id: number | null;
  item_description: string;
}

export interface InventoryItemAdjustmentRequest {
  bol_getone: boolean | number;
  adjustment_id: number;
  date_from: string;
  date_to: string;
}

export interface InventoryItemAdjustmentTemplateRequest {
  bol_getone: boolean | number;
  template_id: number;
  description: string;
}

export interface PostInventoryItemAdjustmentRequest {
  template_id: number;
  source_unit_id: number | null;
  destination_unit_id: number | null;
  item_id: number;
  quantity: number;
  unit_cost: number;
  remarks: string;
  user_id: number;
}

export interface PostInventoryItemAdjustmentTemplateRequest {
  process_type: number;
  description: string;
  require_destination_and_source: boolean | number;
  add_to_quantity: boolean | number;
  user_id: number;
  template_id: number;
}
