import 'package:flutter/material.dart';
import '../../constants/app_texts.dart';
import '../../constants/app_colors.dart';
import '../../models/transaction.dart';
import '../../models/item.dart';
import '../../services/database_service.dart';
import '../../widgets/app_drawer.dart';

class TransactionListView extends StatefulWidget {
  const TransactionListView({Key? key}) : super(key: key);

  @override
  State<TransactionListView> createState() => _TransactionListViewState();
}

class _TransactionListViewState extends State<TransactionListView> {
  final DatabaseService _databaseService = DatabaseService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Transaction> _transactions = [];
  List<Transaction> _filteredTransactions = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // متغيرات حالة للأصناف
  List<Item> _allItems = [];
  List<Item> _filteredItems = [];
  String _itemSearchQuery = '';
  bool _isLoadingItems = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _loadItems();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    try {
      final transactions = await _databaseService.getAllTransactions();
      setState(() {
        _transactions = transactions;
        _filteredTransactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      print('خطأ في تحميل الحركات: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadItems() async {
    setState(() => _isLoadingItems = true);
    final items = await _databaseService.getAllItems();
    setState(() {
      _allItems = items;
      _filteredItems = items;
      _isLoadingItems = false;
    });
  }

  void _filterTransactions() {
    setState(() {
      _filteredTransactions = _transactions.where((transaction) {
        return transaction.itemName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            (transaction.notes
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false) ||
            transaction.id.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    });
  }

  void _filterItems(String query) {
    setState(() {
      _itemSearchQuery = query;
      if (query.isEmpty) {
        _filteredItems = _allItems;
      } else {
        _filteredItems = _allItems.where((item) {
          return item.name.toLowerCase().contains(query.toLowerCase()) ||
              item.code.toLowerCase().contains(query.toLowerCase()) ||
              item.categoryDisplayName
                  .toLowerCase()
                  .contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  String _getTransactionTypeText(TransactionType type) {
    switch (type) {
      case TransactionType.incoming:
        return 'وارد';
      case TransactionType.outgoing:
        return 'صادر';
    }
  }

  Color _getTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.incoming:
        return AppColors.incoming;
      case TransactionType.outgoing:
        return AppColors.outgoing;
    }
  }

  IconData _getTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.incoming:
        return Icons.arrow_downward;
      case TransactionType.outgoing:
        return Icons.arrow_upward;
    }
  }

  void _showAddTransactionDialog() {
    final _formKey = GlobalKey<FormState>();
    String selectedItemId = '';
    String selectedItemName = '';
    double currentQuantity = 0;
    String currentUnit = '';
    TransactionType type = TransactionType.incoming;
    double quantity = 0;
    String responsiblePerson = '';
    String notes = '';
    String location = '';
    String category = '';
    String spendingReason = '';
    String central = '';
    String recipientName = '';
    String requestNumber = '';

    final List<String> centralOptions = [
      'العريش',
      'السلام',
      'المساعيد',
      'بئر العبد',
      'الشيخ زويد'
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('إضافة حركة جديدة'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // اختيار الصنف
                  _isLoadingItems
                      ? const Center(child: CircularProgressIndicator())
                      : DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'الصنف'),
                          value: selectedItemId.isEmpty ? null : selectedItemId,
                          items: _allItems
                              .map((item) => DropdownMenuItem(
                                    value: item.id,
                                    child: Text(
                                        '${item.name} (${item.code}) - ${item.quantity} ${item.unitDisplayName}'),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              final selectedItem = _allItems
                                  .firstWhere((item) => item.id == value);
                              setState(() {
                                selectedItemId = value;
                                selectedItemName = selectedItem.name;
                                category = selectedItem.categoryDisplayName;
                                currentQuantity = selectedItem.quantity;
                                currentUnit = selectedItem.unitDisplayName;
                              });
                            }
                          },
                          validator: (value) => value == null ? 'مطلوب' : null,
                        ),
                  if (selectedItemId.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.inventory,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'الكمية الحالية: $currentQuantity $currentUnit',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  // نوع الحركة
                  DropdownButtonFormField<TransactionType>(
                    value: type,
                    decoration: const InputDecoration(labelText: 'نوع الحركة'),
                    items: TransactionType.values
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(_getTransactionTypeText(t)),
                            ))
                        .toList(),
                    onChanged: (value) {
                      type = value!;
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 12),
                  // الكمية
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'الكمية'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                    onChanged: (v) => quantity = double.tryParse(v) ?? 0,
                  ),
                  const SizedBox(height: 12),
                  // رقم كشف الطلب (فقط للوارد)
                  if (type == TransactionType.incoming) ...[
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'رقم كشف الطلب'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'مطلوب للوارد' : null,
                      onChanged: (v) => requestNumber = v,
                    ),
                    const SizedBox(height: 12),
                  ],
                  // الشخص المسؤول
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'الشخص المسؤول'),
                    validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                    onChanged: (v) => responsiblePerson = v,
                  ),
                  const SizedBox(height: 12),
                  // الحقول الخاصة بالصادر
                  if (type == TransactionType.outgoing) ...[
                    // السنترال
                    DropdownButtonFormField<String>(
                      value: central.isEmpty ? null : central,
                      decoration: const InputDecoration(labelText: 'السنترال'),
                      items: centralOptions
                          .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (value) => central = value ?? '',
                    ),
                    const SizedBox(height: 12),
                    // اسم المنصرف إليه
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'اسم المنصرف إليه'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'مطلوب للصادر' : null,
                      onChanged: (v) => recipientName = v,
                    ),
                    const SizedBox(height: 12),
                    // أسباب الصرف
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'أسباب الصرف'),
                      maxLines: 2,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'مطلوب للصادر' : null,
                      onChanged: (v) => spendingReason = v,
                    ),
                    const SizedBox(height: 12),
                  ],
                  // الملاحظات
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'الملاحظات'),
                    maxLines: 3,
                    onChanged: (v) => notes = v,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  if (_formKey.currentState!.validate() &&
                      selectedItemId.isNotEmpty) {
                    // إنشاء بيانات الحركة بدون معرف (سيتم إنشاؤه تلقائياً)
                    final transactionData = {
                      'item_id': selectedItemId,
                      'item_name': selectedItemName,
                      'type': type.toString().split('.').last,
                      'quantity': quantity,
                      'unit': currentUnit,
                      'date': DateTime.now().toIso8601String(),
                      'responsible_person': responsiblePerson,
                      'location': location.isNotEmpty ? location : null,
                      'notes': notes.isNotEmpty ? notes : null,
                      'request_number':
                          requestNumber.isNotEmpty ? requestNumber : null,
                      'created_by': 'admin',
                      'category': category.isNotEmpty ? category : null,
                      'spending_reason':
                          spendingReason.isNotEmpty ? spendingReason : null,
                      'central': central.isNotEmpty ? central : null,
                      'recipient_name':
                          recipientName.isNotEmpty ? recipientName : null,
                    };

                    await _databaseService.supabase
                        .from('transactions')
                        .insert(transactionData);
                    await _loadTransactions();
                    if (mounted) Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('تمت إضافة الحركة بنجاح')));
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('حدث خطأ أثناء إضافة الحركة: $e')),
                  );
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu, color: AppColors.textDark),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(AppTexts.transactions),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddTransactionDialog,
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: '/transactions'),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Column(
          children: [
            // ===== شريط البحث =====
            Container(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 2,
                shadowColor: Colors.black.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: AppColors.cardBorder,
                    width: 1,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: AppColors.cardGradient,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'البحث في الحركات...',
                      border: InputBorder.none,
                      icon: Icon(
                        Icons.search,
                        color: AppColors.textLight,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: AppColors.textLight,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                                _filterTransactions();
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                      _filterTransactions();
                    },
                  ),
                ),
              ),
            ),

            // ===== قائمة الحركات =====
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _filteredTransactions.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: _filteredTransactions.length,
                          itemBuilder: (context, index) {
                            final transaction = _filteredTransactions[index];
                            final typeColor = _getTypeColor(transaction.type);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Card(
                                elevation: 4,
                                shadowColor: Colors.black.withOpacity(0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: AppColors.cardBorder,
                                    width: 1,
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: AppColors.cardGradient,
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(20),
                                    leading: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: typeColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        _getTypeIcon(transaction.type),
                                        color: typeColor,
                                        size: 24,
                                      ),
                                    ),
                                    title: Text(
                                      transaction.itemName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textDark,
                                          ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 8),
                                        if (transaction.notes?.isNotEmpty ==
                                            true)
                                          Text(
                                            transaction.notes!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: AppColors.textLight,
                                                ),
                                          ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            _InfoChip(
                                              icon: Icons.swap_horiz,
                                              label: _getTransactionTypeText(
                                                  transaction.type),
                                              color: typeColor,
                                            ),
                                            const SizedBox(width: 8),
                                            _InfoChip(
                                              icon: Icons.inventory,
                                              label:
                                                  '${transaction.quantity} ${transaction.unit}',
                                              color: AppColors.success,
                                            ),
                                            const SizedBox(width: 8),
                                            _InfoChip(
                                              icon: Icons.calendar_today,
                                              label: _formatDate(
                                                  transaction.createdAt),
                                              color: AppColors.info,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTransactionDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textInverse,
        icon: const Icon(Icons.add),
        label: const Text('حركة جديدة'),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.textLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.swap_horiz_outlined,
                size: 64,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد حركات',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'ابدأ بتسجيل حركات جديدة للمخزون',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textLight,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showAddTransactionDialog,
              icon: const Icon(Icons.add),
              label: const Text('حركة جديدة'),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== شريحة المعلومات =====
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
