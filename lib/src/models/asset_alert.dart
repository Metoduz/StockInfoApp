enum AlertType {
  priceAbove,
  priceBelow,
  percentChange,
  volumeSpike,
  newsAlert
}

enum AlertSource {
  local,
  backend
}

enum AlertStatus {
  active,
  triggered,
  disabled
}

class NotificationSettings {
  final bool enablePushNotifications;
  final bool enableEmailNotifications;
  final bool enableInAppNotifications;
  final List<String> notificationTimes;
  final bool enableWeekendNotifications;

  const NotificationSettings({
    this.enablePushNotifications = true,
    this.enableEmailNotifications = false,
    this.enableInAppNotifications = true,
    this.notificationTimes = const [],
    this.enableWeekendNotifications = false,
  });

  NotificationSettings copyWith({
    bool? enablePushNotifications,
    bool? enableEmailNotifications,
    bool? enableInAppNotifications,
    List<String>? notificationTimes,
    bool? enableWeekendNotifications,
  }) {
    return NotificationSettings(
      enablePushNotifications: enablePushNotifications ?? this.enablePushNotifications,
      enableEmailNotifications: enableEmailNotifications ?? this.enableEmailNotifications,
      enableInAppNotifications: enableInAppNotifications ?? this.enableInAppNotifications,
      notificationTimes: notificationTimes ?? this.notificationTimes,
      enableWeekendNotifications: enableWeekendNotifications ?? this.enableWeekendNotifications,
    );
  }
}

class AssetAlert {
  final String id;
  final String assetId;
  final String assetName;
  final AlertType type;
  final double threshold;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime? triggeredAt;
  final NotificationSettings notifications;
  final String? backendAlertId;
  final AlertSource source;
  final Map<String, dynamic>? metadata;

  const AssetAlert({
    required this.id,
    required this.assetId,
    required this.assetName,
    required this.type,
    required this.threshold,
    this.isEnabled = true,
    required this.createdAt,
    this.triggeredAt,
    this.notifications = const NotificationSettings(),
    this.backendAlertId,
    this.source = AlertSource.local,
    this.metadata,
  });

  AssetAlert copyWith({
    String? id,
    String? assetId,
    String? assetName,
    AlertType? type,
    double? threshold,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? triggeredAt,
    NotificationSettings? notifications,
    String? backendAlertId,
    AlertSource? source,
    Map<String, dynamic>? metadata,
  }) {
    return AssetAlert(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      assetName: assetName ?? this.assetName,
      type: type ?? this.type,
      threshold: threshold ?? this.threshold,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      triggeredAt: triggeredAt ?? this.triggeredAt,
      notifications: notifications ?? this.notifications,
      backendAlertId: backendAlertId ?? this.backendAlertId,
      source: source ?? this.source,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Validates the alert configuration
  bool isValid() {
    // Check if required fields are present
    if (id.isEmpty || assetId.isEmpty || assetName.isEmpty) {
      return false;
    }

    // Validate threshold based on alert type
    switch (type) {
      case AlertType.priceAbove:
      case AlertType.priceBelow:
        return threshold > 0;
      case AlertType.percentChange:
        return threshold >= 0 && threshold <= 100;
      case AlertType.volumeSpike:
        return threshold > 0;
      case AlertType.newsAlert:
        return true; // News alerts don't require threshold validation
    }
  }

  /// Returns validation error message if alert is invalid
  String? getValidationError() {
    if (id.isEmpty) return 'Alert ID cannot be empty';
    if (assetId.isEmpty) return 'Asset ID cannot be empty';
    if (assetName.isEmpty) return 'Asset name cannot be empty';

    switch (type) {
      case AlertType.priceAbove:
      case AlertType.priceBelow:
        if (threshold <= 0) return 'Price threshold must be greater than 0';
        break;
      case AlertType.percentChange:
        if (threshold < 0 || threshold > 100) {
          return 'Percentage change must be between 0 and 100';
        }
        break;
      case AlertType.volumeSpike:
        if (threshold <= 0) return 'Volume spike threshold must be greater than 0';
        break;
      case AlertType.newsAlert:
        break; // No specific validation for news alerts
    }

    return null;
  }

  /// Checks if the alert condition is met based on current asset data
  bool shouldTrigger(double currentPrice, double? previousPrice, double? volume) {
    if (!isEnabled || triggeredAt != null) return false;

    switch (type) {
      case AlertType.priceAbove:
        return currentPrice > threshold;
      case AlertType.priceBelow:
        return currentPrice < threshold;
      case AlertType.percentChange:
        if (previousPrice == null || previousPrice == 0) return false;
        final percentChange = ((currentPrice - previousPrice) / previousPrice).abs() * 100;
        return percentChange >= threshold;
      case AlertType.volumeSpike:
        return volume != null && volume > threshold;
      case AlertType.newsAlert:
        return false; // News alerts are triggered externally
    }
  }

  /// Creates a triggered version of this alert
  AssetAlert trigger() {
    return copyWith(triggeredAt: DateTime.now());
  }

  /// Enables the alert
  AssetAlert enable() {
    return copyWith(isEnabled: true);
  }

  /// Disables the alert
  AssetAlert disable() {
    return copyWith(isEnabled: false);
  }

  /// Resets the alert (clears triggered state)
  AssetAlert reset() {
    return copyWith(triggeredAt: null);
  }

  /// Returns a human-readable description of the alert
  String getDescription() {
    switch (type) {
      case AlertType.priceAbove:
        return 'Alert when $assetName price goes above €${threshold.toStringAsFixed(2)}';
      case AlertType.priceBelow:
        return 'Alert when $assetName price goes below €${threshold.toStringAsFixed(2)}';
      case AlertType.percentChange:
        return 'Alert when $assetName changes by ${threshold.toStringAsFixed(1)}%';
      case AlertType.volumeSpike:
        return 'Alert when $assetName volume exceeds ${threshold.toStringAsFixed(0)}';
      case AlertType.newsAlert:
        return 'Alert for $assetName news updates';
    }
  }

  /// Returns the alert status
  AlertStatus get status {
    if (!isEnabled) return AlertStatus.disabled;
    if (triggeredAt != null) return AlertStatus.triggered;
    return AlertStatus.active;
  }

  /// Converts to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assetId': assetId,
      'assetName': assetName,
      'type': type.name,
      'threshold': threshold,
      'isEnabled': isEnabled,
      'createdAt': createdAt.toIso8601String(),
      'triggeredAt': triggeredAt?.toIso8601String(),
      'notifications': {
        'enablePushNotifications': notifications.enablePushNotifications,
        'enableEmailNotifications': notifications.enableEmailNotifications,
        'enableInAppNotifications': notifications.enableInAppNotifications,
        'notificationTimes': notifications.notificationTimes,
        'enableWeekendNotifications': notifications.enableWeekendNotifications,
      },
      'backendAlertId': backendAlertId,
      'source': source.name,
      'metadata': metadata,
    };
  }

  /// Creates from JSON
  factory AssetAlert.fromJson(Map<String, dynamic> json) {
    return AssetAlert(
      id: json['id'] as String,
      assetId: json['assetId'] as String,
      assetName: json['assetName'] as String,
      type: AlertType.values.firstWhere((e) => e.name == json['type']),
      threshold: (json['threshold'] as num).toDouble(),
      isEnabled: json['isEnabled'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      triggeredAt: json['triggeredAt'] != null 
          ? DateTime.parse(json['triggeredAt'] as String) 
          : null,
      notifications: NotificationSettings(
        enablePushNotifications: json['notifications']['enablePushNotifications'] as bool? ?? true,
        enableEmailNotifications: json['notifications']['enableEmailNotifications'] as bool? ?? false,
        enableInAppNotifications: json['notifications']['enableInAppNotifications'] as bool? ?? true,
        notificationTimes: List<String>.from(json['notifications']['notificationTimes'] as List? ?? []),
        enableWeekendNotifications: json['notifications']['enableWeekendNotifications'] as bool? ?? false,
      ),
      backendAlertId: json['backendAlertId'] as String?,
      source: AlertSource.values.firstWhere(
        (e) => e.name == json['source'], 
        orElse: () => AlertSource.local,
      ),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}