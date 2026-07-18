import 'package:firebase_database/firebase_database.dart';

import '../models/chat_message.dart';

class ChatService {
  ChatService(this._database);

  final FirebaseDatabase _database;

  DatabaseReference messagesRef(String matchId) => _database.ref('matchMessages/$matchId');
  DatabaseReference ratingsRef(String matchId) => _database.ref('matchRatings/$matchId');

  Stream<List<ChatMessage>> watchMessages(String matchId) {
    return messagesRef(matchId).orderByChild('sentAt').onValue.map((event) {
      final value = event.snapshot.value;
      if (value is! Map) {
        return <ChatMessage>[];
      }

      final messages = <ChatMessage>[];
      for (final entry in value.entries) {
        final item = entry.value;
        if (item is Map) {
          messages.add(ChatMessage.fromJson(Map<String, dynamic>.from(item)));
        }
      }

      messages.sort((left, right) => left.sentAt.compareTo(right.sentAt));
      return messages;
    });
  }

  Future<void> sendMessage({
    required String matchId,
    required String senderId,
    required String senderNickname,
    required String text,
  }) async {
    final messageId = messagesRef(matchId).push().key;
    if (messageId == null) {
      return;
    }

    await messagesRef(matchId).child(messageId).set({
      'messageId': messageId,
      'senderId': senderId,
      'senderNickname': senderNickname,
      'text': text,
      'sentAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> submitRating({
    required String matchId,
    required String raterId,
    required String targetId,
    required bool isPositive,
  }) async {
    await ratingsRef(matchId).child(raterId).set({
      'raterId': raterId,
      'targetId': targetId,
      'isPositive': isPositive,
      'ratedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }
}
