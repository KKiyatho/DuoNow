# DuoNow

실력과 플레이 스타일이 맞는 게이머를 찾기 위한 듀오 매칭 웹앱입니다.

## 핵심 기능

- 이메일 로그인 / 회원가입
- Google OAuth 로그인
- 휴대폰 OTP 로그인
- 로그인 사용자 프로필 조회 및 저장

## 기술 스택

- React 19 + Vite 8
- React Router 7
- Supabase Auth / Database
- Tailwind CSS 4
- Oxlint

## 시작하기

### 1. 의존성 설치

```powershell
npm install
```

### 2. 환경변수 설정

프로젝트 루트에 `.env.local` 파일을 만들고 값을 입력하세요.

```env
VITE_SUPABASE_URL=https://your-project-id.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key
```

### 3. 개발 서버 실행

```powershell
npm run dev
```

## 스크립트

- `npm run dev`: 개발 서버 실행
- `npm run build`: 프로덕션 빌드
- `npm run preview`: 빌드 결과 미리보기
- `npm run lint`: 코드 린트
- `npm run test`: 테스트 실행
- `npm run test:watch`: 테스트 감시 모드

## 프로젝트 구조

```text
src/
	components/
		AuthForm.jsx
		AuthForm.test.jsx
		ProfileForm.jsx
	test/
		setup.js
	services/
		supabase.js
	App.jsx
	main.jsx
```

## Supabase 테이블 가이드

`profiles` 테이블 예시 컬럼:

- `id` (uuid, auth.users.id와 동일)
- `nickname` (text)
- `game` (text)
- `tier` (text)
- `play_style` (text)
- `updated_at` (timestamp)

운영 환경에서는 RLS(Row Level Security) 정책을 반드시 적용하세요.

샘플 정책 파일: `supabase/profiles_rls.sql`
