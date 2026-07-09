export interface InventoryUnitItemRequest {
  bol_getone: boolean | number;
  unit_id: number | null;
  item_category_id: number | null;
  unit_item_id: number;
  item_description: string;
}

export interface UnitItemInfoByBinRequest {
  bin_id: number;
}

export interface SwappedItem {
  unit_item_id: number;
  from_bin_id: number;
  to_bin_id: number;
}

export interface PostUnitItemBinSwitchRequest {
  user_id: number;
  swapped_items: SwappedItem[];
}

export interface PostInventoryUnitItemRequest {
  process_type: number;
  unit_item_id: number;
  item_id: number | null;
  unit_id: number;
  starting_period: string;
  starting_quantity: number;
  quantity_in: number;
  quantity_out: number;
  unit_cost: number;
  last_highest_in_unit_cost: number;
  bin_id: number | null;
  user_id: number;
}

