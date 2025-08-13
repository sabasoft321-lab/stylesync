import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

import '../models/user_model.dart';

class ProfileProvider with ChangeNotifier {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('users');
  AppUser? _user;

  AppUser? get user => _user;

  Future<void> fetchUserData(String uid) async {
    try {
      final snapshot = await _dbRef.child(uid).get();
      if (snapshot.exists) {
        _user = AppUser.fromMap(uid, Map<String, dynamic>.from(snapshot.value as Map));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  void updateRegion(String region) {
    if (_user != null) {
      _user!.region = region;
      notifyListeners();
    }
  }

  void updateStyle(String style) {
    if (_user != null) {
      _user!.styleType = style;
      notifyListeners();
    }
  }

  void updateFavoriteColors(List<String> colors) {
    if (_user != null) {
      _user!.favoriteColors = colors;
      notifyListeners();
    }
  }

  void updateBudget(String budget) {
    if (_user != null) {
      _user!.budgetTier = budget;
      notifyListeners();
    }
  }

  Future<void> saveUserData() async {
    if (_user == null) return;

    try {
      // Update the entire user object in one operation
      await _dbRef.child(_user!.uid).update(_user!.toMap());

      // Show debug message
      debugPrint('User data updated successfully');
    } catch (e) {
      debugPrint('Error updating user data: $e');
      rethrow;
    }
  }
}