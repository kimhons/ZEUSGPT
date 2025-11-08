import 'package:flutter/material.dart';
import '../utils/platform_helper.dart';
import '../services/native_menu_manager.dart';

/// Wraps the app with native desktop menus
/// Only renders menus on desktop platforms (macOS, Windows, Linux)
class DesktopMenuWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onNewChat;
  final VoidCallback? onSaveChat;
  final VoidCallback? onExportChat;
  final VoidCallback? onExitApp;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final VoidCallback? onCut;
  final VoidCallback? onCopy;
  final VoidCallback? onPaste;
  final VoidCallback? onSelectAll;
  final VoidCallback? onClearChat;
  final VoidCallback? onDeleteChat;
  final VoidCallback? onToggleSidebar;
  final VoidCallback? onToggleTheme;
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;
  final VoidCallback? onResetZoom;
  final VoidCallback? onOpenSettings;
  final VoidCallback? onMinimizeWindow;
  final VoidCallback? onMaximizeWindow;
  final VoidCallback? onRestoreWindow;
  final VoidCallback? onShowDocumentation;
  final VoidCallback? onShowShortcuts;
  final VoidCallback? onReportIssue;
  final VoidCallback? onCheckUpdates;
  final VoidCallback? onShowAbout;

  const DesktopMenuWrapper({
    super.key,
    required this.child,
    this.onNewChat,
    this.onSaveChat,
    this.onExportChat,
    this.onExitApp,
    this.onUndo,
    this.onRedo,
    this.onCut,
    this.onCopy,
    this.onPaste,
    this.onSelectAll,
    this.onClearChat,
    this.onDeleteChat,
    this.onToggleSidebar,
    this.onToggleTheme,
    this.onZoomIn,
    this.onZoomOut,
    this.onResetZoom,
    this.onOpenSettings,
    this.onMinimizeWindow,
    this.onMaximizeWindow,
    this.onRestoreWindow,
    this.onShowDocumentation,
    this.onShowShortcuts,
    this.onReportIssue,
    this.onCheckUpdates,
    this.onShowAbout,
  });

  @override
  State<DesktopMenuWrapper> createState() => _DesktopMenuWrapperState();
}

class _DesktopMenuWrapperState extends State<DesktopMenuWrapper> {
  @override
  void initState() {
    super.initState();
    if (PlatformHelper.isDesktop) {
      _registerMenuCallbacks();
    }
  }

  @override
  void dispose() {
    if (PlatformHelper.isDesktop) {
      _unregisterMenuCallbacks();
    }
    super.dispose();
  }

  void _registerMenuCallbacks() {
    final menuManager = NativeMenuManager.instance;

    if (widget.onNewChat != null) {
      menuManager.registerCallback('new_chat', widget.onNewChat!);
    }
    if (widget.onSaveChat != null) {
      menuManager.registerCallback('save_chat', widget.onSaveChat!);
    }
    if (widget.onExportChat != null) {
      menuManager.registerCallback('export_chat', widget.onExportChat!);
    }
    if (widget.onExitApp != null) {
      menuManager.registerCallback('exit_app', widget.onExitApp!);
    }
    if (widget.onUndo != null) {
      menuManager.registerCallback('undo', widget.onUndo!);
    }
    if (widget.onRedo != null) {
      menuManager.registerCallback('redo', widget.onRedo!);
    }
    if (widget.onCut != null) {
      menuManager.registerCallback('cut', widget.onCut!);
    }
    if (widget.onCopy != null) {
      menuManager.registerCallback('copy', widget.onCopy!);
    }
    if (widget.onPaste != null) {
      menuManager.registerCallback('paste', widget.onPaste!);
    }
    if (widget.onSelectAll != null) {
      menuManager.registerCallback('select_all', widget.onSelectAll!);
    }
    if (widget.onClearChat != null) {
      menuManager.registerCallback('clear_chat', widget.onClearChat!);
    }
    if (widget.onDeleteChat != null) {
      menuManager.registerCallback('delete_chat', widget.onDeleteChat!);
    }
    if (widget.onToggleSidebar != null) {
      menuManager.registerCallback('toggle_sidebar', widget.onToggleSidebar!);
    }
    if (widget.onToggleTheme != null) {
      menuManager.registerCallback('toggle_theme', widget.onToggleTheme!);
    }
    if (widget.onZoomIn != null) {
      menuManager.registerCallback('zoom_in', widget.onZoomIn!);
    }
    if (widget.onZoomOut != null) {
      menuManager.registerCallback('zoom_out', widget.onZoomOut!);
    }
    if (widget.onResetZoom != null) {
      menuManager.registerCallback('reset_zoom', widget.onResetZoom!);
    }
    if (widget.onOpenSettings != null) {
      menuManager.registerCallback('open_settings', widget.onOpenSettings!);
    }
    if (widget.onMinimizeWindow != null) {
      menuManager.registerCallback('minimize_window', widget.onMinimizeWindow!);
    }
    if (widget.onMaximizeWindow != null) {
      menuManager.registerCallback('maximize_window', widget.onMaximizeWindow!);
    }
    if (widget.onRestoreWindow != null) {
      menuManager.registerCallback('restore_window', widget.onRestoreWindow!);
    }
    if (widget.onShowDocumentation != null) {
      menuManager.registerCallback('show_documentation', widget.onShowDocumentation!);
    }
    if (widget.onShowShortcuts != null) {
      menuManager.registerCallback('show_shortcuts', widget.onShowShortcuts!);
    }
    if (widget.onReportIssue != null) {
      menuManager.registerCallback('report_issue', widget.onReportIssue!);
    }
    if (widget.onCheckUpdates != null) {
      menuManager.registerCallback('check_updates', widget.onCheckUpdates!);
    }
    if (widget.onShowAbout != null) {
      menuManager.registerCallback('show_about', widget.onShowAbout!);
    }
  }

  void _unregisterMenuCallbacks() {
    final menuManager = NativeMenuManager.instance;

    menuManager.unregisterCallback('new_chat');
    menuManager.unregisterCallback('save_chat');
    menuManager.unregisterCallback('export_chat');
    menuManager.unregisterCallback('exit_app');
    menuManager.unregisterCallback('undo');
    menuManager.unregisterCallback('redo');
    menuManager.unregisterCallback('cut');
    menuManager.unregisterCallback('copy');
    menuManager.unregisterCallback('paste');
    menuManager.unregisterCallback('select_all');
    menuManager.unregisterCallback('clear_chat');
    menuManager.unregisterCallback('delete_chat');
    menuManager.unregisterCallback('toggle_sidebar');
    menuManager.unregisterCallback('toggle_theme');
    menuManager.unregisterCallback('zoom_in');
    menuManager.unregisterCallback('zoom_out');
    menuManager.unregisterCallback('reset_zoom');
    menuManager.unregisterCallback('open_settings');
    menuManager.unregisterCallback('minimize_window');
    menuManager.unregisterCallback('maximize_window');
    menuManager.unregisterCallback('restore_window');
    menuManager.unregisterCallback('show_documentation');
    menuManager.unregisterCallback('show_shortcuts');
    menuManager.unregisterCallback('report_issue');
    menuManager.unregisterCallback('check_updates');
    menuManager.unregisterCallback('show_about');
  }

  @override
  Widget build(BuildContext context) {
    // Only show menus on desktop platforms
    if (!PlatformHelper.isDesktop) {
      return widget.child;
    }

    return PlatformMenuBar(
      menus: _buildMenus(),
      child: widget.child,
    );
  }

  List<PlatformMenuItem> _buildMenus() {
    final isMac = PlatformHelper.isMacOS;

    return [
      _buildFileMenu(),
      _buildEditMenu(isMac),
      _buildViewMenu(),
      _buildWindowMenu(isMac),
      _buildHelpMenu(),
    ];
  }

  PlatformMenu _buildFileMenu() {
    return PlatformMenu(
      label: 'File',
      menus: [
        if (widget.onNewChat != null)
          PlatformMenuItem(
            label: 'New Chat',
            onSelected: widget.onNewChat,
          ),
        if (widget.onSaveChat != null)
          PlatformMenuItem(
            label: 'Save Chat',
            onSelected: widget.onSaveChat,
          ),
        if (widget.onExportChat != null)
          PlatformMenuItem(
            label: 'Export Chat',
            onSelected: widget.onExportChat,
          ),
        if (widget.onNewChat != null ||
            widget.onSaveChat != null ||
            widget.onExportChat != null)
        if (PlatformHelper.isMacOS)
          PlatformMenuItem(
            label: 'Close Window',
            onSelected: widget.onExitApp,
          )
        else if (widget.onExitApp != null)
          PlatformMenuItem(
            label: 'Exit',
            onSelected: widget.onExitApp,
          ),
      ],
    );
  }

  PlatformMenu _buildEditMenu(bool isMac) {
    return PlatformMenu(
      label: 'Edit',
      menus: [
        if (widget.onUndo != null)
          PlatformMenuItem(
            label: 'Undo',
            onSelected: widget.onUndo,
          ),
        if (widget.onRedo != null)
          PlatformMenuItem(
            label: 'Redo',
            onSelected: widget.onRedo,
          ),
        if (widget.onUndo != null || widget.onRedo != null)
        if (widget.onCut != null)
          PlatformMenuItem(
            label: 'Cut',
            onSelected: widget.onCut,
          ),
        if (widget.onCopy != null)
          PlatformMenuItem(
            label: 'Copy',
            onSelected: widget.onCopy,
          ),
        if (widget.onPaste != null)
          PlatformMenuItem(
            label: 'Paste',
            onSelected: widget.onPaste,
          ),
        if (widget.onSelectAll != null)
          PlatformMenuItem(
            label: 'Select All',
            onSelected: widget.onSelectAll,
          ),
        if (widget.onCut != null ||
            widget.onCopy != null ||
            widget.onPaste != null ||
            widget.onSelectAll != null)
        if (widget.onClearChat != null)
          PlatformMenuItem(
            label: 'Clear Chat',
            onSelected: widget.onClearChat,
          ),
        if (widget.onDeleteChat != null)
          PlatformMenuItem(
            label: 'Delete Chat',
            onSelected: widget.onDeleteChat,
          ),
      ],
    );
  }

  PlatformMenu _buildViewMenu() {
    return PlatformMenu(
      label: 'View',
      menus: [
        if (widget.onToggleSidebar != null)
          PlatformMenuItem(
            label: 'Toggle Sidebar',
            onSelected: widget.onToggleSidebar,
          ),
        if (widget.onToggleTheme != null)
          PlatformMenuItem(
            label: 'Toggle Theme',
            onSelected: widget.onToggleTheme,
          ),
        if (widget.onToggleSidebar != null || widget.onToggleTheme != null)
        if (widget.onZoomIn != null)
          PlatformMenuItem(
            label: 'Zoom In',
            onSelected: widget.onZoomIn,
          ),
        if (widget.onZoomOut != null)
          PlatformMenuItem(
            label: 'Zoom Out',
            onSelected: widget.onZoomOut,
          ),
        if (widget.onResetZoom != null)
          PlatformMenuItem(
            label: 'Reset Zoom',
            onSelected: widget.onResetZoom,
          ),
        if (widget.onZoomIn != null ||
            widget.onZoomOut != null ||
            widget.onResetZoom != null)
        if (widget.onOpenSettings != null)
          PlatformMenuItem(
            label: 'Open Settings',
            onSelected: widget.onOpenSettings,
          ),
      ],
    );
  }

  PlatformMenu _buildWindowMenu(bool isMac) {
    return PlatformMenu(
      label: 'Window',
      menus: [
        if (widget.onMinimizeWindow != null)
          PlatformMenuItem(
            label: 'Minimize',
            onSelected: widget.onMinimizeWindow,
          ),
        if (isMac) ...[
          PlatformMenuItem(label: 'Zoom'),
          PlatformMenuItem(label: 'Bring All to Front'),
        ] else ...[
          if (widget.onMaximizeWindow != null)
            PlatformMenuItem(
              label: 'Maximize',
              onSelected: widget.onMaximizeWindow,
            ),
          if (widget.onRestoreWindow != null)
            PlatformMenuItem(
              label: 'Restore',
              onSelected: widget.onRestoreWindow,
            ),
        ],
      ],
    );
  }

  PlatformMenu _buildHelpMenu() {
    return PlatformMenu(
      label: 'Help',
      menus: [
        if (widget.onShowDocumentation != null)
          PlatformMenuItem(
            label: 'Documentation',
            onSelected: widget.onShowDocumentation,
          ),
        if (widget.onShowShortcuts != null)
          PlatformMenuItem(
            label: 'Keyboard Shortcuts',
            onSelected: widget.onShowShortcuts,
          ),
        if (widget.onShowDocumentation != null || widget.onShowShortcuts != null)
        if (widget.onReportIssue != null)
          PlatformMenuItem(
            label: 'Report Issue',
            onSelected: widget.onReportIssue,
          ),
        if (widget.onCheckUpdates != null)
          PlatformMenuItem(
            label: 'Check for Updates',
            onSelected: widget.onCheckUpdates,
          ),
        if (widget.onReportIssue != null || widget.onCheckUpdates != null)
        if (widget.onShowAbout != null)
          PlatformMenuItem(
            label: 'About ZeusGPT',
            onSelected: widget.onShowAbout,
          ),
      ],
    );
  }
}

