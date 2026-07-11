import { createClient } from '@supabase/supabase-js'
import { NextResponse } from 'next/server'

export async function POST(request: Request) {
  try {
    const { email, password } = await request.json()

    const supabase = createClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.SUPABASE_SERVICE_ROLE_KEY!,
      { auth: { autoRefreshToken: false, persistSession: false } }
    )

    // Check user is admin
    const { data: user } = await supabase
      .from('users')
      .select('id, email, name, user_type')
      .eq('email', email)
      .eq('user_type', 'admin')
      .single()

    if (!user) {
      return NextResponse.json({ error: 'Invalid credentials' }, { status: 401 })
    }

    // Check credentials table
    const { data: cred } = await supabase
      .from('user_credentials')
      .select('password_hash')
      .eq('user_id', user.id)
      .single()

    if (!cred) {
      return NextResponse.json({ error: 'Invalid credentials' }, { status: 401 })
    }

    // Verify SHA-256
    const encoder = new TextEncoder()
    const hashBuffer = await crypto.subtle.digest('SHA-256', encoder.encode(password))
    const hashHex = Array.from(new Uint8Array(hashBuffer)).map(b => b.toString(16).padStart(2, '0')).join('')
    const base64Hash = Buffer.from(password).toString('base64')

    if (cred.password_hash !== hashHex && cred.password_hash !== base64Hash) {
      return NextResponse.json({ error: 'Invalid credentials' }, { status: 401 })
    }

    // Sign session
    const token = Buffer.from(JSON.stringify({
      uid: user.id, email: user.email, role: 'admin',
      exp: Date.now() + 86400000
    })).toString('base64url')

    const response = NextResponse.json({ success: true, user: { id: user.id, email: user.email, name: user.name } })
    response.cookies.set('winga_admin_session', token, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'lax',
      maxAge: 86400,
      path: '/',
    })
    return response
  } catch (e) {
    return NextResponse.json({ error: 'Server error' }, { status: 500 })
  }
}
