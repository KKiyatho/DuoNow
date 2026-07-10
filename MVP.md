# 🎯 DuoNow MVP (Minimum Viable Product) 정의

**버전:** 1.0  
**작성일:** 2026-07-10  
**목표 완성일:** 2026-08-10 (1개월)  
**목표:** 대구 바이브 벤처 심사 데모 및 MVP 출시

---

## 1. MVP 핵심 정의

DuoNow MVP는 **"글로벌 게이머가 3초 내에 실력이 맞는 게임 파트너를 찾아 즉시 채팅을 시작하는 경험"**을 완성하는 것이 목표입니다.

### ✅ 포함 범위 (Must Have)
| 기능 | 설명 | 우선순위 |
|------|------|---------|
| **회원가입/로그인** | 이메일/닉네임 기반 회원 시스템 | P0 |
| **게임 선택** | 초기 2-3개 게임만 제공(리그, 발로란트 등) | P0 |
| **프로필 설정** | 현재 티어, 플레이 스타일(빡겜/즐겜) 저장 | P0 |
| **3단계 매칭** | 게임 → 티어 → 스타일 순서 로직 | P0 |
| **매칭 UI** | 매칭 버튼 → 로딩 애니메이션 → 결과 화면 | P0 |
| **1:1 채팅방** | 매칭 즉시 자동 생성 및 메시지 송수신 | P0 |
| **매너 평가** | 게임 종료 후 상대방 좋아요/싫어요 | P0 |
| **대기 폴백** | 45초 이상 매칭 안 되면 재탐색 옵션 제공 | P0 |

### ❌ 제외 범위 (Could Have / 후속 버전)
- 푸시 알림 시스템
- 신고/차단 기능
- 멀티 게임 확장(3개 이상)
- 지역/언어 추천
- 결제/구독 기능 (시연만 가능)
- 소셜 기능(친구 추가, 팔로우)

---

## 2. 기술 스택

### 프론트엔드
- **프레임워크:** React 18+
- **스타일링:** Tailwind CSS
- **상태 관리:** Zustand
- **실시간 통신:** WebSocket / Firebase Realtime
- **배포:** Vercel 또는 Azure Static Web Apps

### 백엔드
- **런타임:** Node.js + Express 또는 Python + FastAPI
- **데이터베이스:** Supabase (PostgreSQL) 또는 Firebase
- **인증:** Supabase Auth 또는 Firebase Auth
- **실시간:** Supabase Realtime 또는 Firebase Realtime DB
- **배포:** Vercel / Azure Container Apps / Railway

### 선택 기준
| 시나리오 | 추천 조합 |
|---------|---------|
| **가장 빠른 개발** | React + Supabase (PostgreSQL + Auth + Realtime) |
| **최대 유연성** | React + Node.js/Express + PostgreSQL + Socket.io |
| **가장 저비용** | React + Firebase (Realtime DB + Auth) |

---

## 3. 데이터 모델

```sql
-- 사용자 테이블
CREATE TABLE users (
  user_id UUID PRIMARY KEY,
  nickname VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  profile_image_url TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 사용자 프로필 (게임별 정보)
CREATE TABLE user_profiles (
  profile_id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
  game_id VARCHAR(50) NOT NULL, -- 'lol', 'valorant', etc.
  tier VARCHAR(50) NOT NULL,    -- 'bronze', 'silver', 'gold', etc.
  play_style VARCHAR(50) NOT NULL, -- 'casual', 'ranked', 'competitive'
  mannor_score FLOAT DEFAULT 50.0, -- 0-100 scale
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, game_id)
);

-- 매칭 요청
CREATE TABLE match_requests (
  request_id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
  game_id VARCHAR(50) NOT NULL,
  tier VARCHAR(50) NOT NULL,
  play_style VARCHAR(50) NOT NULL,
  status VARCHAR(50) DEFAULT 'waiting', -- 'waiting', 'matched', 'cancelled'
  created_at TIMESTAMP DEFAULT NOW(),
  expires_at TIMESTAMP DEFAULT NOW() + INTERVAL '120 seconds'
);

-- 매칭 세션 (1:1 연결)
CREATE TABLE match_sessions (
  session_id UUID PRIMARY KEY,
  user_a_id UUID REFERENCES users(user_id),
  user_b_id UUID REFERENCES users(user_id),
  game_id VARCHAR(50) NOT NULL,
  tier VARCHAR(50) NOT NULL,
  play_style VARCHAR(50) NOT NULL,
  status VARCHAR(50) DEFAULT 'active', -- 'active', 'ended'
  created_at TIMESTAMP DEFAULT NOW(),
  ended_at TIMESTAMP,
  CHECK (user_a_id < user_b_id) -- 순서 일관성
);

-- 채팅 메시지
CREATE TABLE messages (
  message_id UUID PRIMARY KEY,
  session_id UUID REFERENCES match_sessions(session_id) ON DELETE CASCADE,
  sender_id UUID REFERENCES users(user_id),
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- 매너 평가
CREATE TABLE reviews (
  review_id UUID PRIMARY KEY,
  session_id UUID REFERENCES match_sessions(session_id),
  from_user_id UUID REFERENCES users(user_id),
  to_user_id UUID REFERENCES users(user_id),
  vote VARCHAR(50) NOT NULL, -- 'like', 'dislike'
  created_at TIMESTAMP DEFAULT NOW()
);

-- 인덱스 (성능)
CREATE INDEX idx_user_profiles_game_tier ON user_profiles(game_id, tier);
CREATE INDEX idx_match_requests_status_game ON match_requests(status, game_id, created_at);
CREATE INDEX idx_match_sessions_active ON match_sessions(status, created_at);
CREATE INDEX idx_messages_session ON messages(session_id, created_at);
```

---

## 4. 핵심 알고리즘

### 4.1 매칭 로직

```
입력: user_id, game_id, tier, play_style
출력: matched_user_id 또는 timeout

1단계: 정확한 일치 탐색 (0~15초)
  - SELECT FROM match_requests 
    WHERE game_id = {game_id}
    AND tier = {tier}
    AND play_style = {play_style}
    AND status = 'waiting'
    AND created_at > NOW() - INTERVAL '120 seconds'
    LIMIT 1
  - 매칭 발견 → 즉시 session 생성, 양측 알림
  - 미발견 → 2단계로

2단계: 조건 완화 제안 (15~45초)
  - 사용자에게 "인접 티어 허용?" 선택 팝업 제공
  - 선택 시: tier in {adjacent_tiers} 조건으로 재탐색
  - 미선택 시 → 3단계로

3단계: 글로벌 확장 (45~90초)
  - play_style 완화 또는 지역 범위 확대
  - 마지막 시도

4단계: 폴백 모드 (90초+)
  - 예약 매칭 안내 (푸시 알림으로 재호출)
  - 친구 초대 링크 제공
```

### 4.2 공정성 정책

```
모든 사용자에게 동일 적용:
- 티어 차이 상한: ±1 (금은/금금 매칭만 가능, 금플은 불가)
- 플레이 스타일 완화: 2단계 이후만
- 매너 점수 하한: 30점 이하 유저는 매칭 제한
```

---

## 5. 핵심 화면 (UI 프로토타입)

### 화면 1: 홈 (게임 선택)
```
┌─────────────────────────┐
│  DuoNow  [프로필]       │
├─────────────────────────┤
│                         │
│  ┌──────────┐ ┌──────┐ │
│  │ 🗡️ LOL   │ │발로  │ │
│  │ 리그     │ │ 란트  │ │
│  └──────────┘ └──────┘ │
│                         │
│  ┌──────────┐           │
│  │ 기타게임  │           │
│  └──────────┘           │
└─────────────────────────┘
```

### 화면 2: 프로필 & 매칭 설정
```
┌─────────────────────────┐
│  게임: 리그             │ (선택됨)
├─────────────────────────┤
│ 당신의 티어:            │
│ ○ Bronze ○ Silver ◉Gold │
│                         │
│ 플레이 스타일:          │
│ ○ 즐겜  ◉ 빡겜          │
│                         │
│ [         매칭 시작     │
│  ⟳ 애니메이션         ]│
└─────────────────────────┘
```

### 화면 3: 매칭 완료 & 채팅
```
┌─────────────────────────┐
│ 파트너 찾음!            │
│ 🟢 GoldenKnight         │
│    Gold | 빡겜          │
├─────────────────────────┤
│                         │
│ ┌─────────────────────┐ │
│ │ GoldenKnight: 안녕  │ │
│ │ You: 안녕! 밴픽?    │ │
│ │ GoldenKnight: 미드.. │ │
│ └─────────────────────┘ │
│                         │
│ [닉네임 복사] [게임 시작]│
└─────────────────────────┘
```

---

## 6. 1개월 로드맵

### 1주차: 요구사항 구체화 & 프론트엔드 기초
**목표:** 게임 선택 & 매칭 설정 화면 동작

| 날짜 | 과제 | 산출물 |
|------|------|--------|
| 월~수 | 기술 스택 최종 결정, 프로젝트 보일러플레이트 | github repo + 로컬 개발 환경 |
| 목~금 | 게임 선택 그리드 UI 구현 (Tailwind) | 정적 홈 화면 |
| 토~일 | 프로필 필터 화면 UI | 게임/티어/스타일 선택 폼 |

### 2주차: 인증 & 데이터베이스 & 회원 기능
**목표:** 회원가입/로그인 → 프로필 저장 완성

| 날짜 | 과제 | 산출물 |
|------|------|--------|
| 월~수 | DB 스키마 설계 & Supabase/Firebase 프로비저닝 | schema.sql + 테이블 생성 |
| 목~금 | 회원가입/로그인 UI + 백엔드 로직 | 인증 플로우 테스트 |
| 토~일 | 프로필 저장/조회 API | 유저 프로필 저장 & 읽기 |

### 3주차: 핵심 매칭 & 채팅 기능
**목표:** 실제 1:1 매칭 → 채팅 가능까지 전 기능 동작

| 날짜 | 과제 | 산출물 |
|------|------|--------|
| 월~수 | 매칭 알고리즘 구현 (Queue 로직) | 매칭 엔진 백엔드 |
| 목~금 | 실시간 채팅 기능 (WebSocket/Realtime) | 양방향 메시지 송수신 |
| 토~일 | 매너 평가 & 세션 종료 로직 | 리뷰 저장 & 점수 반영 |

### 4주차: 데모 안정화 & 발표 준비
**목표:** 심사용 엔드투엔드 시연 100% 성공

| 날짜 | 과제 | 산출물 |
|------|------|--------|
| 월~수 | 버그 수정 & 성능 최적화 | 안정적인 프로덕션 빌드 |
| 목~금 | 가상 게이머 50명 데이터 생성 스크립트 | seed_data.js + 50명 프로필 |
| 토~일 | 발표자료 & 시연 리허설 | 프레젠테이션 완성 & 백업 시나리오 |

---

## 7. 성공 지표 (KPI)

### 제품 KPI
| 지표 | 목표 | 측정 방법 |
|------|------|---------|
| 평균 매칭 대기시간 | ≤ 10초 (피크 시 ≤ 30초) | 로그 분석 |
| 매칭 성공률 | ≥ 70% (유효한 요청 대비) | (matched_count / total_requests) |
| 채팅 생성 성공률 | ≥ 99% | (session_created / matched) |
| 비매너 신고 처리율 | ≥ 95% | 리뷰 기반 노출 제한 |

### 발표 KPI
| 지표 | 목표 | 검증 |
|------|------|------|
| 데모 플로우 무중단 성공률 | 100% | 리허설 3회 연속 성공 |
| Q&A 대응 준비도 | 100% | 근거 문서 완성 |
| 심사 시간 내 완성 | 100% | 1개월 데드라인 |

---

## 8. 위험요소 & 대응책

| 리스크 | 영향도 | 대응책 |
|--------|--------|--------|
| **피크 시 매칭 지연** | 높음 | 큐 우선순위화, 조건 완화 옵션 사전 제공 |
| **비매너 유저 유입** | 중간 | 시연 데이터는 사전 검증, 평가 점수 기반 노출 제한 |
| **실시간 통신 장애** | 높음 | WebSocket 폴백 (HTTP 롱폴링), 재연결 로직 강화 |
| **발표 중 서버 장애** | 높음 | 로컬 데모 환경 준비, 녹화 백업 영상 |
| **저작권 이슈** | 낮음 | 자체 아이콘 + 게임사 컬러만 사용 |

---

## 9. 체크리스트 (주간)

### 1주차 종료 체크
- [ ] 기술 스택 최종 결정 (React/Supabase 또는 대안)
- [ ] GitHub 저장소 & 개발 환경 구성
- [ ] 홈 화면 정적 UI 완성 (저작권 프리 아이콘)
- [ ] 프로필 필터 폼 완성
- [ ] 코파일럿과 함께 UI 컴포넌트 자동 생성

### 2주차 종료 체크
- [ ] 데이터베이스 스키마 배포 (테이블 5개)
- [ ] 회원가입/로그인 엔드투엔드 테스트
- [ ] 프로필 CRUD 동작 확인
- [ ] 테스트 계정 10개 생성 & 프로필 설정

### 3주차 종료 체크
- [ ] 매칭 알고리즘 구현 & 단위 테스트
- [ ] 실시간 채팅 송수신 성공
- [ ] 매너 평가 저장 & 점수 반영
- [ ] 엔드투엔드 시나리오 테스트 (3회)

### 4주차 종료 체크
- [ ] 전체 기능 통합 테스트 (no bugs)
- [ ] 가상 데이터 50명 생성 & 로드
- [ ] 발표 시뮬레이션 (3회 연속 성공)
- [ ] 발표자료 & 백업 영상 준비

---

## 10. 다음 액션 (오늘)

1. **기술 스택 최종 확정**
   - React + Supabase 추천 (개발 속도 최대화)
   - 또는 React + Firebase (비용 최소화)

2. **개발 환경 설정**
   - `create-react-app` 또는 Vite 초기화
   - Supabase/Firebase 프로젝트 생성
   - GitHub 저장소 초기화

3. **팀 분업**
   - FE Lead: 화면 구현 담당
   - BE Lead: 매칭 알고리즘 & 채팅 로직
   - DevOps: 배포 & 인프라

4. **1주차 마일스톤**
   - 홈 화면 UI 동작 데모 (금요일)
   - 프로필 필터 완성 (일요일)

---

## 11. 성과물 제출 형식

각 주차 종료 시 제출:
```
📦 DuoNow Week {N} Deliverables
├── 📹 데모 영상 (3분, MP4)
├── 🔗 라이브 프리뷰 링크 (Vercel)
├── 📋 완료 체크리스트
├── 🐛 남은 버그 목록
└── 📊 주차별 통계 (코드 라인, 커밋, 이슈 해결)
```

---

**끝. 준비 완료. 1개월 스프린트 시작!** 🚀

