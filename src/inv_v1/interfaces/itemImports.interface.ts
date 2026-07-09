export interface ItemImportListRequest {
  [key: string]: never;
}

export interface ItemImportsRequest {
  import_type: string;
  bol_getone: boolean | number;
  id: number;
  description: string;
}

export interface ImportItemsRequest {
  unit_id: number;
  item_description: string;
}

export interface PostItemImportsRequest {
  process_type: number;
  import_type: string;
  description: string;
  user_id: number;
  id: number;
}
