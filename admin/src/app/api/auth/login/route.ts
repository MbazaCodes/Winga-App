import { createClient } from '@supabase/supabase-js'
import { NextResponse } from 'next/server'

export async function POST(request: Request) {
  try {
    // ── 1. Validate env vars ──────────────────────────────────────
    const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
    const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY

    if (!supabaseUrl || !serviceKey) {
      console.error('[login] Missing env vars:', {
        hasUrl: !!supabaseUrl,
        hasKey: !!serviceKey,
      })
      return NextResponse.json(
        { error: 'Server configuration error — contact admin', debug: 'Missing Supabase environment variables on Vercel. Go to Vercel Dashboard → Settings → Environment Variables and add NEXT_PUBLIC_SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY.' },
        { status: 500 }
      )
    }

    // ── 2. Parse body ─────────────────────────────────────────────
    const body = await request.json()
    const { email, password } = body

    if (!email || !password) {
      return NextResponse.json({ error: 'Email and password are required' }, { status: 400 })
    }

    // ── 3. Init Supabase ──────────────────────────────────────────
    const supabase = createClient(supabaseUrl, serviceKey, {
      auth: { autoRefreshToken: false, persistSession: false },
    })

    // ── 4. Look up admin user ─────────────────────────────────────
    const { data: user, error: userErr } = await supabase
      .from('users')
      .select('id, email, name, user_type')
      .eq('email', email)
      .eq('user_type', 'admin')
      .single()

    if (userErr) {
      console.error('[login] Supabase error fetching user:', userErr.message)
      return NextResponse.json(
        { error: 'Server error — check database setup', debug: userErr.message },
        { status: 500 }
      )
    }

    if (!user) {
      console.warn('[login] No admin user found for email:', email)
      return NextResponse.json({ error: 'Invalid credentials' }, { status: 401 })
    }

    // ── 5. Look up password hash ──────────────────────────────────
    const { data: cred, error: credErr } = await supabase
      .from('user_credentials')
      .select('password_hash')
      .eq('user_id', user.id)
      .single()

    if (credErr) {
      console.error('[login] Supabase error fetching credentials:', credErr.message)
      return NextResponse.json(
        { error: 'Server error — check database setup', debug: credErr.message },
        { status: 500 }
      )
    }

    if (!cred) {
      console.warn('[login] No credentials found for user:', user.id)
      return NextResponse.json({ error: 'Invalid credentials' }, { status: 401 })
    }

    // ── 6. Verify SHA-256 password ────────────────────────────────
    const encoder = new TextEncoder()
    const hashBuffer = await crypto.subtle.digest('SHA-256', encoder.encode(password))
    const hashHex = Array.from(new Uint8Array(hashBuffer))
      .map((b) => b.toString(16).padStart(2, '0'))
      .join('')
    const hashBytes = new Uint8Array(hashBuffer)
    let binary = ''
    for (let i = 0; i < hashBytes.length; i++) binary += String.fromCharCode(hashBytes[i])
    const hashBase64 = btoa(binary)

    if (cred.password_hash !== hashHex && cred.password_hash !== hashBase64) {
      console.warn('[login] Password hash mismatch for:', email)
      return NextResponse.json({ error: 'Invalid credentials' }, { status: 401 })
    }

    // ── 7. Create session token ───────────────────────────────────
    const payload = JSON.stringify({
      uid: user.id,
      email: user.email,
      role: 'admin',
      exp: Date.now() + 86400000,
    })
    const token = btoa(payload)
      .replace(/\+/g, '-')
      .replace(/\//g, '_')
      .replace(/=+$/, '')

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

    console.log('[login] Success for:', email)
    return response
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e)
    console.error('[login] Unhandled error:', msg)
    return NextResponse.json({ error: 'Server error', debug: msg }, { status: 500 })
  }
}