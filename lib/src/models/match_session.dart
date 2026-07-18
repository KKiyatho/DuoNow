class MatchSession {
  const MatchSession({
    required this.matchId,
    required this.userId,
    required this.userNickname,
    required this.partnerId,
    required this.partnerNickname,
    required this.game,
    required this.tier,
    required this.playStyle,
    required this.createdAt,
  });

  final String matchId;
  final String userId;
  final String userNickname;
  final String partnerId;
  final String partnerNickname;
  final String game;
  final String tier;
  final String playStyle;
  final int createdAt;

  Map<String, dynamic> toJson() => {
        'matchId': matchId,
        'userId': userId,
        'userNickname': userNickname,
        'partnerId': partnerId,
        'partnerNickname': partnerNickname,
        'game': game,
        'tier': tier,
        'playStyle': playStyle,
        'createdAt': createdAt,
      };

  MatchSession swapped() {
    return MatchSession(
      matchId: matchId,
      userId: partnerId,
      userNickname: partnerNickname,
      partnerId: userId,
      partnerNickname: userNickname,
      game: game,
      tier: tier,
      playStyle: playStyle,
      createdAt: createdAt,
    );
  }

  factory MatchSession.fromJson(Map<String, dynamic> json) {
    return MatchSession(
      matchId: (json['matchId'] as String?) ?? '',
      userId: (json['userId'] as String?) ?? '',
      userNickname: (json['userNickname'] as String?) ?? '',
      partnerId: (json['partnerId'] as String?) ?? '',
      partnerNickname: (json['partnerNickname'] as String?) ?? '',
      game: (json['game'] as String?) ?? '',
      tier: (json['tier'] as String?) ?? '',
      playStyle: (json['playStyle'] as String?) ?? '',
      createdAt: (json['createdAt'] as int?) ?? 0,
    );
  }
}
