import { createClient } from '@supabase/supabase-js'
import { NextResponse } from 'next/server'

export async function GET() {
  try {
    const url = process.env.NEXT_PUBLIC_SUPABASE_URL
    const anonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
    const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY

    if (!url || !anonKey || !serviceKey) {
      return NextResponse.json(
        {
          status: 'error',
          message: 'Missing Supabase env vars on Vercel',
          hasUrl: !!url,
          hasAnonKey: !!anonKey,
          hasServiceKey: !!serviceKey,
        },
        { status: 500 }
      )
    }

    // Test database connection
    const adminClient = createClient(url, serviceKey, {
      auth: { autoRefreshToken: false, persistSession: false },
    })

    const { count, error: dbErr } = await adminClient
      .from('users')
      .select('*', { count: 'exact', head: true })

    if (dbErr) {
      return NextResponse.json(
        {
          status: 'error',
          message: 'Supabase DB query failed — run the migration SQL',
          detail: dbErr.message,
        },
        { status: 500 }
      )
    }

    // Check admin user exists in users table
    const { data: admin, error: adminErr } = await adminClient
      .from('users')
      .select('id, email, name, user_type')
      .eq('user_type', 'admin')
      .single()

    // Check if admin exists in Supabase Auth
    let authCheck = 'not_checked'
    if (admin) {
      const authClient = createClient(url, anonKey)
      const { data: authUser } = await authClient.auth.admin.listUsers({
        perPage: 1,
      })
      if (authUser?.users) {
        const found = authUser.users.find((u) => u.email === admin.email)
        authCheck = found ? 'exists_in_auth' : 'missing_from_auth'
      }
    }

    return NextResponse.json({
      status: 'ok',
      supabase: 'connected',
      database: {
        userCount: count,
        adminInUsersTable: admin
          ? { id: admin.id, email: admin.email, name: admin.name }
          : null,
        adminInSupabaseAuth: authCheck,
      },
      envVars: { hasUrl: true, hasAnonKey: true, hasServiceKey: true },
      note: admin
        ? 'Login uses Supabase Auth. Make sure the admin email exists in BOTH Supabase Auth AND the users table (user_type=admin).'
        : 'No admin user found in users table. Insert one with user_type=admin, and create the same email in Supabase Auth.',
    })
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e)
    return NextResponse.json({ status: 'error', message: msg }, { status: 500 })
  }
}