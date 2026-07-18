# DuoNow

실력과 플레이 스타일이 맞는 게이머를 찾기 위한 Flutter + Firebase 듀오 매칭 앱입니다.

## 핵심 기능

- 이메일 로그인 / 회원가입
- Google 로그인
- 휴대폰 OTP 로그인
- 로그인 사용자 프로필 조회 및 저장

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

가장 쉬운 방법은 `flutterfire configure`를 쓰는 것입니다. 이 레포는 `dart-define` 방식도 지원합니다.

```powershell
dart pub global activate flutterfire_cli
flutterfire configure
```

직접 실행할 경우 `flutter run` 뒤에 Firebase 값들을 넘기세요.

```powershell
flutter run --dart-define=FIREBASE_API_KEY=... --dart-define=FIREBASE_APP_ID=... --dart-define=FIREBASE_MESSAGING_SENDER_ID=... --dart-define=FIREBASE_PROJECT_ID=...
```

현재 기본 프로젝트 ID는 `duonow-cabda`로 맞춰 두었습니다.

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
- 실제 서비스에서는 Realtime Database 보안 규칙으로 각 사용자가 자신의 프로필만 읽고 쓰도록 제한하세요.
- Realtime Database 규칙은 [database.rules.json](database.rules.json)에 들어 있습니다.
