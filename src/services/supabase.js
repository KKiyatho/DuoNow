import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

export const hasSupabaseEnv = Boolean(supabaseUrl && supabaseAnonKey)

const createNoEnvError = () =>
  new Error(
    'Supabase 환경변수가 없습니다. .env.local에 VITE_SUPABASE_URL, VITE_SUPABASE_ANON_KEY를 설정하세요.',
  )

export const supabase = hasSupabaseEnv ? createClient(supabaseUrl, supabaseAnonKey) : null

export const getCurrentSession = async () => {
  if (!supabase) {
    return { data: { session: null }, error: null }
  }

  return supabase.auth.getSession()
}

export const onAuthSessionChange = (callback) => {
  if (!supabase) {
    return () => {}
  }

  const {
    data: { subscription },
  } = supabase.auth.onAuthStateChange((_event, nextSession) => {
    callback(nextSession)
  })

  return () => subscription.unsubscribe()
}

export const signUpEmail = async (email, password) => {
  if (!supabase) {
    return { data: null, error: createNoEnvError() }
  }

  return supabase.auth.signUp({ email, password })
}

export const signInEmail = async (email, password) => {
  if (!supabase) {
    return { data: null, error: createNoEnvError() }
  }

  return supabase.auth.signInWithPassword({ email, password })
}

export const signInOAuth = async (provider) => {
  if (!supabase) {
    return { data: null, error: createNoEnvError() }
  }

  return supabase.auth.signInWithOAuth({
    provider,
    options: {
      redirectTo: `${window.location.origin}/profile`,
    },
  })
}

export const requestPhoneOtp = async (phone) => {
  if (!supabase) {
    return { data: null, error: createNoEnvError() }
  }

  return supabase.auth.signInWithOtp({
    phone,
  })
}

export const verifyPhoneOtp = async (phone, token) => {
  if (!supabase) {
    return { data: null, error: createNoEnvError() }
  }

  return supabase.auth.verifyOtp({
    phone,
    token,
    type: 'sms',
  })
}

export const signOutUser = async () => {
  if (!supabase) {
    return { error: createNoEnvError() }
  }

  return supabase.auth.signOut()
}

export const getProfile = async (userId) => {
  if (!supabase) {
    return { data: null, error: createNoEnvError() }
  }

  const result = await supabase
    .from('profiles')
    .select('nickname, game, tier, play_style')
    .eq('id', userId)
    .maybeSingle()

  return result
}

export const upsertProfile = async (profile) => {
  if (!supabase) {
    return { data: null, error: createNoEnvError() }
  }

  return supabase
    .from('profiles')
    .upsert(
      {
        ...profile,
        updated_at: new Date().toISOString(),
      },
      {
        onConflict: 'id',
      },
    )
    .select()
    .single()
}
