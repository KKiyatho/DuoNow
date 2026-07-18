import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'screens/auth_screen.dart';
import 'screens/profile_screen.dart';
import 'theme.dart';

class DuoNowApp extends StatelessWidget {
  const DuoNowApp({super.key, required this.firebaseConfigured});

  final bool firebaseConfigured;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DuoNow',
      theme: buildTheme(),
      home: firebaseConfigured ? const _AuthGate() : const _FirebaseSetupScreen(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        final user = snapshot.data;
        if (user == null) {
          return const AuthScreen();
        }

        return ProfileScreen(user: user);
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('서비스 정보를 불러오는 중입니다.'),
          ],
        ),
      ),
    );
  }
}

class _FirebaseSetupScreen extends StatelessWidget {
  const _FirebaseSetupScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E1728),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFF22314C)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Firebase 설정 필요', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 12),
                    const Text(
                      '앱은 실행되지만 Firebase 연결 값이 아직 없습니다. 아래 `dart-define` 값을 넣고 다시 실행하세요.',
                    ),
                    const SizedBox(height: 16),
                    const SelectableText(
                      'flutter run --dart-define=FIREBASE_API_KEY=... '
                      '--dart-define=FIREBASE_APP_ID=... '
                      '--dart-define=FIREBASE_MESSAGING_SENDER_ID=... '
                      '--dart-define=FIREBASE_PROJECT_ID=... '
                      '--dart-define=FIREBASE_AUTH_DOMAIN=... '
                      '--dart-define=FIREBASE_STORAGE_BUCKET=... '
                      '--dart-define=FIREBASE_MEASUREMENT_ID=... '
                      '--dart-define=FIREBASE_IOS_BUNDLE_ID=...',
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '프로젝트를 생성했다면 flutterfire configure로도 자동 생성할 수 있습니다.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(builder: (_) => const _DemoModeScreen()),
                          );
                        },
                        child: const Text('데모 모드로 계속하기'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DemoModeScreen extends StatefulWidget {
  const _DemoModeScreen();

  @override
  State<_DemoModeScreen> createState() => _DemoModeScreenState();
}

class _DemoModeScreenState extends State<_DemoModeScreen> {
  bool _signedIn = false;
  bool _isSignUp = false;
  bool _phoneMode = false;
  bool _otpRequested = false;
  bool _saving = false;
  final _emailController = TextEditingController(text: 'demo@example.com');
  final _passwordController = TextEditingController(text: 'demo1234');
  final _phoneController = TextEditingController(text: '+821012345678');
  final _otpController = TextEditingController();
  final _nicknameController = TextEditingController(text: 'DemoUser');
  final _gameController = TextEditingController(text: 'League of Legends');
  final _tierController = TextEditingController(text: 'Gold 2');
  final _playStyleController = TextEditingController(text: '공격적, 오더 가능');
  String? _message;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _nicknameController.dispose();
    _gameController.dispose();
    _tierController.dispose();
    _playStyleController.dispose();
    super.dispose();
  }

  Future<void> _fakeAction(String message, {bool signedIn = false}) async {
    setState(() {
      _saving = true;
      _message = null;
    });

    await Future<void>.delayed(const Duration(milliseconds: 300));

    setState(() {
      _saving = false;
      _message = message;
      if (signedIn) {
        _signedIn = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E1728),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFF22314C)),
                ),
                child: _signedIn ? _buildProfileForm(context) : _buildAuthForm(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('데모 모드', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Text('Firebase 없이 웹 UI를 먼저 확인할 수 있습니다.', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        const Text('아래 버튼은 실제 로그인 대신 화면 전환만 시험합니다.'),
        const SizedBox(height: 24),
        TextField(controller: _emailController, enabled: !_phoneMode, decoration: const InputDecoration(labelText: '이메일')),
        const SizedBox(height: 12),
        TextField(controller: _passwordController, enabled: !_phoneMode, obscureText: true, decoration: const InputDecoration(labelText: '비밀번호')),
        const SizedBox(height: 16),
        if (_message != null) Text(_message!, style: const TextStyle(color: Color(0xFF8DE4B3))),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _saving ? null : () => _fakeAction(_isSignUp ? '데모 회원가입 완료' : '데모 로그인 완료', signedIn: true),
            child: Text(_saving ? '처리 중...' : (_isSignUp ? '회원가입' : '로그인')),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _saving ? null : () => _fakeAction('Google 데모 로그인 완료', signedIn: true),
            child: const Text('Google로 계속하기'),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _saving
              ? null
              : () {
                  setState(() {
                    _phoneMode = !_phoneMode;
                    _message = null;
                  });
                },
          child: Text(_phoneMode ? '휴대폰 로그인 닫기' : '휴대폰으로 계속하기'),
        ),
        if (_phoneMode) ...[
          const SizedBox(height: 12),
          TextField(controller: _phoneController, decoration: const InputDecoration(labelText: '휴대폰 번호')),
          const SizedBox(height: 12),
          if (_otpRequested)
            TextField(controller: _otpController, decoration: const InputDecoration(labelText: '인증번호')),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving
                  ? null
                  : () {
                      if (_otpRequested) {
                        _fakeAction('데모 전화번호 인증 완료', signedIn: true);
                      } else {
                        setState(() {
                          _otpRequested = true;
                          _message = '데모 인증번호가 전송되었습니다. 아무 숫자나 입력해도 됩니다.';
                        });
                      }
                    },
              child: Text(_otpRequested ? '인증번호 확인' : '인증번호 받기'),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: _saving
                ? null
                : () {
                    setState(() => _isSignUp = !_isSignUp);
                  },
            child: Text(_isSignUp ? '이미 계정이 있나요? 로그인' : '처음이신가요? 회원가입'),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text('프로필 설정', style: Theme.of(context).textTheme.headlineMedium)),
            TextButton(
              onPressed: _saving
                  ? null
                  : () {
                      setState(() => _signedIn = false);
                    },
              child: const Text('로그아웃'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text('데모 사용자: demo@example.com'),
        const SizedBox(height: 20),
        TextField(controller: _nicknameController, decoration: const InputDecoration(labelText: '닉네임')),
        const SizedBox(height: 12),
        TextField(controller: _gameController, decoration: const InputDecoration(labelText: '게임')),
        const SizedBox(height: 12),
        TextField(controller: _tierController, decoration: const InputDecoration(labelText: '티어')),
        const SizedBox(height: 12),
        TextField(controller: _playStyleController, decoration: const InputDecoration(labelText: '플레이 스타일')),
        const SizedBox(height: 16),
        if (_message != null) Text(_message!, style: const TextStyle(color: Color(0xFF8DE4B3))),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _saving
                ? null
                : () async {
                    await _fakeAction('데모 프로필이 저장되었습니다.');
                  },
            child: Text(_saving ? '저장 중...' : '프로필 저장'),
          ),
        ),
      ],
    );
  }
}
