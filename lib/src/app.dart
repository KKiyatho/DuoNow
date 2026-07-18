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
