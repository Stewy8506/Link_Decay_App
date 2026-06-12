# Desktop Build Guide

LinkShelf compiles to native desktop applications for macOS (using Cocoa runners) and Windows (using Win32/C++ runners). This document covers compiler requirements, compilation steps, and window manager configurations.

---

## ✦ 1. macOS Build Setup

### System Prerequisites
To compile the macOS binary, you must develop on a Mac running:
- **Xcode** (with command line tools installed)
- **CocoaPods** (for managing native plugin pods)

Verify dependencies using:
```bash
pod --version
```

### Window Manager Constraints
The macOS runner is configured to initialize with a customized layout viewport. It overrides default windows frames to enforce size boundaries:
- **Default dimensions**: Initial window size defaults to `1024x768px`.
- **Minimum bounds**: Window resizing is limited to a minimum of `380x600px` to protect the layout structure.

### Compile macOS App
Run the build script to compile a release application package:
```bash
flutter build macos --release
```

The compiled output bundle is located at:
`build/macos/Build/Products/Release/LinkShelf.app`

---

## ✦ 2. Windows Build Setup

### System Prerequisites
To build the Windows executable, you must develop on a Windows PC running:
- **Visual Studio** with the **"Desktop development with C++"** workload enabled.
- **CMake**

### Compile Windows App
Run the build script:
```bash
flutter build windows --release
```

The compiler will build the asset tree, copy resources, and output an executable folder under:
`build/windows/runner/Release/`

---

## ✦ 3. Desktop Application Packaging

Unlike mobile files, desktop builds output raw binaries. To distribute them:
- **macOS**: Pack the `.app` folder into a `.dmg` installer or generate a zip bundle.
- **Windows**: Use tools like **Inno Setup** or **WiX Toolset** to wrap the contents of the `build/windows/runner/Release/` folder into a single installer.
