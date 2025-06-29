enum TransactionType {
  incoming, // وارد
  outgoing, // صادر
}

class Transaction {
  final String id;
  final String itemId;
  final String itemName;
  final TransactionType type;
  final double quantity;
  final String unit;
  final DateTime date;
  final String? workOrder;
  final String? requestForm;
  final String? requestNumber;
  final String responsiblePerson;
  final String? location;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  final String? category; // الفئة
  final String? spendingReason; // أسباب الصرف
  final String? central; // السنترال
  final String? recipientName; // اسم المنصرف إليه

  Transaction({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.type,
    required this.quantity,
    required this.unit,
    required this.date,
    this.workOrder,
    this.requestForm,
    this.requestNumber,
    required this.responsiblePerson,
    this.location,
    this.notes,
    required this.createdBy,
    required this.createdAt,
    this.category,
    this.spendingReason,
    this.central,
    this.recipientName,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    // تحويل نوع الحركة
    TransactionType type;
    final typeString = json['type'];
    switch (typeString) {
      case 'incoming':
        type = TransactionType.incoming;
        break;
      case 'outgoing':
        type = TransactionType.outgoing;
        break;
      default:
        type = TransactionType.incoming;
    }

    // التعامل مع التواريخ
    DateTime date;
    final dateValue = json['date'];
    if (dateValue is String) {
      date = DateTime.parse(dateValue);
    } else if (dateValue is DateTime) {
      date = dateValue;
    } else {
      date = DateTime.now();
    }

    DateTime createdAt;
    final createdAtValue = json['created_at'];
    if (createdAtValue is String) {
      createdAt = DateTime.parse(createdAtValue);
    } else if (createdAtValue is DateTime) {
      createdAt = createdAtValue;
    } else {
      createdAt = DateTime.now();
    }

    return Transaction(
      id: json['id']?.toString() ?? '',
      itemId: json['item_id']?.toString() ?? '',
      itemName: json['item_name']?.toString() ?? '',
      type: type,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit']?.toString() ?? 'قطعة',
      date: date,
      workOrder: json['work_order']?.toString(),
      requestForm: json['request_form']?.toString(),
      requestNumber: json['request_number']?.toString(),
      responsiblePerson: json['responsible_person']?.toString() ?? '',
      location: json['location']?.toString(),
      notes: json['notes']?.toString(),
      createdBy: json['created_by']?.toString() ?? '',
      createdAt: createdAt,
      category: json['category']?.toString(),
      spendingReason: json['spending_reason']?.toString(),
      central: json['central']?.toString(),
      recipientName: json['recipient_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_id': itemId,
      'item_name': itemName,
      'type': type.toString().split('.').last,
      'quantity': quantity,
      'unit': unit,
      'date': date.toIso8601String(),
      'work_order': workOrder,
      'request_form': requestForm,
      'request_number': requestNumber,
      'responsible_person': responsiblePerson,
      'location': location,
      'notes': notes,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'category': category,
      'spending_reason': spendingReason,
      'central': central,
      'recipient_name': recipientName,
    };
  }

  Transaction copyWith({
    String? id,
    String? itemId,
    String? itemName,
    TransactionType? type,
    double? quantity,
    String? unit,
    DateTime? date,
    String? workOrder,
    String? requestForm,
    String? requestNumber,
    String? responsiblePerson,
    String? location,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
    String? category,
    String? spendingReason,
    String? central,
    String? recipientName,
  }) {
    return Transaction(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      date: date ?? this.date,
      workOrder: workOrder ?? this.workOrder,
      requestForm: requestForm ?? this.requestForm,
      requestNumber: requestNumber ?? this.requestNumber,
      responsiblePerson: responsiblePerson ?? this.responsiblePerson,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      spendingReason: spendingReason ?? this.spendingReason,
      central: central ?? this.central,
      recipientName: recipientName ?? this.recipientName,
    );
  }

  String get typeDisplayName {
    switch (type) {
      case TransactionType.incoming:
        return 'وارد';
      case TransactionType.outgoing:
        return 'صادر';
    }
  }

  String get typeIcon {
    switch (type) {
      case TransactionType.incoming:
        return '📥';
      case TransactionType.outgoing:
        return '📤';
    }
  }

  bool get isIncoming => type == TransactionType.incoming;
  bool get isOutgoing => type == TransactionType.outgoing;
}
