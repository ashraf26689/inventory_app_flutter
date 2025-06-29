enum ItemCategory {
  copperCable, // كابل نحاس
  fiberCable, // كابل فايبر
  copperWelding, // لحام نحاس
  fiberWelding, // لحام فايبر
  other, // أخرى
}

enum ItemUnit {
  meter, // متر
  piece, // قطعة
  box, // صندوق
  roll, // بكرة
  kg, // كيلوغرام
  liter, // لتر
}

class Item {
  final String id;
  final String name;
  final String code;
  final ItemCategory category;
  final double quantity;
  final ItemUnit unit;
  final double minQuantity;
  final String? requestNumber; // رقم كشف الطلب
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  Item({
    required this.id,
    required this.name,
    required this.code,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.minQuantity,
    this.requestNumber,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    // تحويل الفئة
    ItemCategory category;
    final categoryString = json['category'];
    switch (categoryString) {
      case 'copper_cable':
        category = ItemCategory.copperCable;
        break;
      case 'fiber_cable':
        category = ItemCategory.fiberCable;
        break;
      case 'copper_welding':
        category = ItemCategory.copperWelding;
        break;
      case 'fiber_welding':
        category = ItemCategory.fiberWelding;
        break;
      case 'other':
        category = ItemCategory.other;
        break;
      default:
        category = ItemCategory.other;
    }

    // تحويل الوحدة
    ItemUnit unit;
    final unitString = json['unit'];
    switch (unitString) {
      case 'meter':
        unit = ItemUnit.meter;
        break;
      case 'piece':
        unit = ItemUnit.piece;
        break;
      case 'box':
        unit = ItemUnit.box;
        break;
      case 'roll':
        unit = ItemUnit.roll;
        break;
      case 'kg':
        unit = ItemUnit.kg;
        break;
      case 'liter':
        unit = ItemUnit.liter;
        break;
      default:
        unit = ItemUnit.piece;
    }

    // التعامل مع is_active
    bool isActive;
    final isActiveValue = json['is_active'];
    if (isActiveValue == null) {
      isActive = true;
    } else if (isActiveValue is bool) {
      isActive = isActiveValue;
    } else if (isActiveValue is int) {
      isActive = isActiveValue == 1;
    } else {
      isActive = true;
    }

    // التعامل مع التواريخ
    DateTime createdAt;
    final createdAtValue = json['created_at'];
    if (createdAtValue is String) {
      createdAt = DateTime.parse(createdAtValue);
    } else if (createdAtValue is DateTime) {
      createdAt = createdAtValue;
    } else {
      createdAt = DateTime.now();
    }

    DateTime updatedAt;
    final updatedAtValue = json['updated_at'];
    if (updatedAtValue is String) {
      updatedAt = DateTime.parse(updatedAtValue);
    } else if (updatedAtValue is DateTime) {
      updatedAt = updatedAtValue;
    } else {
      updatedAt = DateTime.now();
    }

    return Item(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      category: category,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: unit,
      minQuantity: (json['min_quantity'] as num?)?.toDouble() ?? 0.0,
      requestNumber: json['request_number']?.toString(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
    );
  }

  Map<String, dynamic> toJson() {
    // تحويل الفئة إلى نص
    String categoryString;
    switch (category) {
      case ItemCategory.copperCable:
        categoryString = 'copper_cable';
        break;
      case ItemCategory.fiberCable:
        categoryString = 'fiber_cable';
        break;
      case ItemCategory.copperWelding:
        categoryString = 'copper_welding';
        break;
      case ItemCategory.fiberWelding:
        categoryString = 'fiber_welding';
        break;
      case ItemCategory.other:
        categoryString = 'other';
        break;
    }

    // تحويل الوحدة إلى نص
    String unitString;
    switch (unit) {
      case ItemUnit.meter:
        unitString = 'meter';
        break;
      case ItemUnit.piece:
        unitString = 'piece';
        break;
      case ItemUnit.box:
        unitString = 'box';
        break;
      case ItemUnit.roll:
        unitString = 'roll';
        break;
      case ItemUnit.kg:
        unitString = 'kg';
        break;
      case ItemUnit.liter:
        unitString = 'liter';
        break;
    }

    return {
      'id': id,
      'name': name,
      'code': code,
      'category': categoryString,
      'quantity': quantity,
      'unit': unitString,
      'min_quantity': minQuantity,
      'request_number': requestNumber,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  Item copyWith({
    String? id,
    String? name,
    String? code,
    ItemCategory? category,
    double? quantity,
    ItemUnit? unit,
    double? minQuantity,
    String? requestNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      minQuantity: minQuantity ?? this.minQuantity,
      requestNumber: requestNumber ?? this.requestNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  String get categoryDisplayName {
    switch (category) {
      case ItemCategory.copperCable:
        return 'كابل نحاس';
      case ItemCategory.fiberCable:
        return 'كابل فايبر';
      case ItemCategory.copperWelding:
        return 'لحام نحاس';
      case ItemCategory.fiberWelding:
        return 'لحام فايبر';
      case ItemCategory.other:
        return 'أخرى';
    }
  }

  String get unitDisplayName {
    switch (unit) {
      case ItemUnit.meter:
        return 'متر';
      case ItemUnit.piece:
        return 'قطعة';
      case ItemUnit.box:
        return 'صندوق';
      case ItemUnit.roll:
        return 'بكرة';
      case ItemUnit.kg:
        return 'كجم';
      case ItemUnit.liter:
        return 'لتر';
    }
  }

  bool get isLowStock => quantity <= minQuantity;
  bool get isOutOfStock => quantity <= 0;

  String get statusText {
    if (isOutOfStock) return 'نفذ المخزون';
    if (isLowStock) return 'مخزون منخفض';
    return 'متوفر';
  }
}
