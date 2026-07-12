import { supabase } from './supabase'

/**
 * Upload a profile photo from a File/Blob to Supabase Storage.
 * Returns the public URL or throws on error.
 * Path: avatars/{uid}/profile.{ext}
 */
export async function uploadProfilePhoto(file: File, uid: string): Promise<string> {
  const ext = file.name.split('.').pop()?.toLowerCase() || 'jpg'
  const path = `${uid}/profile.${ext}`

  // Remove old file first (upsert)
  await supabase.storage.from('avatars').remove([path]).catch(() => {})

  const { error } = await supabase.storage
    .from('avatars')
    .upload(path, file, {
      contentType: file.type || 'image/jpeg',
      upsert: true,
    })

  if (error) throw error

  const { data } = supabase.storage.from('avatars').getPublicUrl(path)
  // Add cache-bust so browser picks up new photo
  return data.publicUrl + '?t=' + Date.now()
}

/**
 * Pick a photo file from device camera or gallery.
 * Returns a File or null if cancelled.
 */
export function pickPhoto(capture?: 'camera' | 'gallery'): Promise<File | null> {
  return new Promise(resolve => {
    const input = document.createElement('input')
    input.type = 'file'
    input.accept = 'image/*'
    if (capture === 'camera') input.capture = 'environment'
    input.onchange = () => resolve(input.files?.[0] ?? null)
    input.oncancel = () => resolve(null)
    input.click()
  })
}
