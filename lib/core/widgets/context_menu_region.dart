import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/platform_helper.dart';

/// A widget that shows a context menu on right-click (desktop) or long-press (mobile)
///
/// This widget provides a native-like context menu experience with
/// customizable menu items and keyboard shortcuts.
///
/// Usage:
/// ```dart
/// ContextMenuRegion(
///   menuItems: [
///     ContextMenuItem(
///       title: 'Copy',
///       icon: Icons.copy,
///       onTap: () => handleCopy(),
///     ),
///   ],
///   child: Text('Right-click me'),
/// )
/// ```
class ContextMenuRegion extends StatelessWidget {
  final Widget child;
  final List<ContextMenuItem> menuItems;
  final bool enabled;
  final VoidCallback? onMenuOpened;
  final VoidCallback? onMenuClosed;

  const ContextMenuRegion({
    super.key,
    required this.child,
    required this.menuItems,
    this.enabled = true,
    this.onMenuOpened,
    this.onMenuClosed,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled || menuItems.isEmpty) {
      return child;
    }

    // On desktop, use right-click
    if (PlatformHelper.isDesktop) {
      return GestureDetector(
        onSecondaryTapUp: (details) {
          onMenuOpened?.call();
          _showContextMenu(context, details.globalPosition);
        },
        child: child,
      );
    }

    // On mobile, use long-press
    return GestureDetector(
      onLongPressStart: (details) {
        onMenuOpened?.call();
        _showContextMenu(context, details.globalPosition);
      },
      child: child,
    );
  }

  void _showContextMenu(BuildContext context, Offset position) {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    
    showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(position.dx, position.dy, 0, 0),
        Offset.zero & overlay.size,
      ),
      items: menuItems.map((item) {
        return PopupMenuItem<String>(
          value: item.id,
          enabled: item.enabled,
          child: Row(
            children: [
              if (item.icon != null) ...[
                Icon(item.icon, size: 18),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(item.title),
              ),
              if (item.shortcut != null) ...[
                const SizedBox(width: 24),
                Text(
                  item.shortcut!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
      elevation: 8,
    ).then((value) {
      onMenuClosed?.call();
      if (value != null) {
        final item = menuItems.firstWhere((item) => item.id == value);
        item.onTap?.call();
      }
    });
  }
}

/// Represents a single item in a context menu
class ContextMenuItem {
  final String id;
  final String title;
  final IconData? icon;
  final VoidCallback? onTap;
  final String? shortcut;
  final bool enabled;
  final Color? color;

  const ContextMenuItem({
    required this.title,
    this.id = '',
    this.icon,
    this.onTap,
    this.shortcut,
    this.enabled = true,
    this.color,
  });

  /// Create a separator item
  static ContextMenuItem separator() {
    return const ContextMenuItem(
      title: '',
      id: '__separator__',
      enabled: false,
    );
  }
}

/// Common context menu presets
class ContextMenuPresets {
  /// Text editing menu (copy, paste, cut, select all)
  static List<ContextMenuItem> textEditing({
    VoidCallback? onCopy,
    VoidCallback? onPaste,
    VoidCallback? onCut,
    VoidCallback? onSelectAll,
  }) {
    return [
      ContextMenuItem(
        title: 'Copy',
        icon: Icons.copy,
        onTap: onCopy,
        shortcut: PlatformHelper.isMacOS ? '⌘C' : 'Ctrl+C',
      ),
      ContextMenuItem(
        title: 'Cut',
        icon: Icons.content_cut,
        onTap: onCut,
        shortcut: PlatformHelper.isMacOS ? '⌘X' : 'Ctrl+X',
      ),
      ContextMenuItem(
        title: 'Paste',
        icon: Icons.paste,
        onTap: onPaste,
        shortcut: PlatformHelper.isMacOS ? '⌘V' : 'Ctrl+V',
      ),
      ContextMenuItem.separator(),
      ContextMenuItem(
        title: 'Select All',
        icon: Icons.select_all,
        onTap: onSelectAll,
        shortcut: PlatformHelper.isMacOS ? '⌘A' : 'Ctrl+A',
      ),
    ];
  }

  /// File menu (open, save, delete, rename)
  static List<ContextMenuItem> file({
    VoidCallback? onOpen,
    VoidCallback? onSave,
    VoidCallback? onDelete,
    VoidCallback? onRename,
  }) {
    return [
      ContextMenuItem(
        title: 'Open',
        icon: Icons.folder_open,
        onTap: onOpen,
      ),
      ContextMenuItem(
        title: 'Save',
        icon: Icons.save,
        onTap: onSave,
        shortcut: PlatformHelper.isMacOS ? '⌘S' : 'Ctrl+S',
      ),
      ContextMenuItem.separator(),
      ContextMenuItem(
        title: 'Rename',
        icon: Icons.edit,
        onTap: onRename,
      ),
      ContextMenuItem(
        title: 'Delete',
        icon: Icons.delete,
        onTap: onDelete,
        color: Colors.red,
      ),
    ];
  }

  /// Chat message menu
  static List<ContextMenuItem> chatMessage({
    VoidCallback? onCopy,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
    VoidCallback? onRegenerate,
  }) {
    return [
      ContextMenuItem(
        title: 'Copy',
        icon: Icons.copy,
        onTap: onCopy,
      ),
      ContextMenuItem(
        title: 'Edit',
        icon: Icons.edit,
        onTap: onEdit,
      ),
      ContextMenuItem(
        title: 'Regenerate',
        icon: Icons.refresh,
        onTap: onRegenerate,
      ),
      ContextMenuItem.separator(),
      ContextMenuItem(
        title: 'Delete',
        icon: Icons.delete,
        onTap: onDelete,
        color: Colors.red,
      ),
    ];
  }
}
