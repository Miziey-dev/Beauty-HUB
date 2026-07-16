class UserProfile {
  final String id;
  final String? fullName;
  final String? phone;
  final List<String> savedAddresses;
  final bool pushNotificationsEnabled;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.savedAddresses,
    required this.pushNotificationsEnabled,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        fullName: json['full_name'] as String?,
        phone: json['phone'] as String?,
        savedAddresses:
            (json['saved_addresses'] as List<dynamic>? ?? []).map((e) => e as String).toList(),
        pushNotificationsEnabled: json['push_notifications_enabled'] as bool? ?? true,
      );

  UserProfile copyWith({
    String? fullName,
    List<String>? savedAddresses,
    bool? pushNotificationsEnabled,
  }) {
    return UserProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      phone: phone,
      savedAddresses: savedAddresses ?? this.savedAddresses,
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
    );
  }
}
