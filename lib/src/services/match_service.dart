import 'package:firebase_database/firebase_database.dart';

import '../models/match_session.dart';
import '../models/profile.dart';

class MatchService {
  MatchService(this._database);

  final FirebaseDatabase _database;

  DatabaseReference get _queueRef => _database.ref('matchQueue');
  DatabaseReference get _activeRef => _database.ref('activeMatches');
  DatabaseReference get _historyRef => _database.ref('matchHistory');
  DatabaseReference get _notificationRef => _database.ref('notifications');
  DatabaseReference get _communityRef => _database.ref('communityPosts');
  DatabaseReference get _profileRef => _database.ref('profiles');

  Stream<MatchSession?> watchActiveMatch(String uid) {
    return _activeRef.child(uid).onValue.map((event) {
      final value = event.snapshot.value;
      if (value is! Map) {
        return null;
      }

      return MatchSession.fromJson(Map<String, dynamic>.from(value));
    });
  }

  Stream<List<Map<String, dynamic>>> watchHistory(String uid) {
    return _historyRef.child(uid).onValue.map((event) {
      final value = event.snapshot.value;
      if (value is! Map) {
        return <Map<String, dynamic>>[];
      }

      final items = <Map<String, dynamic>>[];
      for (final entry in value.entries) {
        final raw = entry.value;
        if (raw is! Map) {
          continue;
        }

        final item = Map<String, dynamic>.from(raw);
        item['id'] = entry.key.toString();
        items.add(item);
      }

      items.sort((a, b) {
        final left = (a['updatedAt'] as int?) ?? 0;
        final right = (b['updatedAt'] as int?) ?? 0;
        return right.compareTo(left);
      });
      return items;
    });
  }

  Stream<List<Map<String, dynamic>>> watchNotifications(String uid) {
    return _notificationRef.child(uid).onValue.map((event) {
      final value = event.snapshot.value;
      if (value is! Map) {
        return <Map<String, dynamic>>[];
      }

      final items = <Map<String, dynamic>>[];
      for (final entry in value.entries) {
        final raw = entry.value;
        if (raw is! Map) {
          continue;
        }

        final item = Map<String, dynamic>.from(raw);
        item['id'] = entry.key.toString();
        items.add(item);
      }

      items.sort((a, b) {
        final left = (a['createdAt'] as int?) ?? 0;
        final right = (b['createdAt'] as int?) ?? 0;
        return right.compareTo(left);
      });
      return items;
    });
  }

  Stream<int> watchUnreadNotificationCount(String uid) {
    return watchNotifications(uid).map((items) {
      var unread = 0;
      for (final item in items) {
        final isRead = (item['read'] as bool?) ?? false;
        if (!isRead) {
          unread += 1;
        }
      }
      return unread;
    });
  }

  Stream<List<Map<String, dynamic>>> watchCommunityPosts({String? game}) {
    final query = (game == null || game.trim().isEmpty)
        ? _communityRef.orderByChild('createdAt')
        : _communityRef.orderByChild('game').equalTo(game.trim());

    return query.onValue.map((event) {
      final value = event.snapshot.value;
      if (value is! Map) {
        return <Map<String, dynamic>>[];
      }

      final items = <Map<String, dynamic>>[];
      for (final entry in value.entries) {
        final raw = entry.value;
        if (raw is! Map) {
          continue;
        }

        final item = Map<String, dynamic>.from(raw);
        item['id'] = entry.key.toString();
        items.add(item);
      }

      items.sort((a, b) {
        final left = (a['createdAt'] as int?) ?? 0;
        final right = (b['createdAt'] as int?) ?? 0;
        return right.compareTo(left);
      });
      return items;
    });
  }

  Future<void> createCommunityPost({
    required String uid,
    required String nickname,
    required String game,
    required String tier,
    required String playStyle,
    required String title,
    required String content,
  }) async {
    final postId = _communityRef.push().key;
    if (postId == null) {
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    await _communityRef.child(postId).set({
      'postId': postId,
      'ownerId': uid,
      'ownerNickname': nickname,
      'game': game,
      'tier': tier,
      'playStyle': playStyle,
      'title': title,
      'content': content,
      'status': 'open',
      'createdAt': now,
      'updatedAt': now,
      'applicantCount': 0,
      'participants': {uid: true},
      'applicants': <String, dynamic>{},
    });
  }

  Future<bool> updateCommunityPost({
    required String uid,
    required String postId,
    required String title,
    required String content,
  }) async {
    final postRef = _communityRef.child(postId);
    final snapshot = await postRef.get();
    if (!snapshot.exists || snapshot.value is! Map) {
      return false;
    }

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    final ownerId = (data['ownerId'] ?? '').toString();
    if (ownerId != uid) {
      return false;
    }

    await postRef.update({
      'title': title,
      'content': content,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
    return true;
  }

  Future<bool> deleteCommunityPost({
    required String uid,
    required String postId,
  }) async {
    final postRef = _communityRef.child(postId);
    final snapshot = await postRef.get();
    if (!snapshot.exists || snapshot.value is! Map) {
      return false;
    }

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    final ownerId = (data['ownerId'] ?? '').toString();
    if (ownerId != uid) {
      return false;
    }

    await postRef.remove();
    return true;
  }

  Future<bool> joinCommunityPost({
    required String uid,
    required String nickname,
    required String postId,
  }) async {
    final postRef = _communityRef.child(postId);
    final snapshot = await postRef.get();
    if (!snapshot.exists || snapshot.value is! Map) {
      return false;
    }

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    final participants = data['participants'] is Map ? Map<String, dynamic>.from(data['participants'] as Map) : <String, dynamic>{};
    if (participants[uid] == true) {
      return false;
    }

    participants[uid] = true;
    final now = DateTime.now().millisecondsSinceEpoch;
    final applicants = data['applicants'] is Map ? Map<String, dynamic>.from(data['applicants'] as Map) : <String, dynamic>{};
    final existingApplicant = applicants[uid];
    if (existingApplicant is Map && (existingApplicant['status'] as String?) == 'accepted') {
      return false;
    }

    applicants[uid] = {
      'uid': uid,
      'nickname': nickname,
      'status': 'pending',
      'requestedAt': now,
    };

    final ownerId = (data['ownerId'] as String?) ?? '';
    final applicantCount = applicants.length;

    await postRef.update({
      'participants': participants,
      'applicantCount': applicantCount,
      'applicants': applicants,
      'updatedAt': now,
    });

    if (ownerId.isNotEmpty && ownerId != uid) {
      final notificationId = _notificationRef.child(ownerId).push().key;
      if (notificationId != null) {
        await _notificationRef.child(ownerId).child(notificationId).set({
          'type': 'community_join',
          'title': '팀원 모집 공고에 참여자가 생겼습니다',
          'body': '$nickname 님이 공고에 관심을 보냈습니다.',
          'createdAt': now,
          'read': false,
          'postId': postId,
        });
      }
    }

    return true;
  }

  Future<bool> updateCommunityApplicantStatus({
    required String ownerUid,
    required String postId,
    required String applicantUid,
    required String status,
  }) async {
    if (status != 'accepted' && status != 'rejected') {
      return false;
    }

    final postRef = _communityRef.child(postId);
    final snapshot = await postRef.get();
    if (!snapshot.exists || snapshot.value is! Map) {
      return false;
    }

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    final currentOwnerId = (data['ownerId'] as String?) ?? '';
    if (currentOwnerId != ownerUid) {
      return false;
    }

    final applicants = data['applicants'] is Map ? Map<String, dynamic>.from(data['applicants'] as Map) : <String, dynamic>{};
    final targetRaw = applicants[applicantUid];
    if (targetRaw is! Map) {
      return false;
    }

    final target = Map<String, dynamic>.from(targetRaw);
    target['status'] = status;
    target['updatedAt'] = DateTime.now().millisecondsSinceEpoch;
    applicants[applicantUid] = target;

    final now = DateTime.now().millisecondsSinceEpoch;
    await postRef.update({
      'applicants': applicants,
      'updatedAt': now,
    });

    final notificationId = _notificationRef.child(applicantUid).push().key;
    if (notificationId != null) {
      await _notificationRef.child(applicantUid).child(notificationId).set({
        'type': 'community_result',
        'title': status == 'accepted' ? '공고 참여가 수락되었습니다' : '공고 참여가 거절되었습니다',
        'body': status == 'accepted' ? '지원한 팀원 모집 공고에 합류할 수 있습니다.' : '지원한 팀원 모집 공고가 거절되었습니다.',
        'createdAt': now,
        'read': false,
        'postId': postId,
      });
    }

    if (status == 'accepted') {
      await _createDirectMatchFromCommunity(
        ownerUid: ownerUid,
        applicantUid: applicantUid,
        postData: data,
      );
    }

    return true;
  }

  Future<void> createReservationNudge({
    required String uid,
    required String game,
    required String tier,
    required String playStyle,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final notificationId = _notificationRef.child(uid).push().key;
    if (notificationId == null) {
      return;
    }

    await _notificationRef.child(uid).child(notificationId).set({
      'type': 'reservation_nudge',
      'title': '예약 매칭으로 전환되었습니다',
      'body': '알림 재호출을 설정했어요. 매칭되면 즉시 알려드릴게요.',
      'createdAt': now,
      'read': false,
      'game': game,
      'tier': tier,
      'playStyle': playStyle,
    });
  }

  Future<MatchSession?> startMatching({
    required String uid,
    required Profile profile,
    bool allowAdjacentTier = false,
    bool allowPlayStyleMismatch = false,
  }) async {
    final existingActiveMatch = await _activeRef.child(uid).get();
    if (existingActiveMatch.value is Map) {
      return MatchSession.fromJson(Map<String, dynamic>.from(existingActiveMatch.value as Map));
    }

    final queueSnapshot = await _queueRef.orderByChild('game').equalTo(profile.game).get();
    final queueValue = queueSnapshot.value;

    if (queueValue is Map) {
      for (final entry in queueValue.entries) {
        final candidateUid = entry.key.toString();
        if (candidateUid == uid) {
          continue;
        }

        final candidateValue = entry.value;
        if (candidateValue is! Map) {
          continue;
        }

        final candidateProfile = Profile.fromJson(Map<String, dynamic>.from(candidateValue));
        if (candidateProfile.game != profile.game) {
          continue;
        }

        if (!_isTierCompatible(profile.tier, candidateProfile.tier, allowAdjacentTier: allowAdjacentTier)) {
          continue;
        }

        if (!allowPlayStyleMismatch && !_isPlayStyleCompatible(profile.playStyle, candidateProfile.playStyle)) {
          continue;
        }

        final matchId = _database.ref().push().key;
        if (matchId == null) {
          continue;
        }

        final selfMatch = MatchSession(
          matchId: matchId,
          userId: uid,
          userNickname: profile.nickname,
          partnerId: candidateUid,
          partnerNickname: candidateProfile.nickname,
          game: profile.game,
          tier: profile.tier,
          playStyle: profile.playStyle,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        );
        final partnerMatch = selfMatch.swapped();
        final now = DateTime.now().millisecondsSinceEpoch;
        final selfHistory = {
          'matchId': matchId,
          'partnerId': candidateUid,
          'partnerNickname': candidateProfile.nickname,
          'game': profile.game,
          'tier': profile.tier,
          'playStyle': profile.playStyle,
          'status': 'active',
          'createdAt': now,
          'updatedAt': now,
        };
        final partnerHistory = {
          'matchId': matchId,
          'partnerId': uid,
          'partnerNickname': profile.nickname,
          'game': profile.game,
          'tier': candidateProfile.tier,
          'playStyle': candidateProfile.playStyle,
          'status': 'active',
          'createdAt': now,
          'updatedAt': now,
        };

        final selfNotificationId = _notificationRef.child(uid).push().key;
        final partnerNotificationId = _notificationRef.child(candidateUid).push().key;

        await Future.wait([
          _activeRef.child(uid).set(selfMatch.toJson()),
          _activeRef.child(candidateUid).set(partnerMatch.toJson()),
          _historyRef.child(uid).child(matchId).set(selfHistory),
          _historyRef.child(candidateUid).child(matchId).set(partnerHistory),
          if (selfNotificationId != null)
            _notificationRef.child(uid).child(selfNotificationId).set({
              'type': 'match_found',
              'title': '매칭이 성사되었습니다',
              'body': '${candidateProfile.nickname}님과 듀오가 연결됐습니다.',
              'createdAt': now,
              'read': false,
              'matchId': matchId,
            }),
          if (partnerNotificationId != null)
            _notificationRef.child(candidateUid).child(partnerNotificationId).set({
              'type': 'match_found',
              'title': '매칭이 성사되었습니다',
              'body': '${profile.nickname}님과 듀오가 연결됐습니다.',
              'createdAt': now,
              'read': false,
              'matchId': matchId,
            }),
          _queueRef.child(candidateUid).remove(),
          _queueRef.child(uid).remove(),
        ]);

        return selfMatch;
      }
    }

    await _queueRef.child(uid).set({
      ...profile.toJson(),
      'uid': uid,
      'status': 'waiting',
      'requestedAt': DateTime.now().millisecondsSinceEpoch,
    });
    return null;
  }

  Future<void> cancelQueue(String uid) {
    return _queueRef.child(uid).remove();
  }

  Future<void> endMatch({required String uid, required String partnerUid}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final selfSnapshot = await _activeRef.child(uid).get();

    String? matchId;
    if (selfSnapshot.value is Map) {
      matchId = (selfSnapshot.child('matchId').value as String?);
    }

    if (matchId != null && matchId.isNotEmpty) {
      await Future.wait([
        _historyRef.child(uid).child(matchId).update({'status': 'ended', 'updatedAt': now}),
        _historyRef.child(partnerUid).child(matchId).update({'status': 'ended', 'updatedAt': now}),
      ]);

      final selfNotificationId = _notificationRef.child(uid).push().key;
      final partnerNotificationId = _notificationRef.child(partnerUid).push().key;
      await Future.wait([
        if (selfNotificationId != null)
          _notificationRef.child(uid).child(selfNotificationId).set({
            'type': 'match_ended',
            'title': '매칭이 종료되었습니다',
            'body': '방금 듀오 기록이 히스토리에 저장되었습니다.',
            'createdAt': now,
            'read': false,
            'matchId': matchId,
          }),
        if (partnerNotificationId != null)
          _notificationRef.child(partnerUid).child(partnerNotificationId).set({
            'type': 'match_ended',
            'title': '매칭이 종료되었습니다',
            'body': '방금 듀오 기록이 히스토리에 저장되었습니다.',
            'createdAt': now,
            'read': false,
            'matchId': matchId,
          }),
      ]);
    }

    await Future.wait([
      _activeRef.child(uid).remove(),
      _activeRef.child(partnerUid).remove(),
    ]);
  }

  Future<void> markNotificationAsRead({required String uid, required String notificationId}) {
    return _notificationRef.child(uid).child(notificationId).update({'read': true});
  }

  bool _isPlayStyleCompatible(String first, String second) {
    final normalizedFirst = first.trim().toLowerCase();
    final normalizedSecond = second.trim().toLowerCase();
    if (normalizedFirst.isEmpty || normalizedSecond.isEmpty) {
      return true;
    }

    return normalizedFirst == normalizedSecond;
  }

  bool _isTierCompatible(String first, String second, {required bool allowAdjacentTier}) {
    final firstRank = _tierRank(first);
    final secondRank = _tierRank(second);

    if (firstRank == null || secondRank == null) {
      return true;
    }

    final difference = (firstRank - secondRank).abs();
    return difference == 0 || (allowAdjacentTier && difference == 1);
  }

  int? _tierRank(String tier) {
    final normalized = tier.trim().toLowerCase();
    if (normalized.isEmpty) {
      return null;
    }

    const tiers = [
      'iron',
      'bronze',
      'silver',
      'gold',
      'platinum',
      'emerald',
      'diamond',
      'master',
      'grandmaster',
      'challenger',
      'radiant',
      'ascendant',
    ];

    for (var i = 0; i < tiers.length; i++) {
      if (normalized.contains(tiers[i])) {
        return i;
      }
    }

    return null;
  }

  Future<void> _createDirectMatchFromCommunity({
    required String ownerUid,
    required String applicantUid,
    required Map<String, dynamic> postData,
  }) async {
    final ownerActive = await _activeRef.child(ownerUid).get();
    final applicantActive = await _activeRef.child(applicantUid).get();
    if (ownerActive.value is Map || applicantActive.value is Map) {
      return;
    }

    final ownerProfileSnapshot = await _profileRef.child(ownerUid).get();
    final applicantProfileSnapshot = await _profileRef.child(applicantUid).get();
    if (ownerProfileSnapshot.value is! Map || applicantProfileSnapshot.value is! Map) {
      return;
    }

    final ownerProfile = Profile.fromJson(Map<String, dynamic>.from(ownerProfileSnapshot.value as Map));
    final applicantProfile = Profile.fromJson(Map<String, dynamic>.from(applicantProfileSnapshot.value as Map));
    final matchId = _database.ref().push().key;
    if (matchId == null) {
      return;
    }

    final game = (postData['game'] as String?) ?? ownerProfile.game;
    final playStyle = (postData['playStyle'] as String?) ?? ownerProfile.playStyle;
    final now = DateTime.now().millisecondsSinceEpoch;

    final ownerMatch = MatchSession(
      matchId: matchId,
      userId: ownerUid,
      userNickname: ownerProfile.nickname,
      partnerId: applicantUid,
      partnerNickname: applicantProfile.nickname,
      game: game,
      tier: ownerProfile.tier,
      playStyle: playStyle,
      createdAt: now,
    );
    final applicantMatch = ownerMatch.swapped();

    final ownerHistory = {
      'matchId': matchId,
      'partnerId': applicantUid,
      'partnerNickname': applicantProfile.nickname,
      'game': game,
      'tier': ownerProfile.tier,
      'playStyle': playStyle,
      'status': 'active',
      'createdAt': now,
      'updatedAt': now,
      'source': 'community',
    };
    final applicantHistory = {
      'matchId': matchId,
      'partnerId': ownerUid,
      'partnerNickname': ownerProfile.nickname,
      'game': game,
      'tier': applicantProfile.tier,
      'playStyle': playStyle,
      'status': 'active',
      'createdAt': now,
      'updatedAt': now,
      'source': 'community',
    };

    final ownerNotificationId = _notificationRef.child(ownerUid).push().key;
    final applicantNotificationId = _notificationRef.child(applicantUid).push().key;

    await Future.wait([
      _activeRef.child(ownerUid).set(ownerMatch.toJson()),
      _activeRef.child(applicantUid).set(applicantMatch.toJson()),
      _historyRef.child(ownerUid).child(matchId).set(ownerHistory),
      _historyRef.child(applicantUid).child(matchId).set(applicantHistory),
      if (ownerNotificationId != null)
        _notificationRef.child(ownerUid).child(ownerNotificationId).set({
          'type': 'match_found',
          'title': '공고 수락으로 듀오가 시작되었습니다',
          'body': '${applicantProfile.nickname}님과 채팅방이 자동 개설되었습니다.',
          'createdAt': now,
          'read': false,
          'matchId': matchId,
        }),
      if (applicantNotificationId != null)
        _notificationRef.child(applicantUid).child(applicantNotificationId).set({
          'type': 'match_found',
          'title': '공고 수락으로 듀오가 시작되었습니다',
          'body': '${ownerProfile.nickname}님과 채팅방이 자동 개설되었습니다.',
          'createdAt': now,
          'read': false,
          'matchId': matchId,
        }),
      _database.ref('matchMessages/$matchId/system').set({
        'messageId': 'system',
        'senderId': 'system',
        'senderNickname': 'DuoNow',
        'text': '커뮤니티 수락으로 듀오 채팅방이 열렸습니다. 인사하고 게임 초대를 시작해보세요!',
        'sentAt': now,
      }),
    ]);
  }
}
