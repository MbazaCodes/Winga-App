import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import AppBar from '../components/layout/AppBar'
import BottomNav from '../components/layout/BottomNav'
import { supabase } from '../lib/supabase'
import { Session } from '../lib/session'
import { CATEGORIES, fmt } from '../lib/constants'

// Keys MUST match DB CHECK constraint: 'hourly','half_day','full_day'
const SERVICE_TYPES = [
  { key: 'hourly' as const, label: 'Saa 1', price: 15000 },
  { key: 'half_day' as const, label: 'Nusu Siku', price: 25000 },
  { key: 'full_day' as const, label: 'Siku Nzima', price: 40000 },
]


const DELIVERY_METHODS = [
  { key: 'with_client' as const, label: 'Na Mteja', emoji: '🚶' },
  { key: 'deliver' as const, label: 'Tunawasilisha', emoji: '🛵' },
  { key: 'pickup' as const, label: 'Pickup', emoji: '📍' },
]

const section: React.CSSProperties = {
  background: '#fff',
  borderRadius: 16,
  padding: '16px',
  marginBottom: 16,
  boxShadow: '0 2px 12px rgba(0,0,0,0.06)',
}

const labelStyle: React.CSSProperties = {
  fontFamily: 'Inter',
  fontSize: 13,
  fontWeight: 600,
  color: '#374151',
  marginBottom: 10,
  display: 'block',
}

const inputStyle: React.CSSProperties = {
  width: '100%',
  height: 52,
  borderRadius: 14,
  border: '1px solid #E5E7EB',
  padding: '0 16px',
  fontSize: 14,
  fontFamily: 'Inter',
  color: '#1A1A1A',
  outline: 'none',
  boxSizing: 'border-box',
  background: '#FAFAFA',
}

export default function BookingScreen() {
  const nav = useNavigate()

  const [selectedCategory, setSelectedCategory] = useState('')
  const [meetingPoint, setMeetingPoint] = useState('')
  const [shoppingArea, setShoppingArea] = useState('Kariakoo Market')
  const [selectedServiceType, setSelectedServiceType] = useState<'hourly' | 'half_day' | 'full_day' | ''>('')
  const [selectedDelivery, setSelectedDelivery] = useState<'with_client' | 'deliver' | 'pickup' | ''>('')
  const [note, setNote] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  const price = selectedServiceType ? (SERVICE_TYPES.find(s => s.key === selectedServiceType)?.price ?? 0) : 0

  async function handleSubmit() {
    setError('')

    if (!selectedCategory) return setError('Tafadhali chagua kategoria.')
    if (!meetingPoint.trim()) return setError('Tafadhali weka mahali pa kukutana.')
    if (!shoppingArea.trim()) return setError('Tafadhali weka eneo la manunuzi.')
    if (!selectedServiceType) return setError('Tafadhali chagua aina ya huduma.')
    if (!selectedDelivery) return setError('Tafadhali chagua njia ya upoaji.')

    setLoading(true)
    try {
      // Use the real Supabase auth uid (required for RLS policies)
      const { data: { user } } = await supabase.auth.getUser()
      const authUid = user?.id || Session.uid()
      if (!authUid) {
        setError('Tafadhali ingia tena kwenye akaunti yako.')
        return
      }

      const { error: dbError } = await supabase.from('requests').insert({
        customer_id: authUid,
        category: selectedCategory,
        meeting_point: meetingPoint.trim(),
        shopping_area: shoppingArea.trim(),
        service_type: selectedServiceType,
        delivery_method: selectedDelivery,
        estimated_price: price,
        note: note.trim() || null,
        status: 'searching',
      })
      if (dbError) {
        // Common errors with helpful messages
        if (dbError.message?.includes('permission denied')) {
          setError('Hitilafu ya ruhusa. Tafadhali toka na uingie tena.')
        } else if (dbError.message?.includes('violates foreign key')) {
          setError('Tatizo la akaunti. Tafadhali toka na uingie tena.')
        } else {
          setError(dbError.message || 'Hitilafu imetokea. Jaribu tena.')
        }
        return
      }
      nav('/requests', { state: { justBooked: true } })
    } catch (err: any) {
      setError(err.message || 'Hitilafu imetokea. Jaribu tena.')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="page">
      <AppBar title="Omba Winga" back={true} />

      <div className="scroll" style={{ padding: '16px 20px 100px' }}>
        {/* Category */}
        <div style={section}>
          <label style={labelStyle}>Kategoria</label>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 10 }}>
            {CATEGORIES.map(cat => {
              const active = selectedCategory === cat.sw
              return (
                <button
                  key={cat.sw}
                  onClick={() => setSelectedCategory(active ? '' : cat.sw)}
                  style={{
                    display: 'flex',
                    flexDirection: 'column',
                    alignItems: 'center',
                    gap: 6,
                    padding: '14px 4px 12px',
                    borderRadius: 14,
                    border: active ? 'none' : '1px solid #E5E7EB',
                    background: active ? '#1A5C2A' : '#fff',
                    cursor: 'pointer',
                    transition: 'all 0.15s',
                  }}
                >
                  <span style={{ fontSize: 24 }}>{cat.emoji}</span>
                  <span style={{
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: 500,
                    color: active ? '#fff' : '#374151',
                    textAlign: 'center',
                    lineHeight: 1.3,
                  }}>
                    {cat.sw}
                  </span>
                </button>
              )
            })}
          </div>
        </div>

        {/* Meeting Point */}
        <div style={section}>
          <label style={labelStyle}>Mahali pa Kukutana</label>
          <input
            style={inputStyle}
            placeholder="E.g. Mlimani City, Posta"
            value={meetingPoint}
            onChange={e => setMeetingPoint(e.target.value)}
          />
        </div>

        {/* Shopping Area */}
        <div style={section}>
          <label style={labelStyle}>Eneo la Manunuzi</label>
          <input
            style={inputStyle}
            value={shoppingArea}
            onChange={e => setShoppingArea(e.target.value)}
          />
        </div>

        {/* Service Type */}
        <div style={section}>
          <label style={labelStyle}>Aina ya Huduma</label>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            {SERVICE_TYPES.map(st => {
              const active = selectedServiceType === st.key
              return (
                <button
                  key={st.key}
                  onClick={() => setSelectedServiceType(active ? '' : st.key)}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    padding: '14px 16px',
                    borderRadius: 14,
                    border: active ? 'none' : '1px solid #E5E7EB',
                    background: active ? '#1A5C2A' : '#fff',
                    cursor: 'pointer',
                    transition: 'all 0.15s',
                  }}
                >
                  <span style={{
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: 500,
                    color: active ? '#fff' : '#1A1A1A',
                  }}>
                    {st.label}
                  </span>
                  <span style={{
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: 600,
                    color: active ? 'rgba(255,255,255,0.9)' : '#6B7280',
                  }}>
                    {fmt(st.price)}
                  </span>
                </button>
              )
            })}
          </div>
        </div>

        {/* Delivery Method */}
        <div style={section}>
          <label style={labelStyle}>Njia ya Upoaji</label>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 10 }}>
            {DELIVERY_METHODS.map(dm => {
              const active = selectedDelivery === dm.key
              return (
                <button
                  key={dm.key}
                  onClick={() => setSelectedDelivery(active ? '' : dm.key)}
                  style={{
                    display: 'flex',
                    flexDirection: 'column',
                    alignItems: 'center',
                    gap: 6,
                    padding: '14px 4px 12px',
                    borderRadius: 14,
                    border: active ? 'none' : '1px solid #E5E7EB',
                    background: active ? '#1A5C2A' : '#fff',
                    cursor: 'pointer',
                    transition: 'all 0.15s',
                  }}
                >
                  <span style={{ fontSize: 22 }}>{dm.emoji}</span>
                  <span style={{
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: 500,
                    color: active ? '#fff' : '#374151',
                    textAlign: 'center',
                    lineHeight: 1.3,
                  }}>
                    {dm.label}
                  </span>
                </button>
              )
            })}
          </div>
        </div>

        {/* Note */}
        <div style={section}>
          <label style={labelStyle}>Maoni <span style={{ fontWeight: 400, color: '#9CA3AF' }}>(hiari)</span></label>
          <textarea
            placeholder="Maoni ya ziada..."
            value={note}
            onChange={e => setNote(e.target.value)}
            rows={3}
            style={{
              ...inputStyle,
              height: 'auto',
              minHeight: 80,
              padding: '14px 16px',
              borderRadius: 14,
              resize: 'none',
              lineHeight: 1.5,
            }}
          />
        </div>

        {/* Estimated Price */}
        <div style={{
          background: '#E8F5E9',
          borderRadius: 16,
          padding: '20px 16px',
          marginBottom: 16,
          textAlign: 'center',
        }}>
          <div style={{ fontFamily: 'Inter', fontSize: 12, color: '#6B7280', marginBottom: 4 }}>
            Gharama Inayokadiriwa
          </div>
          <div style={{ fontFamily: 'Inter', fontSize: 28, fontWeight: 700, color: '#1A5C2A' }}>
            {price > 0 ? fmt(price) : '—'}
          </div>
        </div>

        {/* Error */}
        {error && (
          <div style={{
            background: '#FEF2F2',
            border: '1px solid #FECACA',
            borderRadius: 12,
            padding: '12px 16px',
            marginBottom: 16,
            fontFamily: 'Inter',
            fontSize: 13,
            color: '#B91C1C',
          }}>
            {error}
          </div>
        )}

        {/* Submit */}
        <button
          onClick={handleSubmit}
          disabled={loading}
          style={{
            width: '100%',
            height: 54,
            background: loading ? '#9CA3AF' : '#1A5C2A',
            color: '#fff',
            border: 'none',
            borderRadius: 14,
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: 600,
            cursor: loading ? 'not-allowed' : 'pointer',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: 8,
            marginTop: 4,
          }}
        >
          {loading ? (
            <>
              <span style={{
                width: 20,
                height: 20,
                border: '2px solid rgba(255,255,255,0.3)',
                borderTopColor: '#fff',
                borderRadius: '50%',
                display: 'inline-block',
                animation: 'spin 0.6s linear infinite',
              }} />
              Inatuma...
            </>
          ) : (
            'Tuma Ombi'
          )}
        </button>

        {/* Spinner keyframes */}
        <style>{`
          @keyframes spin {
            to { transform: rotate(360deg); }
          }
        `}</style>
      </div>

      <BottomNav />
    </div>
  )
}