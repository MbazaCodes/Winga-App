export const PRICES = { hourly:15000, halfDay:25000, fullDay:40000 }
export const BADGES:Record<string,{emoji:string,color:string,bg:string}> = {
  Starter:{emoji:'🥉',color:'#CD7F32',bg:'#FFF3E0'},
  Mid:{emoji:'🥈',color:'#9E9E9E',bg:'#F5F5F5'},
  Verified:{emoji:'🥇',color:'#F9A825',bg:'#FFF8E1'},
}
export const CATEGORIES = [
  {emoji:'📱',sw:'Elektroniki'},{emoji:'👕',sw:'Mavazi'},{emoji:'👟',sw:'Viatu'},
  {emoji:'💄',sw:'Vipodozi'},{emoji:'🔨',sw:'Vifaa vya Ujenzi'},{emoji:'🛋️',sw:'Samani'},
  {emoji:'🍳',sw:'Vifaa vya Nyumbani'},{emoji:'🔧',sw:'Spare Parts'},
  {emoji:'💊',sw:'Manukato'},{emoji:'⋯',sw:'Zaidi'},
]
export const fmt=(n:number)=>'TZS '+n.toLocaleString('en-US')
