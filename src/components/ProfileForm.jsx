import React from 'react'
import { useEffect, useState } from 'react'
import { getProfile, signOutUser, upsertProfile } from '../services/supabase'

const EMPTY_PROFILE = {
  nickname: '',
  game: '',
  tier: '',
  playStyle: '',
}

function ProfileForm({ session, onSignedOut }) {
  const [profile, setProfile] = useState(EMPTY_PROFILE)
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')
  const [message, setMessage] = useState('')

  useEffect(() => {
    let active = true

    const load = async () => {
      const { data, error: loadError } = await getProfile(session.user.id)

      if (!active) {
        return
      }

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

    return () => {
      active = false
    }
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

export default ProfileForm