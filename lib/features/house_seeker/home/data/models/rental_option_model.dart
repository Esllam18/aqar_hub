class RentalOptionModel {
  final String id;
  final String propertyId;
  final String type;
  final double price;
  final int totalQuantity;
  final int availableQuantity;
  final DateTime? updatedAt;

  const RentalOptionModel({
    required this.id,
    required this.propertyId,
    required this.type,
    required this.price,
    required this.totalQuantity,
    required this.availableQuantity,
    this.updatedAt,
  });

  bool get isFullyBooked => availableQuantity <= 0;
  bool get isLimited => availableQuantity > 0 && availableQuantity <= 2;
  int get bookedQuantity =>
      (totalQuantity - availableQuantity).clamp(0, totalQuantity);

  RentalOptionModel copyWith({
    String? id,
    String? propertyId,
    String? type,
    double? price,
    int? totalQuantity,
    int? availableQuantity,
    DateTime? updatedAt,
  }) {
    return RentalOptionModel(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      type: type ?? this.type,
      price: price ?? this.price,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory RentalOptionModel.fromMap(Map<String, dynamic> m) {
    String readString(List<String> keys, [String fallback = '']) {
      for (final key in keys) {
        final value = m[key];
        if (value is String && value.isNotEmpty) return value;
      }
      return fallback;
    }

    int readInt(List<String> keys, [int fallback = 0]) {
      for (final key in keys) {
        final value = m[key];
        if (value is int) return value;
        if (value is num) return value.toInt();
      }
      return fallback;
    }

    double readDouble(List<String> keys, [double fallback = 0]) {
      for (final key in keys) {
        final value = m[key];
        if (value is num) return value.toDouble();
      }
      return fallback;
    }

    DateTime? readDate(List<String> keys) {
      for (final key in keys) {
        final value = m[key];
        if (value is String) return DateTime.tryParse(value);
      }
      return null;
    }

    return RentalOptionModel(
      id: readString(['id']),
      propertyId: readString(['propertyid', 'property_id']),
      type: readString(['type'], 'apartment'),
      price: readDouble(['price']),
      totalQuantity: readInt(['totalquantity', 'total_quantity'], 1),
      availableQuantity: readInt([
        'availablequantity',
        'available_quantity',
      ], 1),
      updatedAt: readDate(['updatedat', 'updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'propertyid': propertyId,
      'type': type,
      'price': price,
      'totalquantity': totalQuantity,
      'availablequantity': availableQuantity,
      'updatedat': updatedAt?.toIso8601String(),
    };
  }
}
