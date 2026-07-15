import { createClient } from '@supabase/supabase-js'
const URL = import.meta.env.VITE_SUPABASE_URL || 'https://kevdbsyiqelksxvmuped.supabase.co'
const KEY = import.meta.env.VITE_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtldmRic3lpcWVsa3N4dm11cGVkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODM3MzUyMjIsImV4cCI6MjA5OTMxMTIyMn0.pNmc5HGE9huxmh4-eqveLETkxnxJ_j5rigeS8t35o2A'
export const supabase = createClient(URL, KEY)
export const EDGE = `${URL}/functions/v1`
