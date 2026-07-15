import { useState, useEffect, useRef } from 'react'
import { useNavigate } from 'react-router-dom'
import { supabase } from '../lib/supabase'
import BottomNav from '../components/layout/BottomNav'

interface Conversation {
  requestId: string
  wingaName: string
  wingaId: string
  lastMessage: string
  lastTime: string
  unread: number
  status: string
  category: string
}

interface Message {
  id: string
  sender_id: string
  sender_type: string
  type: string
  body: string | null
  photo_url: string | null
  created_at: string
}

const C = {
  primary: '#1A5C2A', gold: '#F9A825', white: '#fff',
  bg: '#F8F9FA', textSec: '#6B7280', border: '#E5E7EB',
  surface: '#E8F5E9', error: '#D32F2F',
}

export default function MessagesScreen() {
  const nav = useNavigate()
  const [view, setView] = useState<'list' | 'chat'>('list')
  const [conversations, setConversations] = useState<Conversation[]>([])
  const [activeConv, setActiveConv] = useState<Conversation | null>(null)
  const [messages, setMessages] = useState<Message[]>([])
  const [text, setText] = useState('')
  const [loading, setLoading] = useState(true)
  const [sending, setSending] = useState(false)
  const [authUid, setAuthUid] = useState('')
  const mounted = useRef(true)
  const scrollRef = useRef<HTMLDivElement>(null)
  const channelRef = useRef<any>(null)

  useEffect(() => {
    mounted.current = true
    init()
    return () => {
      mounted.current = false
      channelRef.current?.unsubscribe()
    }
  }, [])

  async function init() {
    const { data: { user } } = await supabase.auth.getUser()
    const uid = user?.id || ''
    if (!mounted.current) return
    setAuthUid(uid)
    loadConversations(uid)
  }

  async function loadConversations(uid: string) {
    if (!uid) { setLoading(false); return }
    setLoading(true)
    try {
      // Get all requests that have messages
      const { data: reqs } = await supabase
        .from('requests')
        .select('id, category, status, winga:wingas!winga_id(id, name)')
        .eq('customer_id', uid)
        .in('status', ['accepted', 'shopping', 'completed'])
        .order('created_at', { ascending: false })

      if (!reqs || !mounted.current) { setLoading(false); return }

      const convs: Conversation[] = []
      for (const req of reqs) {
        // Get last message for this request
        const { data: msgs } = await supabase
          .from('messages')
          .select('body, created_at, sender_type')
          .eq('request_id', req.id)
          .order('created_at', { ascending: false })
          .limit(1)

        // Count unread
        const { count } = await supabase
          .from('messages')
          .select('id', { count: 'exact', head: true })
          .eq('request_id', req.id)
          .eq('is_read', false)
          .eq('sender_type', 'winga')

        const winga = Array.isArray(req.winga) ? req.winga[0] : req.winga
        if (!winga) continue

        convs.push({
          requestId: req.id,
          wingaId: (winga as any).id,
          wingaName: (winga as any).name || 'Winga',
          lastMessage: msgs?.[0]?.body || 'Gonga ili kuanza mazungumzo',
          lastTime: msgs?.[0]?.created_at || req.id,
          unread: count || 0,
          status: req.status,
          category: req.category,
        })
      }

      if (mounted.current) {
        setConversations(convs)
        setLoading(false)
      }
    } catch {
      if (mounted.current) setLoading(false)
    }
  }

  async function openChat(conv: Conversation) {
    setActiveConv(conv)
    setView('chat')
    loadMessages(conv.requestId)

    // Mark messages as read
    await supabase
      .from('messages')
      .update({ is_read: true })
      .eq('request_id', conv.requestId)
      .eq('sender_type', 'winga')

    // Subscribe to realtime
    channelRef.current?.unsubscribe()
    channelRef.current = supabase
      .channel(`messages-${conv.requestId}`)
      .on('postgres_changes', {
        event: 'INSERT', schema: 'public', table: 'messages',
        filter: `request_id=eq.${conv.requestId}`,
      }, (payload) => {
        if (!mounted.current) return
        setMessages(prev => [...prev, payload.new as Message])
        setTimeout(() => scrollRef.current?.scrollTo({ top: 99999, behavior: 'smooth' }), 100)
      })
      .subscribe()
  }

  async function loadMessages(requestId: string) {
    const { data } = await supabase
      .from('messages')
      .select('id, sender_id, sender_type, type, body, photo_url, created_at')
      .eq('request_id', requestId)
      .order('created_at')
    if (mounted.current) {
      setMessages((data as Message[]) || [])
      setTimeout(() => scrollRef.current?.scrollTo({ top: 99999 }), 100)
    }
  }

  async function sendMessage() {
    if (!text.trim() || !activeConv || sending) return
    setSending(true)
    const body = text.trim()
    setText('')
    try {
      await supabase.from('messages').insert({
        request_id: activeConv.requestId,
        sender_id: authUid,
        sender_type: 'customer',
        type: 'text',
        body,
      })
    } catch {}
    setSending(false)
  }

  function timeLabel(iso: string) {
    const d = new Date(iso)
    const now = new Date()
    const diff = now.getTime() - d.getTime()
    if (diff < 86400000) return d.toLocaleTimeString('sw-TZ', { hour: '2-digit', minute: '2-digit' })
    return d.toLocaleDateString('sw-TZ', { day: 'numeric', month: 'short' })
  }

  // ── CHAT VIEW ──────────────────────────────────────────────────────────────
  if (view === 'chat' && activeConv) {
    return (
      <div style={{ height: '100dvh', display: 'flex', flexDirection: 'column', background: '#F0F2F5' }}>
        {/* Header */}
        <div style={{ background: C.primary, paddingTop: 'env(safe-area-inset-top,0px)', flexShrink: 0 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '12px 16px' }}>
            <button onClick={() => { setView('list'); channelRef.current?.unsubscribe(); loadConversations(authUid) }}
              style={{ background: 'none', border: 'none', color: C.white, fontSize: 22, cursor: 'pointer', padding: 0 }}>←</button>
            <div style={{ width: 40, height: 40, borderRadius: 20, background: 'rgba(255,255,255,0.2)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 20 }}>👤</div>
            <div>
              <div style={{ fontFamily: 'Inter', fontSize: 15, fontWeight: 600, color: C.white }}>{activeConv.wingaName}</div>
              <div style={{ fontFamily: 'Inter', fontSize: 11, color: 'rgba(255,255,255,0.75)' }}>{activeConv.category} · {activeConv.status}</div>
            </div>
          </div>
        </div>

        {/* Messages */}
        <div ref={scrollRef} style={{ flex: 1, overflowY: 'auto', padding: '12px 16px', display: 'flex', flexDirection: 'column', gap: 8 }}>
          {messages.length === 0 && (
            <div style={{ textAlign: 'center', padding: '40px 20px' }}>
              <div style={{ fontSize: 40, marginBottom: 12 }}>💬</div>
              <p style={{ fontFamily: 'Inter', fontSize: 14, color: C.textSec }}>Anza mazungumzo na {activeConv.wingaName}</p>
            </div>
          )}
          {messages.map(msg => {
            const isMe = msg.sender_id === authUid || msg.sender_type === 'customer'
            const isSystem = msg.sender_type === 'system'
            if (isSystem) return (
              <div key={msg.id} style={{ textAlign: 'center' }}>
                <span style={{ fontFamily: 'Inter', fontSize: 11, background: 'rgba(0,0,0,0.08)', color: '#374151', padding: '4px 12px', borderRadius: 20 }}>{msg.body}</span>
              </div>
            )
            return (
              <div key={msg.id} style={{ display: 'flex', justifyContent: isMe ? 'flex-end' : 'flex-start' }}>
                <div style={{
                  maxWidth: '72%', padding: '10px 14px', borderRadius: isMe ? '18px 18px 4px 18px' : '18px 18px 18px 4px',
                  background: isMe ? C.primary : C.white,
                  boxShadow: '0 1px 4px rgba(0,0,0,0.08)',
                }}>
                  {msg.photo_url && (
                    <img src={msg.photo_url} alt="" style={{ width: '100%', borderRadius: 10, marginBottom: msg.body ? 6 : 0, display: 'block' }} />
                  )}
                  {msg.body && (
                    <p style={{ fontFamily: 'Inter', fontSize: 14, color: isMe ? C.white : '#1A1A1A', margin: 0, lineHeight: 1.5 }}>{msg.body}</p>
                  )}
                  <p style={{ fontFamily: 'Inter', fontSize: 10, color: isMe ? 'rgba(255,255,255,0.6)' : '#9CA3AF', margin: '4px 0 0', textAlign: 'right' }}>
                    {timeLabel(msg.created_at)}
                  </p>
                </div>
              </div>
            )
          })}
        </div>

        {/* Input */}
        <div style={{ background: C.white, borderTop: `1px solid ${C.border}`, padding: `10px 12px calc(10px + env(safe-area-inset-bottom,0px))`, display: 'flex', gap: 8, alignItems: 'flex-end', flexShrink: 0 }}>
          <div style={{ flex: 1, background: '#F3F4F6', borderRadius: 24, padding: '10px 16px', minHeight: 44, display: 'flex', alignItems: 'center' }}>
            <textarea value={text} onChange={e => setText(e.target.value)}
              onKeyDown={e => { if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); sendMessage() } }}
              placeholder="Andika ujumbe..." rows={1}
              style={{ flex: 1, background: 'none', border: 'none', outline: 'none', fontFamily: 'Inter', fontSize: 14, resize: 'none', maxHeight: 100, lineHeight: 1.5 }} />
          </div>
          <button onClick={sendMessage} disabled={!text.trim() || sending}
            style={{ width: 44, height: 44, borderRadius: 22, background: text.trim() ? C.primary : '#E5E7EB', border: 'none', cursor: text.trim() ? 'pointer' : 'default', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0, transition: 'background 0.15s' }}>
            <span style={{ fontSize: 18, transform: 'rotate(45deg)', display: 'block', color: text.trim() ? C.white : '#9CA3AF' }}>➤</span>
          </button>
        </div>
      </div>
    )
  }

  // ── CONVERSATION LIST VIEW ────────────────────────────────────────────────
  return (
    <div className="page">
      {/* Header */}
      <div style={{ background: C.white, paddingTop: 'env(safe-area-inset-top,0px)', borderBottom: `1px solid ${C.border}`, flexShrink: 0 }}>
        <div style={{ padding: '16px 20px 12px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <h1 style={{ fontFamily: 'Inter', fontSize: 20, fontWeight: 700, color: '#1A1A1A' }}>Ujumbe 💬</h1>
        </div>
      </div>

      <div className="scroll">
        {loading ? (
          <div style={{ padding: '20px 16px' }}>
            {[1,2,3].map(i => (
              <div key={i} style={{ height: 72, background: '#F3F4F6', borderRadius: 16, marginBottom: 10, animation: 'pulse 1.5s infinite' }} />
            ))}
          </div>
        ) : conversations.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '60px 24px' }}>
            <div style={{ fontSize: 56, marginBottom: 16 }}>💬</div>
            <h2 style={{ fontFamily: 'Inter', fontSize: 18, fontWeight: 700, color: '#1A1A1A', marginBottom: 8 }}>Hakuna ujumbe bado</h2>
            <p style={{ fontFamily: 'Inter', fontSize: 14, color: C.textSec, marginBottom: 24 }}>
              Mazungumzo na Winga yako yataonekana hapa baada ya kukubali ombi lako
            </p>
            <button onClick={() => nav('/book')}
              style={{ background: C.primary, color: C.white, border: 'none', borderRadius: 12, padding: '12px 28px', fontFamily: 'Inter', fontSize: 14, fontWeight: 600, cursor: 'pointer' }}>
              Omba Winga Sasa →
            </button>
          </div>
        ) : (
          <div style={{ padding: '8px 0' }}>
            {conversations.map(conv => (
              <div key={conv.requestId} onClick={() => openChat(conv)}
                style={{ display: 'flex', gap: 14, padding: '14px 20px', cursor: 'pointer', background: C.white, borderBottom: `1px solid ${C.border}`, WebkitTapHighlightColor: 'transparent', position: 'relative' }}>
                {/* Avatar */}
                <div style={{ position: 'relative', flexShrink: 0 }}>
                  <div style={{ width: 52, height: 52, borderRadius: 26, background: C.surface, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 26 }}>👤</div>
                  <div style={{ position: 'absolute', bottom: 1, right: 1, width: 14, height: 14, borderRadius: 7, background: conv.status === 'shopping' ? '#22C55E' : '#9CA3AF', border: '2px solid white' }} />
                </div>
                {/* Content */}
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 3 }}>
                    <span style={{ fontFamily: 'Inter', fontSize: 14, fontWeight: conv.unread > 0 ? 700 : 600, color: '#1A1A1A' }}>{conv.wingaName}</span>
                    <span style={{ fontFamily: 'Inter', fontSize: 11, color: C.textSec, flexShrink: 0 }}>{timeLabel(conv.lastTime)}</span>
                  </div>
                  <div style={{ fontFamily: 'Inter', fontSize: 12, color: '#9CA3AF', marginBottom: 4 }}>{conv.category}</div>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <span style={{ fontFamily: 'Inter', fontSize: 13, color: conv.unread > 0 ? '#1A1A1A' : C.textSec, fontWeight: conv.unread > 0 ? 600 : 400, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap', flex: 1 }}>
                      {conv.lastMessage}
                    </span>
                    {conv.unread > 0 && (
                      <div style={{ width: 20, height: 20, borderRadius: 10, background: C.primary, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0, marginLeft: 8 }}>
                        <span style={{ fontFamily: 'Inter', fontSize: 11, fontWeight: 700, color: C.white }}>{conv.unread}</span>
                      </div>
                    )}
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
        <div style={{ height: 20 }} />
      </div>

      <BottomNav />
      <style>{`@keyframes pulse{0%,100%{opacity:1}50%{opacity:.5}}`}</style>
    </div>
  )
}
