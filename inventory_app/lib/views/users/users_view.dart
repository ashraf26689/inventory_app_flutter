import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_texts.dart';
import '../../models/user.dart';
import '../../services/database_service.dart';
import '../../widgets/app_drawer.dart';

class UsersView extends StatefulWidget {
  const UsersView({Key? key}) : super(key: key);

  @override
  State<UsersView> createState() => _UsersViewState();
}

class _UsersViewState extends State<UsersView> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<User> _users = [];
  List<User> _filteredUsers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedRole = 'الكل';

  final List<String> _roles = ['الكل', 'مدير', 'مشرف', 'مستخدم', 'محاسب'];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _databaseService.getAllUsers();
      setState(() {
        _users = users;
        _filteredUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      print('خطأ في تحميل المستخدمين: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterUsers() {
    setState(() {
      _filteredUsers = _users.where((user) {
        final matchesSearch = user.name
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            user.username.toLowerCase().contains(_searchQuery.toLowerCase());

        final matchesRole =
            _selectedRole == 'الكل' || user.roleDisplayName == _selectedRole;

        return matchesSearch && matchesRole;
      }).toList();
    });
  }

  Color _getRoleColor(String roleDisplayName) {
    switch (roleDisplayName) {
      case 'مدير':
        return AppColors.error;
      case 'مشرف':
        return AppColors.warning;
      case 'مستخدم':
        return AppColors.primary;
      case 'محاسب':
        return AppColors.success;
      default:
        return AppColors.textLight;
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
        title: const Text('إدارة المستخدمين'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddUserDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: '/users'),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Column(
          children: [
            // شريط البحث
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
                      hintText: 'البحث في المستخدمين...',
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
                                _filterUsers();
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                      _filterUsers();
                    },
                  ),
                ),
              ),
            ),

            // شريط التصفية السريع
            if (_selectedRole != 'الكل')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(_selectedRole),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          setState(() {
                            _selectedRole = 'الكل';
                          });
                          _filterUsers();
                        },
                        backgroundColor:
                            _getRoleColor(_selectedRole).withOpacity(0.1),
                        side: BorderSide(color: _getRoleColor(_selectedRole)),
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedRole = 'الكل';
                        });
                        _filterUsers();
                      },
                      icon: const Icon(Icons.clear_all),
                      label: const Text('مسح الكل'),
                    ),
                  ],
                ),
              ),

            // قائمة المستخدمين
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _filteredUsers.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];
                            final roleColor =
                                _getRoleColor(user.roleDisplayName);

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
                                        color: roleColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.person,
                                        color: roleColor,
                                        size: 24,
                                      ),
                                    ),
                                    title: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            user.name,
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
                                            color: roleColor.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color:
                                                    roleColor.withOpacity(0.3)),
                                          ),
                                          child: Text(
                                            user.roleDisplayName,
                                            style: TextStyle(
                                              color: roleColor,
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
                                              icon: Icons.email,
                                              label: user.username,
                                              color: AppColors.secondary,
                                            ),
                                            const SizedBox(width: 8),
                                            _InfoChip(
                                              icon: Icons.calendar_today,
                                              label:
                                                  _formatDate(user.createdAt),
                                              color: AppColors.info,
                                            ),
                                            const SizedBox(width: 8),
                                            _InfoChip(
                                              icon: user.isActive
                                                  ? Icons.check_circle
                                                  : Icons.cancel,
                                              label: user.isActive
                                                  ? 'مفعل'
                                                  : 'معطل',
                                              color: user.isActive
                                                  ? AppColors.success
                                                  : AppColors.error,
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
                                            _showEditUserDialog(context, user);
                                            break;
                                          case 'delete':
                                            _showDeleteDialog(context, user);
                                            break;
                                          case 'toggle':
                                            _toggleUserStatus(user);
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
                                              const Text('تعديل'),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'toggle',
                                          child: Row(
                                            children: [
                                              Icon(
                                                user.isActive
                                                    ? Icons.block
                                                    : Icons.check_circle,
                                                color: user.isActive
                                                    ? AppColors.error
                                                    : AppColors.success,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(user.isActive
                                                  ? 'تعطيل'
                                                  : 'تفعيل'),
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
                                              const Text('حذف'),
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
        onPressed: _showAddUserDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textInverse,
        icon: const Icon(Icons.add),
        label: const Text('إضافة مستخدم'),
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
                Icons.people_outline,
                size: 64,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'لا يوجد مستخدمين',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'ابدأ بإضافة مستخدمين جدد للنظام',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textLight,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showAddUserDialog,
              icon: const Icon(Icons.add),
              label: const Text('إضافة مستخدم جديد'),
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
        title: const Text('تصفية المستخدمين'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'الدور',
                border: OutlineInputBorder(),
              ),
              items: _roles.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(role),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
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
              _filterUsers();
              Navigator.pop(context);
            },
            child: const Text('تطبيق'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المستخدم'),
        content: Text('هل أنت متأكد من حذف المستخدم "${user.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _databaseService.deleteUser(user.id);
                await _loadUsers();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حذف المستخدم بنجاح')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('خطأ في حذف المستخدم: $e')),
                  );
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

  void _toggleUserStatus(User user) async {
    try {
      final updatedUser = user.copyWith(isActive: !user.isActive);
      await _databaseService.updateUser(updatedUser);
      await _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              user.isActive
                  ? 'تم تعطيل المستخدم بنجاح'
                  : 'تم تفعيل المستخدم بنجاح',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحديث حالة المستخدم: $e')),
        );
      }
    }
  }

  void _showAddUserDialog() {
    final _formKey = GlobalKey<FormState>();
    String name = '';
    String username = '';
    String password = '';
    UserRole role = UserRole.user;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة مستخدم جديد'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'الاسم الكامل'),
                  validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                  onChanged: (v) => name = v,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'اسم المستخدم'),
                  validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                  onChanged: (v) => username = v,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'كلمة المرور'),
                  obscureText: true,
                  validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                  onChanged: (v) => password = v,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<UserRole>(
                  value: role,
                  decoration: const InputDecoration(labelText: 'الدور'),
                  items: [
                    DropdownMenuItem(
                        value: UserRole.admin, child: const Text('مدير')),
                    DropdownMenuItem(
                        value: UserRole.manager, child: const Text('مشرف')),
                    DropdownMenuItem(
                        value: UserRole.user, child: const Text('مستخدم')),
                    DropdownMenuItem(
                        value: UserRole.accountant, child: const Text('محاسب')),
                  ],
                  onChanged: (v) => role = v!,
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
                // إنشاء بيانات المستخدم بدون معرف (سيتم إنشاؤه تلقائياً)
                final userData = {
                  'name': name,
                  'username': username,
                  'password': password,
                  'role': role.toString().split('.').last,
                  'is_active': true,
                };

                try {
                  await _databaseService.supabase
                      .from('users')
                      .insert(userData);
                  await _loadUsers();
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تمت إضافة المستخدم بنجاح')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('خطأ في إضافة المستخدم: $e')),
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

  void _showEditUserDialog(BuildContext context, User user) {
    final _formKey = GlobalKey<FormState>();
    String name = user.name;
    String username = user.username;
    String password = '';
    UserRole role = user.role;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل المستخدم'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'الاسم الكامل'),
                  initialValue: name,
                  validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                  onChanged: (v) => name = v,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'اسم المستخدم'),
                  initialValue: username,
                  validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                  onChanged: (v) => username = v,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'كلمة المرور الجديدة (اختياري)'),
                  obscureText: true,
                  onChanged: (v) => password = v,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<UserRole>(
                  value: role,
                  decoration: const InputDecoration(labelText: 'الدور'),
                  items: [
                    DropdownMenuItem(
                        value: UserRole.admin, child: const Text('مدير')),
                    DropdownMenuItem(
                        value: UserRole.manager, child: const Text('مشرف')),
                    DropdownMenuItem(
                        value: UserRole.user, child: const Text('مستخدم')),
                    DropdownMenuItem(
                        value: UserRole.accountant, child: const Text('محاسب')),
                  ],
                  onChanged: (v) => role = v!,
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
                // تحديث بيانات المستخدم
                final userData = {
                  'name': name,
                  'username': username,
                  'role': role.toString().split('.').last,
                };

                // إضافة كلمة المرور فقط إذا تم تغييرها
                if (password.isNotEmpty) {
                  userData['password'] = password;
                }

                try {
                  await _databaseService.supabase
                      .from('users')
                      .update(userData)
                      .eq('id', user.id);
                  await _loadUsers();
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم تحديث المستخدم بنجاح')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('خطأ في تحديث المستخدم: $e')),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// شريحة المعلومات
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
