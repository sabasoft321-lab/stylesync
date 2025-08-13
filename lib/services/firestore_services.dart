// lib/services/realtime_db_service.dart
import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';

class RealtimeDbService {
  final DatabaseReference _users = FirebaseDatabase.instance.ref('users');

  // Stream<AppUser?> like before
  Stream<AppUser?> userStream(String uid) {
    final userRef = _users.child(uid);
    return userRef.onValue.map((DatabaseEvent event) {
      final snap = event.snapshot;
      if (!snap.exists || snap.value == null) return null;
      final map = Map<dynamic, dynamic>.from(snap.value as Map);
      return AppUser.fromMap(uid, map);
    });
  }

  Future<bool> isOnboarded(String uid) async {
    final snap = await _users.child(uid).get();
    if (!snap.exists || snap.value == null) return false;
    final data = Map<dynamic, dynamic>.from(snap.value as Map);
    return data['onboardingComplete'] == true;
  }

  /// Merge-like upsert:
  /// - If the user doesn’t exist, this creates the node.
  /// - Only provided keys are updated (others remain untouched).
  Future<void> upsertUser(String uid, Map<String, dynamic> data) async {
    // Add a server timestamp on write (optional)
    final withTimestamp = {
      ...data,
      'updatedAt': ServerValue.timestamp,
    };
    await _users.child(uid).update(withTimestamp);
  }
}
