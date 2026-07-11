import { NextResponse } from 'next/server'
import type { NextRequest, NextResponse as NextResponseType } from 'next/server'

const PUBLIC_PATHS = ['/login', '/api/auth', '/api/health', '/mobile', '/_next', '/favicon']
const SESSION_COOKIE = 'winga_admin_session'
const SESSION_DURATION = 86400000   // 24h
const REFRESH_THRESHOLD = 21600000  // refresh if < 6h left

export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl

  if (PUBLIC_PATHS.some(p => pathname.startsWith(p))) {
    return NextResponse.next()
  }

  const cookie = request.cookies.get(SESSION_COOKIE)?.value
  if (!cookie) return redirectToLogin(request)

  let decoded: { uid: string; email: string; name?: string; role: string; exp: number }
  try {
    decoded = JSON.parse(Buffer.from(cookie, 'base64url').toString())
  } catch {
    return redirectToLogin(request)
  }

  if (!decoded.uid || !decoded.role || decoded.role !== 'admin') {
    return redirectToLogin(request)
  }

  if (decoded.exp < Date.now()) {
    return redirectToLogin(request)
  }

  const res = NextResponse.next()

  // Sliding window: refresh token if less than 6h remaining
  if (decoded.exp - Date.now() < REFRESH_THRESHOLD) {
    const refreshed = Buffer.from(JSON.stringify({
      ...decoded,
      exp: Date.now() + SESSION_DURATION,
    })).toString('base64url')

    res.cookies.set(SESSION_COOKIE, refreshed, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'lax',
      maxAge: SESSION_DURATION / 1000,
      path: '/',
    })
  }

  return res
}

function redirectToLogin(request: NextRequest) {
  const url = new URL('/login', request.url)
  url.searchParams.set('from', request.nextUrl.pathname)
  const res = NextResponse.redirect(url)
  res.cookies.delete(SESSION_COOKIE)
  return res
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico|icons|screenshots).*)'],
}
