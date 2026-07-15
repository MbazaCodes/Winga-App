// Safe localStorage wrapper — Safari private mode throws SecurityError
function safeGet(key: string): string | null {
  try { return localStorage.getItem(key) } catch { return null }
}
function safeSet(key: string, val: string) {
  try { localStorage.setItem(key, val) } catch { /* silent */ }
}
function safeRemove(key: string) {
  try { localStorage.removeItem(key) } catch { /* silent */ }
}

export const Session = {
  set: (uid: string, type: 'customer' | 'winga') => {
    safeSet('w_uid', uid)
    safeSet('w_type', type)
  },
  uid: () => safeGet('w_uid'),
  type: () => safeGet('w_type') as 'customer' | 'winga' | null,
  isLoggedIn: () => !!safeGet('w_uid'),
  isWinga: () => safeGet('w_type') === 'winga',
  setOnboarded: () => safeSet('w_onboarded', '1'),
  isOnboarded: () => !!safeGet('w_onboarded'),
  clear: () => {
    safeRemove('w_uid')
    safeRemove('w_type')
  },
}
