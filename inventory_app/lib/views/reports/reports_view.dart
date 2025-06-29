import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_texts.dart';
import '../../models/item.dart';
import '../../models/transaction.dart';
import '../../services/database_service.dart';
import '../../services/export_service.dart';
import '../../widgets/app_drawer.dart';

class ReportsView extends StatefulWidget {
  const ReportsView({super.key});

  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseService _databaseService = DatabaseService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Filter states
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedItemType;
  String? _selectedTransactionType;

  // Data states
  List<Item> _items = [];
  List<Transaction> _transactions = [];
  Map<String, dynamic> _summaryData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final items = await _databaseService.getAllItems();
      final transactions = await _databaseService.getAllTransactions();

      setState(() {
        _items = items;
        _transactions = transactions;
        _calculateSummaryData();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  void _calculateSummaryData() {
    // Calculate summary statistics
    final totalItems = _items.length;
    final totalQuantity =
        _items.fold<double>(0, (sum, item) => sum + item.quantity);
    final lowStockItems =
        _items.where((item) => item.quantity <= item.minQuantity).length;
    final recentTransactions = _transactions
        .where((t) => DateTime.now().difference(t.date).inDays <= 30)
        .length;

    _summaryData = {
      'totalItems': totalItems,
      'totalQuantity': totalQuantity,
      'lowStockItems': lowStockItems,
      'recentTransactions': recentTransactions,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu, color: AppColors.textDark),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          AppTexts.reports,
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.textDark),
            onPressed: _loadData,
          ),
          IconButton(
            icon: Icon(Icons.filter_list, color: AppColors.textDark),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: '/reports'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Summary Cards
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                          child: _buildSummaryCard(
                        'Total Items',
                        _summaryData['totalItems'].toString(),
                        Icons.inventory,
                        AppColors.primary,
                      )),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _buildSummaryCard(
                        'Total Quantity',
                        _summaryData['totalQuantity'].toStringAsFixed(0),
                        Icons.attach_money,
                        AppColors.accent,
                      )),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _buildSummaryCard(
                        'Low Stock',
                        _summaryData['lowStockItems'].toString(),
                        Icons.warning,
                        AppColors.error,
                      )),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _buildSummaryCard(
                        'Recent Transactions',
                        _summaryData['recentTransactions'].toString(),
                        Icons.receipt_long,
                        AppColors.textDark,
                      )),
                    ],
                  ),
                ),

                // Tabs
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textDark.withOpacity(0.6),
                    indicatorColor: AppColors.primary,
                    tabs: const [
                      Tab(text: AppTexts.overview),
                      Tab(text: AppTexts.items),
                      Tab(text: AppTexts.transactions),
                      Tab(text: AppTexts.analytics),
                    ],
                  ),
                ),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(),
                      _buildItemsTab(),
                      _buildTransactionsTab(),
                      _buildAnalyticsTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    String arabicTitle = title;
    switch (title) {
      case 'Total Items':
        arabicTitle = AppTexts.totalItems;
        break;
      case 'Total Quantity':
        arabicTitle = AppTexts.totalQuantity;
        break;
      case 'Low Stock':
        arabicTitle = AppTexts.lowStockItems;
        break;
      case 'Recent Transactions':
        arabicTitle = AppTexts.recentTransactions;
        break;
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                arabicTitle,
                style: TextStyle(
                  color: AppColors.textDark.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Charts Row
          Row(
            children: [
              Expanded(
                child: _buildChartCard(
                  'Items by Category',
                  _buildPieChart(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildChartCard(
                  'Monthly Transactions',
                  _buildLineChart(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Activity
          _buildRecentActivityCard(),
        ],
      ),
    );
  }

  Widget _buildItemsTab() {
    final filteredItems = _items.where((item) {
      if (_selectedItemType != null &&
          item.categoryDisplayName != _selectedItemType) {
        return false;
      }
      return true;
    }).toList();

    return Column(
      children: [
        // Filters
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedItemType,
                  decoration: InputDecoration(
                    labelText: AppTexts.filterByType,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text(AppTexts.allTypes)),
                    ..._items
                        .map((item) => item.categoryDisplayName)
                        .toSet()
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        ),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedItemType = value);
                  },
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  final path =
                      await ExportService.exportItemsToExcel(filteredItems);
                  if (path != null) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                '${AppTexts.exportSuccess}\n${AppTexts.fileSaved}: $path')),
                      );
                      await ExportService.openFile(path);
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text(AppTexts.exportError)),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.download),
                label: const Text(AppTexts.exportToExcel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // Items Table
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text(AppTexts.itemName)),
                  DataColumn(label: Text(AppTexts.category)),
                  DataColumn(label: Text(AppTexts.quantity)),
                  DataColumn(label: Text(AppTexts.unit)),
                  DataColumn(label: Text(AppTexts.status)),
                ],
                rows: filteredItems.map((item) {
                  final isLowStock = item.quantity <= item.minQuantity;
                  return DataRow(
                    cells: [
                      DataCell(Text(item.name)),
                      DataCell(Text(item.categoryDisplayName)),
                      DataCell(Text(item.quantity.toString())),
                      DataCell(Text(item.unitDisplayName)),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isLowStock
                                ? AppColors.error
                                : AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isLowStock ? AppTexts.lowStock : AppTexts.inStock,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsTab() {
    final filteredTransactions = _transactions.where((transaction) {
      if (_startDate != null && transaction.date.isBefore(_startDate!)) {
        return false;
      }
      if (_endDate != null && transaction.date.isAfter(_endDate!)) {
        return false;
      }
      if (_selectedTransactionType != null) {
        final selectedType = _selectedTransactionType == 'IN'
            ? TransactionType.incoming
            : TransactionType.outgoing;
        if (transaction.type != selectedType) {
          return false;
        }
      }
      return true;
    }).toList();

    return Column(
      children: [
        // Filters
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedTransactionType,
                  decoration: InputDecoration(
                    labelText: AppTexts.filterByType,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text(AppTexts.allTypes)),
                    const DropdownMenuItem(
                        value: 'IN', child: Text(AppTexts.incoming)),
                    const DropdownMenuItem(
                        value: 'OUT', child: Text(AppTexts.outgoing)),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedTransactionType = value);
                  },
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  final path = await ExportService.exportTransactionsToExcel(
                      filteredTransactions, _items);
                  if (path != null) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                '${AppTexts.exportSuccess}\n${AppTexts.fileSaved}: $path')),
                      );
                      await ExportService.openFile(path);
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text(AppTexts.exportError)),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.download),
                label: const Text(AppTexts.exportToExcel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // Transactions Table
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text(AppTexts.date)),
                  DataColumn(label: Text(AppTexts.itemName)),
                  DataColumn(label: Text(AppTexts.transactionType)),
                  DataColumn(label: Text(AppTexts.quantity)),
                  DataColumn(label: Text(AppTexts.responsiblePerson)),
                ],
                rows: filteredTransactions.map((transaction) {
                  final item = _items.firstWhere(
                    (item) => item.id == transaction.itemId,
                    orElse: () => Item(
                      id: '0',
                      name: 'غير معروف',
                      code: '',
                      category: ItemCategory.other,
                      quantity: 0,
                      unit: ItemUnit.piece,
                      minQuantity: 0,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    ),
                  );

                  return DataRow(
                    cells: [
                      DataCell(Text(transaction.date.toString().split(' ')[0])),
                      DataCell(Text(item.name)),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: transaction.isIncoming
                                ? AppColors.primary
                                : AppColors.error,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            transaction.typeDisplayName == 'IN'
                                ? AppTexts.incoming
                                : AppTexts.outgoing,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                      DataCell(Text(transaction.quantity.toString())),
                      DataCell(Text(transaction.responsiblePerson)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Analytics Cards
          Row(
            children: [
              Expanded(
                child: _buildAnalyticsCard(
                  'Most Active Items',
                  _buildMostActiveItemsChart(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAnalyticsCard(
                  'Transaction Trends',
                  _buildTransactionTrendsChart(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Performance Metrics
          _buildPerformanceMetricsCard(),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(height: 200, child: chart),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, Widget content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    final typeCounts = <String, int>{};
    for (final item in _items) {
      typeCounts[item.categoryDisplayName] =
          (typeCounts[item.categoryDisplayName] ?? 0) + 1;
    }

    final sections = typeCounts.entries.map((entry) {
      final colors = [
        AppColors.primary,
        AppColors.accent,
        AppColors.error,
        AppColors.textDark
      ];
      final color =
          colors[typeCounts.keys.toList().indexOf(entry.key) % colors.length];

      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${entry.key}\n${entry.value}',
        color: color,
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }

  Widget _buildLineChart() {
    final monthlyData = <String, int>{};
    for (int i = 11; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i * 30));
      final month = '${date.month}/${date.year}';
      monthlyData[month] = 0;
    }

    for (final transaction in _transactions) {
      final month = '${transaction.date.month}/${transaction.date.year}';
      if (monthlyData.containsKey(month)) {
        monthlyData[month] = (monthlyData[month] ?? 0) + 1;
      }
    }

    final spots = monthlyData.entries.map((entry) {
      final index = monthlyData.keys.toList().indexOf(entry.key);
      return FlSpot(index.toDouble(), entry.value.toDouble());
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMostActiveItemsChart() {
    final itemTransactionCounts = <String, int>{};
    for (final transaction in _transactions) {
      final item = _items.firstWhere(
        (item) => item.id == transaction.itemId,
        orElse: () => Item(
          id: '0',
          name: 'Unknown',
          code: '',
          category: ItemCategory.other,
          quantity: 0,
          unit: ItemUnit.piece,
          minQuantity: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      itemTransactionCounts[item.name] =
          (itemTransactionCounts[item.name] ?? 0) + 1;
    }

    final sortedItems = itemTransactionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sortedItems.take(5).map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                flex: entry.value,
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Text(
                  entry.key,
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                entry.value.toString(),
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTransactionTrendsChart() {
    final inTransactions = _transactions.where((t) => t.isIncoming).length;
    final outTransactions = _transactions.where((t) => t.isOutgoing).length;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    'IN',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    inTransactions.toString(),
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    'OUT',
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    outTransactions.toString(),
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: _transactions.length.toDouble(),
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      toY: inTransactions.toDouble(),
                      color: AppColors.primary,
                      width: 40,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(
                      toY: outTransactions.toDouble(),
                      color: AppColors.error,
                      width: 40,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivityCard() {
    final recentTransactions = _transactions
      ..sort((a, b) => b.date.compareTo(a.date));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...recentTransactions.take(5).map((transaction) {
            final item = _items.firstWhere(
              (item) => item.id == transaction.itemId,
              orElse: () => Item(
                id: '0',
                name: 'Unknown',
                code: '',
                category: ItemCategory.other,
                quantity: 0,
                unit: ItemUnit.piece,
                minQuantity: 0,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            );

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: transaction.isIncoming
                          ? AppColors.primary
                          : AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${transaction.typeDisplayName} ${item.name}',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    transaction.date.toString().split(' ')[0],
                    style: TextStyle(
                      color: AppColors.textDark.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetricsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Metrics',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Average Items per Transaction',
                  (_items.length / _transactions.length).toStringAsFixed(1),
                  Icons.analytics,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  'Stock Turnover Rate',
                  '${(_transactions.length / _items.length).toStringAsFixed(1)}x',
                  Icons.trending_up,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textDark.withOpacity(0.6),
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Reports'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Date Range'),
              subtitle: Text(
                _startDate != null && _endDate != null
                    ? '${_startDate.toString().split(' ')[0]} to ${_endDate.toString().split(' ')[0]}'
                    : 'Select date range',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final DateTimeRange? range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (range != null) {
                  setState(() {
                    _startDate = range.start;
                    _endDate = range.end;
                  });
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _startDate = null;
                _endDate = null;
                _selectedItemType = null;
                _selectedTransactionType = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Clear All'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
