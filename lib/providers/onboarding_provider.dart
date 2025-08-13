// lib/providers/onboarding_provider.dart
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/firestore_services.dart';


class OnboardingProvider with ChangeNotifier {
  final _db = RealtimeDbService();

  String? region;
  String? styleType;
  final List<String> favoriteColors = [];
  final Map<String, String> sizes = {};
  String? budgetTier;

  void setRegion(String v) { region = v; notifyListeners(); }
  void setStyleType(String v) { styleType = v; notifyListeners(); }
  void toggleColor(String c) {
    if (favoriteColors.contains(c)) { favoriteColors.remove(c); }
    else { favoriteColors.add(c); }
    notifyListeners();
  }
  void setSize(String key, String value) { sizes[key] = value; notifyListeners(); }
  void setBudget(String v) { budgetTier = v; notifyListeners(); }

  bool get isValid =>
      (region?.isNotEmpty ?? false) &&
          (styleType?.isNotEmpty ?? false) &&
          favoriteColors.isNotEmpty &&
          (budgetTier?.isNotEmpty ?? false);

  Future<void> saveFor(String uid, {String? email, String? displayName, String? photoUrl}) async {
    final user = AppUser(
      uid: uid,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      region: region,
      styleType: styleType,
      favoriteColors: favoriteColors,
      sizes: sizes,
      budgetTier: budgetTier,
      onboardingComplete: true,
    );
    await _db.upsertUser(uid, user.toMap());
  }
}
