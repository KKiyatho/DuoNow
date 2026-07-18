# DuoNow

실력과 플레이 스타일이 맞는 게이머를 찾기 위한 Flutter + Firebase 듀오 매칭 앱입니다.

## 핵심 기능

- 이메일 로그인 / 회원가입
- Google 로그인
- 휴대폰 OTP 로그인
- 로그인 사용자 프로필 조회 및 저장
- 프로필 저장 후 게임 선택 홈 그리드로 이동
- RTDB 기반 듀오 매칭 대기열 및 활성 매칭 화면
- 실시간 채팅, 닉네임 복사, 매너 평가
- 저트래픽 폴백 매칭 안내

## 기술 스택

- Flutter
- Firebase Authentication
- Firebase Realtime Database

## 시작하기

### 1. Flutter 설치 확인

```powershell
flutter --version
```

### 2. Firebase 연결

Firebase 웹 설정은 코드에 이미 반영되어 있어서, 지금은 바로 실행할 수 있습니다.

필요하면 `flutterfire configure`로 다시 생성할 수 있지만, 필수는 아닙니다.

### 3. 의존성 설치

```powershell
flutter pub get
```

### 4. 앱 실행

```powershell
flutter run
```

## 프로젝트 구조

```text
lib/
	main.dart
	src/
		app.dart
		theme.dart
		firebase_options.dart
		models/
			profile.dart
		screens/
			auth_screen.dart
			profile_screen.dart
		services/
			auth_service.dart
			profile_service.dart
```

## Firebase 설정 메모

- Authentication에서 Email/Password, Google, Phone 제공자를 활성화하세요.
- Realtime Database에 `profiles/{uid}` 경로를 저장하도록 구성했습니다.
- 게임 선택과 매칭 흐름은 `matchQueue/{uid}`, `activeMatches/{uid}`, `matchMessages/{matchId}`, `matchRatings/{matchId}`를 사용합니다.
- 매칭 허브는 `matchQueue/{uid}`와 `activeMatches/{uid}`를 사용합니다.
- 실제 서비스에서는 Realtime Database 보안 규칙으로 각 사용자가 자신의 프로필만 읽고 쓰도록 제한하세요.
- Realtime Database 규칙은 [database.rules.json](database.rules.json)에 들어 있습니다.
