export const PRICES = { hourly: 15000, halfDay: 25000, fullDay: 40000 }

export const BADGES: Record<string, { emoji: string; color: string; bg: string }> = {
  Starter:  { emoji: '🥉', color: '#CD7F32', bg: '#FFF3E0' },
  Mid:      { emoji: '🥈', color: '#9E9E9E', bg: '#F5F5F5' },
  Verified: { emoji: '🥇', color: '#F9A825', bg: '#FFF8E1' },
}

export const CATEGORIES = [
  { id: 'electronics', name: 'Elektroniki',        icon: '📱', emoji: '📱', sw: 'Elektroniki' },
  { id: 'clothing',    name: 'Mavazi',              icon: '👕', emoji: '👕', sw: 'Mavazi' },
  { id: 'shoes',       name: 'Viatu',               icon: '👟', emoji: '👟', sw: 'Viatu' },
  { id: 'beauty',      name: 'Vipodozi',            icon: '💄', emoji: '💄', sw: 'Vipodozi' },
  { id: 'hardware',    name: 'Vifaa vya Ujenzi',   icon: '🔨', emoji: '🔨', sw: 'Vifaa vya Ujenzi' },
  { id: 'furniture',   name: 'Samani',              icon: '🛋️', emoji: '🛋️', sw: 'Samani' },
  { id: 'kitchen',     name: 'Vifaa vya Nyumbani', icon: '🍳', emoji: '🍳', sw: 'Vifaa vya Nyumbani' },
  { id: 'spareparts',  name: 'Spare Parts',         icon: '🔧', emoji: '🔧', sw: 'Spare Parts' },
  { id: 'medicine',    name: 'Manukato',            icon: '💊', emoji: '💊', sw: 'Manukato' },
  { id: 'food',        name: 'Chakula',             icon: '🛒', emoji: '🛒', sw: 'Chakula' },
  { id: 'other',       name: 'Zaidi',               icon: '⋯', emoji: '⋯', sw: 'Zaidi' },
]

export const SPECIALTIES = [
  'Elektroniki', 'Mavazi', 'Viatu', 'Vipodozi', 'Vifaa vya Ujenzi',
  'Samani', 'Vifaa vya Nyumbani', 'Spare Parts', 'Manukato', 'Chakula', 'Jumla (General)',
]

export const CITIES = [
  'Dar es Salaam', 'Arusha', 'Moshi', 'Mwanza', 'Dodoma',
  'Tanga', 'Morogoro', 'Zanzibar City', 'Mbeya', 'Iringa',
]

export const AREAS: Record<string, string[]> = {
  'Dar es Salaam': ['Kariakoo', 'Mwenge', 'Mnazi Mmoja', 'Ilala', 'Kinondoni', 'Temeke', 'Tabata', 'Mbagala'],
  'Arusha': ['Arusha CBD', 'Sakina Market', 'Kaloleni'],
  'Moshi': ['Moshi Market', 'Moshi CBD'],
  'Mwanza': ['Mwanza Market', 'Kirumba'],
  'Zanzibar City': ['Darajani Market', 'Stone Town'],
}

export const fmt = (n: number) => 'TZS ' + n.toLocaleString('en-US')
