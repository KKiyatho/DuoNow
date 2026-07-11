import { useEffect, useState } from 'react'
import { Navigate, Route, Routes } from 'react-router-dom'
import {
  getCurrentSession,
  getProfile,
  hasSupabaseEnv,
  onAuthSessionChange,
  requestPhoneOtp,
  signInEmail,
  signInOAuth,
  signOutUser,
  signUpEmail,
  upsertProfile,
  verifyPhoneOtp,
} from './services/supabase'

const EMPTY_PROFILE = {
  nickname: '',
  game: '',
  tier: '',
  playStyle: '',
}

function GoogleLogo() {
  return (
    <svg width="18" height="18" viewBox="0 0 48 48" aria-hidden="true">
      <path fill="#FFC107" d="M43.611 20.083H42V20H24v8h11.303C33.651 32.657 29.195 36 24 36c-6.627 0-12-5.373-12-12s5.373-12 12-12c3.059 0 5.842 1.154 7.957 3.043l5.657-5.657C34.046 6.053 29.274 4 24 4C12.955 4 4 12.955 4 24s8.955 20 20 20s20-8.955 20-20c0-1.341-.138-2.65-.389-3.917z"/>
      <path fill="#FF3D00" d="M6.306 14.691l6.571 4.819C14.655 16.108 18.961 12 24 12c3.059 0 5.842 1.154 7.957 3.043l5.657-5.657C34.046 6.053 29.274 4 24 4C16.318 4 9.656 8.337 6.306 14.691z"/>
      <path fill="#4CAF50" d="M24 44c5.173 0 9.86-1.977 13.409-5.192l-6.19-5.238C29.148 35.091 26.676 36 24 36c-5.174 0-9.617-3.325-11.283-7.946l-6.522 5.025C9.505 39.556 16.227 44 24 44z"/>
      <path fill="#1976D2" d="M43.611 20.083H42V20H24v8h11.303c-.793 2.307-2.273 4.296-4.084 5.57c.001-.001 6.19 5.238 6.19 5.238C36.971 39.205 44 34 44 24c0-1.341-.138-2.65-.389-3.917z"/>
    </svg>
  )
}

function App() {
  const [session, setSession] = useState(null)
  const [booting, setBooting] = useState(true)

  useEffect(() => {
    if (!hasSupabaseEnv) {
      setBooting(false)
      return
    }

    getCurrentSession().then(({ data }) => {
      setSession(data?.session ?? null)
      setBooting(false)
    })

    const unsubscribe = onAuthSessionChange((nextSession) => {
      setSession(nextSession)
    })

    return unsubscribe
  }, [])

  if (booting) {
    return (
      <main className="min-h-screen bg-slate-950 px-6 py-12 text-slate-100">
        <section className="mx-auto w-full max-w-4xl rounded-3xl border border-slate-800 bg-slate-900/80 p-10 shadow-2xl shadow-slate-950/40">
          <h1 className="m-0 text-4xl font-semibold tracking-tight text-slate-100">DUONOW</h1>
          <p className="mt-4 text-slate-400">서비스 정보를 불러오는 중입니다.</p>
        </section>
      </main>
    )
  }

  return (
    <main className="min-h-screen bg-slate-950 px-4 py-10 text-slate-100 sm:px-6">
      {!hasSupabaseEnv && (
        <div className="fixed inset-x-0 top-0 z-20 border-b border-slate-700/70 bg-slate-900/95 backdrop-blur">
          <p className="mx-auto max-w-6xl px-4 py-2 text-center text-xs text-slate-300 sm:text-sm">
            개발 환경 안내: .env.local에 VITE_SUPABASE_URL, VITE_SUPABASE_ANON_KEY를 설정하세요.
          </p>
        </div>
      )}

      <section className="mx-auto w-full max-w-5xl rounded-3xl border border-slate-800/90 bg-slate-900/80 p-6 shadow-2xl shadow-slate-950/50 backdrop-blur sm:p-10">
        <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
          <div className="max-w-3xl">
            <p className="text-xs font-semibold uppercase tracking-[0.2em] text-blue-300">DUONOW</p>
            <h1 className="mt-3 text-3xl font-semibold leading-tight tracking-tight text-white sm:text-5xl sm:leading-[1.08]">
              실력과 스타일이 맞는 듀오를 빠르게
            </h1>
            <p className="mt-4 max-w-2xl text-sm leading-7 text-slate-300 sm:text-base">
              게이머 프로필 데이터 기반으로 팀원을 매칭하는 플랫폼입니다. 로그인 후 프로필을 등록하면
              본격적으로 매칭 기능을 사용할 수 있습니다.
            </p>
          </div>

          <div className="group relative w-fit">
            <p
              className={`rounded-full border px-3 py-1 text-xs font-semibold ${
                hasSupabaseEnv
                  ? 'border-emerald-500/40 bg-emerald-500/10 text-emerald-300'
                  : 'border-violet-500/40 bg-violet-500/10 text-violet-300'
              }`}
            >
              {hasSupabaseEnv ? '운영 준비 완료' : '연동 설정 필요'}
            </p>
            {!hasSupabaseEnv && (
              <div className="pointer-events-none absolute right-0 top-9 w-72 rounded-xl border border-slate-700 bg-slate-900/95 p-3 text-xs leading-5 text-slate-300 opacity-0 shadow-xl transition-opacity duration-200 group-hover:opacity-100">
                .env.local 파일에 VITE_SUPABASE_URL과 VITE_SUPABASE_ANON_KEY 값을 입력해 주세요.
              </div>
            )}
          </div>
        </div>

        <div className="mt-6 inline-flex rounded-full border border-slate-700 bg-slate-950/70 px-3 py-1 text-xs font-medium text-slate-300">
          인증 상태: {session ? '로그인됨' : '로그인 전'}
        </div>

        <Routes>
          <Route
            path="/login"
            element={
              session ? <Navigate to="/profile" replace /> : <AuthForm onSignedIn={setSession} />
            }
          />
          <Route
            path="/profile"
            element={
              session ? (
                <ProfileForm key={session.user.id} session={session} onSignedOut={() => setSession(null)} />
              ) : (
                <Navigate to="/login" replace />
              )
            }
          />
          <Route path="*" element={<Navigate to={session ? '/profile' : '/login'} replace />} />
        </Routes>
      </section>
    </main>
  )
}

function AuthForm({ onSignedIn }) {
  const [isSignUp, setIsSignUp] = useState(false)
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [phoneLoginOpen, setPhoneLoginOpen] = useState(false)
  const [phone, setPhone] = useState('')
  const [otpCode, setOtpCode] = useState('')
  const [otpRequested, setOtpRequested] = useState(false)
  const [submitting, setSubmitting] = useState(false)
  const [oauthLoading, setOauthLoading] = useState('')
  const [phoneLoading, setPhoneLoading] = useState(false)
  const [error, setError] = useState('')
  const [message, setMessage] = useState('')

  const submit = async (event) => {
    event.preventDefault()
    setError('')
    setMessage('')
    setSubmitting(true)

    const action = isSignUp ? signUpEmail : signInEmail
    const { data, error: authError } = await action(email, password)

    if (authError) {
      setError(authError.message)
      setSubmitting(false)
      return
    }

    if (isSignUp) {
      setMessage('가입 요청이 완료되었습니다. 이메일 인증 후 로그인하세요.')
      setSubmitting(false)
      return
    }

    onSignedIn(data.session)
    setSubmitting(false)
  }

  const startOAuth = async (provider) => {
    setError('')
    setMessage('')
    setOauthLoading(provider)

    try {
      const { error: oauthError } = await signInOAuth(provider)

      if (oauthError) {
        if (oauthError.message.includes('Unsupported provider: missing OAuth secret')) {
          setError('Google Provider의 Client Secret이 Supabase에 설정되지 않았습니다. Sign In / Providers > Google에서 Client ID/Secret을 저장해 주세요.')
        } else {
          setError(oauthError.message)
        }
      }
    } finally {
      setOauthLoading('')
    }
  }

  const sendPhoneOtp = async () => {
    setError('')
    setMessage('')
    setPhoneLoading(true)

    try {
      const { error: otpError } = await requestPhoneOtp(phone.trim())

      if (otpError) {
        setError(otpError.message)
        return
      }

      setOtpRequested(true)
      setMessage('인증번호를 전송했습니다. 문자로 받은 6자리 코드를 입력해 주세요.')
    } finally {
      setPhoneLoading(false)
    }
  }

  const submitPhoneOtp = async () => {
    setError('')
    setMessage('')
    setPhoneLoading(true)

    try {
      const { data, error: verifyError } = await verifyPhoneOtp(phone.trim(), otpCode.trim())

      if (verifyError) {
        setError(verifyError.message)
        return
      }

      onSignedIn(data.session)
    } finally {
      setPhoneLoading(false)
    }
  }

  return (
    <div className="mt-7 rounded-2xl border border-slate-800 bg-slate-950/60 p-5 sm:p-6">
      <h2 className="m-0 text-xl font-semibold text-white">{isSignUp ? '회원가입' : '로그인'}</h2>
      <p className="mt-2 text-sm text-slate-400">계정 정보를 입력해 DUONOW를 시작하세요.</p>

      <form className="mt-5 grid gap-4" onSubmit={submit}>
        <label className="grid gap-2 text-sm font-medium text-slate-200">
          이메일
          <input
            type="email"
            value={email}
            onChange={(event) => setEmail(event.target.value)}
            required
            autoComplete="email"
            placeholder="you@example.com"
            className="w-full rounded-xl border border-slate-700 bg-slate-900/60 px-3 py-3 text-sm text-slate-100 placeholder:text-slate-500 transition-all duration-200 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/40"
          />
        </label>
        <label className="grid gap-2 text-sm font-medium text-slate-200">
          비밀번호
          <input
            type="password"
            value={password}
            onChange={(event) => setPassword(event.target.value)}
            required
            minLength={6}
            autoComplete={isSignUp ? 'new-password' : 'current-password'}
            placeholder="6자 이상"
            className="w-full rounded-xl border border-slate-700 bg-slate-900/60 px-3 py-3 text-sm text-slate-100 placeholder:text-slate-500 transition-all duration-200 focus:border-violet-500 focus:outline-none focus:ring-2 focus:ring-violet-500/40"
          />
        </label>

        {error && <p className="m-0 text-sm text-rose-400">{error}</p>}
        {message && <p className="m-0 text-sm text-emerald-400">{message}</p>}

        <button
          type="submit"
          disabled={submitting || Boolean(oauthLoading) || phoneLoading}
          className="rounded-xl bg-gradient-to-r from-blue-500 to-violet-500 px-4 py-3 text-sm font-semibold text-white transition-all duration-200 hover:opacity-90 active:scale-[0.99] disabled:cursor-not-allowed disabled:opacity-60"
        >
          {submitting ? '처리 중...' : isSignUp ? '회원가입' : '로그인'}
        </button>
      </form>

      <div className="mt-4 grid gap-4">
          <button
            type="button"
            onClick={() => startOAuth('google')}
            disabled={submitting || Boolean(oauthLoading) || phoneLoading}
            className="flex w-full items-center justify-center gap-2 rounded-xl border border-slate-300 bg-white px-4 py-3 text-sm font-semibold text-slate-900 transition-all duration-200 hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-60"
          >
            <GoogleLogo />
            {oauthLoading === 'google' ? 'Google 연결 중...' : 'Google로 계속하기'}
          </button>

          <div className="flex items-center gap-3 text-xs text-slate-500">
            <span className="h-px flex-1 bg-slate-800" />
            다른 방법으로 계속하기
            <span className="h-px flex-1 bg-slate-800" />
          </div>

          <div className="grid gap-3">
            <button
              type="button"
              onClick={() => {
                setError('')
                setMessage('')
                setPhoneLoginOpen((prev) => !prev)
              }}
              disabled={submitting || Boolean(oauthLoading) || phoneLoading}
              className="w-full rounded-xl border border-slate-700 bg-slate-900 px-4 py-3 text-sm font-semibold text-slate-100 transition-all duration-200 hover:border-slate-500 hover:bg-slate-800 disabled:cursor-not-allowed disabled:opacity-60"
            >
              {phoneLoginOpen ? '휴대폰 로그인 닫기' : '휴대폰으로 계속하기'}
            </button>

            {phoneLoginOpen && (
              <div className="grid gap-3">
                <input
                  type="tel"
                  value={phone}
                  onChange={(event) => setPhone(event.target.value)}
                  placeholder="예: +821012345678"
                  className="w-full rounded-xl border border-slate-700 bg-slate-900/60 px-3 py-3 text-sm text-slate-100 placeholder:text-slate-500 transition-all duration-200 focus:border-violet-500 focus:outline-none focus:ring-2 focus:ring-violet-500/30"
                />
                {otpRequested && (
                  <input
                    value={otpCode}
                    onChange={(event) => setOtpCode(event.target.value)}
                    inputMode="numeric"
                    maxLength={6}
                    placeholder="인증번호 6자리"
                    className="w-full rounded-xl border border-slate-700 bg-slate-900/60 px-3 py-3 text-sm text-slate-100 placeholder:text-slate-500 transition-all duration-200 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/30"
                  />
                )}
                <button
                  type="button"
                  onClick={otpRequested ? submitPhoneOtp : sendPhoneOtp}
                  disabled={submitting || Boolean(oauthLoading) || phoneLoading || !phone.trim()}
                  className="w-full rounded-xl border border-slate-700 bg-slate-800 px-4 py-3 text-sm font-semibold text-slate-100 transition-all duration-200 hover:bg-slate-700 disabled:cursor-not-allowed disabled:opacity-60"
                >
                  {phoneLoading
                    ? '처리 중...'
                    : otpRequested
                      ? '인증번호 확인'
                      : '인증번호 받기'}
                </button>
              </div>
            )}
          </div>
        </div>

      <button
        className="mt-4 border-0 bg-transparent p-0 text-sm font-semibold text-blue-300 transition-colors hover:text-blue-200"
        type="button"
        onClick={() => setIsSignUp((prev) => !prev)}
      >
        {isSignUp ? '이미 계정이 있나요? 로그인' : '처음이신가요? 회원가입'}
      </button>
    </div>
  )
}

function ProfileForm({ session, onSignedOut }) {
  const [profile, setProfile] = useState(EMPTY_PROFILE)
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')
  const [message, setMessage] = useState('')

  useEffect(() => {
    const load = async () => {
      const { data, error: loadError } = await getProfile(session.user.id)

      if (loadError) {
        setError(loadError.message)
        setLoading(false)
        return
      }

      if (data) {
        setProfile({
          nickname: data.nickname ?? '',
          game: data.game ?? '',
          tier: data.tier ?? '',
          playStyle: data.play_style ?? '',
        })
      }

      setLoading(false)
    }

    load()
  }, [session.user.id])

  const save = async (event) => {
    event.preventDefault()
    setSaving(true)
    setError('')
    setMessage('')

    const payload = {
      id: session.user.id,
      nickname: profile.nickname.trim(),
      game: profile.game.trim(),
      tier: profile.tier.trim(),
      play_style: profile.playStyle.trim(),
    }

    const { error: saveError } = await upsertProfile(payload)

    if (saveError) {
      setError(saveError.message)
      setSaving(false)
      return
    }

    setMessage('프로필이 저장되었습니다.')
    setSaving(false)
  }

  const updateField = (field) => (event) => {
    setProfile((prev) => ({ ...prev, [field]: event.target.value }))
  }

  return (
    <div className="mt-7 rounded-2xl border border-slate-800 bg-slate-950/60 p-5 sm:p-6">
      <div className="flex items-center justify-between gap-3">
        <h2 className="m-0 text-xl font-semibold text-white">프로필 설정</h2>
        <button
          className="border-0 bg-transparent p-0 text-sm font-semibold text-slate-300 transition-colors hover:text-white"
          type="button"
          onClick={async () => {
            await signOutUser()
            onSignedOut()
          }}
        >
          로그아웃
        </button>
      </div>
      <p className="mt-2 text-sm text-slate-400">로그인 계정: {session.user.email}</p>

      {loading ? (
        <p className="mt-4 text-sm text-slate-400">프로필을 불러오는 중입니다.</p>
      ) : (
        <form className="mt-5 grid gap-4" onSubmit={save}>
          <label className="grid gap-2 text-sm font-medium text-slate-200">
            닉네임
            <input
              value={profile.nickname}
              onChange={updateField('nickname')}
              required
              className="w-full rounded-xl border border-slate-700 bg-slate-900/60 px-3 py-3 text-sm text-slate-100 placeholder:text-slate-500 transition-all duration-200 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/40"
            />
          </label>
          <label className="grid gap-2 text-sm font-medium text-slate-200">
            게임
            <input
              value={profile.game}
              onChange={updateField('game')}
              placeholder="예: League of Legends"
              required
              className="w-full rounded-xl border border-slate-700 bg-slate-900/60 px-3 py-3 text-sm text-slate-100 placeholder:text-slate-500 transition-all duration-200 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/40"
            />
          </label>
          <label className="grid gap-2 text-sm font-medium text-slate-200">
            티어
            <input
              value={profile.tier}
              onChange={updateField('tier')}
              placeholder="예: Gold 2"
              required
              className="w-full rounded-xl border border-slate-700 bg-slate-900/60 px-3 py-3 text-sm text-slate-100 placeholder:text-slate-500 transition-all duration-200 focus:border-violet-500 focus:outline-none focus:ring-2 focus:ring-violet-500/40"
            />
          </label>
          <label className="grid gap-2 text-sm font-medium text-slate-200">
            플레이 스타일
            <input
              value={profile.playStyle}
              onChange={updateField('playStyle')}
              placeholder="예: 공격적, 오더 가능"
              required
              className="w-full rounded-xl border border-slate-700 bg-slate-900/60 px-3 py-3 text-sm text-slate-100 placeholder:text-slate-500 transition-all duration-200 focus:border-violet-500 focus:outline-none focus:ring-2 focus:ring-violet-500/40"
            />
          </label>

          {error && <p className="m-0 text-sm text-rose-400">{error}</p>}
          {message && <p className="m-0 text-sm text-emerald-400">{message}</p>}

          <button
            type="submit"
            disabled={saving}
            className="rounded-xl bg-gradient-to-r from-blue-500 to-violet-500 px-4 py-3 text-sm font-semibold text-white transition-all duration-200 hover:opacity-90 active:scale-[0.99] disabled:cursor-not-allowed disabled:opacity-60"
          >
            {saving ? '저장 중...' : '프로필 저장'}
          </button>
        </form>
      )}
    </div>
  )
}

export default App
