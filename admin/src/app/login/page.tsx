'use client'
import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { Eye, EyeOff, Lock, Mail, MapPin } from 'lucide-react'

export default function LoginPage() {
  const router = useRouter()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [showPw, setShowPw] = useState(false)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError('')

    try {
      const res = await fetch('/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password }),
      })
      const data = await res.json()

      if (!res.ok) {
        setError(data.error || 'Invalid email or password')
        setLoading(false)
        return
      }

      router.push('/')
      router.refresh()
    } catch {
      setError('Connection error. Try again.')
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen bg-[#F8F9FA] flex items-center justify-center p-4">
      <div className="w-full max-w-md">
        <div className="text-center mb-8">
          <div className="w-16 h-16 bg-[#1A5C2A] rounded-2xl flex items-center justify-center mx-auto mb-4 shadow-lg">
            <MapPin className="w-8 h-8 text-[#F9A825]" />
          </div>
          <h1 className="text-2xl font-bold text-gray-900">Winga Admin</h1>
          <p className="text-gray-500 text-sm mt-1">Sign in to your admin panel</p>
        </div>

        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-8">
          <form onSubmit={handleLogin} className="space-y-5">
            {error && (
              <div className="bg-red-50 border border-red-100 text-red-600 text-sm px-4 py-3 rounded-xl">
                {error}
              </div>
            )}
            <div>
              <label className="text-sm font-semibold text-gray-700 block mb-2">Email</label>
              <div className="relative">
                <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                <input type="email" value={email} onChange={e => setEmail(e.target.value)}
                  placeholder="admin@winga.co.tz" required
                  className="w-full pl-10 pr-4 py-3 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#1A5C2A]/20 focus:border-[#1A5C2A]/40" />
              </div>
            </div>
            <div>
              <label className="text-sm font-semibold text-gray-700 block mb-2">Password</label>
              <div className="relative">
                <Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                <input type={showPw ? 'text' : 'password'} value={password} onChange={e => setPassword(e.target.value)}
                  placeholder="Enter your password" required
                  className="w-full pl-10 pr-12 py-3 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#1A5C2A]/20 focus:border-[#1A5C2A]/40" />
                <button type="button" onClick={() => setShowPw(!showPw)}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600">
                  {showPw ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                </button>
              </div>
            </div>
            <button type="submit" disabled={loading}
              className="w-full bg-[#1A5C2A] text-white py-3 rounded-xl font-semibold text-sm hover:bg-[#0F3D1A] transition-colors disabled:opacity-50 flex items-center justify-center gap-2">
              {loading && <span className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />}
              {loading ? 'Signing in...' : 'Sign In'}
            </button>
          </form>
          <p className="text-center text-xs text-gray-400 mt-6">Winga Admin Panel v1.0 · Secured Access Only</p>
        </div>
      </div>
    </div>
  )
}
