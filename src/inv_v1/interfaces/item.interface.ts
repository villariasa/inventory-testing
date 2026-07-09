export interface InventoryItemRequest {
  bol_getone: boolean | number;
  item_category_id: number;
  item_id: number;
  item_description: string;
}

export interface InventoryItemNoUnitRequest {
  unit_id: number;
  item_category_id: number;
  item_description: string;
}

export interface ItemImageRequest {
  item_id: number;
}

export interface EmptyUnitBinRequest {
  bol_getone: boolean | number;
  bin_id: number;
  unit_id: number;
  description: string;
}

export interface PostItemToUnitsUnit {
  unit_id: number;
  bin_id: number;
}

export interface PostInventoryItemRequest {
  process_type: number;
  item_category_id: number;
  brand_id: number | null;
  model_description: string;
  part_id: number | null;
  part_number_id: number | null;
  size_id: number | null;
  valve_id: number | null;
  ratio_id: number | null;
  pattern_id: number | null;
  stocking_unit: string;
  retail_unit: string;
  rtu_over_stu: number;
  wtd_ave_cost: number;
  mark_up_rate: number;
  selling_price: number | null;
  user_id: number;
  has_empty_case: number;
  image: string | null;
  item_id: number;
  barcode?: string | null;
}

export interface ScanInventoryItemRequest {
  barcode: string;
}

export interface PostItemToUnitsRequest {
  item_id: number;
  user_id: number;
  units: PostItemToUnitsUnit[];
}
