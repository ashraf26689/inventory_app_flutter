// ===== ورقة التصفية السفلية =====
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_button.dart';

class FilterBottomSheet extends StatefulWidget {
  final Map<String, dynamic> initialFilters;
  final Function(Map<String, dynamic>) onApplyFilters;
  final List<String> categories;
  final List<String> statuses;

  const FilterBottomSheet({
    Key? key,
    required this.initialFilters,
    required this.onApplyFilters,
    required this.categories,
    required this.statuses,
  }) : super(key: key);

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late Map<String, dynamic> _filters;

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.initialFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  'تصفية النتائج',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _filters.clear();
                    });
                  },
                  child: const Text('مسح الكل'),
                ),
              ],
            ),
          ),
          
          // Filters
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Filter
                  _buildFilterSection(
                    title: 'الفئة',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.categories.map((category) {
                        final isSelected = _filters['category'] == category;
                        return FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _filters['category'] = category;
                              } else {
                                _filters.remove('category');
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Status Filter
                  _buildFilterSection(
                    title: 'الحالة',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.statuses.map((status) {
                        final isSelected = _filters['status'] == status;
                        return FilterChip(
                          label: Text(status),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _filters['status'] = status;
                              } else {
                                _filters.remove('status');
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Quantity Range
                  _buildFilterSection(
                    title: 'نطاق الكمية',
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'من',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  _filters['minQuantity'] = double.tryParse(value);
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'إلى',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  _filters['maxQuantity'] = double.tryParse(value);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Actions
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إلغاء'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AnimatedButton(
                    onPressed: () {
                      widget.onApplyFilters(_filters);
                      Navigator.pop(context);
                    },
                    child: const Text('تطبيق'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}