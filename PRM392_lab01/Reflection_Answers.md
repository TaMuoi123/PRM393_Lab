# Lab 1 - Reflection Questions

**1. What is the purpose of the flutter doctor command?**
The `flutter doctor` command is a diagnostic tool that checks your development environment and displays a report in the terminal. It verifies whether all necessary tools and dependencies (such as the Flutter SDK, Android Studio, Android toolchain, VS Code, and connected devices) are properly installed and configured to develop Flutter apps. It also provides actionable steps to fix any missing or misconfigured components.

**2. What file acts as the entry point of a Flutter application?**
The `lib/main.dart` file acts as the entry point of a Flutter application. Inside this file, the `main()` function is the specific method that is executed first when the application starts.

**3. Explain the difference between Hot Reload and Hot Restart.**
- **Hot Reload:** Injects updated source code into the running Dart Virtual Machine (VM) while preserving the current state of the application. It is very fast and is primarily used for tweaking UI and layout changes.
- **Hot Restart:** Recompiles the code and completely restarts the app, resetting its state to the initial value. It takes slightly longer than a hot reload and is required when there are changes to the app's logic, initialized state, or variables.

**4. How does runApp() build the widget tree?**
The `runApp()` function takes a `Widget` (typically the root widget of your app, like `MyApp`) and attaches it to the screen. It makes the given widget the root of the widget tree and triggers the framework to recursively call the `build()` methods of the widget and its children, constructing the entire visual layout to be rendered.

**5. Describe how Flutter's architecture enables cross-platform development.**
Flutter achieves cross-platform development by using a single codebase written in Dart. Instead of relying on native OEM UI components (like standard Android or iOS buttons), Flutter uses its own high-performance 2D rendering engine (Skia or Impeller) to paint every pixel on the screen directly. This ensures the app looks and feels identical across different platforms. When platform-specific features (like camera or Bluetooth) are needed, Flutter communicates with the native code via Platform Channels.
