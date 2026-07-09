export interface InventoryItemCategoryRequest {
  bol_getone: boolean;
  item_category_id: number;
  description: string;
}

export interface PostInventoryItemCategoryRequest {
  process_type: number;
  description: string;
  glsl_id: number;
  user_id: number;
  item_category_id: number;
}
