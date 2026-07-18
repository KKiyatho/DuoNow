import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../models/profile.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.user});

  final User user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileService = ProfileService(FirebaseDatabase.instance);
  final _authService = AuthService(FirebaseAuth.instance);
  final _nicknameController = TextEditingController();
  final _gameController = TextEditingController();
  final _tierController = TextEditingController();
  final _playStyleController = TextEditingController();
  StreamSubscription? _profileSubscription;
  bool _loading = true;
  bool _saving = false;
  String? _error;
  String? _message;

  @override
  void initState() {
    super.initState();
    _profileSubscription = _profileService.watchProfile(widget.user.uid).listen((profile) {
      if (!mounted || profile == null) {
        if (mounted) {
          setState(() => _loading = false);
        }
        return;
      }

      _nicknameController.text = profile.nickname;
      _gameController.text = profile.game;
      _tierController.text = profile.tier;
      _playStyleController.text = profile.playStyle;

      if (mounted) {
        setState(() => _loading = false);
      }
    });
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    _nicknameController.dispose();
    _gameController.dispose();
    _tierController.dispose();
    _playStyleController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() {
      _saving = true;
      _error = null;
      _message = null;
    });

    try {
      await _profileService.saveProfile(
        widget.user.uid,
        Profile(
          nickname: _nicknameController.text.trim(),
          game: _gameController.text.trim(),
          tier: _tierController.text.trim(),
          playStyle: _playStyleController.text.trim(),
        ),
      );
      setState(() => _message = '프로필이 저장되었습니다.');
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '프로필 설정',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                        TextButton(
                          onPressed: () async => _authService.signOut(),
                          child: const Text('로그아웃'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('로그인 계정: ${widget.user.email ?? 'unknown'}'),
                    const SizedBox(height: 20),
                    if (_loading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else ...[
                      TextField(
                        controller: _nicknameController,
                        decoration: const InputDecoration(labelText: '닉네임'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _gameController,
                        decoration: const InputDecoration(
                          labelText: '게임',
                          hintText: '예: League of Legends',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _tierController,
                        decoration: const InputDecoration(labelText: '티어', hintText: '예: Gold 2'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _playStyleController,
                        decoration: const InputDecoration(
                          labelText: '플레이 스타일',
                          hintText: '예: 공격적, 오더 가능',
                        ),
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
                          onPressed: _saving ? null : _saveProfile,
                          child: Text(_saving ? '저장 중...' : '프로필 저장'),
                        ),
                      ),
                    ],
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
