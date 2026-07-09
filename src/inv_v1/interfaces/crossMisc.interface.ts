export interface EmployeeNameRequest {
  bol_getone: boolean | number;
  employee_id: number;
  employee_name: string;
}

export interface NotificationRequest {
  [key: string]: never;
}
