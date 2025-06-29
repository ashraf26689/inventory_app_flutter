import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_texts.dart';
import '../../services/database_service.dart';
import '../../widgets/app_drawer.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../models/transaction.dart';

class SettingsView extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;
  const SettingsView(
      {Key? key, this.isDarkMode = false, required this.onDarkModeChanged})
      : super(key: key);

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final DatabaseService _databaseService = DatabaseService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // إعدادات النظام
  bool _notificationsEnabled = true;
  bool _autoBackupEnabled = true;
  String _language = 'العربية';
  String _currency = 'جنيه مصري';
  int _backupFrequency = 7; // أيام
  double _lowStockThreshold = 10.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // هنا يمكن تحميل الإعدادات من التخزين المحلي
    // حالياً نستخدم القيم الافتراضية
  }

  String _getBackupFrequencyDisplay() {
    switch (_backupFrequency) {
      case 1:
        return 'كل يوم';
      case 3:
        return 'كل 3 أيام';
      case 7:
        return 'كل أسبوع';
      case 30:
        return 'كل شهر';
      default:
        return 'كل أسبوع';
    }
  }

  Future<void> _saveSettings() async {
    // هنا يمكن حفظ الإعدادات إلى التخزين المحلي
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ الإعدادات بنجاح')),
      );
    }
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
        title: const Text('الإعدادات'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: '/settings'),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // إعدادات عامة
            _buildSectionCard(
              title: 'إعدادات عامة',
              icon: Icons.settings,
              children: [
                _buildSwitchTile(
                  title: 'الإشعارات',
                  subtitle: 'تفعيل إشعارات النظام',
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                  icon: Icons.notifications,
                ),
                _buildSwitchTile(
                  title: 'النسخ الاحتياطي التلقائي',
                  subtitle: 'إنشاء نسخة احتياطية تلقائياً',
                  value: _autoBackupEnabled,
                  onChanged: (value) {
                    setState(() {
                      _autoBackupEnabled = value;
                    });
                  },
                  icon: Icons.backup,
                ),
                _buildSwitchTile(
                  title: 'الوضع المظلم',
                  subtitle: 'تفعيل المظهر الداكن',
                  value: widget.isDarkMode,
                  onChanged: widget.onDarkModeChanged,
                  icon: Icons.dark_mode,
                ),
                _buildDropdownTile(
                  title: 'اللغة',
                  subtitle: 'اختر لغة التطبيق',
                  value: _language,
                  items: ['العربية', 'English'],
                  onChanged: (value) {
                    setState(() {
                      _language = value!;
                    });
                  },
                  icon: Icons.language,
                ),
                _buildDropdownTile(
                  title: 'العملة',
                  subtitle: 'اختر عملة النظام',
                  value: _currency,
                  items: [
                    'جنيه مصري',
                    'دولار أمريكي',
                    'ريال سعودي',
                    'درهم إماراتي'
                  ],
                  onChanged: (value) {
                    setState(() {
                      _currency = value!;
                    });
                  },
                  icon: Icons.attach_money,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // إعدادات المخزون
            _buildSectionCard(
              title: 'إعدادات المخزون',
              icon: Icons.inventory,
              children: [
                _buildSliderTile(
                  title: 'حد المخزون المنخفض',
                  subtitle: 'النسبة المئوية للتنبيه',
                  value: _lowStockThreshold,
                  min: 1.0,
                  max: 50.0,
                  divisions: 49,
                  onChanged: (value) {
                    setState(() {
                      _lowStockThreshold = value;
                    });
                  },
                  icon: Icons.warning,
                ),
                _buildDropdownTile(
                  title: 'تكرار النسخ الاحتياطي',
                  subtitle: 'عدد الأيام بين النسخ',
                  value: _getBackupFrequencyDisplay(),
                  items: ['كل يوم', 'كل 3 أيام', 'كل أسبوع', 'كل شهر'],
                  onChanged: (value) {
                    setState(() {
                      switch (value) {
                        case 'كل يوم':
                          _backupFrequency = 1;
                          break;
                        case 'كل 3 أيام':
                          _backupFrequency = 3;
                          break;
                        case 'كل أسبوع':
                          _backupFrequency = 7;
                          break;
                        case 'كل شهر':
                          _backupFrequency = 30;
                          break;
                      }
                    });
                  },
                  icon: Icons.schedule,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // إدارة البيانات
            _buildSectionCard(
              title: 'إدارة البيانات',
              icon: Icons.storage,
              children: [
                _buildActionTile(
                  title: 'إنشاء نسخة احتياطية',
                  subtitle: 'تصدير جميع البيانات',
                  icon: Icons.backup,
                  onTap: () => _showBackupDialog(),
                ),
                _buildActionTile(
                  title: 'استعادة نسخة احتياطية',
                  subtitle: 'استيراد البيانات من ملف',
                  icon: Icons.restore,
                  onTap: () => _showRestoreDialog(),
                ),
                _buildActionTile(
                  title: 'تصدير البيانات',
                  subtitle: 'تصدير البيانات بصيغة Excel',
                  icon: Icons.file_download,
                  onTap: () => _showExportDialog(),
                ),
                _buildActionTile(
                  title: 'مسح جميع البيانات',
                  subtitle: 'حذف جميع البيانات نهائياً',
                  icon: Icons.delete_forever,
                  onTap: () => _showClearDataDialog(),
                  isDestructive: true,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // معلومات النظام
            _buildSectionCard(
              title: 'معلومات النظام',
              icon: Icons.info,
              children: [
                _buildInfoTile(
                  title: 'إصدار التطبيق',
                  subtitle: '1.0.0',
                  icon: Icons.app_settings_alt,
                ),
                _buildInfoTile(
                  title: 'تاريخ آخر تحديث',
                  subtitle: '2024-01-15',
                  icon: Icons.update,
                ),
                _buildInfoTile(
                  title: 'حجم قاعدة البيانات',
                  subtitle: '2.5 MB',
                  icon: Icons.storage,
                ),
                _buildActionTile(
                  title: 'تحديث التطبيق',
                  subtitle: 'التحقق من وجود تحديثات جديدة',
                  icon: Icons.system_update,
                  onTap: () => _checkForUpdates(),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // حول التطبيق
            _buildSectionCard(
              title: 'حول التطبيق',
              icon: Icons.help,
              children: [
                _buildActionTile(
                  title: 'دليل المستخدم',
                  subtitle: 'تعلم كيفية استخدام التطبيق',
                  icon: Icons.help_outline,
                  onTap: () => _showUserGuide(),
                ),
                _buildActionTile(
                  title: 'سياسة الخصوصية',
                  subtitle: 'قراءة سياسة الخصوصية',
                  icon: Icons.privacy_tip,
                  onTap: () => _showPrivacyPolicy(),
                ),
                _buildActionTile(
                  title: 'شروط الاستخدام',
                  subtitle: 'قراءة شروط الاستخدام',
                  icon: Icons.description,
                  onTap: () => _showTermsOfService(),
                ),
                _buildActionTile(
                  title: 'تواصل معنا',
                  subtitle: 'إرسال رسالة للدعم الفني',
                  icon: Icons.contact_support,
                  onTap: () => _contactSupport(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                  ),
                ],
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppColors.textLight,
          fontSize: 12,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppColors.textLight,
          fontSize: 12,
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        underline: Container(),
      ),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required IconData icon,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
          Text(
            '${value.toInt()}%',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive
              ? AppColors.error.withOpacity(0.1)
              : AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDestructive ? AppColors.error : AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDestructive ? AppColors.error : AppColors.textDark,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppColors.textLight,
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: AppColors.textLight,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppColors.textLight,
          fontSize: 12,
        ),
      ),
    );
  }

  // دوال الإجراءات
  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إنشاء نسخة احتياطية'),
        content: const Text('هل تريد إنشاء نسخة احتياطية من جميع البيانات؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('تم إنشاء النسخة الاحتياطية بنجاح')),
              );
            },
            child: const Text('إنشاء'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('استعادة نسخة احتياطية'),
        content: const Text('هل تريد استعادة البيانات من النسخة الاحتياطية؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم استعادة البيانات بنجاح')),
              );
            },
            child: const Text('استعادة'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصدير البيانات'),
        content: const Text('هل تريد تصدير جميع البيانات بصيغة Excel؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                // جلب البيانات
                final items = await _databaseService.getAllItems();
                final transactions =
                    await _databaseService.getAllTransactions();

                // إنشاء ملف Excel
                final excel = Excel.createExcel();
                final itemsSheet = excel['الأصناف'];
                final transactionsSheet = excel['الحركات'];

                // رؤوس الأعمدة للأصناف
                itemsSheet.appendRow(
                    ['الكود', 'الاسم', 'الفئة', 'الكمية', 'الوحدة', 'الوصف']);
                for (final item in items) {
                  itemsSheet.appendRow([
                    item.code,
                    item.name,
                    item.categoryDisplayName,
                    item.quantity,
                    item.unitDisplayName,
                    '',
                  ]);
                }

                // رؤوس الأعمدة للحركات
                transactionsSheet.appendRow([
                  'الكود',
                  'اسم الصنف',
                  'النوع',
                  'الكمية',
                  'الوحدة',
                  'التاريخ',
                  'الشخص المسؤول',
                  'الملاحظات'
                ]);
                for (final t in transactions) {
                  transactionsSheet.appendRow([
                    t.itemId,
                    t.itemName,
                    t.typeDisplayName,
                    t.quantity,
                    t.unit,
                    t.date.toString(),
                    t.responsiblePerson,
                    t.notes ?? '',
                  ]);
                }

                // حفظ الملف في Downloads
                final dir = await getDownloadsDirectory();
                final filePath =
                    '${dir!.path}/inventory_export_${DateTime.now().millisecondsSinceEpoch}.xlsx';
                final fileBytes = excel.encode();
                final file = File(filePath)
                  ..createSync(recursive: true)
                  ..writeAsBytesSync(fileBytes!);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('تم تصدير البيانات بنجاح إلى:\n$filePath')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('حدث خطأ أثناء التصدير: $e')),
                );
              }
            },
            child: const Text('تصدير'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح جميع البيانات'),
        content: const Text(
            'هل أنت متأكد من حذف جميع البيانات نهائياً؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم مسح جميع البيانات')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('مسح'),
          ),
        ],
      ),
    );
  }

  void _checkForUpdates() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('لا توجد تحديثات جديدة متاحة')),
    );
  }

  void _showUserGuide() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم فتح دليل المستخدم')),
    );
  }

  void _showPrivacyPolicy() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم فتح سياسة الخصوصية')),
    );
  }

  void _showTermsOfService() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم فتح شروط الاستخدام')),
    );
  }

  void _contactSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم فتح صفحة التواصل مع الدعم الفني')),
    );
  }
}
