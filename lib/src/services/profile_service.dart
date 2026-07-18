import 'package:firebase_database/firebase_database.dart';

import '../models/profile.dart';

class ProfileService {
  ProfileService(this._database);

  final FirebaseDatabase _database;

  Stream<Profile?> watchProfile(String uid) {
    return _database.ref('profiles/$uid').onValue.map((event) {
      final value = event.snapshot.value;
      if (value is! Map) {
        return null;
      }

      return Profile.fromJson(Map<String, dynamic>.from(value));
    });
  }

  Future<void> saveProfile(String uid, Profile profile) {
    return _database.ref('profiles/$uid').update(profile.toJson());
  }
}
