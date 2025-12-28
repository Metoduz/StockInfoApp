# Project Structure

## Root Directory Layout
```
stockinfoapp/
├── lib/                    # Main Dart source code
├── assets/                 # Static assets (images, fonts)
├── android/               # Android-specific configuration
├── ios/                   # iOS-specific configuration  
├── web/                   # Web-specific configuration
├── windows/               # Windows-specific configuration
├── macos/                 # macOS-specific configuration
├── linux/                 # Linux-specific configuration
├── test/                  # Unit and widget tests
├── .dart_tool/            # Generated Dart tooling files
└── build/                 # Build output directory
```

## Source Code Organization (`lib/`)
```
lib/
├── main.dart              # App entry point
└── src/
    ├── app.dart           # Main app widget with theme configuration
    ├── models/            # Data models and business logic
    │   └── asset_item.dart
    ├── strategies/        # Trading strategies
    │   └── trendline.dart
    ├── screens/           # Full-screen UI components
    │   └── asset_list.dart
    ├── widgets/           # Reusable UI components
    │   ├── asset_card.dart
    │   └── hint_card.dart
    └── localization/      # Internationalization files
        └── app_en.arb
```

## Architecture Patterns

### Widget Organization
- **Screens**: Full-page widgets that represent app routes (`/screens/`)
- **Models**: Data classes with business logic (`/models/`)
- **Widgets**: Reusable UI components (`/widgets/`)
- Create extra file for bigger lose UI components (widgets)

### Naming Conventions
- **Files**: Use snake_case (e.g., `asset_list.dart`)
- **Classes**: Use PascalCase (e.g., `AssetList`)
- **Variables**: Use camelCase (e.g., `currentValue`)
- **Constants**: Use lowerCamelCase with `const` (e.g., `const routeName`)

### State Management
- Uses StatefulWidget for local component state
- No external state management library (provider, bloc, etc.)
- State is managed at the widget level where needed

### Model Structure
- **AssetItem**: Main data model with calculated properties
- **AssetHint**: Supporting model for trading analysis data
- Models include `copyWith()` methods for immutability
- Helper getters for calculated values (e.g., `calculatedDayChange`)

### Asset Organization
```
assets/
└── images/
    ├── flutter_logo.png    # Base resolution
    ├── 2.0x/              # 2x resolution variants
    └── 3.0x/              # 3x resolution variants
```

## Configuration Files
- `pubspec.yaml`: Dependencies and asset declarations
- `analysis_options.yaml`: Dart analyzer configuration
- `l10n.yaml`: Localization generation settings
- Platform-specific configs in respective platform folders