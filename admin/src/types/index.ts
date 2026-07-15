export type { Request, RequestStatus, Winga, Client, Review, Transaction, Notification } from '@/lib/data'

export interface PaginationState {
  page: number
  pageSize: number
  total: number
}

export interface DateRange {
  from: Date
  to: Date
}

export interface ChartDataPoint {
  date: string
  [key: string]: string | number
}
