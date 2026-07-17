import { useEffect, useState } from 'react'
import { Navigate, Route, Routes } from 'react-router-dom'
import AuthForm from './components/AuthForm'
import ProfileForm from './components/ProfileForm'
import { getCurrentSession, hasSupabaseEnv, onAuthSessionChange } from './services/supabase'

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

export default App
