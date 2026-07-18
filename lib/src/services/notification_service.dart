import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  String? _boundUid;
  StreamSubscription<RemoteMessage>? _onMessageSubscription;
  StreamSubscription<RemoteMessage>? _onOpenSubscription;

  Future<void> bindUser(String uid) async {
    if (_boundUid == uid) {
      return;
    }

    _boundUid = uid;

    try {
      await _messaging.requestPermission(alert: true, badge: true, sound: true);
      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        final tokenKey = token.replaceAll('.', '_');
        await _database.ref('deviceTokens/$uid/$tokenKey').set({
          'token': token,
          'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        });
      }
    } catch (_) {
      // Keep app usable even if push permission/token fails.
    }

    await _onMessageSubscription?.cancel();
    await _onOpenSubscription?.cancel();

    _onMessageSubscription = FirebaseMessaging.onMessage.listen((message) async {
      await _savePushAsNotification(uid, message, source: 'foreground');
    });

    _onOpenSubscription = FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      await _savePushAsNotification(uid, message, source: 'opened');
    });
  }

  Future<void> _savePushAsNotification(String uid, RemoteMessage message, {required String source}) async {
    final id = _database.ref('notifications/$uid').push().key;
    if (id == null) {
      return;
    }

    final title = message.notification?.title ?? message.data['title']?.toString() ?? '새 알림';
    final body = message.notification?.body ?? message.data['body']?.toString() ?? '알림이 도착했습니다.';

    await _database.ref('notifications/$uid/$id').set({
      'type': 'push_message',
      'title': title,
      'body': body,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'read': false,
      'source': source,
    });
  }
}
