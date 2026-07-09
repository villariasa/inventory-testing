export interface Member {
  member_id: number;
  email: string;
  first_name: string;
  last_name: string;
  phone: string;
  status: 'PENDING' | 'ACTIVE' | 'INACTIVE' | 'SUSPENDED' | 'DELETED';
  avatar_url?: string;
}

export interface Role {
  role_id: number;
  role_name: 'guest' | 'member' | 'instructor' | 'scheduler' | 'admin';
}

export interface User {
  member: Member | null;
  role: Role;
  loggedIn: boolean;
  access_token?: string;
  session_id?: string;
}

export interface SpEnvelope<T> {
  success: boolean | number;
  message: string;
  json_data: T;
}

export interface StandardResponse<T = unknown> {
  success: boolean;
  http_code: number;
  message: string;
  data: SpEnvelope<T>;
}

export interface InventoryItem {
  item_id: number;
  item_category_id: number;
  item_category_description?: string;
  item_category?: string | null;
  brand_id?: number | null;
  brand_description?: string;
  brand?: string | null;
  model_description: string;
  part_id?: number | null;
  part_number_id?: number | null;
  size_id?: number | null;
  valve_id?: number | null;
  ratio_id?: number | null;
  pattern_id?: number | null;
  stocking_unit: string;
  retail_unit: string;
  rtu_over_stu: number;
  wtd_ave_cost: number;
  mark_up_rate: number;
  selling_price: number | null;
  has_empty_case: number;
  is_empty_case?: number | null;
  last_highest_in_unit_cost?: number;
  image?: string | null;
  in_unit_item?: boolean | number;
  created_at?: string;
  barcode?: string | null;
  barcodes?: Array<{ barcode_value: string; barcode_type: string }> | null;
  unit?: string;
  quantity_cap?: number;
}

export interface ItemCategory {
  item_category_id: number;
  item_category_description: string;
  status: 'ACTIVE' | 'INACTIVE';
}

export interface InventoryUnit {
  unit_id: number;
  description: string;
  bol_warehouse: number;
  bol_employee: number;
  person_in_charge: number | null;
  person_name?: string | null;
}

export interface UnitBin {
  bin_id: number;
  unit_id: number;
  description: string;
  status: 'ACTIVE' | 'INACTIVE';
}

export interface UnitItem {
  unit_item_id: number;
  unit_id: number;
  unit_description?: string;
  item_id: number;
  item_description: string;
  item_category_description?: string;
  item_category?: string;
  item_category_id?: number;
  stocking_unit: string;
  retail_unit: string;
  qty_on_hand: number;
  bin_id?: number | null;
  bin_description?: string | null;
  bin?: string | null;
  starting_period?: string | null;
  last_entry?: string | null;
  starting_quantity?: number;
  quantity_in?: number;
  quantity_out?: number;
  ending_quantity?: number;
  starting_cost?: number;
  cost_in?: number;
  cost_out?: number;
  ending_cost?: number;
  unit_cost?: number;
  last_highest_in_unit_cost?: number;
  is_used?: number;
}

export interface UnitItemHistory {
  history_id: number;
  unit_id: number;
  item_id: number;
  transaction_type: string;
  reference_no: string;
  qty_in: number;
  qty_out: number;
  balance_qty: number;
  remarks: string;
  added_by_name: string;
  added_date: string;
}

export interface Adjustment {
  adjustment_id: number;
  template_id: number;
  template_description?: string;
  template?: string;
  source_unit_id?: number | null;
  source_unit_description?: string | null;
  source_unit?: string | null;
  destination_unit_id?: number | null;
  destination_unit_description?: string | null;
  destination_unit?: string | null;
  item_id: number;
  item_description?: string;
  quantity: number | string;
  unit_cost: number | string;
  remarks: string;
  status?: string;
  added_date?: string;
  adjustment_date?: string;
  frmt_adjustment_date?: string;
  added_by?: string;
}


export interface AdjustmentTemplate {
  template_id: number;
  description: string;
  add_to_quantity: number;
  require_destination_and_source: number;
  template_ind: number;
  requires_src_dest?: number;
  add_to_qty?: number;
  status?: string;
}

export interface InTransitReportRow {
  invoice_id: number;
  reference_no: string;
  supplier_name: string;
  item_description: string;
  quantity_sent: number;
  quantity_received: number;
  status: string;
  added_date: string;
}

export interface InTransitInvoice {
  invoice_id: number;
  reference_no: string;
  supplier_id: number;
  supplier_name: string;
  added_date: string;
  status: 'PENDING' | 'CONFIRMED';
}

export interface InTransitItem {
  invoice_detail_id: number;
  invoice_id: number;
  item_id: number;
  item_description: string;
  quantity_ordered: number;
  quantity_received: number;
  quantity_confirmed?: number;
}
