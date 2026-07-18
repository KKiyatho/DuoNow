import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/chat_message.dart';
import '../models/match_session.dart';
import '../models/profile.dart';
import 'profile_screen.dart';
import '../services/chat_service.dart';
import '../services/match_service.dart';
import '../services/profile_service.dart';

class DuoFlowScreen extends StatelessWidget {
  const DuoFlowScreen({super.key, required this.user, required this.profile});

  final User user;
  final Profile profile;

  @override
  Widget build(BuildContext context) {
    return GameHomeScreen(user: user, profile: profile);
  }
}

class GameHomeScreen extends StatefulWidget {
  const GameHomeScreen({super.key, required this.user, required this.profile});

  final User user;
  final Profile profile;

  @override
  State<GameHomeScreen> createState() => _GameHomeScreenState();
}

class _GameHomeScreenState extends State<GameHomeScreen> {
  final _profileService = ProfileService(FirebaseDatabase.instance);

  late String _selectedGame;
  late String _selectedTier;
  late String _selectedStyle;

  final _games = const [
    _GameOption('League of Legends', Icons.shield_rounded, Color(0xFF1E2A4A)),
    _GameOption('VALORANT', Icons.gps_fixed_rounded, Color(0xFF3A1720)),
    _GameOption('Overwatch 2', Icons.all_inclusive_rounded, Color(0xFF24324B)),
    _GameOption('Apex Legends', Icons.flight_takeoff_rounded, Color(0xFF3A2417)),
    _GameOption('PUBG', Icons.crop_square_rounded, Color(0xFF1E2B3D)),
    _GameOption('Fortnite', Icons.extension_rounded, Color(0xFF2A1E4A)),
  ];

  static const _tiers = [
    'Iron',
    'Bronze',
    'Silver',
    'Gold',
    'Platinum',
    'Diamond',
    'Master',
    'Challenger',
  ];

  static const _styles = [
    '빡겜',
    '즐겜',
    '오더 가능',
    '디스코드 필수',
  ];

  @override
  void initState() {
    super.initState();
    _selectedGame = widget.profile.game.isEmpty ? _games.first.name : widget.profile.game;
    _selectedTier = widget.profile.tier.isEmpty ? _tiers[3] : widget.profile.tier;
    _selectedStyle = widget.profile.playStyle.isEmpty ? _styles.first : widget.profile.playStyle;
  }

  Future<void> _continue() async {
    final updatedProfile = widget.profile.copyWith(
      game: _selectedGame,
      tier: _selectedTier,
      playStyle: _selectedStyle,
    );

    await _profileService.saveProfile(widget.user.uid, updatedProfile);
    if (!mounted) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MatchFilterScreen(user: widget.user, profile: updatedProfile),
      ),
    );
  }

  Future<void> _openProfile() async {
    final updated = await Navigator.of(context).push<Profile>(
      MaterialPageRoute<Profile>(
        builder: (_) => ProfileScreen(user: widget.user),
      ),
    );
    if (!mounted || updated == null) {
      return;
    }

    setState(() {
      _selectedGame = updated.game.isEmpty ? _selectedGame : updated.game;
      _selectedTier = updated.tier.isEmpty ? _selectedTier : updated.tier;
      _selectedStyle = updated.playStyle.isEmpty ? _selectedStyle : updated.playStyle;
    });
  }

  void _openHistory() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MatchHistoryScreen(user: widget.user, profile: widget.profile),
      ),
    );
  }

  void _openCommunity() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CommunityBoardScreen(user: widget.user, profile: widget.profile),
      ),
    );
  }

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NotificationCenterScreen(user: widget.user, profile: widget.profile),
      ),
    );
  }

  Future<void> _openSettings() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('프로필 수정'),
                onTap: () {
                  Navigator.of(context).pop();
                  _openProfile();
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('로그아웃'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await FirebaseAuth.instance.signOut();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _AtmosphereBackground(),
          SafeArea(
            child: Column(
              children: [
                _NeoTopBar(
                  active: 'Home',
                  nickname: widget.profile.nickname,
                  avatarUrl: widget.profile.avatarUrl,
                  onHome: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('현재 Home 화면입니다.')),
                    );
                  },
                  onProfile: _openProfile,
                  onCommunity: _openCommunity,
                  onHistory: _openHistory,
                  onNotifications: _openNotifications,
                  onSettings: _openSettings,
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1120),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0566D9).withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(color: const Color(0xFFADC6FF).withValues(alpha: 0.5)),
                                    ),
                                    child: const Text('14,204 PLAYERS ONLINE', style: TextStyle(letterSpacing: 1.2, fontSize: 12, color: Color(0xFFADC6FF))),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Select Your Arena',
                                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '플레이할 게임과 실력을 선택하고, 맞춤 듀오를 초고속으로 찾아보세요.',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: const Color(0xFFC6C6CD)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            _GlassPanel(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final crossAxisCount = constraints.maxWidth >= 700 ? 2 : 1;
                                  return GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: _games.length,
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      mainAxisSpacing: 14,
                                      crossAxisSpacing: 14,
                                      childAspectRatio: 2.18,
                                    ),
                                    itemBuilder: (context, index) {
                                      final game = _games[index];
                                      final selected = _selectedGame == game.name;
                                      return InkWell(
                                        onTap: () => setState(() => _selectedGame = game.name),
                                        borderRadius: BorderRadius.circular(18),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 180),
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                game.color.withValues(alpha: selected ? 0.45 : 0.26),
                                                const Color(0xFF0F172A).withValues(alpha: 0.92),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(18),
                                            border: Border.all(color: selected ? const Color(0xFFADC6FF) : const Color(0xFF323537), width: selected ? 1.6 : 1),
                                            boxShadow: selected
                                                ? const [BoxShadow(color: Color(0x440566D9), blurRadius: 20, spreadRadius: 1)]
                                                : null,
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 54,
                                                height: 54,
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius.circular(14),
                                                ),
                                                child: Icon(game.icon, color: const Color(0xFFE0E3E5), size: 30),
                                              ),
                                              const SizedBox(width: 14),
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(game.name, style: Theme.of(context).textTheme.titleLarge),
                                                    const SizedBox(height: 4),
                                                    Text(selected ? 'Selected' : 'Tap to select', style: const TextStyle(color: Color(0xFFC6C6CD))),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            _GlassPanel(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _SectionTitle(label: 'Select Your Tier'),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: _tiers.map((tier) {
                                      return ChoiceChip(
                                        label: Text(tier),
                                        selected: _selectedTier == tier,
                                        onSelected: (_) => setState(() => _selectedTier = tier),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 16),
                                  _SectionTitle(label: 'Play Style'),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: _styles.map((style) {
                                      return ChoiceChip(
                                        label: Text('#$style'),
                                        selected: _selectedStyle == style,
                                        onSelected: (_) => setState(() => _selectedStyle = style),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF101B2D),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: const Color(0xFF323537)),
                                    ),
                                    child: Text('$_selectedGame  ·  $_selectedTier  ·  $_selectedStyle', style: const TextStyle(color: Color(0xFFE0E3E5))),
                                  ),
                                  const SizedBox(height: 14),
                                  SizedBox(
                                    width: double.infinity,
                                    child: FilledButton.icon(
                                      onPressed: _continue,
                                      icon: const Icon(Icons.rocket_launch_rounded),
                                      label: const Text('Launch Global Search'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('프로필로 돌아가기'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const _NeoFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MatchFilterScreen extends StatefulWidget {
  const MatchFilterScreen({super.key, required this.user, required this.profile});

  final User user;
  final Profile profile;

  @override
  State<MatchFilterScreen> createState() => _MatchFilterScreenState();
}

class _MatchFilterScreenState extends State<MatchFilterScreen> {
  final _matchService = MatchService(FirebaseDatabase.instance);
  bool _matching = false;
  bool _queued = false;
  bool _allowAdjacentTier = false;
  bool _expandRegion = false;
  bool _reservable = false;
  bool _attempting = false;
  bool _reservationNotified = false;
  String _stageText = '매칭 버튼을 누르면 후보 탐색이 시작됩니다.';
  String? _error;
  Timer? _timer;
  Timer? _autoRetryTimer;
  DateTime? _startedAt;

  @override
  void dispose() {
    _timer?.cancel();
    _autoRetryTimer?.cancel();
    super.dispose();
  }

  Future<void> _startMatching() async {
    setState(() {
      _matching = true;
      _queued = false;
      _error = null;
      _startedAt = DateTime.now();
      _stageText = '0~15초: 완전일치 조건으로 검색 중';
      _reservable = false;
      _reservationNotified = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateStage());
    _autoRetryTimer?.cancel();
    _autoRetryTimer = Timer.periodic(const Duration(seconds: 8), (_) => _autoRetry());

    try {
      final match = await _attemptMatch();
      if (!mounted) {
        return;
      }

      if (match == null) {
        setState(() {
          _matching = false;
          _queued = true;
          _stageText = '대기열에 등록되었습니다. 같은 조건의 상대를 기다리는 중입니다.';
        });
        return;
      }

      _openChat(match);
    } catch (error) {
      if (!mounted) {
        return;
      }

      final rawError = error.toString();
      final denied = rawError.contains('permission-denied') || rawError.contains('Permission denied');
      setState(() {
        _matching = false;
        _attempting = false;
        _error = denied
            ? 'Realtime Database 권한이 거부되었습니다. Firebase 콘솔에서 rules를 반영한 뒤 다시 시도하세요.\n실행 명령: firebase deploy --only database'
            : rawError;
      });
    }
  }

  Future<MatchSession?> _attemptMatch() async {
    if (_attempting) {
      return null;
    }

    _attempting = true;
    try {
      return await _matchService.startMatching(
        uid: widget.user.uid,
        profile: widget.profile,
        allowAdjacentTier: _allowAdjacentTier,
        allowPlayStyleMismatch: _expandRegion,
      );
    } finally {
      _attempting = false;
    }
  }

  Future<void> _autoRetry() async {
    if (!mounted || !_queued) {
      return;
    }

    final match = await _attemptMatch();
    if (!mounted || match == null) {
      return;
    }
    _openChat(match);
  }

  Future<void> _openProfile() async {
    await Navigator.of(context).push<Profile>(
      MaterialPageRoute<Profile>(
        builder: (_) => ProfileScreen(user: widget.user),
      ),
    );
  }

  void _openHistory() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MatchHistoryScreen(user: widget.user, profile: widget.profile),
      ),
    );
  }

  void _openCommunity() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CommunityBoardScreen(user: widget.user, profile: widget.profile),
      ),
    );
  }

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NotificationCenterScreen(user: widget.user, profile: widget.profile),
      ),
    );
  }

  Future<void> _openSettings() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('프로필 수정'),
                onTap: () {
                  Navigator.of(context).pop();
                  _openProfile();
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('로그아웃'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await FirebaseAuth.instance.signOut();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateStage() {
    if (!mounted || _startedAt == null) {
      return;
    }

    final elapsed = DateTime.now().difference(_startedAt!).inSeconds;
    setState(() {
      if (elapsed < 15) {
        _stageText = '0~15초: 완전일치 조건으로 검색 중';
      } else if (elapsed < 45) {
        _stageText = '15~45초: 인접 티어 1단계 확장 가능';
        _allowAdjacentTier = true;
      } else if (elapsed < 90) {
        _stageText = '45~90초: 지역 범위 확장과 예약 매칭 제안';
        _expandRegion = true;
      } else {
        _stageText = '90초+: 예약 매칭 또는 친구 초대 링크를 안내합니다.';
        _reservable = true;
      }
    });

    if (elapsed >= 15 && _queued) {
      _autoRetry();
    }

    if (elapsed >= 90 && !_reservationNotified) {
      _reservationNotified = true;
      _sendReservationNudge();
    }
  }

  Future<void> _sendReservationNudge() async {
    await _matchService.createReservationNudge(
      uid: widget.user.uid,
      game: widget.profile.game,
      tier: widget.profile.tier,
      playStyle: widget.profile.playStyle,
    );
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('예약 매칭 알림을 설정했어요. 매칭되면 알림센터로 알려드립니다.')),
    );
  }

  String _buildInviteLink() {
    final params = <String, String>{
      'host': widget.user.uid,
      'game': widget.profile.game,
      'tier': widget.profile.tier,
      'style': widget.profile.playStyle,
    };
    return Uri.https('duonow.app', '/invite', params).toString();
  }

  Future<void> _copyInviteLink() async {
    final link = _buildInviteLink();
    await Clipboard.setData(ClipboardData(text: link));
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('친구 초대 링크를 복사했습니다.')),
    );
  }

  void _openChat(MatchSession match) {
    _timer?.cancel();
    _autoRetryTimer?.cancel();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ChatRoomScreen(
          user: widget.user,
          profile: widget.profile,
          match: match,
        ),
      ),
    );
  }

  Future<void> _retryWithRelaxedTier() async {
    setState(() => _allowAdjacentTier = true);
    await _startMatching();
  }

  Future<void> _cancelQueue() async {
    await _matchService.cancelQueue(widget.user.uid);
    _timer?.cancel();
    _autoRetryTimer?.cancel();
    if (!mounted) {
      return;
    }

    setState(() {
      _matching = false;
      _queued = false;
      _attempting = false;
      _stageText = '대기를 취소했습니다.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    return Scaffold(
      body: Stack(
        children: [
          const _AtmosphereBackground(),
          SafeArea(
            child: Column(
              children: [
                _NeoTopBar(
                  active: 'Home',
                  nickname: widget.profile.nickname,
                  avatarUrl: widget.profile.avatarUrl,
                  onHome: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  onProfile: _openProfile,
                  onCommunity: _openCommunity,
                  onHistory: _openHistory,
                  onNotifications: _openNotifications,
                  onSettings: _openSettings,
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1120),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: _GlassPanel(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('조건 필터 및 매칭', style: Theme.of(context).textTheme.headlineMedium),
                                    const SizedBox(height: 10),
                                    Text('${profile.nickname}님의 ${profile.game} 조건을 기준으로 상대를 찾습니다.', style: const TextStyle(color: Color(0xFFC6C6CD))),
                                    const SizedBox(height: 18),
                                    _InfoRow(label: '게임', value: profile.game),
                                    _InfoRow(label: '티어', value: profile.tier),
                                    _InfoRow(label: '플레이 스타일', value: profile.playStyle),
                                    const SizedBox(height: 12),
                                    SwitchListTile(
                                      value: _allowAdjacentTier,
                                      onChanged: (value) => setState(() => _allowAdjacentTier = value),
                                      title: const Text('인접 티어 1단계 허용'),
                                      subtitle: const Text('저트래픽 시간대에는 조건을 완화합니다.'),
                                    ),
                                    SwitchListTile(
                                      value: _expandRegion,
                                      onChanged: (value) => setState(() => _expandRegion = value),
                                      title: const Text('지역 범위 확장'),
                                      subtitle: const Text('예약 매칭 단계에서 글로벌 탐색으로 전환합니다.'),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF101B2D),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: const Color(0xFF323537)),
                                      ),
                                      child: Text(_stageText, style: const TextStyle(color: Color(0xFFADC6FF))),
                                    ),
                                    if (_error != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(_error!, style: const TextStyle(color: Color(0xFFFF8D8D))),
                                      ),
                                    const SizedBox(height: 14),
                                    SizedBox(
                                      width: double.infinity,
                                      child: FilledButton.icon(
                                        onPressed: _matching ? null : _startMatching,
                                        icon: Icon(_matching ? Icons.sync : Icons.rocket_launch_rounded),
                                        label: Text(_matching ? 'Scanning...' : '매칭 시작'),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    if (_queued)
                                      SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton(
                                          onPressed: _cancelQueue,
                                          child: const Text('대기 취소'),
                                        ),
                                      ),
                                    if (_reservable)
                                      SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton(
                                          onPressed: _retryWithRelaxedTier,
                                          child: const Text('예약 매칭 / 완화 재시도'),
                                        ),
                                      ),
                                    if (_queued || _reservable) ...[
                                      const SizedBox(height: 12),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: const Color(0x220566D9),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(color: const Color(0x880566D9)),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('저트래픽 모드: 팀원 모집 커뮤니티', style: TextStyle(fontWeight: FontWeight.w700)),
                                            const SizedBox(height: 6),
                                            const Text('즉시 매칭이 어려우면 공고를 올려 팀원을 모집하고, 알림으로 참여자를 받아보세요.'),
                                            const SizedBox(height: 10),
                                            SizedBox(
                                              width: double.infinity,
                                              child: FilledButton.icon(
                                                onPressed: _openCommunity,
                                                icon: const Icon(Icons.campaign_outlined),
                                                label: const Text('팀원 모집 공고 올리기'),
                                              ),
                                            ),
                                            if (_reservable) ...[
                                              const SizedBox(height: 8),
                                              SizedBox(
                                                width: double.infinity,
                                                child: OutlinedButton.icon(
                                                  onPressed: _copyInviteLink,
                                                  icon: const Icon(Icons.link_rounded),
                                                  label: const Text('친구 초대 링크 복사'),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text('게임 선택으로 돌아가기'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 7,
                              child: _GlassPanel(
                                child: _RadarMatcher(
                                  matching: _matching,
                                  status: _matching ? 'Finding elite partners in your region...' : 'Press start to launch search',
                                  onTap: _matching ? _cancelQueue : _startMatching,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const _NeoFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({super.key, required this.user, required this.profile, required this.match});

  final User user;
  final Profile profile;
  final MatchSession match;

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _chatService = ChatService(FirebaseDatabase.instance);
  final _matchService = MatchService(FirebaseDatabase.instance);
  final _textController = TextEditingController();
  late final Stream<List<ChatMessage>> _messagesStream;
  bool _sending = false;
  bool? _positiveRating;

  @override
  void initState() {
    super.initState();
    _messagesStream = _chatService.watchMessages(widget.match.matchId);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      return;
    }

    setState(() => _sending = true);
    try {
      await _chatService.sendMessage(
        matchId: widget.match.matchId,
        senderId: widget.user.uid,
        senderNickname: widget.profile.nickname,
        text: text,
      );
      _textController.clear();
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  Future<void> _ratePartner(bool positive) async {
    await _chatService.submitRating(
      matchId: widget.match.matchId,
      raterId: widget.user.uid,
      targetId: widget.match.partnerId,
      isPositive: positive,
    );
    if (!mounted) {
      return;
    }

    setState(() => _positiveRating = positive);
  }

  Future<void> _copyNickname() async {
    await Clipboard.setData(ClipboardData(text: widget.match.partnerNickname));
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('게임 닉네임을 복사했습니다.')),
    );
  }

  Future<void> _openProfile() async {
    await Navigator.of(context).push<Profile>(
      MaterialPageRoute<Profile>(
        builder: (_) => ProfileScreen(user: widget.user),
      ),
    );
  }

  void _openHistory() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MatchHistoryScreen(user: widget.user, profile: widget.profile),
      ),
    );
  }

  void _openCommunity() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CommunityBoardScreen(user: widget.user, profile: widget.profile),
      ),
    );
  }

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NotificationCenterScreen(user: widget.user, profile: widget.profile),
      ),
    );
  }

  Future<void> _openSettings() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('프로필 수정'),
                onTap: () {
                  Navigator.of(context).pop();
                  _openProfile();
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('로그아웃'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await FirebaseAuth.instance.signOut();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _AtmosphereBackground(),
          SafeArea(
            child: Column(
              children: [
                _NeoTopBar(
                  active: 'History',
                  nickname: widget.profile.nickname,
                  avatarUrl: widget.profile.avatarUrl,
                  onHome: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  onProfile: _openProfile,
                  onCommunity: _openCommunity,
                  onHistory: _openHistory,
                  onNotifications: _openNotifications,
                  onSettings: _openSettings,
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1120),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                        child: _GlassPanel(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('매칭 완료 및 채팅', style: Theme.of(context).textTheme.headlineMedium),
                              const SizedBox(height: 10),
                              Text('${widget.match.partnerNickname}님과 연결되었습니다.', style: const TextStyle(color: Color(0xFFC6C6CD))),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  _StatChip(label: '게임', value: widget.match.game),
                                  _StatChip(label: '상대 티어', value: widget.match.tier),
                                  _StatChip(label: '성향', value: widget.match.playStyle),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text('상대 닉네임: ${widget.match.partnerNickname}', style: Theme.of(context).textTheme.titleLarge),
                                  ),
                                  TextButton(
                                    onPressed: _copyNickname,
                                    child: const Text('게임 닉네임 복사하기'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF101B2D),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: const Color(0xFF323537)),
                                  ),
                                  child: StreamBuilder<List<ChatMessage>>(
                                    stream: _messagesStream,
                                    builder: (context, snapshot) {
                                      final messages = snapshot.data ?? const <ChatMessage>[];
                                      return ListView.builder(
                                        itemCount: messages.length,
                                        itemBuilder: (context, index) {
                                          final message = messages[index];
                                          final isMine = message.senderId == widget.user.uid;
                                          return Align(
                                            alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                                            child: Container(
                                              margin: const EdgeInsets.only(bottom: 10),
                                              padding: const EdgeInsets.all(12),
                                              constraints: const BoxConstraints(maxWidth: 420),
                                              decoration: BoxDecoration(
                                                color: isMine ? const Color(0xFF0566D9) : const Color(0xFF1A2436),
                                                borderRadius: BorderRadius.circular(14),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                                children: [
                                                  Text(message.senderNickname, style: Theme.of(context).textTheme.labelLarge),
                                                  const SizedBox(height: 4),
                                                  Text(message.text),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _textController,
                                      decoration: const InputDecoration(
                                        labelText: '실시간 텍스트',
                                        hintText: '대화 내용을 입력하세요',
                                      ),
                                      minLines: 1,
                                      maxLines: 3,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  FilledButton(
                                    onPressed: _sending ? null : _send,
                                    child: Text(_sending ? '전송 중' : '전송'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF101B2D),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFF323537)),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _positiveRating == null ? '매너 평가를 남겨주세요.' : (_positiveRating == true ? '좋아요를 남겼습니다.' : '싫어요를 남겼습니다.'),
                                        style: const TextStyle(color: Color(0xFFC6C6CD)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    FilledButton(
                                      onPressed: _positiveRating == null ? () => _ratePartner(true) : null,
                                      child: const Text('좋아요'),
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton(
                                      onPressed: _positiveRating == null ? () => _ratePartner(false) : null,
                                      child: const Text('싫어요'),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () async {
                                    await _matchService.endMatch(uid: widget.user.uid, partnerUid: widget.match.partnerId);
                                    if (!context.mounted) {
                                      return;
                                    }
                                    Navigator.of(context).popUntil((route) => route.isFirst);
                                  },
                                  child: const Text('매칭 허브로 돌아가기'),
                                ),
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: TextButton(
                                  onPressed: () async {
                                    await Clipboard.setData(ClipboardData(text: 'DuoNow/${widget.match.matchId}'));
                                    if (!context.mounted) {
                                      return;
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('친구 초대 링크용 코드를 복사했습니다.')),
                                    );
                                  },
                                  child: const Text('친구 초대 링크 복사'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const _NeoFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AtmosphereBackground extends StatelessWidget {
  const _AtmosphereBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.65, -0.55),
          radius: 1.5,
          colors: [
            Color(0x33234A8B),
            Color(0xFF101415),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            left: -40,
            child: Container(
              width: 260,
              height: 260,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [Color(0x333B82F6), Colors.transparent]),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -70,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [Color(0x22D0BCFF), Colors.transparent]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0x55101415),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x1AFFFFFF)),
      ),
      child: child,
    );
  }
}

class _NeoTopBar extends StatelessWidget {
  const _NeoTopBar({
    required this.active,
    this.nickname,
    this.avatarUrl,
    this.onHome,
    this.onProfile,
    this.onCommunity,
    this.onHistory,
    this.onNotifications,
    this.onSettings,
  });

  final String active;
  final String? nickname;
  final String? avatarUrl;
  final VoidCallback? onHome;
  final VoidCallback? onProfile;
  final VoidCallback? onCommunity;
  final VoidCallback? onHistory;
  final VoidCallback? onNotifications;
  final VoidCallback? onSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x80101415),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Row(
        children: [
          const Text('DuoNow', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(width: 24),
          _TopTab(label: 'Home', active: active == 'Home', onTap: onHome),
          const SizedBox(width: 10),
          _TopTab(label: 'Profile', active: active == 'Profile', onTap: onProfile),
          const SizedBox(width: 10),
          _TopTab(label: 'Community', active: active == 'Community', onTap: onCommunity, emphasized: true),
          const SizedBox(width: 10),
          _TopTab(label: 'History', active: active == 'History', onTap: onHistory),
          const Spacer(),
          IconButton(onPressed: onNotifications, icon: const Icon(Icons.notifications_none_rounded)),
          IconButton(onPressed: onSettings, icon: const Icon(Icons.settings_outlined)),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 14,
            backgroundColor: const Color(0xFF22314C),
            backgroundImage: _avatarImageProvider(avatarUrl),
            child: avatarUrl != null && avatarUrl!.trim().isNotEmpty
                ? null
                : Text(
                    ((nickname ?? 'U').trim().isEmpty ? 'U' : (nickname ?? 'U').trim().substring(0, 1)).toUpperCase(),
                    style: const TextStyle(fontSize: 12),
                  ),
          ),
        ],
      ),
    );
  }
}

class _TopTab extends StatelessWidget {
  const _TopTab({required this.label, required this.active, this.onTap, this.emphasized = false});

  final String label;
  final bool active;
  final VoidCallback? onTap;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: active
                ? const Color(0x220566D9)
                : (emphasized ? const Color(0x140566D9) : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: active
                  ? const Color(0x660566D9)
                  : (emphasized ? const Color(0x440566D9) : Colors.transparent),
            ),
          ),
          child: Text(label, style: TextStyle(color: active ? const Color(0xFFADC6FF) : const Color(0xFFC6C6CD))),
        ),
      ),
    );
  }
}

ImageProvider? _avatarImageProvider(String? avatarUrl) {
  if (avatarUrl == null || avatarUrl.trim().isEmpty) {
    return null;
  }

  final value = avatarUrl.trim();
  if (value.startsWith('data:image') && value.contains(',')) {
    final comma = value.indexOf(',');
    if (comma > -1) {
      try {
        final bytes = base64Decode(value.substring(comma + 1));
        return MemoryImage(bytes);
      } catch (_) {
        return null;
      }
    }
  }

  return NetworkImage(value);
}

class _NeoFooter extends StatelessWidget {
  const _NeoFooter();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 10, top: 2),
      child: Text('Copyright 2026 DuoNow', style: TextStyle(color: Color(0xFF909097))),
    );
  }
}

class MatchHistoryScreen extends StatelessWidget {
  MatchHistoryScreen({super.key, required this.user, required this.profile});

  final User user;
  final Profile profile;
  final MatchService _matchService = MatchService(FirebaseDatabase.instance);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _AtmosphereBackground(),
          SafeArea(
            child: Column(
              children: [
                _NeoTopBar(
                  active: 'History',
                  nickname: profile.nickname,
                  avatarUrl: profile.avatarUrl,
                  onHome: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  onCommunity: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => CommunityBoardScreen(user: user, profile: profile),
                      ),
                    );
                  },
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                    child: _GlassPanel(
                      child: StreamBuilder<List<Map<String, dynamic>>>(
                        stream: _matchService.watchHistory(user.uid),
                        builder: (context, snapshot) {
                          final items = snapshot.data ?? const <Map<String, dynamic>>[];
                          if (items.isEmpty) {
                            return const Center(child: Text('아직 매칭 히스토리가 없습니다.'));
                          }

                          return ListView.separated(
                            itemCount: items.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = items[index];
                              final updatedAt = DateTime.fromMillisecondsSinceEpoch((item['updatedAt'] as int?) ?? 0);
                              return Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF101B2D),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0x1AFFFFFF)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${item['game'] ?? ''} · ${item['partnerNickname'] ?? ''}', style: Theme.of(context).textTheme.titleMedium),
                                    const SizedBox(height: 6),
                                    Text('티어: ${item['tier'] ?? '-'} · 성향: ${item['playStyle'] ?? '-'}'),
                                    const SizedBox(height: 6),
                                    Text('상태: ${item['status'] ?? 'active'} · ${updatedAt.toLocal()}'),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const _NeoFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CommunityBoardScreen extends StatefulWidget {
  const CommunityBoardScreen({super.key, required this.user, required this.profile});

  final User user;
  final Profile profile;

  @override
  State<CommunityBoardScreen> createState() => _CommunityBoardScreenState();
}

class _CommunityBoardScreenState extends State<CommunityBoardScreen> {
  final MatchService _matchService = MatchService(FirebaseDatabase.instance);
  final ProfileService _profileService = ProfileService(FirebaseDatabase.instance);
  String? _gameFilter;

  Future<void> _applyApplicantDecision({
    required String postId,
    required String applicantUid,
    required String status,
  }) async {
    final ok = await _matchService.updateCommunityApplicantStatus(
      ownerUid: widget.user.uid,
      postId: postId,
      applicantUid: applicantUid,
      status: status,
    );
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? (status == 'accepted' ? '지원자를 수락했습니다.' : '지원자를 거절했습니다.') : '처리에 실패했습니다. 내 공고인지 확인 후 다시 시도하세요.'),
      ),
    );
  }

  Future<void> _requestJoinPost({
    required String postId,
  }) async {
    final ok = await _matchService.joinCommunityPost(
      uid: widget.user.uid,
      nickname: widget.profile.nickname,
      postId: postId,
    );
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? '참여 신청이 접수되었습니다.' : '이미 참여했거나 처리할 수 없는 공고입니다.'),
      ),
    );
  }

  Future<void> _openCreatePost() async {
    await _openPostEditor();
  }

  Future<void> _openPostEditor({
    String? postId,
    String? initialTitle,
    String? initialContent,
  }) async {
    final editing = postId != null;
    final titleController = TextEditingController(text: initialTitle ?? '${widget.profile.game} 듀오 구해요');
    final contentController = TextEditingController(text: initialContent ?? '현재 ${widget.profile.tier} / ${widget.profile.playStyle} 입니다. 함께 랭크 하실 분!');

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(editing ? '공고 수정' : '팀원 모집 공고 등록'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: '제목')),
                const SizedBox(height: 10),
                TextField(
                  controller: contentController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: '내용'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('취소')),
            FilledButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final content = contentController.text.trim();
                if (title.isEmpty || content.isEmpty) {
                  return;
                }

                if (editing) {
                  await _matchService.updateCommunityPost(
                    uid: widget.user.uid,
                    postId: postId,
                    title: title,
                    content: content,
                  );
                } else {
                  await _matchService.createCommunityPost(
                    uid: widget.user.uid,
                    nickname: widget.profile.nickname,
                    game: widget.profile.game,
                    tier: widget.profile.tier,
                    playStyle: widget.profile.playStyle,
                    title: title,
                    content: content,
                  );
                }
                if (!context.mounted) {
                  return;
                }
                Navigator.of(context).pop();
              },
              child: Text(editing ? '저장' : '등록'),
            ),
          ],
        );
      },
    );

    titleController.dispose();
    contentController.dispose();
  }

  Future<void> _deletePost(String postId) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('공고 삭제'),
              content: const Text('이 공고를 삭제할까요?'),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('취소')),
                FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('삭제')),
              ],
            );
          },
        ) ??
        false;
    if (!confirmed) {
      return;
    }

    final ok = await _matchService.deleteCommunityPost(uid: widget.user.uid, postId: postId);
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? '공고를 삭제했습니다.' : '삭제에 실패했습니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _AtmosphereBackground(),
          SafeArea(
            child: Column(
              children: [
                _NeoTopBar(
                  active: 'Community',
                  nickname: widget.profile.nickname,
                  avatarUrl: widget.profile.avatarUrl,
                  onHome: () => Navigator.of(context).popUntil((route) => route.isFirst),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                    child: _GlassPanel(
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0x220566D9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0x880566D9)),
                            ),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Text('커뮤니티 공고'),
                                ),
                                const SizedBox(width: 10),
                                FilledButton.icon(
                                  onPressed: _openCreatePost,
                                  icon: const Icon(Icons.campaign_outlined),
                                  label: const Text('공고 등록'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ChoiceChip(
                                  label: const Text('전체'),
                                  selected: _gameFilter == null,
                                  onSelected: (_) => setState(() => _gameFilter = null),
                                ),
                                ChoiceChip(
                                  label: Text(widget.profile.game.isEmpty ? '내 게임' : widget.profile.game),
                                  selected: _gameFilter == widget.profile.game,
                                  onSelected: (_) => setState(() => _gameFilter = widget.profile.game),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: StreamBuilder<List<Map<String, dynamic>>>(
                              stream: _matchService.watchCommunityPosts(game: _gameFilter),
                              builder: (context, snapshot) {
                                final items = snapshot.data ?? const <Map<String, dynamic>>[];
                                if (items.isEmpty) {
                                  return const Center(child: Text('등록된 모집 공고가 없습니다. 첫 공고를 올려보세요.'));
                                }

                                return ListView.separated(
                                  itemCount: items.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    final item = items[index];
                                    final postId = (item['id'] as String?) ?? '';
                                    final ownerId = (item['ownerId'] ?? '').toString();
                                    final isOwner = ownerId == widget.user.uid;
                                    final participants = item['participants'] is Map
                                        ? Map<String, dynamic>.from(item['participants'] as Map)
                                        : <String, dynamic>{};
                                    final joined = participants[widget.user.uid] == true;
                                    final applicants = item['applicants'] is Map
                                        ? Map<String, dynamic>.from(item['applicants'] as Map)
                                        : <String, dynamic>{};
                                    final applicantEntries = applicants.entries.toList();
                                    final pendingEntries = applicantEntries
                                      .where((entry) => entry.value is Map && (entry.value['status'] as String?) == 'pending')
                                      .toList();
                                    final acceptedUids = applicantEntries
                                        .where((entry) {
                                          final value = entry.value;
                                          return value is Map && (value['status'] as String?) == 'accepted';
                                        })
                                        .map((entry) => entry.key.toString())
                                        .toList();
                                    return Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF101B2D),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0x2AFFFFFF)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text((item['title'] as String?) ?? '모집 공고', style: Theme.of(context).textTheme.titleMedium),
                                              ),
                                              if (isOwner) ...[
                                                IconButton(
                                                  tooltip: '수정',
                                                  onPressed: postId.isEmpty
                                                      ? null
                                                      : () => _openPostEditor(
                                                            postId: postId,
                                                            initialTitle: (item['title'] as String?) ?? '',
                                                            initialContent: (item['content'] as String?) ?? '',
                                                          ),
                                                  icon: const Icon(Icons.edit_outlined),
                                                ),
                                                IconButton(
                                                  tooltip: '삭제',
                                                  onPressed: postId.isEmpty ? null : () => _deletePost(postId),
                                                  icon: const Icon(Icons.delete_outline),
                                                ),
                                              ],
                                            ],
                                          ),
                                          Text(
                                            (item['content'] as String?) ?? '',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Text('작성자 ${item['ownerNickname'] ?? '-'} · 지원 ${item['applicantCount'] ?? 0}명 · ${item['tier'] ?? '-'}'),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: const Color(0x220566D9),
                                                  borderRadius: BorderRadius.circular(999),
                                                ),
                                                child: Text('${item['game'] ?? '-'} · ${item['playStyle'] ?? '-'}', style: const TextStyle(fontSize: 12)),
                                              ),
                                              const Spacer(),
                                              if (isOwner)
                                                const Text('내 공고')
                                              else
                                                FilledButton(
                                                  onPressed: joined || postId.isEmpty
                                                      ? null
                                                      : () => _requestJoinPost(postId: postId),
                                                  child: Text(joined ? '참여함' : '참여 신청'),
                                                ),
                                            ],
                                          ),
                                          if (isOwner)
                                            ExpansionTile(
                                              dense: true,
                                              tilePadding: EdgeInsets.zero,
                                              childrenPadding: EdgeInsets.zero,
                                              title: Text('지원자 관리 (${pendingEntries.length})'),
                                              children: [
                                                if (applicantEntries.isEmpty)
                                                  const Padding(
                                                    padding: EdgeInsets.only(bottom: 8),
                                                    child: Text('아직 지원자가 없습니다.', style: TextStyle(color: Color(0xFF9EA8B3))),
                                                  )
                                                else
                                                  for (final entry in applicantEntries)
                                                    _ApplicantDecisionRow(
                                                      applicantUid: entry.key.toString(),
                                                      applicantRaw: entry.value,
                                                      onAccept: postId.isEmpty
                                                          ? null
                                                          : () => _applyApplicantDecision(
                                                                postId: postId,
                                                                applicantUid: entry.key.toString(),
                                                                status: 'accepted',
                                                              ),
                                                      onReject: postId.isEmpty
                                                          ? null
                                                          : () => _applyApplicantDecision(
                                                                postId: postId,
                                                                applicantUid: entry.key.toString(),
                                                                status: 'rejected',
                                                              ),
                                                    ),
                                              ],
                                            ),
                                          if (acceptedUids.isNotEmpty) ...[
                                            ExpansionTile(
                                              dense: true,
                                              tilePadding: EdgeInsets.zero,
                                              childrenPadding: EdgeInsets.zero,
                                              title: Text('수락된 팀원 (${acceptedUids.length})'),
                                              children: [
                                                for (final uid in acceptedUids)
                                                  StreamBuilder<Profile?>(
                                                    stream: _profileService.watchProfile(uid),
                                                    builder: (context, snapshot) {
                                                      final profile = snapshot.data;
                                                      if (profile == null) {
                                                        return const SizedBox.shrink();
                                                      }
                                                      return Container(
                                                        margin: const EdgeInsets.only(bottom: 8),
                                                        padding: const EdgeInsets.all(10),
                                                        decoration: BoxDecoration(
                                                          color: const Color(0xFF0E1728),
                                                          borderRadius: BorderRadius.circular(10),
                                                          border: Border.all(color: const Color(0x2AFFFFFF)),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            CircleAvatar(
                                                              radius: 16,
                                                              backgroundImage: _avatarImageProvider(profile.avatarUrl),
                                                              child: profile.avatarUrl.trim().isEmpty
                                                                  ? Text((profile.nickname.isEmpty ? 'U' : profile.nickname.substring(0, 1)).toUpperCase())
                                                                  : null,
                                                            ),
                                                            const SizedBox(width: 8),
                                                            Expanded(
                                                              child: Text('${profile.nickname} · ${profile.tier}'),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const _NeoFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ApplicantDecisionRow extends StatelessWidget {
  const _ApplicantDecisionRow({
    required this.applicantUid,
    required this.applicantRaw,
    required this.onAccept,
    required this.onReject,
  });

  final String applicantUid;
  final dynamic applicantRaw;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    if (applicantRaw is! Map) {
      return const SizedBox.shrink();
    }

    final value = Map<String, dynamic>.from(applicantRaw as Map);
    final nickname = (value['nickname'] as String?) ?? applicantUid;
    final status = (value['status'] as String?) ?? 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1728),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x2AFFFFFF)),
      ),
      child: Row(
        children: [
          Expanded(child: Text('$nickname ($status)')),
          if (status == 'pending') ...[
            FilledButton.tonal(onPressed: onAccept, child: const Text('수락')),
            const SizedBox(width: 6),
            OutlinedButton(onPressed: onReject, child: const Text('거절')),
          ] else
            Text(status == 'accepted' ? '수락됨' : '거절됨'),
        ],
      ),
    );
  }
}

class NotificationCenterScreen extends StatelessWidget {
  NotificationCenterScreen({super.key, required this.user, required this.profile});

  final User user;
  final Profile profile;
  final MatchService _matchService = MatchService(FirebaseDatabase.instance);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _AtmosphereBackground(),
          SafeArea(
            child: Column(
              children: [
                _NeoTopBar(
                  active: 'History',
                  nickname: profile.nickname,
                  avatarUrl: profile.avatarUrl,
                  onHome: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  onCommunity: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => CommunityBoardScreen(user: user, profile: profile),
                      ),
                    );
                  },
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                    child: _GlassPanel(
                      child: StreamBuilder<List<Map<String, dynamic>>>(
                        stream: _matchService.watchNotifications(user.uid),
                        builder: (context, snapshot) {
                          final items = snapshot.data ?? const <Map<String, dynamic>>[];
                          if (items.isEmpty) {
                            return const Center(child: Text('새 알림이 없습니다.'));
                          }

                          return ListView.separated(
                            itemCount: items.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final item = items[index];
                              final id = (item['id'] as String?) ?? '';
                              final isRead = (item['read'] as bool?) ?? false;
                              return ListTile(
                                leading: Icon(isRead ? Icons.mark_email_read_outlined : Icons.mark_email_unread_outlined),
                                title: Text((item['title'] as String?) ?? '알림'),
                                subtitle: Text((item['body'] as String?) ?? ''),
                                trailing: isRead
                                    ? const Text('읽음')
                                    : TextButton(
                                        onPressed: id.isEmpty
                                            ? null
                                            : () => _matchService.markNotificationAsRead(uid: user.uid, notificationId: id),
                                        child: const Text('읽음 처리'),
                                      ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const _NeoFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarMatcher extends StatefulWidget {
  const _RadarMatcher({
    required this.matching,
    required this.status,
    required this.onTap,
  });

  final bool matching;
  final String status;
  final VoidCallback onTap;

  @override
  State<_RadarMatcher> createState() => _RadarMatcherState();
}

class _RadarMatcherState extends State<_RadarMatcher> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 380,
            height: 380,
            child: Stack(
              alignment: Alignment.center,
              children: [
                for (final size in [380.0, 300.0, 220.0, 140.0])
                  Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0x33565E74)),
                    ),
                  ),
                if (widget.matching)
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      return Transform.rotate(
                        angle: _controller.value * 2 * math.pi,
                        child: Container(
                          width: 380,
                          height: 380,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: SweepGradient(
                              colors: [
                                Colors.transparent,
                                Color(0x55ADC6FF),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                SizedBox(
                  width: 170,
                  height: 170,
                  child: ClipOval(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, _) {
                            final pulse = widget.matching
                                ? (0.85 + (math.sin(_controller.value * 2 * math.pi) + 1) * 0.075)
                                : 0.78;
                            return Container(
                              decoration: BoxDecoration(
                                gradient: SweepGradient(
                                  transform: GradientRotation(_controller.value * 2 * math.pi),
                                  colors: widget.matching
                                      ? const [
                                          Color(0xFF0350AE),
                                          Color(0xFF56A4FF),
                                          Color(0xFF0350AE),
                                        ]
                                      : const [
                                          Color(0xFF0350AE),
                                          Color(0xFF1E72D4),
                                          Color(0xFF0350AE),
                                        ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0x990566D9),
                                    blurRadius: widget.matching ? 26 * pulse : 14,
                                    spreadRadius: widget.matching ? 2 : 0,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        FilledButton(
                          onPressed: widget.onTap,
                          style: FilledButton.styleFrom(
                            shape: const CircleBorder(),
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(widget.matching ? Icons.sync_rounded : Icons.rocket_launch_rounded, size: 46),
                              const SizedBox(height: 4),
                              Text(widget.matching ? 'WAITING' : 'START', style: const TextStyle(fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(widget.status, style: const TextStyle(color: Color(0xFFC6C6CD))),
        ],
      ),
    );
  }
}

class _GameOption {
  const _GameOption(this.name, this.icon, this.color);

  final String name;
  final IconData icon;
  final Color color;
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(label, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF101B2D),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF26344D)),
        ),
        child: Row(
          children: [
            SizedBox(width: 100, child: Text(label, style: Theme.of(context).textTheme.labelLarge)),
            Expanded(child: Text(value)),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF101B2D),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF323537)),
      ),
      child: Text('$label: $value', style: const TextStyle(color: Color(0xFFE0E3E5))),
    );
  }
}
