# DuoNow

> **"한 판 같이할 듀오, 지금 바로."**  
> 실력과 플레이 스타일이 맞는 게이머를 빠르게 연결하는 실시간 듀오 매칭 플랫폼

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)]()
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%2B%20RTDB-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)

---

## 앱 소개

**DuoNow**는 게임별/티어별/플레이 스타일 기반으로 듀오를 연결해주는 Flutter 앱입니다.  
단순한 매칭을 넘어, 실시간 채팅, 커뮤니티 모집글, 알림 센터, 매칭 히스토리까지 하나의 흐름으로 제공합니다.

### 핵심 가치
- **빠른 매칭 경험**: 조건 기반 큐 탐색으로 즉시 매칭 시도
- **실시간 소통**: 매칭 후 채팅방 자동 연결
- **유연한 탐색**: 티어 인접 허용, 플레이 스타일 완화 등 저트래픽 폴백
- **커뮤니티 확장**: 모집글 기반 직접 듀오 전환

---

## 핵심 기능

### 1) 인증
```text
Email / Google / Phone(OTP) 로그인 지원
├─ 이메일 회원가입 & 로그인
├─ Google OAuth 로그인
└─ 휴대폰 인증번호(OTP) 기반 로그인
```

### 2) 프로필
```text
매칭 품질을 높이는 유저 정보 관리
├─ 닉네임, 게임, 티어, 플레이 스타일 저장
├─ 아바타 URL 입력 또는 이미지 업로드
└─ 사용자별 프로필 실시간 조회/수정
```

### 3) 매칭
```text
RTDB 기반 실시간 듀오 매칭
├─ matchQueue: 대기열 등록
├─ activeMatches: 활성 매칭 상태 관리
├─ 티어/스타일 조건 비교
└─ 저트래픽 시 완화 조건 + 예약 알림 흐름
```

### 4) 채팅 & 매너 평가
```text
매칭 직후 바로 대화 시작
├─ matchMessages 실시간 채팅
├─ 닉네임 복사 UX
└─ matchRatings 기반 매너 평가 저장
```

### 5) 커뮤니티 & 알림
```text
같이할 사람을 먼저 찾는 커뮤니티 허브
├─ 모집글 작성 / 수정 / 삭제
├─ 지원자 신청, 수락/거절
├─ 수락 시 직접 매칭 생성
└─ notifications로 이벤트 알림 누적
```

---

## 스크린샷

### 로그인 화면
![홈 화면](<img width="1920" height="941" alt="스크린샷 2026-07-20 145932" src="https://github.com/user-attachments/assets/012f248b-e531-40ba-9ca3-fa61918e3030" />
)

### 매칭 화면
![매칭 화면](<img width="1920" height="943" alt="스크린샷 2026-07-20 150033" src="https://github.com/user-attachments/assets/72e2f7e7-4f73-4c8d-8e0b-3b82ab065635" />
)

### 커뮤니티 화면
![커뮤니티 화면](<img width="1920" height="944" alt="스크린샷 2026-07-20 150240" src="https://github.com/user-attachments/assets/536a84e7-1723-4718-b395-30b243fa8d8f" />
)

---

## 기술 스택

| 계층 | 기술 |
|------|------|
| Frontend | Flutter (Dart) |
| 인증 | Firebase Authentication |
| 실시간 DB | Firebase Realtime Database |
| 푸시/토큰 | Firebase Messaging |
| 파일 선택 | file_picker |
| 소셜 로그인 | google_sign_in |

---

## 데이터 구조

```text
profiles/{uid}
matchQueue/{uid}
activeMatches/{uid}
matchHistory/{uid}/{matchId}
matchMessages/{matchId}/{messageId}
matchRatings/{matchId}/{raterId}
communityPosts/{postId}
notifications/{uid}/{notificationId}
deviceTokens/{uid}/{tokenKey}
```

---

## 프로젝트 구조

```text
lib/
  main.dart
  src/
    app.dart
    theme.dart
    firebase_options.dart
    models/
      chat_message.dart
      match_session.dart
      profile.dart
    screens/
      auth_screen.dart
      duo_flow_screen.dart
      profile_screen.dart
    services/
      auth_service.dart
      chat_service.dart
      match_service.dart
      notification_service.dart
      profile_service.dart
database.rules.json
firebase.json
```

---

## 로컬 실행

### 요구사항
- Flutter SDK
- Firebase 프로젝트 (Auth + Realtime Database 활성화)

### 설치
```bash
flutter pub get
```

### 실행
```bash
flutter run -d chrome
```

### 빌드
```bash
flutter build web
```

### 분석 / 테스트
```bash
flutter analyze
flutter test
```

---

## Firebase 설정 메모

- Authentication 제공자: Email/Password, Google, Phone 활성화
- Realtime Database 규칙 파일: `database.rules.json`
- 필요 시 설정 재생성:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

---

## 로드맵

### Phase 1
- [x] 인증/프로필/실시간 매칭
- [x] 실시간 채팅
- [x] 커뮤니티 모집글
- [x] 알림 센터

### Phase 2
- [ ] 매칭 정확도 개선(조건 가중치)
- [ ] 사용자 차단/신고 기능
- [ ] 커뮤니티 댓글/답글
- [ ] 푸시 알림 고도화

### Phase 3
- [ ] 게임별 확장 데이터(포지션, 선호 시간대)
- [ ] 추천 기반 자동 듀오 제안
- [ ] 웹/모바일 배포 파이프라인 자동화

---

## 👤 개발자

**최민준** (KKiyatho)  
- GitHub: [@KKiyatho](https://github.com/KKiyatho)
- Email: hellochoi1016@gmail.com

**Made by 최민준**
