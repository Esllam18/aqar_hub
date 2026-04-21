class RentalOptionModel {
  final String id;
  final String propertyId;
  final String type;
  final double price;
  final int totalQuantity;
  final int availableQuantity;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RentalOptionModel({
    required this.id,
    required this.propertyId,
    required this.type,
    required this.price,
    required this.totalQuantity,
    required this.availableQuantity,
    this.createdAt,
    this.updatedAt,
  });

  bool get isFullyBooked => availableQuantity <= 0;
  bool get isLimited => availableQuantity > 0 && availableQuantity <= 2;

  factory RentalOptionModel.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic value) {
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    return RentalOptionModel(
      id: (map['id'] ?? '').toString(),
      propertyId: (map['property_id'] ?? map['propertyid'] ?? '').toString(),
      type: (map['type'] ?? 'apartment').toString(),
      price: ((map['price'] ?? 0) as num).toDouble(),
      totalQuantity:
          ((map['total_quantity'] ?? map['totalquantity'] ?? 1) as num).toInt(),
      availableQuantity:
          ((map['available_quantity'] ?? map['availablequantity'] ?? 1) as num)
              .toInt(),
      createdAt: parseDate(map['created_at'] ?? map['createdat']),
      updatedAt: parseDate(map['updated_at'] ?? map['updatedat']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'property_id': propertyId,
      'type': type,
      'price': price,
      'total_quantity': totalQuantity,
      'available_quantity': availableQuantity,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
