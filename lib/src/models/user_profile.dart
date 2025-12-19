class UserProfile {
  final String? name;
  final String? email;
  final String? profileImagePath;
  final String preferredCurrency;
  final DateTime createdAt;
  final DateTime lastUpdated;
  final String? backendUserId;

  const UserProfile({
    this.name,
    this.email,
    this.profileImagePath,
    this.preferredCurrency = 'EUR',
    required this.createdAt,
    required this.lastUpdated,
    this.backendUserId,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? profileImagePath,
    String? preferredCurrency,
    DateTime? createdAt,
    DateTime? lastUpdated,
    String? backendUserId,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      backendUserId: backendUserId ?? this.backendUserId,
    );
  }

  /// Validates the user profile data
  /// Returns null if valid, otherwise returns error message
  String? validate() {
    // Validate name if provided
    if (name != null && name!.trim().isEmpty) {
      return 'Name cannot be empty';
    }
    
    if (name != null && name!.length > 100) {
      return 'Name cannot exceed 100 characters';
    }

    // Validate email if provided
    if (email != null && email!.isNotEmpty) {
      final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
      if (!emailRegex.hasMatch(email!)) {
        return 'Invalid email format';
      }
    }

    // Validate preferred currency
    final supportedCurrencies = ['EUR', 'USD', 'GBP', 'CAD'];
    if (!supportedCurrencies.contains(preferredCurrency)) {
      return 'Unsupported currency: $preferredCurrency';
    }

    return null; // Valid
  }

  /// Checks if the profile has basic information filled
  bool get isComplete {
    return name != null && name!.trim().isNotEmpty;
  }

  /// Creates a new UserProfile with current timestamp as lastUpdated
  UserProfile withUpdatedTimestamp() {
    return copyWith(lastUpdated: DateTime.now());
  }

  /// Converts UserProfile to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'profileImagePath': profileImagePath,
      'preferredCurrency': preferredCurrency,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'backendUserId': backendUserId,
    };
  }

  /// Creates UserProfile from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String?,
      email: json['email'] as String?,
      profileImagePath: json['profileImagePath'] as String?,
      preferredCurrency: json['preferredCurrency'] as String? ?? 'EUR',
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      backendUserId: json['backendUserId'] as String?,
    );
  }

  /// Creates a default UserProfile
  factory UserProfile.defaultProfile() {
    final now = DateTime.now();
    return UserProfile(
      createdAt: now,
      lastUpdated: now,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.name == name &&
        other.email == email &&
        other.profileImagePath == profileImagePath &&
        other.preferredCurrency == preferredCurrency &&
        other.createdAt == createdAt &&
        other.lastUpdated == lastUpdated &&
        other.backendUserId == backendUserId;
  }

  @override
  int get hashCode {
    return Object.hash(
      name,
      email,
      profileImagePath,
      preferredCurrency,
      createdAt,
      lastUpdated,
      backendUserId,
    );
  }

  @override
  String toString() {
    return 'UserProfile(name: $name, email: $email, preferredCurrency: $preferredCurrency)';
  }
}