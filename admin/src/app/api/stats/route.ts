import { NextResponse } from 'next/server'
import { getSupabaseAdmin } from '@/lib/supabase-server'

export async function GET() {
  try {
    const supabase = getSupabaseAdmin()
    const { data } = await supabase.rpc('get_dashboard_stats')
    return NextResponse.json(data || {})
  } catch (e) {
    return NextResponse.json({}, { status: 500 })
  }
}
