import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../domain/models/budget_by_month_model.dart';
import '../domain/models/budget_model.dart';
import '../domain/models/month_model.dart';
import '../domain/models/regular_payment_model.dart';
import '../domain/models/regular_payment_snapshot_model.dart';
import '../logger/logger.dart';

class DatabaseHelper {
  static const _databaseName = 'budget_manager.db';
  static const _databaseVersion = 4;

  static const _tableMonths = 'months';
  static const _tableBudgets = 'budgets';
  static const _tableBudgetByMonth = 'budget_by_month';
  static const _tableRegularPayments = 'regular_payments';
  static const _tableRegularPaymentSnapshots = 'regular_payment_snapshots';

  /// Maps each schema version to the SQL statements required to upgrade the
  /// database to that version from the previous one.
  ///
  /// To introduce a new migration:
  ///   1. Increment [_databaseVersion].
  ///   2. Add a new entry here whose key matches the new version number.
  ///
  /// The generic [_onUpgrade] handler applies every entry whose key is
  /// greater than the stored version and at most [_databaseVersion], in
  /// ascending order — so multi-version upgrades are handled automatically.
  static final Map<int, List<String>> _migrations = {
    2: [
      'ALTER TABLE $_tableMonths ADD COLUMN closedOn TEXT NULL',
      'ALTER TABLE $_tableBudgets ADD COLUMN hiddenOn TEXT NULL',
    ],
    3: [
      '''
      CREATE TABLE $_tableRegularPayments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        amount REAL NOT NULL DEFAULT 0.0,
        months_mask INTEGER NOT NULL DEFAULT 0
      )
      ''',
    ],
    4: [
      '''
      CREATE TABLE $_tableRegularPaymentSnapshots (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        month_id INTEGER NOT NULL UNIQUE,
        amount REAL NOT NULL DEFAULT 0.0,
        items_json TEXT NOT NULL DEFAULT '[]',
        FOREIGN KEY (month_id) REFERENCES $_tableMonths(id) ON DELETE CASCADE
      )
      ''',
    ],
  };

  Database? _database;
  Completer<Database>? _dbCompleter;

  Future<Database> get database async {
    if (_database != null) return _database!;
    if (_dbCompleter != null) return _dbCompleter!.future;
    _dbCompleter = Completer<Database>();
    try {
      _database = await _initDatabase();
      _dbCompleter!.complete(_database!);
    } catch (e, st) {
      _dbCompleter!.completeError(e, st);
      _dbCompleter = null;
      rethrow;
    }
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      // Enable foreign-key constraint enforcement (OFF by default in SQLite).
      // This activates the ON DELETE CASCADE rules defined in the schema.
      onOpen: (db) => db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableMonths (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        closedOn TEXT NULL,
        income REAL NOT NULL DEFAULT 0.0
      )
    ''');
    await db.execute('''
      CREATE TABLE $_tableBudgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        max_amount REAL NOT NULL DEFAULT 0.0,
        hiddenOn TEXT NULL)
    ''');
    await db.execute('''
      CREATE TABLE $_tableBudgetByMonth (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        month_id INTEGER NOT NULL,
        budget_id INTEGER NOT NULL,
        old_limit REAL NOT NULL DEFAULT 0.0,
        current_used REAL NOT NULL DEFAULT 0.0,
        FOREIGN KEY (month_id) REFERENCES $_tableMonths(id) ON DELETE CASCADE,
        FOREIGN KEY (budget_id) REFERENCES $_tableBudgets(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE $_tableRegularPayments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        amount REAL NOT NULL DEFAULT 0.0,
        months_mask INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE $_tableRegularPaymentSnapshots (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        month_id INTEGER NOT NULL UNIQUE,
        amount REAL NOT NULL DEFAULT 0.0,
        items_json TEXT NOT NULL DEFAULT '[]',
        FOREIGN KEY (month_id) REFERENCES $_tableMonths(id) ON DELETE CASCADE
      )
    ''');
  }

  /// Applies every pending migration whose target version is greater than
  /// [oldVersion] and at most [newVersion], in ascending order.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    for (int version = oldVersion + 1; version <= newVersion; version++) {
      final statements = _migrations[version];
      if (statements == null) {
        logger.w(
          'DatabaseHelper: no migration entry found for version $version '
          '(upgrading from $oldVersion to $newVersion). '
          'Add an entry to _migrations for version $version.',
        );
        continue;
      }
      for (final sql in statements) {
        await db.execute(sql);
      }
    }
  }

  // ── Month CRUD ──────────────────────────────────────────────────────────────

  Future<int> insertMonth(MonthModel month) async {
    final db = await database;
    return db.transaction<int>((txn) async {
      final monthId = await txn.insert(
        _tableMonths,
        month.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      if (month.budgets.isNotEmpty) {
        final batch = txn.batch();
        for (final bh in month.budgets) {
          batch.insert(
            _tableBudgetByMonth,
            BudgetByMonthModel(
              id: 0,
              monthId: monthId,
              budgetId: bh.budgetId,
              budgetName: bh.budgetName,
              oldLimit: bh.oldLimit,
              currentUsed: bh.currentUsed,
            ).toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        await batch.commit(noResult: true);
      }
      return monthId;
    });
  }

  Future<List<MonthModel>> getAllMonths() async {
    final db = await database;
    final rows = await db.query(_tableMonths, orderBy: 'date DESC');
    final futures = rows.map((row) async {
      final monthId = (row['id'] as num).toInt();
      final budgets = await getBudgetsByMonth(monthId);
      return MonthModel.fromMap(row, budgets);
    }).toList();
    return Future.wait(futures);
  }

  Future<MonthModel?> getMonth(int id) async {
    final db = await database;
    final rows = await db.query(_tableMonths, where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    final budgets = await getBudgetsByMonth(id);
    return MonthModel.fromMap(rows.first, budgets);
  }

  Future<int> updateMonth(MonthModel month) async {
    final db = await database;
    return db.update(
      _tableMonths,
      month.toMap(),
      where: 'id = ?',
      whereArgs: [month.id],
    );
  }

  Future<int> deleteMonth(int id) async {
    final db = await database;
    // ON DELETE CASCADE on budget_by_month.month_id removes child rows automatically.
    return db.delete(_tableMonths, where: 'id = ?', whereArgs: [id]);
  }

  /// Returns the id of the month whose [date] matches the current year and
  /// month. If no such month exists, one is created and its id is returned.
  Future<int> getCurrentMonthId() async {
    final db = await database;
    // Get latest month that is not closed
    final rows = await db.query(
      _tableMonths,
      columns: ['id'],
      where: 'closedOn IS NULL',
      orderBy: 'date DESC',
      limit: 1,
    );
    if (rows.isNotEmpty) {
      return (rows.first['id'] as num).toInt();
    }

    // No open Month found — create one for the current period.
    // Get income of last month
    MonthModel? lastMonth;
    final lastMonthRows = await db.query(
      _tableMonths,
      orderBy: 'date DESC',
      limit: 1,
    );
    if (lastMonthRows.isNotEmpty) {
      final lastMonthId = (lastMonthRows.first['id'] as num).toInt();
      final budgets = await getBudgetsByMonth(lastMonthId);
      lastMonth = MonthModel.fromMap(lastMonthRows.first, budgets);
    }
    double lastIncome = lastMonth?.income ?? 0.0;

    // Get to creating the new month
    final now = DateTime.now();
    MonthModel newMonth = MonthModel(
      id: 0,
      date: DateTime(now.year, now.month, 1),
      closedOn: null,
      income: lastIncome,
      budgets: [],
    );

    // Create BudgetByMonth entries for all visible budgets for the new month
    List<BudgetModel> budgets = await getAllVisibleBudgets();
    newMonth = newMonth.copyWith(
      budgets: budgets
          .map(
            (b) => BudgetByMonthModel(
              id: 0,
              monthId: 0,
              // Placeholder, will be set in insertMonth transaction
              budgetId: b.id,
              budgetName: b.name,
              oldLimit: b.limit,
              currentUsed: 0.0,
            ),
          )
          .toList(),
    );

    return insertMonth(newMonth);
  }

  // ── Budget CRUD ─────────────────────────────────────────────────────────────

  Future<int> insertBudget(BudgetModel budget) async {
    final db = await database;
    return db.insert(
      _tableBudgets,
      budget.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<BudgetModel>> getAllBudgets() async {
    final db = await database;
    final rows = await db.query(_tableBudgets);
    return rows.map(BudgetModel.fromMap).toList();
  }

  Future<List<BudgetModel>> getAllVisibleBudgets() async {
    final db = await database;
    final rows = await db.query(_tableBudgets, where: 'hiddenOn IS NULL');
    return rows.map(BudgetModel.fromMap).toList();
  }

  Future<BudgetModel> getBudgetById(int id) async {
    final db = await database;
    final rows = await db.query(
      _tableBudgets,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) {
      throw Exception('Budget with id $id not found');
    }
    return BudgetModel.fromMap(rows.first);
  }

  Future<int> updateBudget(BudgetModel budget) async {
    final db = await database;
    return db.update(
      _tableBudgets,
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  Future<int> deleteBudget(int id) async {
    final db = await database;
    // ON DELETE CASCADE on budget_by_month.budget_id removes child rows automatically.
    return db.delete(_tableBudgets, where: 'id = ?', whereArgs: [id]);
  }

  // ── BudgetByMonth CRUD ──────────────────────────────────────────────────────

  Future<int> insertBudgetByMonth(BudgetByMonthModel model) async {
    final db = await database;
    return db.insert(
      _tableBudgetByMonth,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> insertNewBudgetByMonth(int monthId, int budgetId) async {
    // Get Budget limit to set as oldLimit in BudgetByMonth
    final budget = await getBudgetById(budgetId);
    final model = BudgetByMonthModel(
      id: 0,
      monthId: monthId,
      budgetId: budgetId,
      budgetName: budget.name,
      oldLimit: budget.limit,
      currentUsed: 0.0,
    );
    return insertBudgetByMonth(model);
  }

  Future<List<BudgetByMonthModel>> getBudgetsByMonth(int monthId) async {
    final db = await database;
    // Visibility rules (applied via a single SQL query to avoid N+1 queries):
    //
    //  1. Budget is not hidden (hiddenOn IS NULL)
    //     → always show; it is an active budget category.
    //
    //  2. Budget has recorded spending in this month (current_used > 0)
    //     → always show regardless of hidden status; the spending is real data.
    //
    //  3. Month is closed AND the budget was hidden AFTER the month's close date
    //     → always show; the budget was still active when this month was alive,
    //       so it must appear in the historical record even with zero usage.
    //
    // Any hidden budget with zero spending that was hidden before (or on the same
    // day as) the close date is omitted — it was not part of that month's active
    // budget set when the period ended.
    final rows = await db.rawQuery(
      '''
      SELECT
        bm.id,
        bm.month_id,
        bm.budget_id,
        bm.old_limit,
        bm.current_used,
        b.name AS budget_name
      FROM $_tableBudgetByMonth bm
      INNER JOIN $_tableBudgets b ON bm.budget_id = b.id
      INNER JOIN $_tableMonths m ON bm.month_id = m.id
      WHERE bm.month_id = ?
        AND (
          b.hiddenOn IS NULL
          OR bm.current_used > 0
          OR (m.closedOn IS NOT NULL AND b.hiddenOn > m.closedOn)
        )
    ''',
      [monthId],
    );

    return rows.map(BudgetByMonthModel.fromMap).toList();
  }

  Future<BudgetByMonthModel?> getBudgetByMonthById(int id) async {
    final db = await database;
    final rows = await db.rawQuery(
      '''
      SELECT
        bm.id,
        bm.month_id,
        bm.budget_id,
        bm.old_limit,
        bm.current_used,
        b.name AS budget_name
      FROM $_tableBudgetByMonth bm
      INNER JOIN $_tableBudgets b ON bm.budget_id = b.id
      WHERE bm.id = ?
      LIMIT 1
    ''',
      [id],
    );
    if (rows.isEmpty) return null;
    return BudgetByMonthModel.fromMap(rows.first);
  }

  Future<int> updateBudgetByMonth(BudgetByMonthModel model) async {
    final db = await database;
    return db.update(
      _tableBudgetByMonth,
      model.toMap(),
      where: 'id = ?',
      whereArgs: [model.id],
    );
  }

  /// Updates only the [currentUsed] field for the budget_by_month row with [id].
  Future<void> updateBudgetByMonthCurrentUsed(
    int id,
    double currentUsed,
  ) async {
    final db = await database;
    await db.update(
      _tableBudgetByMonth,
      {'current_used': currentUsed},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateOldLimitForBudgetByMonth(
    int monthId,
    int budgetId,
    double newOldLimit,
  ) async {
    final db = await database;
    await db.update(
      _tableBudgetByMonth,
      {'old_limit': newOldLimit},
      where: 'month_id = ? AND budget_id = ?',
      whereArgs: [monthId, budgetId],
    );
  }

  Future<int> deleteBudgetByMonth(int id) async {
    final db = await database;
    return db.delete(_tableBudgetByMonth, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteBudgetsByMonth(int monthId) async {
    final db = await database;
    return db.delete(
      _tableBudgetByMonth,
      where: 'month_id = ?',
      whereArgs: [monthId],
    );
  }

  // ── Regular payment CRUD ───────────────────────────────────────────────────

  Future<int> insertRegularPayment(RegularPaymentModel payment) async {
    final db = await database;
    return db.insert(
      _tableRegularPayments,
      payment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<RegularPaymentModel>> getAllRegularPayments() async {
    final db = await database;
    final rows = await db.query(
      _tableRegularPayments,
      orderBy: 'name COLLATE NOCASE ASC',
    );
    return rows.map(RegularPaymentModel.fromMap).toList();
  }

  Future<RegularPaymentModel?> getRegularPaymentById(int id) async {
    final db = await database;
    final rows = await db.query(
      _tableRegularPayments,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return RegularPaymentModel.fromMap(rows.first);
  }

  Future<List<RegularPaymentModel>> getRegularPaymentsByMonth(int month) async {
    if (month < 1 || month > 12) {
      throw ArgumentError.value(month, 'month', 'Must be between 1 and 12.');
    }
    final db = await database;
    final monthBit = 1 << (month - 1);
    final rows = await db.query(
      _tableRegularPayments,
      where: '(months_mask & ?) != 0',
      whereArgs: [monthBit],
      orderBy: 'name COLLATE NOCASE ASC',
    );
    return rows.map(RegularPaymentModel.fromMap).toList();
  }

  Future<int> updateRegularPayment(RegularPaymentModel payment) async {
    final db = await database;
    return db.update(
      _tableRegularPayments,
      payment.toMap(),
      where: 'id = ?',
      whereArgs: [payment.id],
    );
  }

  Future<int> deleteRegularPayment(int id) async {
    final db = await database;
    return db.delete(_tableRegularPayments, where: 'id = ?', whereArgs: [id]);
  }

  // ── Regular payment snapshot CRUD ──────────────────────────────────────────

  Future<int> insertRegularPaymentSnapshot(
    RegularPaymentSnapshotModel snapshot,
  ) async {
    final db = await database;
    return db.insert(_tableRegularPaymentSnapshots, snapshot.toMap());
  }

  Future<RegularPaymentSnapshotModel?> getRegularPaymentSnapshotByMonthId(
    int monthId,
  ) async {
    final db = await database;
    final rows = await db.query(
      _tableRegularPaymentSnapshots,
      where: 'month_id = ?',
      whereArgs: [monthId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return RegularPaymentSnapshotModel.fromMap(rows.first);
  }

  Future<List<RegularPaymentSnapshotModel>>
  getRegularPaymentSnapshotsByMonthIds(List<int> monthIds) async {
    if (monthIds.isEmpty) return const [];
    final db = await database;
    final placeholders = List.filled(monthIds.length, '?').join(',');
    final rows = await db.query(
      _tableRegularPaymentSnapshots,
      where: 'month_id IN ($placeholders)',
      whereArgs: monthIds,
    );
    return rows.map(RegularPaymentSnapshotModel.fromMap).toList();
  }
}
