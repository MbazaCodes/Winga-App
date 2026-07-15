import { createContext, useContext, useEffect, useState, useRef, useCallback, type ReactNode } from 'react'
import { useNavigate } from 'react-router-dom'
import { supabase } from './supabase'
import { Session } from './session'
import { fmt } from './constants'

/* ------------------------------------------------------------------ */
/*  Types                                                              */
/* ------------------------------------------------------------------ */

interface AcceptNotif {
  type: 'winga_accepted'
  requestId: string
  wingaName: string
  wingaId: string
  wingaPhone: string | null
}

interface NewReqNotif {
  type: 'new_request'
  category: string
  price: number
}

type Notif = AcceptNotif | NewReqNotif | null

interface CtxType {
  dismiss: () => void
}

const Ctx = createContext<CtxType>({ dismiss: () => {} })
export const useNotification = () => useContext(Ctx)

/* ------------------------------------------------------------------ */
/*  Provider                                                           */
/* ------------------------------------------------------------------ */

export function NotificationProvider({ children }: { children: ReactNode }) {
  const nav = useNavigate()
  const [notif, setNotif] = useState<Notif>(null)
  const [vis, setVis] = useState(false)
  const timer = useRef<ReturnType<typeof setTimeout> | null>(null)
  const ch = useRef<any>(null)
  const alive = useRef(true)

  const dismiss = useCallback(() => {
    if (timer.current) clearTimeout(timer.current)
    setVis(false)
    setTimeout(() => { if (alive.current) setNotif(null) }, 300)
  }, [])

  const show = useCallback((n: Notif, ms = 8000) => {
    if (!alive.current) return
    if (timer.current) clearTimeout(timer.current)
    setNotif(n)
    requestAnimationFrame(() => { if (alive.current) setVis(true) })
    if (navigator.vibrate) navigator.vibrate([200, 100, 200])
    timer.current = setTimeout(() => { if (alive.current) dismiss() }, ms)
  }, [dismiss])

  useEffect(() => {
    alive.current = true
    let cancelled = false

    const init = async () => {
      const { data: { user } } = await supabase.auth.getUser()
      const uid = user?.id || Session.uid()
      if (!uid || cancelled) return

      const isWinga = Session.isWinga()

      if (!isWinga) {
        // ═══ CUSTOMER: listen for UPDATE on my requests ═══
        ch.current = supabase
          .channel(`gnotif-c-${uid}`)
          .on('postgres_changes', {
            event: 'UPDATE', schema: 'public', table: 'requests',
            filter: `customer_id=eq.${uid}`,
          }, async (payload: any) => {
            if (!alive.current) return
            const o = payload.old, n = payload.new

            // Winga just accepted
            if (o.status === 'searching' && n.status === 'accepted' && n.winga_id) {
              const { data: w } = await supabase
                .from('wingas').select('name, winga_id, phone').eq('id', n.winga_id).single()
              if (w && alive.current) {
                show({
                  type: 'winga_accepted',
                  requestId: n.id,
                  wingaName: w.name || 'Winga',
                  wingaId: w.winga_id || '',
                  wingaPhone: w.phone || null,
                })
              }
            }
            // Winga completed
            else if (o.status !== 'completed' && n.status === 'completed') {
              if (navigator.vibrate) navigator.vibrate([300, 100, 300])
            }
          })
          .subscribe()
      } else {
        // ═══ WINGA: listen for INSERT (new searching requests) ═══
        ch.current = supabase
          .channel(`gnotif-w-${uid}`)
          .on('postgres_changes', {
            event: 'INSERT', schema: 'public', table: 'requests',
            filter: 'status=eq.searching',
          }, (payload: any) => {
            if (!alive.current) return
            const r = payload.new
            show({
              type: 'new_request',
              category: r.category || '',
              price: r.total_price || r.estimated_price || 0,
            }, 6000)
          })
          .subscribe()
      }
    }

    init()

    return () => {
      alive.current = false
      cancelled = true
      ch.current?.unsubscribe()
      ch.current = null
      if (timer.current) clearTimeout(timer.current)
    }
  }, [show])

  /* ── Render ────────────────────────────────────────────── */
  return (
    <Ctx.Provider value={{ dismiss }}>
      {children}

      {/* OVERLAY */}
      {notif && (
        <div
          onClick={dismiss}
          style={{
            position: 'fixed', inset: 0, zIndex: 300,
            background: 'rgba(0,0,0,0.45)',
            display: 'flex', alignItems: 'flex-start', justifyContent: 'center',
            paddingTop: 'calc(env(safe-area-inset-top, 0px) + 20px)',
            padding: 16,
            opacity: vis ? 1 : 0, transition: 'opacity 0.3s',
            pointerEvents: vis ? 'auto' : 'none',
          }}
        >
          <div
            onClick={e => e.stopPropagation()}
            style={{
              width: '100%', maxWidth: 380,
              opacity: vis ? 1 : 0,
              transform: vis ? 'translateY(0) scale(1)' : 'translateY(-20px) scale(0.95)',
              transition: 'transform 0.4s cubic-bezier(0.34,1.56,0.64,1), opacity 0.3s',
            }}
          >
            {notif.type === 'winga_accepted' && (
              <AcceptedCard n={notif} onDismiss={dismiss} onGo={() => { dismiss(); nav('/requests', { replace: true }) }} />
            )}
            {notif.type === 'new_request' && (
              <NewReqCard n={notif} onDismiss={dismiss} onGo={() => { dismiss(); nav('/winga/home', { replace: true }) }} />
            )}
          </div>
        </div>
      )}
    </Ctx.Provider>
  )
}

/* ═══════════════════════════════════════════════════════════════════ */

function AcceptedCard({ n, onDismiss, onGo }: { n: AcceptNotif; onDismiss: () => void; onGo: () => void }) {
  return (
    <div style={{ background: '#fff', borderRadius: 24, boxShadow: '0 20px 60px rgba(0,0,0,0.3)', overflow: 'hidden' }}>
      <div style={{ background: 'linear-gradient(135deg,#1A5C2A,#2E7D40)', padding: '20px 20px 16px', position: 'relative', overflow: 'hidden' }}>
        <div style={{ position:'absolute',top:'50%',left:'50%',width:100,height:100,borderRadius:50,border:'3px solid rgba(255,255,255,0.1)',transform:'translate(-50%,-50%)',animation:'np 2s ease-in-out infinite' }} />
        <div style={{ display:'flex',alignItems:'center',gap:12,position:'relative',zIndex:1 }}>
          <div style={{ width:52,height:52,borderRadius:26,background:'rgba(255,255,255,0.2)',border:'2px solid rgba(255,255,255,0.4)',display:'flex',alignItems:'center',justifyContent:'center',fontSize:28,animation:'nb 0.6s ease' }}>🤝</div>
          <div>
            <div style={{ fontFamily:'Inter',fontSize:18,fontWeight:800,color:'#fff' }}>Winga Amekubali!</div>
            <div style={{ fontFamily:'Inter',fontSize:12,color:'rgba(255,255,255,0.8)' }}>Ombi lako limechukuliwa</div>
          </div>
        </div>
      </div>
      <div style={{ padding: '20px' }}>
        <div style={{ background:'#E8F5E9',borderRadius:14,padding:'14px 16px',display:'flex',gap:12,alignItems:'center',marginBottom:16 }}>
          <div style={{ width:50,height:50,borderRadius:25,background:'#1A5C2A',display:'flex',alignItems:'center',justifyContent:'center',color:'#fff',fontSize:24,fontWeight:700,flexShrink:0 }}>{n.wingaName?.charAt(0)||'W'}</div>
          <div style={{ flex:1 }}>
            <div style={{ fontFamily:'Inter',fontSize:16,fontWeight:700,color:'#1A1A1A' }}>{n.wingaName}</div>
            <div style={{ fontFamily:'Inter',fontSize:12,color:'#6B7280' }}>{n.wingaId}</div>
          </div>
        </div>
        <p style={{ fontFamily:'Inter',fontSize:13,color:'#6B7280',lineHeight:1.5,marginBottom:16,textAlign:'center' }}>
          Winga wako amekubali ombi na atasafiri kutafuta bidhaa zako. Fuatilia maendeleo kwenye orodha ya safari.
        </p>
        <div style={{ display:'flex',gap:10 }}>
          {n.wingaPhone && (
            <a href={`tel:${n.wingaPhone}`} onClick={e=>e.stopPropagation()}
              style={{ height:50,width:50,borderRadius:14,flexShrink:0,background:'#F3F4F6',border:'none',display:'flex',alignItems:'center',justifyContent:'center',fontSize:22,textDecoration:'none',cursor:'pointer' }}>📞</a>
          )}
          <button onClick={onGo} style={{ flex:1,height:50,background:'#1A5C2A',color:'#fff',border:'none',borderRadius:14,fontFamily:'Inter',fontSize:15,fontWeight:700,cursor:'pointer',boxShadow:'0 4px 12px rgba(26,92,42,0.3)' }}>
            📋 Angalia Safari
          </button>
        </div>
      </div>
    </div>
  )
}

function NewReqCard({ n, onDismiss, onGo }: { n: NewReqNotif; onDismiss: () => void; onGo: () => void }) {
  return (
    <div style={{ background:'#fff',borderRadius:24,boxShadow:'0 20px 60px rgba(0,0,0,0.3)',overflow:'hidden' }}>
      <div style={{ background:'linear-gradient(135deg,#D32F2F,#B71C1C)',padding:'20px 20px 16px',position:'relative',overflow:'hidden' }}>
        <div style={{ position:'absolute',top:'50%',left:'50%',width:100,height:100,borderRadius:50,border:'3px solid rgba(255,255,255,0.1)',transform:'translate(-50%,-50%)',animation:'np 2s ease-in-out infinite' }} />
        <div style={{ display:'flex',alignItems:'center',gap:12,position:'relative',zIndex:1 }}>
          <div style={{ width:52,height:52,borderRadius:26,background:'rgba(255,255,255,0.2)',border:'2px solid rgba(255,255,255,0.4)',display:'flex',alignItems:'center',justifyContent:'center',fontSize:28,animation:'nb 0.6s ease' }}>🔔</div>
          <div>
            <div style={{ fontFamily:'Inter',fontSize:18,fontWeight:800,color:'#fff' }}>Ombi Jipya!</div>
            <div style={{ fontFamily:'Inter',fontSize:12,color:'rgba(255,255,255,0.8)' }}>Mteja anahitaji Winga — haruka!</div>
          </div>
        </div>
      </div>
      <div style={{ padding:'16px 20px' }}>
        <div style={{ display:'flex',justifyContent:'space-between',alignItems:'center',marginBottom:8 }}>
          <div style={{ fontFamily:'Inter',fontSize:16,fontWeight:700,color:'#1A1A1A' }}>{n.category}</div>
          <div style={{ fontFamily:'Inter',fontSize:20,fontWeight:800,color:'#1A5C2A' }}>{fmt(n.price)}</div>
        </div>
        <div style={{ fontFamily:'Inter',fontSize:11,color:'#D32F2F',textAlign:'center',marginBottom:12,animation:'nk 1s infinite' }}>
          ⚡ Winga wengine wanaweza kukubali — weka haraka!
        </div>
        <div style={{ display:'flex',gap:10 }}>
          <button onClick={onDismiss} style={{ flex:1,height:48,background:'#F3F4F6',color:'#6B7280',border:'none',borderRadius:12,fontFamily:'Inter',fontSize:14,fontWeight:600,cursor:'pointer' }}>Ruka</button>
          <button onClick={onGo} style={{ flex:2,height:48,background:'#1A5C2A',color:'#fff',border:'none',borderRadius:12,fontFamily:'Inter',fontSize:15,fontWeight:700,cursor:'pointer',boxShadow:'0 4px 12px rgba(26,92,42,0.3)' }}>🔔 Angalia Maombi</button>
        </div>
      </div>
    </div>
  )
}

/* ── Global keyframes (injected once) ─────────────────────── */
const _style = document.createElement('style')
_style.textContent = `
  @keyframes np{0%,100%{transform:translate(-50%,-50%) scale(1);opacity:0.5}50%{transform:translate(-50%,-50%) scale(1.6);opacity:0}}
  @keyframes nb{0%{transform:scale(0.3)}50%{transform:scale(1.15)}100%{transform:scale(1)}}
  @keyframes nk{0%,100%{opacity:1}50%{opacity:0.4}}
`
if (typeof document !== 'undefined') document.head.appendChild(_style)