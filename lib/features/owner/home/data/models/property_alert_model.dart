enum PropertyAlertSeverity { success, info, warning, error }

class PropertyAlertModel {
  final String code;
  final PropertyAlertSeverity severity;
  final String? rentalType;
  final int? remaining;

  const PropertyAlertModel({
    required this.code,
    required this.severity,
    this.rentalType,
    this.remaining,
  });
}
