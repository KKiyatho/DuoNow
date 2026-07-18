class Profile {
  const Profile({
    required this.nickname,
    required this.game,
    required this.tier,
    required this.playStyle,
    required this.avatarUrl,
  });

  final String nickname;
  final String game;
  final String tier;
  final String playStyle;
  final String avatarUrl;

  Profile copyWith({
    String? nickname,
    String? game,
    String? tier,
    String? playStyle,
    String? avatarUrl,
  }) {
    return Profile(
      nickname: nickname ?? this.nickname,
      game: game ?? this.game,
      tier: tier ?? this.tier,
      playStyle: playStyle ?? this.playStyle,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'nickname': nickname,
        'game': game,
        'tier': tier,
        'playStyle': playStyle,
        'avatarUrl': avatarUrl,
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      };

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      nickname: (json['nickname'] as String?) ?? '',
      game: (json['game'] as String?) ?? '',
      tier: (json['tier'] as String?) ?? '',
      playStyle: (json['playStyle'] as String?) ?? '',
      avatarUrl: (json['avatarUrl'] as String?) ?? '',
    );
  }
}
