import 'package:flutter/material.dart';
import '../../constants/app_texts.dart';
import '../../constants/app_colors.dart';
import '../../models/item.dart';
import '../../services/database_service.dart';
import '../../widgets/app_drawer.dart';

class ItemListView extends StatefulWidget {
  const ItemListView({Key? key}) : super(key: key);

  @override
  State<ItemListView> createState() => _ItemListViewState();
}

class _ItemListViewState extends State<ItemListView> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Item> _items = [];
  List<Item> _filteredItems = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'الكل';
  String _selectedStatus = 'الكل';

  final List<String> _categories = [
    'الكل',
    'كابل نحاس',
    'كابل فايبر',
    'لحام نحاس',
    'لحام فايبر',
    'أخرى'
  ];
  final List<String> _statuses = ['الكل', 'متوفر', 'منخفض', 'نفذ'];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    try {
      final items = await _databaseService.getAllItems();
      setState(() {
        _items = items;
        _filteredItems = items;
        _isLoading = false;
      });
    } catch (e) {
      print('خطأ في تحميل الأصناف: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterItems() {
    setState(() {
      _filteredItems = _items.where((item) {
        final matchesSearch =
            item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (item.requestNumber
                        ?.toLowerCase()
                        .contains(_searchQuery.toLowerCase()) ??
                    false) ||
                item.code.toLowerCase().contains(_searchQuery.toLowerCase());

        final matchesCategory = _selectedCategory == 'الكل' ||
            item.categoryDisplayName == _selectedCategory;

        final matchesStatus = _selectedStatus == 'الكل' ||
            _getItemStatus(item) == _selectedStatus;

        return matchesSearch && matchesCategory && matchesStatus;
      }).toList();
    });
  }

  String _getItemStatus(Item item) {
    if (item.quantity <= 0) return 'نفذ';
    if (item.quantity <= item.minQuantity) return 'منخفض';
    return 'متوفر';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'متوفر':
        return AppColors.stockNormal;
      case 'منخفض':
        return AppColors.stockLow;
      case 'نفذ':
        return AppColors.stockOut;
      default:
        return AppColors.textLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isMediumScreen = screenSize.width >= 600 && screenSize.width < 1200;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu, color: AppColors.textDark),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(AppTexts.inventory),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddItemDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: '/items'),
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
                      hintText: 'البحث في الأصناف...',
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
                                _filterItems();
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                      _filterItems();
                    },
                  ),
                ),
              ),
            ),

            // ===== شريط التصفية السريع =====
            if (_selectedCategory != 'الكل' || _selectedStatus != 'الكل')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    if (_selectedCategory != 'الكل')
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: Chip(
                          label: Text(_selectedCategory),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setState(() {
                              _selectedCategory = 'الكل';
                            });
                            _filterItems();
                          },
                          backgroundColor: AppColors.primaryLight,
                          side: BorderSide(color: AppColors.primary),
                        ),
                      ),
                    if (_selectedStatus != 'الكل')
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: Chip(
                          label: Text(_selectedStatus),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setState(() {
                              _selectedStatus = 'الكل';
                            });
                            _filterItems();
                          },
                          backgroundColor:
                              _getStatusColor(_selectedStatus).withOpacity(0.1),
                          side: BorderSide(
                              color: _getStatusColor(_selectedStatus)),
                        ),
                      ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedCategory = 'الكل';
                          _selectedStatus = 'الكل';
                        });
                        _filterItems();
                      },
                      icon: const Icon(Icons.clear_all),
                      label: const Text('مسح الكل'),
                    ),
                  ],
                ),
              ),

            // ===== قائمة الأصناف =====
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _filteredItems.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: _filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = _filteredItems[index];
                            final status = _getItemStatus(item);
                            final statusColor = _getStatusColor(status);

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
                                        color:
                                            AppColors.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.inventory_2,
                                        color: AppColors.primary,
                                        size: 24,
                                      ),
                                    ),
                                    title: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.textDark,
                                                ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: statusColor.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: statusColor
                                                    .withOpacity(0.3)),
                                          ),
                                          child: Text(
                                            status,
                                            style: TextStyle(
                                              color: statusColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            _InfoChip(
                                              icon: Icons.qr_code,
                                              label: item.code,
                                              color: AppColors.secondary,
                                            ),
                                            const SizedBox(width: 8),
                                            _InfoChip(
                                              icon: Icons.category,
                                              label: item.categoryDisplayName,
                                              color: AppColors.info,
                                            ),
                                            const SizedBox(width: 8),
                                            _InfoChip(
                                              icon: Icons.inventory,
                                              label:
                                                  '${item.quantity} ${item.unitDisplayName}',
                                              color: AppColors.success,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: PopupMenuButton<String>(
                                      icon: Icon(
                                        Icons.more_vert,
                                        color: AppColors.textLight,
                                      ),
                                      onSelected: (value) {
                                        switch (value) {
                                          case 'edit':
                                            _showEditItemDialog(context, item);
                                            break;
                                          case 'delete':
                                            _showDeleteDialog(context, item);
                                            break;
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit,
                                                  color: AppColors.primary),
                                              const SizedBox(width: 8),
                                              Text('تعديل'),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete,
                                                  color: AppColors.error),
                                              const SizedBox(width: 8),
                                              Text('حذف'),
                                            ],
                                          ),
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
        onPressed: _showAddItemDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textInverse,
        icon: const Icon(Icons.add),
        label: const Text('إضافة صنف'),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
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
                Icons.inventory_2_outlined,
                size: 64,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد أصناف',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'ابدأ بإضافة أصناف جديدة إلى المخزون',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textLight,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: إضافة صنف جديد
              },
              icon: const Icon(Icons.add),
              label: const Text('إضافة صنف جديد'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصفية الأصناف'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'الفئة',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'الحالة',
                border: OutlineInputBorder(),
              ),
              items: _statuses.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              _filterItems();
              Navigator.pop(context);
            },
            child: const Text('تطبيق'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Item item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الصنف'),
        content: Text('هل أنت متأكد من حذف الصنف "${item.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _databaseService.deleteItem(item.id);
                await _loadItems();
                if (mounted) {
                  Navigator.pop(context);
                  Future.delayed(Duration.zero, () {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم حذف الصنف بنجاح')),
                      );
                    }
                  });
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  Future.delayed(Duration.zero, () {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('خطأ في حذف الصنف: $e')),
                      );
                    }
                  });
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showEditItemDialog(BuildContext context, Item item) {
    final _formKey = GlobalKey<FormState>();
    String name = item.name;
    String code = item.code;
    String category = item.categoryDisplayName;
    String unit = item.unitDisplayName;
    double quantity = item.quantity;
    double minQuantity = item.minQuantity;
    String requestNumber = item.requestNumber ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل الصنف'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'اسم الصنف'),
                  initialValue: name,
                  validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                  onChanged: (v) => name = v,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'رقم الشطب'),
                  initialValue: code,
                  validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                  onChanged: (v) => code = v,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'الفئة'),
                  items: [
                    'كابل نحاس',
                    'كابل فايبر',
                    'لحام نحاس',
                    'لحام فايبر',
                    'أخرى'
                  ]
                      .map((cat) =>
                          DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (v) => category = v!,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'الكمية'),
                  initialValue: quantity.toString(),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                  onChanged: (v) => quantity = double.tryParse(v) ?? 0,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: unit,
                  decoration: const InputDecoration(labelText: 'الوحدة'),
                  items: ['متر', 'قطعة', 'صندوق', 'بكرة', 'كجم', 'لتر']
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (v) => unit = v!,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'الحد الأدنى'),
                  initialValue: minQuantity.toString(),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => minQuantity = double.tryParse(v) ?? 0,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'رقم كشف الطلب'),
                  initialValue: requestNumber,
                  onChanged: (v) => requestNumber = v,
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
              if (_formKey.currentState!.validate()) {
                // تحديث بيانات الصنف باستخدام كائن Item ودالة updateItem
                final updatedItem = item.copyWith(
                  name: name,
                  code: code,
                  category: _categoryFromDisplayName(category),
                  quantity: quantity,
                  unit: _unitFromDisplayName(unit),
                  minQuantity: minQuantity,
                  requestNumber:
                      requestNumber.isNotEmpty ? requestNumber : null,
                  updatedAt: DateTime.now(),
                );
                try {
                  await _databaseService.updateItem(updatedItem);
                  await _loadItems();
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم تحديث الصنف بنجاح')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('خطأ في تحديث الصنف: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog() {
    final _formKey = GlobalKey<FormState>();
    String name = '';
    String code = '';
    String category = 'كابل نحاس';
    String unit = 'متر';
    double quantity = 0;
    double minQuantity = 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة صنف جديد'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'اسم الصنف'),
                  validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                  onChanged: (v) => name = v,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'رقم الشطب'),
                  validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                  onChanged: (v) => code = v,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'الفئة'),
                  items: [
                    'كابل نحاس',
                    'كابل فايبر',
                    'لحام نحاس',
                    'لحام فايبر',
                    'أخرى'
                  ]
                      .map((cat) =>
                          DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (v) => category = v!,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'الكمية'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                  onChanged: (v) => quantity = double.tryParse(v) ?? 0,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: unit,
                  decoration: const InputDecoration(labelText: 'الوحدة'),
                  items: ['متر', 'قطعة', 'صندوق', 'بكرة', 'كجم', 'لتر']
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (v) => unit = v!,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'الحد الأدنى'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => minQuantity = double.tryParse(v) ?? 0,
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
              if (_formKey.currentState!.validate()) {
                // إنشاء بيانات الصنف بدون معرف (سيتم إنشاؤه تلقائياً)
                final itemData = {
                  'name': name,
                  'code': code,
                  'category': _categoryToSupabase(category),
                  'quantity': quantity,
                  'unit': _unitToSupabase(unit),
                  'min_quantity': minQuantity,
                  'is_active': true,
                };

                await _databaseService.supabase.from('items').insert(itemData);
                await _loadItems();
                if (mounted) Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تمت إضافة الصنف بنجاح')));
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  ItemCategory _categoryFromDisplayName(String display) {
    switch (display) {
      case 'كابل نحاس':
        return ItemCategory.copperCable;
      case 'كابل فايبر':
        return ItemCategory.fiberCable;
      case 'لحام نحاس':
        return ItemCategory.copperWelding;
      case 'لحام فايبر':
        return ItemCategory.fiberWelding;
      case 'أخرى':
        return ItemCategory.other;
      default:
        return ItemCategory.other;
    }
  }

  ItemUnit _unitFromDisplayName(String display) {
    switch (display) {
      case 'متر':
        return ItemUnit.meter;
      case 'قطعة':
        return ItemUnit.piece;
      case 'صندوق':
        return ItemUnit.box;
      case 'بكرة':
        return ItemUnit.roll;
      case 'كجم':
        return ItemUnit.kg;
      case 'لتر':
        return ItemUnit.liter;
      default:
        return ItemUnit.piece;
    }
  }

  String _categoryToSupabase(String display) {
    switch (display) {
      case 'كابل نحاس':
        return 'كابل نحاس';
      case 'كابل فايبر':
        return 'كابل فايبر';
      case 'لحام نحاس':
        return 'لحام نحاس';
      case 'لحام فايبر':
        return 'لحام فايبر';
      case 'أخرى':
        return 'أخرى';
      default:
        return 'أخرى';
    }
  }

  String _unitToSupabase(String display) {
    switch (display) {
      case 'متر':
        return 'متر';
      case 'قطعة':
        return 'قطعة';
      case 'صندوق':
        return 'صندوق';
      case 'بكرة':
        return 'بكرة';
      case 'كجم':
        return 'كجم';
      case 'لتر':
        return 'لتر';
      default:
        return 'قطعة';
    }
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
