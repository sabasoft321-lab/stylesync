// lib/models/user_model.dart
class AppUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
   String? region;
  String? styleType;
  List<String>? favoriteColors;
  final Map<String, String>? sizes;
  String? budgetTier;
  final bool onboardingComplete;

  AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.region,
    this.styleType,
    this.favoriteColors = const [],
    this.sizes,
    this.budgetTier,
    this.onboardingComplete = false,
  });

  Map<String, dynamic> toMap() => {
    'email': email,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'region': region,
    'styleType': styleType,
    'favoriteColors': favoriteColors,
    'sizes': sizes,
    'budgetTier': budgetTier,
    'onboardingComplete': onboardingComplete,
    // Realtime DB server timestamp:
    'updatedAt': DateTime.now(),
  };

  // New: construct from a plain Map (RTDB value)
  factory AppUser.fromMap(String uid, Map<dynamic, dynamic> data) {
    return AppUser(
      uid: uid,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      region: data['region'] as String?,
      styleType: data['styleType'] as String?,
      favoriteColors: (data['favoriteColors'] as List?)?.cast<String>() ?? const [],
      sizes: (data['sizes'] as Map?)?.map((k, v) => MapEntry(k.toString(), v.toString())),
      budgetTier: data['budgetTier'] as String?,
      onboardingComplete: (data['onboardingComplete'] == true),
    );
  }
}
