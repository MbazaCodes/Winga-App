// ── Stats ──────────────────────────────────────────────────────────────────
export const dashboardStats = {
  totalRequests: { value: 1248, change: 12.5, up: true },
  completedRequests: { value: 956, change: 15.2, up: true },
  inProgress: { value: 198, change: 4.3, up: false },
  cancelled: { value: 94, change: 8.7, up: false },
  activeWingas: { value: 342, change: 10.1, up: true },
  totalEarnings: { value: 328500, change: 10.8, up: true },
  totalClients: { value: 2534, change: 8.3, up: true },
  newWingaSignups: { value: 45, change: 5.6, up: true },
}

export const earningsSummary = {
  today: { value: 18500, change: 8.2, up: true },
  thisWeek: { value: 72000, change: 12.5, up: true },
  thisMonth: { value: 328500, change: 10.3, up: true },
  lastMonth: { value: 298000, change: 6.4, up: false },
}

// ── Chart Data ─────────────────────────────────────────────────────────────
export const requestsOverviewData = [
  { date: 'May 10', completed: 210, inProgress: 95, cancelled: 12 },
  { date: 'May 11', completed: 270, inProgress: 105, cancelled: 8 },
  { date: 'May 12', completed: 305, inProgress: 115, cancelled: 15 },
  { date: 'May 13', completed: 285, inProgress: 100, cancelled: 10 },
  { date: 'May 14', completed: 350, inProgress: 125, cancelled: 18 },
  { date: 'May 15', completed: 320, inProgress: 110, cancelled: 14 },
  { date: 'May 16', completed: 340, inProgress: 120, cancelled: 11 },
]

export const categoryData = [
  { name: 'Grocery Shopping', value: 38, color: '#1A5C2A' },
  { name: 'Electronics', value: 24, color: '#1565C0' },
  { name: 'Pharmacy', value: 16, color: '#F9A825' },
  { name: 'Clothing', value: 12, color: '#6A1B9A' },
  { name: 'Others', value: 10, color: '#9CA3AF' },
]

export const weeklyEarningsData = [
  { day: 'Mon', earnings: 42000, tax: 1260 },
  { day: 'Tue', earnings: 38000, tax: 1140 },
  { day: 'Wed', earnings: 55000, tax: 1650 },
  { day: 'Thu', earnings: 48000, tax: 1440 },
  { day: 'Fri', earnings: 62000, tax: 1860 },
  { day: 'Sat', earnings: 71000, tax: 2130 },
  { day: 'Sun', earnings: 58000, tax: 1740 },
]

export const monthlyTrendsData = [
  { month: 'Jan', requests: 820, wingas: 280, clients: 1800 },
  { month: 'Feb', requests: 930, wingas: 295, clients: 1950 },
  { month: 'Mar', requests: 1050, wingas: 310, clients: 2100 },
  { month: 'Apr', requests: 1120, wingas: 325, clients: 2250 },
  { month: 'May', requests: 1248, wingas: 342, clients: 2534 },
]

// ── Requests ───────────────────────────────────────────────────────────────
export type RequestStatus = 'Completed' | 'In Progress' | 'Pending' | 'Cancelled'

export interface Request {
  id: string
  client: string
  clientAvatar?: string
  winga: string
  wingaAvatar?: string
  category: string
  location: string
  amount: number
  status: RequestStatus
  date: string
  time: string
  duration: string
}

export const recentRequests: Request[] = [
  { id: 'WNG-001', client: 'Sarah Kiprotich', winga: 'Ahmed Juma', category: 'Grocery Shopping', location: 'Dar es Salaam', amount: 12000, status: 'Completed', date: 'May 16, 2026', time: '10:30 AM', duration: '2h 15min' },
  { id: 'WNG-002', client: 'John Mwangi', winga: 'Bakari Said', category: 'Electronics Shopping', location: 'Kariakoo, DSM', amount: 15000, status: 'In Progress', date: 'May 16, 2026', time: '09:15 AM', duration: '1h 45min' },
  { id: 'WNG-003', client: 'Amina Hassan', winga: 'Hassan Ally', category: 'Pharmacy Shopping', location: 'Mikocheni, DSM', amount: 10000, status: 'Pending', date: 'May 16, 2026', time: '08:40 AM', duration: '—' },
  { id: 'WNG-004', client: 'David Ochieng', winga: 'Omar Rashid', category: 'Clothing Shopping', location: 'Kinondoni, DSM', amount: 25000, status: 'Cancelled', date: 'May 16, 2026', time: '08:10 AM', duration: '—' },
  { id: 'WNG-005', client: 'Grace Njoroge', winga: 'Juma Abdallah', category: 'Hardware & Tools', location: 'Kariakoo, DSM', amount: 40000, status: 'Completed', date: 'May 15, 2026', time: '03:45 PM', duration: '4h 10min' },
  { id: 'WNG-006', client: 'Peter Kamau', winga: 'Ali Mohamed', category: 'Shoes & Bags', location: 'Mwenge, DSM', amount: 15000, status: 'Completed', date: 'May 15, 2026', time: '02:00 PM', duration: '2h 30min' },
  { id: 'WNG-007', client: 'Fatuma Abdulla', winga: 'Zakia Amani', category: 'Cosmetics & Beauty', location: 'Kariakoo, DSM', amount: 15000, status: 'In Progress', date: 'May 15, 2026', time: '11:20 AM', duration: '1h 05min' },
  { id: 'WNG-008', client: 'James Otieno', winga: 'Ibrahim Musa', category: 'Spare Parts', location: 'Kariakoo, DSM', amount: 25000, status: 'Completed', date: 'May 15, 2026', time: '09:00 AM', duration: '3h 20min' },
  { id: 'WNG-009', client: 'Lilian Wambua', winga: 'Rashid Hamisi', category: 'Furniture', location: 'Mwenge, DSM', amount: 40000, status: 'Cancelled', date: 'May 14, 2026', time: '04:30 PM', duration: '—' },
  { id: 'WNG-010', client: 'Mark Oduya', winga: 'Mwana Baraka', category: 'Stationery', location: 'Kariakoo, DSM', amount: 15000, status: 'Completed', date: 'May 14, 2026', time: '02:15 PM', duration: '1h 50min' },
  { id: 'WNG-011', client: 'Rose Mutua', winga: 'Ahmed Juma', category: 'Grocery Shopping', location: 'Dar es Salaam', amount: 12000, status: 'Completed', date: 'May 14, 2026', time: '10:00 AM', duration: '2h 00min' },
  { id: 'WNG-012', client: 'Tom Njeru', winga: 'Bakari Said', category: 'Electronics Shopping', location: 'Kariakoo, DSM', amount: 15000, status: 'Pending', date: 'May 13, 2026', time: '09:30 AM', duration: '—' },
]

// ── Wingas ─────────────────────────────────────────────────────────────────
export interface Winga {
  id: string
  wingaId: string
  name: string
  phone: string
  email: string
  location: string
  specialty: string
  rating: number
  trips: number
  completionRate: number
  earnings: number
  status: 'Active' | 'Inactive' | 'Suspended' | 'Pending Verification'
  joinDate: string
  badge: 'Starter' | 'Mid' | 'Verified' | 'none'
  totalPoints: number   // good-service points from customers
  ratedTrips: number    // trips that received a rating
  wingaScore: number    // Wilson lower bound 0..1 — ranking
  isTopRated: boolean
  verified: boolean
}

export const wingas: Winga[] = [
  { id: '1', wingaId: 'WNGA12345', name: 'Ahmed Juma', phone: '+255 712 345 678', email: 'ahmed@gmail.com', location: 'Kariakoo, DSM', specialty: 'Electronics', rating: 4.9, trips: 250, completionRate: 98, earnings: 328500, status: 'Active', joinDate: 'Mar 12, 2024', badge: 'Verified', verified: true, totalPoints: 238, ratedTrips: 244, wingaScore: 0.9474, isTopRated: true },
  { id: '2', wingaId: 'WNGA12346', name: 'Bakari Said', phone: '+255 713 456 789', email: 'bakari@gmail.com', location: 'Mwenge, DSM', specialty: 'Clothing', rating: 4.8, trips: 180, completionRate: 96, earnings: 245000, status: 'Active', joinDate: 'Apr 5, 2024', badge: 'Mid', verified: true, totalPoints: 165, ratedTrips: 178, wingaScore: 0.8791, isTopRated: true },
  { id: '3', wingaId: 'WNGA12347', name: 'Hassan Ally', phone: '+255 714 567 890', email: 'hassan@gmail.com', location: 'Kariakoo, DSM', specialty: 'Hardware', rating: 4.7, trips: 120, completionRate: 94, earnings: 168000, status: 'Active', joinDate: 'May 1, 2024', badge: 'Mid', verified: true, totalPoints: 101, ratedTrips: 115, wingaScore: 0.806, isTopRated: true },
  { id: '4', wingaId: 'WNGA12348', name: 'Fatuma Said', phone: '+255 715 678 901', email: 'fatuma@gmail.com', location: 'Kinondoni, DSM', specialty: 'Cosmetics', rating: 4.9, trips: 90, completionRate: 99, earnings: 128000, status: 'Active', joinDate: 'Jun 10, 2024', badge: 'Starter', verified: true, totalPoints: 44, ratedTrips: 52, wingaScore: 0.7248, isTopRated: false },
  { id: '5', wingaId: 'WNGA12349', name: 'Omar Rashid', phone: '+255 716 789 012', email: 'omar@gmail.com', location: 'Kariakoo, DSM', specialty: 'General', rating: 4.5, trips: 60, completionRate: 90, earnings: 85000, status: 'Inactive', joinDate: 'Jul 15, 2024', badge: 'Starter', verified: true, totalPoints: 7, ratedTrips: 9, wingaScore: 0.4526, isTopRated: false },
  { id: '6', wingaId: 'WNGA12350', name: 'Zakia Amani', phone: '+255 717 890 123', email: 'zakia@gmail.com', location: 'Mwenge, DSM', specialty: 'Grocery', rating: 4.6, trips: 75, completionRate: 92, earnings: 96000, status: 'Active', joinDate: 'Aug 20, 2024', badge: 'Starter', verified: true, totalPoints: 58, ratedTrips: 71, wingaScore: 0.7115, isTopRated: false },
  { id: '7', wingaId: 'WNGA12351', name: 'Ibrahim Musa', phone: '+255 718 901 234', email: 'ibrahim@gmail.com', location: 'Kariakoo, DSM', specialty: 'Spare Parts', rating: 4.8, trips: 140, completionRate: 97, earnings: 195000, status: 'Active', joinDate: 'Feb 28, 2024', badge: 'Mid', verified: true, totalPoints: 12, ratedTrips: 20, wingaScore: 0.3866, isTopRated: false },
  { id: '8', wingaId: 'WNGA12352', name: 'Mwana Baraka', phone: '+255 719 012 345', email: 'mwana@gmail.com', location: 'Kariakoo, DSM', specialty: 'Stationery', rating: 4.4, trips: 45, completionRate: 88, earnings: 62000, status: 'Pending Verification', joinDate: 'Sep 1, 2024', badge: 'Starter', verified: false, totalPoints: 0, ratedTrips: 0, wingaScore: 0.0, isTopRated: false },
]

// ── Clients ────────────────────────────────────────────────────────────────
export interface Client {
  id: string
  name: string
  phone: string
  email: string
  location: string
  totalRequests: number
  completedRequests: number
  totalSpent: number
  status: 'Active' | 'Inactive' | 'Banned'
  joinDate: string
  lastActivity: string
}

export const clients: Client[] = [
  { id: '1', name: 'Sarah Kiprotich', phone: '+255 712 111 222', email: 'sarah@gmail.com', location: 'Dar es Salaam', totalRequests: 24, completedRequests: 22, totalSpent: 312000, status: 'Active', joinDate: 'Feb 10, 2024', lastActivity: 'May 16, 2026' },
  { id: '2', name: 'John Mwangi', phone: '+255 713 222 333', email: 'john@gmail.com', location: 'Kariakoo, DSM', totalRequests: 18, completedRequests: 16, totalSpent: 245000, status: 'Active', joinDate: 'Mar 5, 2024', lastActivity: 'May 16, 2026' },
  { id: '3', name: 'Amina Hassan', phone: '+255 714 333 444', email: 'amina@gmail.com', location: 'Mikocheni, DSM', totalRequests: 12, completedRequests: 10, totalSpent: 148000, status: 'Active', joinDate: 'Apr 20, 2024', lastActivity: 'May 16, 2026' },
  { id: '4', name: 'David Ochieng', phone: '+255 715 444 555', email: 'david@gmail.com', location: 'Kinondoni, DSM', totalRequests: 8, completedRequests: 5, totalSpent: 92000, status: 'Inactive', joinDate: 'May 15, 2024', lastActivity: 'Apr 30, 2026' },
  { id: '5', name: 'Grace Njoroge', phone: '+255 716 555 666', email: 'grace@gmail.com', location: 'Dar es Salaam', totalRequests: 31, completedRequests: 30, totalSpent: 428000, status: 'Active', joinDate: 'Jan 8, 2024', lastActivity: 'May 15, 2026' },
  { id: '6', name: 'Peter Kamau', phone: '+255 717 666 777', email: 'peter@gmail.com', location: 'Mwenge, DSM', totalRequests: 15, completedRequests: 14, totalSpent: 198000, status: 'Active', joinDate: 'Mar 22, 2024', lastActivity: 'May 15, 2026' },
  { id: '7', name: 'Fatuma Abdulla', phone: '+255 718 777 888', email: 'fatuma2@gmail.com', location: 'Kariakoo, DSM', totalRequests: 6, completedRequests: 4, totalSpent: 72000, status: 'Active', joinDate: 'Jul 1, 2024', lastActivity: 'May 15, 2026' },
  { id: '8', name: 'James Otieno', phone: '+255 719 888 999', email: 'james@gmail.com', location: 'Kariakoo, DSM', totalRequests: 20, completedRequests: 18, totalSpent: 280000, status: 'Banned', joinDate: 'Feb 14, 2024', lastActivity: 'Mar 10, 2026' },
]

// ── Ratings ────────────────────────────────────────────────────────────────
export interface Review {
  id: string
  client: string
  winga: string
  rating: number
  comment: string
  category: string
  date: string
  helpful: number
}

export const reviews: Review[] = [
  { id: '1', client: 'Sarah Kiprotich', winga: 'Ahmed Juma', rating: 5, comment: 'Ahmed was absolutely amazing! He found the best prices and saved me a lot of money. Very knowledgeable about electronics.', category: 'Electronics', date: 'May 16, 2026', helpful: 12 },
  { id: '2', client: 'Grace Njoroge', winga: 'Juma Abdallah', rating: 5, comment: 'Excellent service! Juma knew exactly where to find quality hardware at fair prices. Will definitely use again.', category: 'Hardware', date: 'May 15, 2026', helpful: 8 },
  { id: '3', client: 'Peter Kamau', winga: 'Bakari Said', rating: 4, comment: 'Good experience overall. Bakari was helpful and friendly. Took a bit longer than expected but found great deals.', category: 'Clothing', date: 'May 15, 2026', helpful: 5 },
  { id: '4', client: 'John Mwangi', winga: 'Bakari Said', rating: 5, comment: 'Perfect! Got exactly what I wanted at the best price. Bakari is very professional.', category: 'Electronics', date: 'May 16, 2026', helpful: 15 },
  { id: '5', client: 'Rose Mutua', winga: 'Ahmed Juma', rating: 4, comment: 'Very helpful Winga. Made my grocery shopping much easier. A few shops were closed but he adapted well.', category: 'Grocery', date: 'May 14, 2026', helpful: 3 },
]

// ── Transactions ───────────────────────────────────────────────────────────
export interface Transaction {
  id: string
  requestId: string
  client: string
  winga: string
  amount: number
  platformFee: number
  wingaPayout: number
  tax: number
  method: string
  status: 'Success' | 'Pending' | 'Failed' | 'Refunded'
  date: string
}

export const transactions: Transaction[] = [
  { id: 'TXN-001', requestId: 'WNG-001', client: 'Sarah Kiprotich', winga: 'Ahmed Juma', amount: 12000, platformFee: 2400, wingaPayout: 9240, tax: 360, method: 'M-Pesa', status: 'Success', date: 'May 16, 2026' },
  { id: 'TXN-002', requestId: 'WNG-005', client: 'Grace Njoroge', winga: 'Juma Abdallah', amount: 40000, platformFee: 8000, wingaPayout: 30800, tax: 1200, method: 'Airtel Money', status: 'Success', date: 'May 15, 2026' },
  { id: 'TXN-003', requestId: 'WNG-006', client: 'Peter Kamau', winga: 'Ali Mohamed', amount: 15000, platformFee: 3000, wingaPayout: 11550, tax: 450, method: 'Winga Wallet', status: 'Success', date: 'May 15, 2026' },
  { id: 'TXN-004', requestId: 'WNG-008', client: 'James Otieno', winga: 'Ibrahim Musa', amount: 25000, platformFee: 5000, wingaPayout: 19250, tax: 750, method: 'Tigo Pesa', status: 'Refunded', date: 'May 15, 2026' },
  { id: 'TXN-005', requestId: 'WNG-010', client: 'Mark Oduya', winga: 'Mwana Baraka', amount: 15000, platformFee: 3000, wingaPayout: 11550, tax: 450, method: 'M-Pesa', status: 'Success', date: 'May 14, 2026' },
  { id: 'TXN-006', requestId: 'WNG-011', client: 'Rose Mutua', winga: 'Ahmed Juma', amount: 12000, platformFee: 2400, wingaPayout: 9240, tax: 360, method: 'Winga Wallet', status: 'Success', date: 'May 14, 2026' },
  { id: 'TXN-007', requestId: 'WNG-003', client: 'Amina Hassan', winga: 'Hassan Ally', amount: 10000, platformFee: 2000, wingaPayout: 7700, tax: 300, method: 'HaloPesa', status: 'Pending', date: 'May 16, 2026' },
  { id: 'TXN-008', requestId: 'WNG-004', client: 'David Ochieng', winga: 'Omar Rashid', amount: 25000, platformFee: 5000, wingaPayout: 0, tax: 0, method: 'Card', status: 'Failed', date: 'May 16, 2026' },
]

// ── Notifications ──────────────────────────────────────────────────────────
export interface Notification {
  id: string
  title: string
  message: string
  type: 'info' | 'success' | 'warning' | 'error'
  time: string
  read: boolean
}

export const notifications: Notification[] = [
  { id: '1', title: 'New Winga Registration', message: 'Mwana Baraka has submitted verification documents.', type: 'info', time: '2 min ago', read: false },
  { id: '2', title: 'Payment Failed', message: 'Transaction TXN-008 failed for David Ochieng.', type: 'error', time: '15 min ago', read: false },
  { id: '3', title: 'High Demand Alert', message: 'Electronics category requests up 40% today.', type: 'warning', time: '1 hour ago', read: false },
  { id: '4', title: 'Milestone Reached', message: '1,200+ requests completed this month!', type: 'success', time: '3 hours ago', read: true },
  { id: '5', title: 'Winga Verification', message: 'Ibrahim Musa completed background check.', type: 'success', time: '5 hours ago', read: true },
]

export const formatTZS = (n: number) =>
  'TZS ' + n.toLocaleString('en-US')
