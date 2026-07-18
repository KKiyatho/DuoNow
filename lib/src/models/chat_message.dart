class ChatMessage {
  const ChatMessage({
    required this.messageId,
    required this.senderId,
    required this.senderNickname,
    required this.text,
    required this.sentAt,
  });

  final String messageId;
  final String senderId;
  final String senderNickname;
  final String text;
  final int sentAt;

  Map<String, dynamic> toJson() => {
        'messageId': messageId,
        'senderId': senderId,
        'senderNickname': senderNickname,
        'text': text,
        'sentAt': sentAt,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      messageId: (json['messageId'] as String?) ?? '',
      senderId: (json['senderId'] as String?) ?? '',
      senderNickname: (json['senderNickname'] as String?) ?? '',
      text: (json['text'] as String?) ?? '',
      sentAt: (json['sentAt'] as int?) ?? 0,
    );
  }
}
