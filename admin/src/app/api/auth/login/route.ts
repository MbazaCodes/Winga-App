import { createClient } from '@supabase/supabase-js'
import { NextResponse } from 'next/server'

export async function POST(request: Request) {
  try {
    // ── 1. Validate env vars ──────────────────────────────────────
    const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
    const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
    const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY

    if (!supabaseUrl || !supabaseAnonKey || !serviceKey) {
      console.error('[login] Missing env vars:', {
        hasUrl: !!supabaseUrl,
        hasAnonKey: !!supabaseAnonKey,
        hasServiceKey: !!serviceKey,
      })
      return NextResponse.json(
        {
          error: 'Server configuration error',
          debug: 'Missing Supabase env vars on Vercel. Set NEXT_PUBLIC_SUPABASE_URL, NEXT_PUBLIC_SUPABASE_ANON_KEY, and SUPABASE_SERVICE_ROLE_KEY in Vercel Dashboard → Settings → Environment Variables.',
        },
        { status: 500 }
      )
    }

    // ── 2. Parse body ─────────────────────────────────────────────
    const body = await request.json()
    const { email, password } = body

    if (!email || !password) {
      return NextResponse.json({ error: 'Email and password are required' }, { status: 400 })
    }

    // ── 3. Authenticate via Supabase Auth ─────────────────────────
    //    Uses the anon key client so Supabase handles password verification
    const authClient = createClient(supabaseUrl, supabaseAnonKey)

    const { data: authData, error: authError } = await authClient.auth.signInWithPassword({
      email,
      password,
    })

    if (authError || !authData.user) {
      console.warn('[login] Supabase Auth rejected:', authError?.message)
      return NextResponse.json({ error: 'Invalid email or password' }, { status: 401 })
    }

    // ── 4. Verify user is an admin in our users table ─────────────
    //    Uses service role to bypass RLS
    const adminClient = createClient(supabaseUrl, serviceKey, {
      auth: { autoRefreshToken: false, persistSession: false },
    })

    const { data: user, error: userErr } = await adminClient
      .from('users')
      .select('id, email, name, user_type')
      .eq('id', authData.user.id)
      .eq('user_type', 'admin')
      .single()

    if (userErr) {
      // PGRST116 = no row returned → user not in our table
      if (userErr.code === 'PGRST116') {
        console.warn('[login] Auth OK but no admin record for:', email)
        return NextResponse.json(
          { error: 'Access denied — your account is not an admin' },
          { status: 403 }
        )
      }
      console.error('[login] DB error checking admin role:', userErr.message)
      return NextResponse.json(
        { error: 'Server error', debug: userErr.message },
        { status: 500 }
      )
    }

    if (!user) {
      console.warn('[login] Auth OK but user_type is not admin:', email)
      return NextResponse.json(
        { error: 'Access denied — admin only' },
        { status: 403 }
      )
    }

    // ── 5. Create session token ───────────────────────────────────
    // Use Node Buffer.from().toString('base64url') — consistent with
    // how middleware decodes it (Buffer.from(cookie, 'base64url'))
    const payload = JSON.stringify({
      uid: user.id,
      email: user.email,
      name: user.name,
      role: 'admin',
      exp: Date.now() + 86400000,  // 24h
    })
    const token = Buffer.from(payload).toString('base64url')

    const response = NextResponse.json({
      success: true,
      user: { id: user.id, email: user.email, name: user.name },
    })
    response.cookies.set('winga_admin_session', token, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'lax',
      maxAge: 86400,
      path: '/',
    })

    console.log('[login] Admin login success:', email)
    return response
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e)
    console.error('[login] Unhandled error:', msg)
    return NextResponse.json({ error: 'Server error', debug: msg }, { status: 500 })
  }
}