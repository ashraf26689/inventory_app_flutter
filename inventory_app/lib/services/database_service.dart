import 'dart:async';
import '../models/user.dart';
import '../models/item.dart';
import '../models/transaction.dart' as app_transaction;
import '../models/transaction.dart' show TransactionType;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;
import '../models/transaction.dart';

class DatabaseService {
  final supabase = supabase_flutter.Supabase.instance.client;

  // ========== عمليات المستخدمين ==========

  Future<List<User>> getAllUsers() async {
    final data = await supabase.from('users').select();
    return (data as List<dynamic>).map((json) => User.fromJson(json)).toList();
  }

  Future<User?> getUserById(String id) async {
    final data =
        await supabase.from('users').select().eq('id', id).maybeSingle();
    if (data != null) {
      return User.fromJson(data);
    }
    return null;
  }

  Future<User?> getUserByUsername(String username) async {
    final data = await supabase
        .from('users')
        .select()
        .eq('username', username)
        .maybeSingle();
    if (data != null) {
      return User.fromJson(data);
    }
    return null;
  }

  Future<void> insertUser(User user) async {
    final data = user.toJson();
    await supabase.from('users').insert(data);
  }

  Future<void> updateUser(User user) async {
    final data = user.toJson();
    await supabase.from('users').update(data).eq('id', user.id);
  }

  Future<void> deleteUser(String id) async {
    await supabase.from('users').delete().eq('id', id);
  }

  // ========== عمليات الأصناف ==========

  Future<List<Item>> getAllItems() async {
    final data = await supabase.from('items').select();
    return (data as List<dynamic>).map((json) => Item.fromJson(json)).toList();
  }

  Future<Item?> getItemById(String id) async {
    final data =
        await supabase.from('items').select().eq('id', id).maybeSingle();
    if (data != null) {
      return Item.fromJson(data);
    }
    return null;
  }

  Future<List<Item>> getItemsByCategory(String category) async {
    final data = await supabase.from('items').select().eq('category', category);
    return (data as List<dynamic>).map((json) => Item.fromJson(json)).toList();
  }

  Future<List<Item>> searchItems(String query) async {
    final data =
        await supabase.from('items').select().ilike('name', '%$query%');
    return (data as List<dynamic>).map((json) => Item.fromJson(json)).toList();
  }

  Future<List<Item>> getLowStockItems() async {
    final data = await supabase.from('items').select().eq('is_active', true);
    return (data as List<dynamic>)
        .map((json) => Item.fromJson(json))
        .where((item) => item.quantity <= item.minQuantity)
        .toList();
  }

  Future<void> insertItem(Item item) async {
    final data = item.toJson();
    await supabase.from('items').insert(data);
  }

  Future<void> updateItem(Item item) async {
    final data = item.toJson();
    await supabase.from('items').update(data).eq('id', item.id);
  }

  Future<void> deleteItem(String id) async {
    await supabase.from('items').delete().eq('id', id);
  }

  // ========== عمليات الحركات ==========

  Future<List<Transaction>> getAllTransactions() async {
    final data = await supabase
        .from('transactions')
        .select()
        .order('date', ascending: false);
    return (data as List<dynamic>)
        .map((json) => Transaction.fromJson(json))
        .toList();
  }

  Future<Transaction?> getTransactionById(String id) async {
    final data =
        await supabase.from('transactions').select().eq('id', id).maybeSingle();
    if (data != null) {
      return Transaction.fromJson(data);
    }
    return null;
  }

  Future<List<Transaction>> getTransactionsByItem(String itemId) async {
    final data = await supabase
        .from('transactions')
        .select()
        .eq('item_id', itemId)
        .order('date', ascending: false);
    return (data as List<dynamic>)
        .map((json) => Transaction.fromJson(json))
        .toList();
  }

  Future<List<Transaction>> getTransactionsByDateRange(
      DateTime start, DateTime end) async {
    final data = await supabase
        .from('transactions')
        .select()
        .gte('date', start.toIso8601String())
        .lte('date', end.toIso8601String())
        .order('date', ascending: false);
    return (data as List<dynamic>)
        .map((json) => Transaction.fromJson(json))
        .toList();
  }

  Future<void> insertTransaction(Transaction transaction) async {
    final data = transaction.toJson();
    await supabase.from('transactions').insert(data);
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final data = transaction.toJson();
    await supabase.from('transactions').update(data).eq('id', transaction.id);
  }

  Future<void> deleteTransaction(String id) async {
    await supabase.from('transactions').delete().eq('id', id);
  }

  // ========== إحصائيات ==========

  Future<Map<String, dynamic>> getDashboardStats() async {
    // إجمالي الأصناف
    final totalItemsResult =
        await supabase.from('items').select().eq('is_active', true);
    final totalItems = totalItemsResult.length;

    // إجمالي الكميات
    final totalQuantityResult =
        await supabase.from('items').select('quantity').eq('is_active', true);
    final totalQuantity = totalQuantityResult.fold<double>(
        0.0, (sum, item) => sum + (item['quantity'] as double));

    // الأصناف منخفضة المخزون
    final lowStockResult =
        await supabase.from('items').select().eq('is_active', true);
    final lowStockItems = lowStockResult
        .where((item) =>
            (item['quantity'] as double) <= (item['min_quantity'] as double))
        .length;

    // عدد الفئات
    final categoriesResult =
        await supabase.from('items').select('category').eq('is_active', true);
    final categories =
        categoriesResult.map((item) => item['category']).toSet().length;

    // آخر الحركات
    final recentTransactionsResult = await supabase
        .from('transactions')
        .select()
        .order('date', ascending: false)
        .limit(5);
    final recentTransactions = List.generate(
      recentTransactionsResult.length,
      (i) => Transaction.fromJson(recentTransactionsResult[i]),
    );

    return {
      'totalItems': totalItems,
      'totalQuantity': totalQuantity,
      'lowStockItems': lowStockItems,
      'categories': categories,
      'recentTransactions': recentTransactions,
    };
  }

  // ===== إنشاء بيانات تجريبية =====
  Future<void> createSampleData() async {
    try {
      print('=== إنشاء بيانات تجريبية ===');

      // إنشاء أصناف تجريبية (بدون معرفات مخصصة)
      final sampleItemsData = [
        {
          'name': 'كابل شبكة CAT6',
          'code': 'CABLE-001',
          'category': 'copper_cable',
          'quantity': 150.0,
          'unit': 'meter',
          'min_quantity': 20.0,
          'request_number': 'REQ-2024-001',
          'is_active': true,
        },
        {
          'name': 'كابل ألياف ضوئية 12 core',
          'code': 'FIBER-001',
          'category': 'fiber_cable',
          'quantity': 500.0,
          'unit': 'meter',
          'min_quantity': 100.0,
          'request_number': 'REQ-2024-002',
          'is_active': true,
        },
        {
          'name': 'لحام نحاس 2.5mm',
          'code': 'WELD-001',
          'category': 'copper_welding',
          'quantity': 8.0,
          'unit': 'piece',
          'min_quantity': 10.0,
          'request_number': 'REQ-2024-003',
          'is_active': true,
        },
        {
          'name': 'لحام فايبر SC',
          'code': 'FIBER-WELD-001',
          'category': 'fiber_welding',
          'quantity': 25.0,
          'unit': 'piece',
          'min_quantity': 5.0,
          'request_number': 'REQ-2024-004',
          'is_active': true,
        },
        {
          'name': 'مفك صغير',
          'code': 'TOOL-001',
          'category': 'other',
          'quantity': 0.0,
          'unit': 'piece',
          'min_quantity': 3.0,
          'request_number': 'REQ-2024-005',
          'is_active': true,
        },
      ];

      // إدراج الأصناف
      for (final itemData in sampleItemsData) {
        await supabase.from('items').insert(itemData);
      }

      // الحصول على الأصناف المدرجة لاستخدام معرفاتها في الحركات
      final items = await supabase.from('items').select('id, name');

      if (items.isNotEmpty) {
        // إنشاء حركات تجريبية (بدون معرفات مخصصة)
        final sampleTransactionsData = [
          {
            'item_id': items[0]['id'],
            'item_name': items[0]['name'],
            'type': 'incoming',
            'quantity': 200.0,
            'unit': 'متر',
            'date': DateTime.now()
                .subtract(const Duration(days: 25))
                .toIso8601String(),
            'responsible_person': 'أحمد محمد',
            'request_number': 'REQ-2024-001',
            'created_by': 'admin',
            'category': 'كابل نحاس',
          },
          {
            'item_id': items[0]['id'],
            'item_name': items[0]['name'],
            'type': 'outgoing',
            'quantity': 50.0,
            'unit': 'متر',
            'date': DateTime.now()
                .subtract(const Duration(days: 20))
                .toIso8601String(),
            'responsible_person': 'محمد علي',
            'created_by': 'admin',
            'category': 'كابل نحاس',
            'spending_reason': 'صيانة شبكة',
            'central': 'العريش',
            'recipient_name': 'فريق الصيانة',
          },
          {
            'item_id': items[1]['id'],
            'item_name': items[1]['name'],
            'type': 'incoming',
            'quantity': 600.0,
            'unit': 'متر',
            'date': DateTime.now()
                .subtract(const Duration(days: 20))
                .toIso8601String(),
            'responsible_person': 'علي أحمد',
            'request_number': 'REQ-2024-002',
            'created_by': 'admin',
            'category': 'كابل فايبر',
          },
        ];

        // إدراج الحركات
        for (final transactionData in sampleTransactionsData) {
          await supabase.from('transactions').insert(transactionData);
        }
      }

      print('✅ تم إنشاء البيانات التجريبية بنجاح');
    } catch (e) {
      print('❌ خطأ في إنشاء البيانات التجريبية: $e');
    }
  }
}
