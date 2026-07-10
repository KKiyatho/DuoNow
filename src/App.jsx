import { useEffect, useState } from 'react'
import { supabase, hasSupabaseEnv } from './services/supabase'
import './App.css'

function App() {
  const [session, setSession] = useState(null)

  useEffect(() => {
    if (!hasSupabaseEnv) return

    supabase.auth.getSession().then(({ data }) => {
      setSession(data.session)
    })

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, nextSession) => {
      setSession(nextSession)
    })

    return () => subscription.unsubscribe()
  }, [])

  return (
    <main className="app-shell">
      <section className="hero-card">
        <p className="chip">DuoNow MVP Bootstrap</p>
        <h1>게임 듀오 매칭, 지금 시작</h1>
        <p className="sub">
          React + Supabase 기반 초기 환경이 준비되었습니다. 다음 단계는 인증 화면과
          매칭 큐 API 연결입니다.
        </p>

        {!hasSupabaseEnv ? (
          <div className="notice warning">
            <strong>환경변수 필요:</strong> 프로젝트 루트에 <code>.env.local</code>을
            만들고 <code>VITE_SUPABASE_URL</code>, <code>VITE_SUPABASE_ANON_KEY</code>
            값을 설정하세요.
          </div>
        ) : (
          <div className="notice ok">
            <strong>Supabase 연결 상태:</strong>{' '}
            {session ? '로그인 세션 감지됨' : '연결됨 (로그인 전)'}
          </div>
        )}

        <div className="next-box">
          <h2>다음 작업</h2>
          <ol>
            <li>인증 페이지 (`/login`) 구성</li>
            <li>프로필 입력 폼 (게임/티어/스타일) 구현</li>
            <li>매칭 요청 테이블 연동</li>
          </ol>
        </div>
      </section>
    </main>
  )
}

export default App
