export const Session = {
  set:(uid:string,type:'customer'|'winga')=>{localStorage.setItem('w_uid',uid);localStorage.setItem('w_type',type)},
  uid:()=>localStorage.getItem('w_uid'),
  type:()=>localStorage.getItem('w_type') as 'customer'|'winga'|null,
  isLoggedIn:()=>!!localStorage.getItem('w_uid'),
  isWinga:()=>localStorage.getItem('w_type')==='winga',
  setOnboarded:()=>localStorage.setItem('w_onboarded','1'),
  isOnboarded:()=>!!localStorage.getItem('w_onboarded'),
  clear:()=>{localStorage.removeItem('w_uid');localStorage.removeItem('w_type')},
}
