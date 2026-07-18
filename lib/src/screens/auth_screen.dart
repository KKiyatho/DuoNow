import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _authService = AuthService(FirebaseAuth.instance);
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isSignUp = false;
  bool _phoneMode = false;
  bool _busy = false;
  bool _otpRequested = false;
  String? _verificationId;
  String? _error;
  String? _message;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
      _message = null;
    });

    try {
      await action();
    } on FirebaseAuthException catch (error) {
      setState(() => _error = error.message);
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _submitEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    await _run(() async {
      if (_isSignUp) {
        await _authService.signUpWithEmail(email, password);
        setState(() => _message = '가입이 완료되었습니다. 이메일 인증 후 로그인하세요.');
      } else {
        await _authService.signInWithEmail(email, password);
      }
    });
  }

  Future<void> _submitGoogle() async {
    await _run(_authService.signInWithGoogle);
  }

  Future<void> _requestPhoneOtp() async {
    final phone = _phoneController.text.trim();

    await _run(() async {
      await _authService.signInWithPhoneNumber(
        phoneNumber: phone,
        onCodeSent: (verificationId) {
          setState(() {
            _verificationId = verificationId;
            _otpRequested = true;
            _message = '인증번호를 전송했습니다. 문자로 받은 6자리 코드를 입력하세요.';
          });
        },
        onError: (error) {
          setState(() => _error = error.message);
        },
      );
    });
  }

  Future<void> _confirmPhoneOtp() async {
    final verificationId = _verificationId;
    if (verificationId == null) {
      setState(() => _error = '먼저 인증번호를 요청하세요.');
      return;
    }

    await _run(() async {
      await _authService.verifyPhoneCode(
        verificationId: verificationId,
        smsCode: _otpController.text.trim(),
      );
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DUONOW', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    Text(
                      '실력과 스타일이 맞는 듀오를 빠르게',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '이메일, Google, 휴대폰 인증으로 로그인하고 프로필을 저장할 수 있습니다.',
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _emailController,
                      enabled: !_phoneMode,
                      decoration: const InputDecoration(labelText: '이메일'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      enabled: !_phoneMode,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: '비밀번호'),
                    ),
                    const SizedBox(height: 16),
                    if (_error != null)
                      Text(_error!, style: const TextStyle(color: Color(0xFFFF8D8D))),
                    if (_message != null)
                      Text(_message!, style: const TextStyle(color: Color(0xFF8DE4B3))),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _busy ? null : _submitEmail,
                        child: Text(_busy ? '처리 중...' : (_isSignUp ? '회원가입' : '로그인')),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _busy ? null : _submitGoogle,
                        icon: const _GoogleLogoMark(size: 20),
                        label: const Text('Google로 계속하기'),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1F1F1F),
                          side: const BorderSide(color: Color(0xFFDADCE0)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () {
                              setState(() {
                                _phoneMode = !_phoneMode;
                                _error = null;
                                _message = null;
                              });
                            },
                      child: Text(_phoneMode ? '휴대폰 로그인 닫기' : '휴대폰으로 계속하기'),
                    ),
                    if (_phoneMode) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: '휴대폰 번호',
                          hintText: '+821012345678',
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_otpRequested)
                        TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: '인증번호'),
                        ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _busy ? null : (_otpRequested ? _confirmPhoneOtp : _requestPhoneOtp),
                          child: Text(_otpRequested ? '인증번호 확인' : '인증번호 받기'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: _busy
                            ? null
                            : () {
                                setState(() => _isSignUp = !_isSignUp);
                              },
                        child: Text(_isSignUp ? '이미 계정이 있나요? 로그인' : '처음이신가요? 회원가입'),
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

class _GoogleLogoMark extends StatelessWidget {
  const _GoogleLogoMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.shortestSide * 0.42;
    final ringWidth = size.shortestSide * 0.16;

    final clipRect = Rect.fromCircle(center: center, radius: outerRadius + ringWidth);

    canvas.save();
    canvas.clipRect(clipRect);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: outerRadius),
      -0.75,
      1.48,
      false,
      Paint()
        ..color = const Color(0xFF4285F4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringWidth
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: outerRadius),
      0.78,
      1.36,
      false,
      Paint()
        ..color = const Color(0xFF34A853)
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringWidth
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: outerRadius),
      2.14,
      1.12,
      false,
      Paint()
        ..color = const Color(0xFFFBBC05)
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringWidth
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: outerRadius),
      -3.12,
      1.0,
      false,
      Paint()
        ..color = const Color(0xFFEA4335)
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringWidth
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();

    final erasePaint = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(center.dx + outerRadius * 0.05, center.dy - ringWidth * 0.65, outerRadius * 0.95, ringWidth * 1.3),
        Radius.circular(ringWidth * 0.6),
      ),
      erasePaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(center.dx + outerRadius * 0.04, center.dy - ringWidth * 0.27, outerRadius * 0.62, ringWidth * 0.54),
        Radius.circular(ringWidth * 0.25),
      ),
      Paint()..color = const Color(0xFF4285F4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
