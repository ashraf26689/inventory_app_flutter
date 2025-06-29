import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../models/item.dart';
import '../models/transaction.dart';
import '../constants/app_texts.dart';

class ExportService {
  static Future<String?> exportItemsToExcel(List<Item> items) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['الأصناف'];

      // إضافة العناوين
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
          .value = 'اسم الصنف';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
          .value = 'رمز الصنف';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0))
          .value = 'الفئة';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0))
          .value = 'الكمية';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0))
          .value = 'الوحدة';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0))
          .value = 'الحد الأدنى';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0))
          .value = 'الحالة';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 0))
          .value = 'تاريخ الإنشاء';

      // تنسيق العناوين
      for (int i = 0; i < 8; i++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
            .cellStyle = CellStyle(
          bold: true,
          horizontalAlign: HorizontalAlign.Center,
          backgroundColorHex: '#E3F2FD',
        );
      }

      // إضافة البيانات
      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        final row = i + 1;

        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
            .value = item.name;
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
            .value = item.code;
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
            .value = item.categoryDisplayName;
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
            .value = item.quantity;
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
            .value = item.unitDisplayName;
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
            .value = item.minQuantity;
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row))
            .value = item.statusText;
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row))
            .value = item.createdAt.toString().split(' ')[0];
      }

      return await _saveExcelFile(
          excel, 'الأصناف_${DateTime.now().millisecondsSinceEpoch}.xlsx');
    } catch (e) {
      print('خطأ في تصدير الأصناف: $e');
      return null;
    }
  }

  static Future<String?> exportTransactionsToExcel(
      List<Transaction> transactions, List<Item> items) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['العمليات'];

      // إضافة العناوين
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
          .value = 'التاريخ';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
          .value = 'اسم الصنف';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0))
          .value = 'نوع العملية';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0))
          .value = 'الكمية';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0))
          .value = 'الشخص المسؤول';
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0))
          .value = 'الملاحظات';

      // تنسيق العناوين
      for (int i = 0; i < 6; i++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
            .cellStyle = CellStyle(
          bold: true,
          horizontalAlign: HorizontalAlign.Center,
          backgroundColorHex: '#E3F2FD',
        );
      }

      // إضافة البيانات
      for (int i = 0; i < transactions.length; i++) {
        final transaction = transactions[i];
        final row = i + 1;

        // البحث عن الصنف المرتبط
        final item = items.firstWhere(
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

        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
            .value = transaction.date.toString().split(' ')[0];
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
            .value = item.name;
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
            .value = transaction.typeDisplayName;
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
            .value = transaction.quantity;
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
            .value = transaction.responsiblePerson;
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
            .value = transaction.notes ?? '';
      }

      return await _saveExcelFile(
          excel, 'العمليات_${DateTime.now().millisecondsSinceEpoch}.xlsx');
    } catch (e) {
      print('خطأ في تصدير العمليات: $e');
      return null;
    }
  }

  static Future<String?> exportSummaryReport(
      List<Item> items, List<Transaction> transactions) async {
    try {
      final excel = Excel.createExcel();

      // صفحة الملخص
      final summarySheet = excel['الملخص'];

      // إحصائيات عامة
      summarySheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
          .value = 'تقرير المخزون';
      summarySheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
          .cellStyle = CellStyle(
        bold: true,
        fontSize: 16,
        horizontalAlign: HorizontalAlign.Center,
      );

      summarySheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2))
          .value = 'تاريخ التقرير:';
      summarySheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 2))
          .value = DateTime.now().toString().split(' ')[0];

      summarySheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 4))
          .value = 'إجمالي الأصناف:';
      summarySheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 4))
          .value = items.length;

      summarySheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 5))
          .value = 'إجمالي الكمية:';
      summarySheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 5))
          .value = items.fold<double>(0, (sum, item) => sum + item.quantity);

      summarySheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 6))
          .value = 'الأصناف منخفضة المخزون:';
      summarySheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 6))
              .value =
          items.where((item) => item.quantity <= item.minQuantity).length;

      summarySheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 7))
          .value = 'إجمالي العمليات:';
      summarySheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 7))
          .value = transactions.length;

      // صفحة الأصناف حسب الفئة
      final categorySheet = excel['الأصناف_حسب_الفئة'];
      categorySheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
          .value = 'الفئة';
      categorySheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
          .value = 'عدد الأصناف';
      categorySheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0))
          .value = 'إجمالي الكمية';

      final categoryStats = <String, Map<String, dynamic>>{};
      for (final item in items) {
        final category = item.categoryDisplayName;
        if (!categoryStats.containsKey(category)) {
          categoryStats[category] = {'count': 0, 'quantity': 0.0};
        }
        categoryStats[category]!['count'] =
            (categoryStats[category]!['count'] as int) + 1;
        categoryStats[category]!['quantity'] =
            (categoryStats[category]!['quantity'] as double) + item.quantity;
      }

      int row = 1;
      for (final entry in categoryStats.entries) {
        categorySheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
            .value = entry.key;
        categorySheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
            .value = entry.value['count'];
        categorySheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
            .value = entry.value['quantity'];
        row++;
      }

      return await _saveExcelFile(
          excel, 'تقرير_المخزون_${DateTime.now().millisecondsSinceEpoch}.xlsx');
    } catch (e) {
      print('خطأ في تصدير التقرير الملخص: $e');
      return null;
    }
  }

  static Future<String?> _saveExcelFile(Excel excel, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(excel.encode()!);
      return file.path;
    } catch (e) {
      print('خطأ في حفظ الملف: $e');
      return null;
    }
  }

  static Future<void> openFile(String filePath) async {
    try {
      await OpenFile.open(filePath);
    } catch (e) {
      print('خطأ في فتح الملف: $e');
    }
  }
}
