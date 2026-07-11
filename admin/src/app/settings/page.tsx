'use client'
import { useState } from 'react'
import AdminLayout from '@/components/layout/AdminLayout'
import { Settings, Bell, Shield, CreditCard, Globe, Smartphone } from 'lucide-react'

export default function SettingsPage() {
  const [commissionRate, setCommissionRate] = useState(20)
  const [taxRate, setTaxRate] = useState(3)
  const [emailNotifs, setEmailNotifs] = useState(true)
  const [smsNotifs, setSmsNotifs] = useState(true)

  return (
    <AdminLayout title="Settings" subtitle="Platform configuration">
      <div className="max-w-3xl space-y-6">
        {/* Platform settings */}
        <div className="bg-white rounded-2xl border border-gray-100 shadow-card">
          <div className="flex items-center gap-2 p-5 border-b border-gray-100">
            <Settings className="w-4 h-4 text-primary" />
            <h2 className="text-base font-semibold text-gray-900">Platform Configuration</h2>
          </div>
          <div className="p-5 space-y-5">
            <div>
              <label className="text-sm font-semibold text-gray-700 block mb-2">Platform Commission Rate (%)</label>
              <div className="flex items-center gap-4">
                <input type="range" min={10} max={30} value={commissionRate} onChange={e => setCommissionRate(+e.target.value)} className="flex-1 accent-primary" />
                <span className="w-12 text-center text-lg font-bold text-primary">{commissionRate}%</span>
              </div>
              <p className="text-xs text-gray-400 mt-1">Winga keeps {100 - commissionRate}% of each transaction</p>
            </div>
            <div>
              <label className="text-sm font-semibold text-gray-700 block mb-2">TRA Tax Rate (%)</label>
              <div className="flex items-center gap-4">
                <input type="range" min={3} max={5} step={0.5} value={taxRate} onChange={e => setTaxRate(+e.target.value)} className="flex-1 accent-primary" />
                <span className="w-12 text-center text-lg font-bold text-primary">{taxRate}%</span>
              </div>
              <p className="text-xs text-gray-400 mt-1">Per TRA regulations — allowed range 3%–5%</p>
            </div>
            <div className="grid grid-cols-2 gap-4">
              {[
                { label: 'Hourly Rate (TZS)', value: '15,000' },
                { label: 'Half Day Rate (TZS)', value: '25,000' },
                { label: 'Full Day Rate (TZS)', value: '40,000' },
                { label: 'Delivery Fee (TZS)', value: '2,000' },
              ].map(f => (
                <div key={f.label}>
                  <label className="text-xs font-semibold text-gray-500 block mb-1.5">{f.label}</label>
                  <input defaultValue={f.value} className="w-full px-3 py-2 text-sm border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary/20" />
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Notification settings */}
        <div className="bg-white rounded-2xl border border-gray-100 shadow-card">
          <div className="flex items-center gap-2 p-5 border-b border-gray-100">
            <Bell className="w-4 h-4 text-primary" />
            <h2 className="text-base font-semibold text-gray-900">Notification Settings</h2>
          </div>
          <div className="p-5 space-y-4">
            {[
              { label: 'Email Notifications', sub: 'Admin alerts via email', val: emailNotifs, set: setEmailNotifs },
              { label: 'SMS Notifications', sub: 'Critical alerts via SMS', val: smsNotifs, set: setSmsNotifs },
            ].map(item => (
              <div key={item.label} className="flex items-center justify-between py-2 border-b border-gray-50 last:border-0">
                <div>
                  <div className="text-sm font-semibold text-gray-700">{item.label}</div>
                  <div className="text-xs text-gray-400">{item.sub}</div>
                </div>
                <button onClick={() => item.set(!item.val)} className={`relative w-11 h-6 rounded-full transition-colors ${item.val ? 'bg-primary' : 'bg-gray-200'}`}>
                  <span className={`absolute top-0.5 w-5 h-5 bg-white rounded-full shadow transition-transform ${item.val ? 'translate-x-5' : 'translate-x-0.5'}`} />
                </button>
              </div>
            ))}
          </div>
        </div>

        <button className="w-full bg-primary text-white font-semibold text-sm py-3 rounded-xl hover:bg-primary-dark transition-colors">
          Save All Settings
        </button>
      </div>
    </AdminLayout>
  )
}
