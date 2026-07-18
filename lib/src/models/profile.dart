class Profile {
  const Profile({
    required this.nickname,
    required this.game,
    required this.tier,
    required this.playStyle,
  });

  final String nickname;
  final String game;
  final String tier;
  final String playStyle;

  Map<String, dynamic> toJson() => {
        'nickname': nickname,
        'game': game,
        'tier': tier,
        'playStyle': playStyle,
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      };

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      nickname: (json['nickname'] as String?) ?? '',
      game: (json['game'] as String?) ?? '',
      tier: (json['tier'] as String?) ?? '',
      playStyle: (json['playStyle'] as String?) ?? '',
    );
  }
}
