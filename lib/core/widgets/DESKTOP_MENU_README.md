# Desktop Native Menus

Comprehensive native menu support for macOS, Windows, and Linux.

## Overview

The desktop menu system provides platform-native menu bars that integrate seamlessly with the operating system. Menus automatically adapt to platform conventions:

- **macOS**: Application menu with standard macOS structure
- **Windows**: Traditional menu bar below title bar
- **Linux**: GNOME/KDE compatible menu bar

## Features

- ✅ Platform-native rendering (uses Flutter's PlatformMenuBar)
- ✅ Keyboard shortcut integration (links to existing ShortcutManager)
- ✅ Platform-specific modifiers (⌘ on macOS, Ctrl elsewhere)
- ✅ Dynamic menu visibility (only show items with callbacks)
- ✅ Standard menus: File, Edit, View, Window, Help
- ✅ Mobile/Web safety (menus only appear on desktop)

## Quick Start

### 1. Basic Integration

Wrap your `MaterialApp` with `DesktopMenuWrapper`:

```dart
import 'package:zeusgpt/core/responsive.dart';

@override
Widget build(BuildContext context, WidgetRef ref) {
  final router = ref.watch(appRouterProvider);

  return DesktopMenuWrapper(
    // Minimal required callbacks
    onNewChat: () => context.go('/chat/new'),
    onShowAbout: () => showAboutDialog(context),

    child: MaterialApp.router(
      title: 'ZeusGPT',
      routerConfig: router,
    ),
  );
}
```

### 2. Full Integration

For complete menu functionality:

```dart
return DesktopMenuWrapper(
  // Navigation
  onNewChat: () => _handleNewChat(context),
  onOpenSettings: () => context.go('/settings'),

  // Chat actions
  onSaveChat: () => _handleSaveChat(context),
  onExportChat: () => _handleExportChat(context),
  onClearChat: () => _handleClearChat(context),
  onDeleteChat: () => _handleDeleteChat(context),

  // Edit actions
  onUndo: () => _handleUndo(),
  onRedo: () => _handleRedo(),
  onCopy: () => _handleCopy(),
  onPaste: () => _handlePaste(),

  // View actions
  onToggleSidebar: () => ref.read(sidebarProvider.notifier).toggle(),
  onToggleTheme: () => ref.read(themeModeProvider.notifier).toggle(),
  onZoomIn: () => _handleZoomIn(),
  onZoomOut: () => _handleZoomOut(),
  onResetZoom: () => _handleResetZoom(),

  // Window actions (desktop only)
  onMinimizeWindow: () => WindowStateManager.instance.minimize(),
  onMaximizeWindow: () => WindowStateManager.instance.maximize(),

  // Help
  onShowShortcuts: () => _showShortcutsDialog(context),
  onShowDocumentation: () => _launchDocs(),
  onShowAbout: () => _showAboutDialog(context),

  child: MaterialApp.router(
    routerConfig: router,
  ),
);
```

## Menu Structure

### File Menu
- **New Chat** (⌘N / Ctrl+N) - Create new chat
- **Save Chat** (⌘S / Ctrl+S) - Save current chat
- **Export Chat** - Export chat to file
- **Close Window** (⌘W) / **Exit** - Close/quit app

### Edit Menu
- **Undo** (⌘Z / Ctrl+Z) - Undo last action
- **Redo** (⌘⇧Z / Ctrl+Y) - Redo action
- **Cut** (⌘X / Ctrl+X) - Cut selection
- **Copy** (⌘C / Ctrl+C) - Copy selection
- **Paste** (⌘V / Ctrl+V) - Paste from clipboard
- **Select All** (⌘A / Ctrl+A) - Select all text
- **Clear Chat** - Clear current chat
- **Delete Chat** - Delete current chat

### View Menu
- **Toggle Sidebar** (⌘B / Ctrl+B) - Show/hide sidebar
- **Toggle Theme** (⌘D / Ctrl+D) - Switch light/dark theme
- **Zoom In** (⌘+ / Ctrl++) - Increase zoom
- **Zoom Out** (⌘- / Ctrl+-) - Decrease zoom
- **Reset Zoom** (⌘0 / Ctrl+0) - Reset to 100%
- **Open Settings** (⌘, / Ctrl+,) - Open settings

### Window Menu
**macOS:**
- **Minimize** (⌘M) - Minimize window
- **Zoom** - Maximize/restore window
- **Bring All to Front** - Focus all windows

**Windows/Linux:**
- **Minimize** (Ctrl+M) - Minimize window
- **Maximize** - Maximize window
- **Restore** - Restore window size

### Help Menu
- **Documentation** - Open documentation
- **Keyboard Shortcuts** (⌘? / Ctrl+?) - Show shortcuts
- **Report Issue** - Report a bug
- **Check for Updates** - Check for updates
- **About ZeusGPT** - Show about dialog

## Architecture

### Components

1. **DesktopMenuWrapper** (`desktop_menu_wrapper.dart`)
   - Widget that wraps MaterialApp
   - Handles callback registration
   - Builds platform-specific menu structure
   - Only renders on desktop platforms

2. **NativeMenuManager** (`native_menu_manager.dart`)
   - Singleton service for menu management
   - Callback registration/execution
   - Menu structure definition
   - Platform detection

3. **Integration with ShortcutManager**
   - Menus use same shortcuts as keyboard shortcuts
   - Shortcuts automatically displayed in menus
   - Platform-specific modifier keys

### Platform Detection

```dart
import 'package:zeusgpt/core/responsive.dart';

if (PlatformHelper.isDesktop) {
  // Desktop-only code
}

if (PlatformHelper.isMacOS) {
  // macOS-specific code
}
```

## Implementation Details

### Keyboard Shortcuts

Shortcuts are automatically imported from `ShortcutManager`:

```dart
// Extension converts AppShortcut to MenuSerializableShortcut
extension on AppShortcut {
  MenuSerializableShortcut? get menuSerializableShortcut {
    final activator = this.activator;
    if (activator is SingleActivator) {
      return MenuSerializableShortcut(
        activator.trigger,
        control: activator.control,
        shift: activator.shift,
        alt: activator.alt,
        meta: activator.meta,
      );
    }
    return null;
  }
}
```

### Conditional Menu Items

Menu items only appear if callbacks are provided:

```dart
if (widget.onNewChat != null)
  PlatformMenuItem(
    label: 'New Chat',
    shortcut: AppShortcut.newChat.menuSerializableShortcut,
    onSelected: widget.onNewChat,
  ),
```

### Platform-Specific Behavior

```dart
if (PlatformHelper.isMacOS)
  const PlatformMenuItem(
    label: 'Close Window',
    shortcut: MenuSerializableShortcut(
      LogicalKeyboardKey.keyW,
      meta: true,
    ),
  )
else
  PlatformMenuItem(
    label: 'Exit',
    onSelected: widget.onExitApp,
  ),
```

## Testing

### Manual Testing on macOS

1. Run app: `flutter run -d macos`
2. Verify menus appear in menu bar
3. Test keyboard shortcuts (⌘N, ⌘S, etc.)
4. Verify callbacks execute correctly
5. Check menu item visibility

### Manual Testing on Windows

1. Run app: `flutter run -d windows`
2. Verify menus appear below title bar
3. Test keyboard shortcuts (Ctrl+N, Ctrl+S, etc.)
4. Test window management (minimize, maximize)

### Manual Testing on Linux

1. Run app: `flutter run -d linux`
2. Verify menus integrate with desktop environment
3. Test GNOME/KDE compatibility
4. Verify shortcuts work correctly

## Common Issues

### Issue: Menus not appearing

**Solution:**
- Ensure running on desktop platform (not mobile/web)
- Check `PlatformHelper.isDesktop` returns true
- Verify callbacks are provided to DesktopMenuWrapper

### Issue: Shortcuts not working

**Solution:**
- Check shortcut definitions in `ShortcutManager`
- Verify platform-specific modifiers (meta vs control)
- Ensure no conflicting shortcuts

### Issue: Menu items missing

**Solution:**
- Menu items only appear if callbacks provided
- Check callback parameters in DesktopMenuWrapper
- Verify null checks in menu building code

## Best Practices

### 1. Minimal Integration

Only implement callbacks for features that exist:

```dart
DesktopMenuWrapper(
  onNewChat: () => _handleNewChat(),
  onShowAbout: () => _showAbout(),
  child: app,
)
```

### 2. Use Action Handlers

Create dedicated handler class:

```dart
class MenuHandlers {
  static void handleExportChat(BuildContext context) {
    // Implementation
  }

  static void handleClearChat(BuildContext context) {
    showDialog(...);
  }
}

// Usage:
onExportChat: () => MenuHandlers.handleExportChat(context),
```

### 3. Integrate with State Management

Connect to Riverpod providers:

```dart
onToggleTheme: () {
  ref.read(themeModeProvider.notifier).toggle();
},
onToggleSidebar: () {
  ref.read(sidebarProvider.notifier).toggle();
},
```

### 4. Window Management

Use WindowStateManager for window actions:

```dart
onMinimizeWindow: () async {
  try {
    await WindowStateManager.instance.minimize();
  } catch (e) {
    debugPrint('Failed to minimize: $e');
  }
},
```

## Examples

See `desktop_menu_integration_example.dart` for:
- Complete integration example
- Action handler implementations
- Keyboard shortcuts dialog
- About dialog
- Window management examples

## Platform-Specific Notes

### macOS
- Uses ⌘ (Command) modifier
- "Close Window" instead of "Exit"
- Standard macOS menu structure
- Integrates with system menu bar

### Windows
- Uses Ctrl modifier
- "Exit" in File menu
- Menu bar below title bar
- Standard Windows behavior

### Linux
- Uses Ctrl modifier
- Compatible with GNOME/KDE
- System integration varies by DE
- Standard desktop conventions

## Future Enhancements

- [ ] Context menu integration
- [ ] Recent files menu
- [ ] Dynamic menu updates
- [ ] Menu item icons
- [ ] Submenu support
- [ ] Localization support

## Related Files

- `/lib/core/services/shortcut_manager.dart` - Keyboard shortcuts
- `/lib/core/services/window_state_manager.dart` - Window management
- `/lib/core/utils/platform_helper.dart` - Platform detection
- `/lib/core/widgets/adaptive_scaffold.dart` - Adaptive navigation

## Support

For issues or questions:
1. Check BUILD_GUIDE.md for platform-specific build issues
2. Review IMPLEMENTATION_STATUS.md for feature status
3. See desktop_menu_integration_example.dart for usage examples
