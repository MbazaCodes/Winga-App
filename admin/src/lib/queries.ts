// Admin panel — Supabase queries
// These replace the mock data when NEXT_PUBLIC_SUPABASE_URL is set

import { supabase } from './supabase'

// ── Dashboard stats ───────────────────────────────────────────────────────
export async function getDashboardStats() {
  const [requests, wingas, clients, transactions] = await Promise.all([
    supabase.from('requests').select('id, status', { count: 'exact' }),
    supabase.from('wingas').select('id, status', { count: 'exact' }),
    supabase.from('users').select('id', { count: 'exact' }).eq('user_type', 'customer'),
    supabase.from('transactions').select('gross_amount, winga_payout, tax, status'),
  ])

  const allRequests = requests.data || []
  const totalEarnings = (transactions.data || [])
    .filter(t => t.status === 'success')
    .reduce((s: number, t: { winga_payout: number }) => s + t.winga_payout, 0)

  return {
    totalRequests:      allRequests.length,
    completedRequests:  allRequests.filter(r => r.status === 'completed').length,
    inProgress:         allRequests.filter(r => r.status === 'accepted' || r.status === 'shopping').length,
    cancelled:          allRequests.filter(r => r.status === 'cancelled').length,
    activeWingas:       (wingas.data || []).filter(w => w.status === 'active').length,
    totalEarnings,
    totalClients:       clients.count || 0,
  }
}

// ── Requests list ─────────────────────────────────────────────────────────
export async function getRequests(status?: string) {
  let query = supabase
    .from('requests')
    .select(`
      id, category, meeting_point, service_type, estimated_price, final_price,
      status, created_at,
      customer:users!customer_id(name, phone),
      winga:wingas!winga_id(name, winga_id)
    `)
    .order('created_at', { ascending: false })
    .limit(100)

  if (status && status !== 'All') {
    query = query.eq('status', status.toLowerCase().replace(' ', '_'))
  }

  const { data, error } = await query
  if (error) throw error
  return data
}

// ── Wingas list with verification info ───────────────────────────────────
export async function getWingas(status?: string) {
  let query = supabase
    .from('wingas')
    .select(`
      id, winga_id, name, phone, email, specialty, home_location,
      rating, total_trips, completion_rate, total_earnings,
      verification_status, verification_tier, badge, badge_expires_at,
      subscription_active, next_payment_due, status, is_online,
      created_at
    `)
    .order('created_at', { ascending: false })

  if (status && status !== 'All') {
    query = query.eq('status', status)
  }

  const { data, error } = await query
  if (error) throw error
  return data
}

// ── Clients list ──────────────────────────────────────────────────────────
export async function getClients() {
  const { data, error } = await supabase
    .from('users')
    .select('id, name, phone, email, is_verified, created_at')
    .eq('user_type', 'customer')
    .order('created_at', { ascending: false })

  if (error) throw error
  return data
}

// ── Transactions ──────────────────────────────────────────────────────────
export async function getTransactions() {
  const { data, error } = await supabase
    .from('transactions')
    .select(`
      id, gross_amount, platform_fee, winga_payout, tax,
      payment_method, provider_ref, status, created_at,
      request:requests!request_id(category),
      winga:wingas!winga_id(name),
      customer:users!customer_id(name)
    `)
    .order('created_at', { ascending: false })
    .limit(100)

  if (error) throw error
  return data
}

// ── Pending verifications ─────────────────────────────────────────────────
export async function getPendingVerifications() {
  const { data, error } = await supabase
    .from('wingas')
    .select('id, winga_id, name, phone, specialty, verification_status, verification_tier, created_at')
    .in('verification_status', ['documents_submitted', 'payment_pending', 'under_review'])
    .order('created_at', { ascending: true })

  if (error) throw error
  return data
}

// ── Admin actions ─────────────────────────────────────────────────────────
export async function verifyWinga(wingaId: string, tier: string, notes?: string) {
  const { data, error } = await supabase.rpc('admin_verify_winga', {
    p_winga_id: wingaId,
    p_tier: tier,
    p_notes: notes || null,
  })
  if (error) throw error
  return data
}

export async function rejectWinga(wingaId: string, reason: string) {
  const { data, error } = await supabase.rpc('admin_reject_winga', {
    p_winga_id: wingaId,
    p_reason: reason,
  })
  if (error) throw error
  return data
}

export async function assignBadge(wingaId: string, badge: string) {
  const { data, error } = await supabase.rpc('admin_assign_badge', {
    p_winga_id: wingaId,
    p_badge: badge,
  })
  if (error) throw error
  return data
}

// ── Notifications ─────────────────────────────────────────────────────────
export async function getAdminNotifications() {
  const { data: adminUser } = await supabase
    .from('users')
    .select('id')
    .eq('user_type', 'admin')
    .single()

  if (!adminUser) return []

  const { data, error } = await supabase
    .from('notifications')
    .select('*')
    .eq('user_id', adminUser.id)
    .order('created_at', { ascending: false })
    .limit(50)

  if (error) throw error
  return data || []
}

export async function markNotificationRead(id: string) {
  await supabase.from('notifications').update({ is_read: true }).eq('id', id)
}
