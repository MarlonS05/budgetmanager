# Budget Manager
This README explains how to set up the project locally for development and how to run the tests.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Local Development Setup](#local-development-setup)
- [Running the App](#running-the-app)
- [Testing](#testing)
  - [Test Setup After Pulling](#test-setup-after-pulling)
  - [Running the Tests](#running-the-tests)
  - [Test Structure](#test-structure)
  - [Coverage](#coverage)
- [Troubleshooting](#troubleshooting)

## Prerequisites

| Tool | Notes |
| --- | --- |
| [Flutter SDK](https://docs.flutter.dev/get-started/install) | Use the stable channel. Check the `environment` section in `pubspec.yaml` for the required SDK version. |
| Git | To clone the repository. |
| An IDE | VS Code (with the Flutter and Dart extensions) or Android Studio. |
| A target device | Android emulator, iOS simulator (macOS only), a physical device, or Chrome. |

Verify your installation:

```bash
flutter doctor
```

Resolve any issues `flutter doctor` reports for the platforms you want to develop on.

## Local Development Setup

1. **Clone the repository**

   ```bash
   git clone https://github.com/MarlonS05/budgetmanager.git
   cd budgetmanager
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Generate code (only if the project uses code generation)**

   If `pubspec.yaml` lists `build_runner` under `dev_dependencies`, run:

   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

   Skip this step if the project has no generated files (`*.g.dart`, `*.freezed.dart`, `*.mocks.dart`).

4. **Check that everything compiles**

   ```bash
   flutter analyze
   ```

## Running the App

List available devices:

```bash
flutter devices
```

Run on a specific device:

```bash
flutter run -d <device-id>
```

Examples:

```bash
flutter run -d chrome      # web
flutter run -d emulator-5554   # Android emulator
flutter run -d "iPhone 15"     # iOS simulator
```

While the app is running, press `r` for hot reload and `R` for hot restart.

## Testing

### Test Setup After Pulling

Run these steps every time you pull new changes, before running the tests. Skipping them is the most common cause of tests failing locally when they pass for everyone else.

```bash
# 1. Pull the latest changes
git pull

# 2. Sync dependencies (pubspec.yaml or pubspec.lock may have changed)
flutter pub get

# 3. Regenerate code (only if the project uses build_runner)
dart run build_runner build --delete-conflicting-outputs

# 4. Make sure the code analyzes cleanly
flutter analyze
```

If tests behave strangely after a large pull, do a clean reset:

```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # only if used
```

Once this is done, you're ready to run the tests.

### Running the Tests

Run the whole test suite:

```bash
flutter test
```

Run a single test file:

```bash
flutter test test/domain/usecases/month/<file_name>_test.dart
```

Run all tests in one folder:

```bash
flutter test test/domain/            # entities, models and use cases
flutter test test/domain/entities/
flutter test test/domain/models/
flutter test test/domain/usecases/month/
flutter test test/screens/           # all widget tests
flutter test test/screens/components/
flutter test test/screens/history/
flutter test test/screens/live/
flutter test test/screens/regularity/
```

Run only tests whose name matches a pattern:

```bash
flutter test --plain-name "your test description"
```

Useful flags:

```bash
flutter test --reporter expanded   # print every test as it runs
flutter test --no-pub              # skip the implicit pub get (faster if already synced)
```

### Test Structure

The tests mirror the app's layers:

```
test/
├── domain/                  # Pure Dart unit tests (no Flutter UI)
│   ├── entities/            # Entity classes
│   ├── models/              # Model classes and mapping logic
│   └── usecases/
│       └── month/           # Month-related use cases
└── screens/                 # Widget tests
    ├── components/          # Reusable UI components
    ├── history/             # History screen
    ├── live/                # Live screen
    └── regularity/          # Regularity screen
```

- **`test/domain/`** contains fast unit tests for the business logic. They don't need a device or emulator.
- **`test/screens/`** contains widget tests. They run in a headless test environment via `flutter test`, so no emulator is required either.

### Coverage

Generate a coverage report:

```bash
flutter test --coverage
```

This writes `coverage/lcov.info`. To view it as an HTML report (requires [`lcov`](https://github.com/linux-test-project/lcov)):

```bash
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html      # macOS
xdg-open coverage/html/index.html  # Linux
```

## Troubleshooting

| Problem | Fix |
| --- | --- |
| `Target of URI doesn't exist` or missing `*.g.dart` / `*.mocks.dart` files | Run `dart run build_runner build --delete-conflicting-outputs`. |
| Dependency or version errors after pulling | Run `flutter pub get`. If it persists, run `flutter clean && flutter pub get`. |
| Tests pass in one run and fail in another | Run `flutter clean`, then repeat the [test setup](#test-setup-after-pulling). |
| `flutter: command not found` | Add the Flutter `bin` directory to your `PATH`, then restart your terminal. |
| Widget tests fail with layout overflow errors | Check that the test sets a suitable surface size, e.g. `tester.view.physicalSize`. |
