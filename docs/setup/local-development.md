# Local Development Guide

This guide details how to set up your local development environment to build, run, and contribute to **LinkShelf**.

---

## ✦ System Prerequisites

Ensure your development machine meets the minimum version requirements:
- **Flutter SDK**: `3.41.0` or higher
- **Dart SDK**: `3.11.0` or higher
- **Git**

Verify your active environment by running:
```bash
flutter --version
dart --version
```

---

## ✦ Clone and Install Dependencies

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/Stewy8506/LinkShelf.git
   cd LinkShelf
   ```

2. **Retrieve Packages**:
   Install all compiler libraries, JS interop packages, and native modules:
   ```bash
   flutter pub get
   ```

3. **Verify Environment Configurations**:
   Check that you have target platform runners (Android SDK, Xcode, or Visual Studio C++ toolchains) installed correctly:
   ```bash
   flutter doctor
   ```

---

## ✦ Running the Code

LinkShelf builds and compiles natively on mobile, desktop, and web runners. Connect a testing device or start an emulator/simulator, then execute:

### Running on Mobile (Android)
```bash
flutter run
```

### Running on Desktop (macOS)
```bash
flutter run -d macos
```

### Running on Desktop (Windows)
```bash
flutter run -d windows
```

### Running on Web / Extension Viewport
To test the web-renderer structure inside a browser window:
```bash
flutter run -d chrome --web-renderer html
```

---

## ✦ Developer Guidelines

- **Lint Inspections**: The project uses strict analysis profiles configured in `analysis_options.yaml`. Ensure your editor (VS Code, Android Studio) highlights lint warnings. You can run checks manually using:
  ```bash
  flutter analyze
  ```
- **File formatting**: Format files before submitting pulls:
  ```bash
  flutter format lib/
  ```
