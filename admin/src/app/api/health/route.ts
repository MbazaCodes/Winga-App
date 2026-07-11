import { createClient } from '@supabase/supabase-js'
import { NextResponse } from 'next/server'

export async function GET() {
  try {
    const url = process.env.NEXT_PUBLIC_SUPABASE_URL
    const key = process.env.SUPABASE_SERVICE_ROLE_KEY

    if (!url || !key) {
      return NextResponse.json({
        status: 'error',
        message: 'Missing Supabase env vars on Vercel',
        hasUrl: !!url,
        hasKey: !!key,
      }, { status: 500 })
    }

    const supabase = createClient(url, key, {
      auth: { autoRefreshToken: false, persistSession: false },
    })

    // Test query
    const { count, error } = await supabase
      .from('users')
      .select('*', { count: 'exact', head: true })

    if (error) {
      return NextResponse.json({
        status: 'error',
        message: 'Supabase query failed — run the migration',
        detail: error.message,
      }, { status: 500 })
    }

    // Check admin user exists
    const { data: admin } = await supabase
      .from('users')
      .select('id, email, name')
      .eq('user_type', 'admin')
      .single()

    // Check credentials exist
    const { data: cred, count: credCount } = await supabase
      .from('user_credentials')
      .select('user_id', { count: 'exact' })

    return NextResponse.json({
      status: 'ok',
      supabase: 'connected',
      userCount: count,
      adminUser: admin ? { email: admin.email, name: admin.name } : null,
      credentialCount: credCount,
    })
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e)
    return NextResponse.json({ status: 'error', message: msg }, { status: 500 })
  }
}