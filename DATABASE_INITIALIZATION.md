# Database Initialization Guide

## Overview

The BudgetManager app uses **SQLite** (via `sqflite` package) for local data storage. The database is automatically initialized when the application starts.

## How It Works

### 1. **App Startup Flow**

```
main() → WidgetsFlutterBinding.ensureInitialized()
         ↓
setupDependencies() → DatabaseHelper created
         ↓
await dbHelper.database → Database initialized (if needed)
         ↓
Database registered in DI container
         ↓
runApp() → App starts with ready database
```

### 2. **Database Creation**

The database is created automatically using these steps:

- **Location**: The database file is stored in the app's documents directory
  - Android: `/data/data/<package>/databases/budget_manager.db`
  - iOS: `~/Documents/budget_manager.db`

- **First Launch**: When the app runs for the first time:
  - `openDatabase()` is called
  - The file doesn't exist, so `onCreate()` callback is triggered
  - Tables are created: `months`, `budgets`, `budget_by_month`
  
- **Subsequent Launches**: 
  - `openDatabase()` is called
  - File exists, so it just opens the existing database
  - No `onCreate()` is called

### 3. **Database Schema**

Three tables are created:

#### **months**
```sql
CREATE TABLE months (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  date TEXT NOT NULL,
  income REAL NOT NULL DEFAULT 0.0
)
```

#### **budgets**
```sql
CREATE TABLE budgets (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  max_amount REAL NOT NULL DEFAULT 0.0
)
```

#### **budget_by_month**
```sql
CREATE TABLE budget_by_month (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  month_id INTEGER NOT NULL,
  budget_id INTEGER NOT NULL,
  old_limit REAL NOT NULL DEFAULT 0.0,
  current_used REAL NOT NULL DEFAULT 0.0,
  FOREIGN KEY (month_id) REFERENCES months(id) ON DELETE CASCADE,
  FOREIGN KEY (budget_id) REFERENCES budgets(id) ON DELETE CASCADE
)
```

## Key Implementation Details

### DatabaseHelper Class (`lib/db/database_helper.dart`)

- **Singleton Pattern**: Uses a single instance with lazy initialization
- **Async Initialization**: The `database` getter ensures initialization happens once
- **Thread Safety**: Uses `Completer` to prevent multiple simultaneous initializations
- **Version Management**: Currently at version 2; the `onUpgrade` callback handles incremental migrations

### Dependency Injection (`lib/di/di.dart`)

```dart
Future<void> setupDependencies() async {
  final dbHelper = DatabaseHelper();
  // Eagerly initialize the database
  await dbHelper.database;
  getIt.registerSingleton<DatabaseHelper>(dbHelper);
  // ... rest of setup
}
```

**Why eager initialization?**
- Database is ready before any UI is shown
- No delay on first screen that needs data
- Easier error handling at startup
- Better user experience

## Checking Database Status

### How to Verify Database Exists

The database will automatically be created. To verify:

**Android (via adb):**
```bash
# List databases
adb shell run-as com.example.budgetmanager ls /data/data/com.example.budgetmanager/databases/

# Pull database to examine
adb shell run-as com.example.budgetmanager cat /data/data/com.example.budgetmanager/databases/budget_manager.db > budget_manager.db
```

**iOS (Simulator):**
```bash
# Find app container
xcrun simctl get_app_container booted com.example.budgetmanager data

# Navigate to database
cd <container_path>/Documents
ls -la budget_manager.db
```

### Programmatic Check

The `DatabaseHelper.database` getter will:
- Return the existing database if initialized
- Initialize and return a new database if not

```dart
final db = await getIt<DatabaseHelper>().database;
print('Database path: ${db.path}');
print('Database is open: ${db.isOpen}');
```

## Database Migrations

Currently at **version 2**. The `_onUpgrade` callback in `DatabaseHelper` applies migrations
automatically using a **migration map** — a `static final Map<int, List<String>>` keyed by
target version. On every upgrade, the generic handler iterates over each version entry between
`oldVersion + 1` and `newVersion` in ascending order, so multi-version leapfrogs are handled
correctly without any extra logic.

### Migration history

| Version | Changes |
|---------|---------|
| 1 | Initial schema – `months`, `budgets`, `budget_by_month` tables |
| 2 | Added `closedOn TEXT NULL` to `months`; added `hiddenOn TEXT NULL` to `budgets` |

### Adding a future migration

1. Increment `_databaseVersion` in `DatabaseHelper`.
2. Add a new entry to `_migrations` whose key matches the new version number.

Example (v2 → v3):
```dart
static const _databaseVersion = 3;

static final Map<int, List<String>> _migrations = {
  2: [
    'ALTER TABLE $_tableMonths ADD COLUMN closedOn TEXT NULL',
    'ALTER TABLE $_tableBudgets ADD COLUMN hiddenOn TEXT NULL',
  ],
  3: [
    // new SQL statements for version 3
    'ALTER TABLE $_tableBudgets ADD COLUMN notes TEXT',
  ],
};
```

No changes to `_onUpgrade` are ever needed.

## Troubleshooting

### Database Not Creating

1. Check Flutter bindings are initialized:
   ```dart
   WidgetsFlutterBinding.ensureInitialized();
   ```

2. Check permissions (Android):
   - Ensure app has storage permissions if needed
   - For Android 10+, database should work without special permissions

3. Check for errors in logs:
   ```bash
   flutter logs
   ```

### Reset Database

To delete and recreate the database:

**During Development:**
```dart
// In database_helper.dart, add a method:
Future<void> deleteDatabase() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, _databaseName);
  await databaseFactory.deleteDatabase(path);
  _database = null;
  _dbCompleter = null;
}
```

**Or uninstall/reinstall the app:**
```bash
flutter clean
flutter run
```

## Best Practices

✅ **DO:**
- Always use `await` when accessing the database
- Access database through repositories, not directly
- Handle database errors gracefully
- Use transactions for multi-step operations

❌ **DON'T:**
- Don't call `openDatabase()` directly multiple times
- Don't access `_database` directly, always use the `database` getter
- Don't forget to close the database when testing
- Don't perform long operations on the main thread

## Summary

**You don't need to do anything special!** The database:
- ✅ Automatically initializes on app startup
- ✅ Creates tables if they don't exist
- ✅ Opens existing database if it does exist
- ✅ Is ready to use when the app UI loads
- ✅ Handles errors during initialization

Just use your repositories to access data, and everything works automatically!

