# Technology Stack

## Framework & Language
- **Flutter SDK**: Cross-platform mobile/desktop/web framework
- **Dart**: Programming language (SDK ^3.6.1)
- **Material Design 3**: UI design system with dynamic theming

## Dependencies
- `flutter_localizations`: Internationalization support
- `flutter_lints`: Code quality and style enforcement

## Development Tools
- **Analysis Options**: Uses `package:flutter_lints/flutter.yaml` for code quality
- **Localization**: ARB files for internationalization with auto-generation

## Common Commands

### Development
```bash
# Get dependencies
flutter pub get

# Run the app (debug mode)
flutter run

# Run on specific platform
flutter run -d chrome          # Web
flutter run -d windows         # Windows
flutter run -d android         # Android

# Hot reload during development
# Press 'r' in terminal or save files in IDE
```

### Testing & Quality
```bash
# Run static analysis
flutter analyze

# Run tests
flutter test

# Check for outdated dependencies
flutter pub outdated
```

### Building
```bash
# Build for release (Android)
flutter build apk --release
flutter build appbundle --release

# Build for release (iOS)
flutter build ios --release

# Build for web
flutter build web --release

# Build for desktop
flutter build windows --release
flutter build macos --release
flutter build linux --release
```

### Code Generation
```bash
# Generate localization files
flutter gen-l10n

# Clean build artifacts
flutter clean
```

## Code Quality Standards
- Follow Flutter linting rules from `flutter_lints` package
- Use Material 3 design components
- Prefer `const` constructors where possible
- Use `super.key` for widget keys
- Replace deprecated `withOpacity()` with `withValues()` for color opacity