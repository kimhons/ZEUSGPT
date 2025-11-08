import 'package:flutter/material.dart';
import '../../../../core/responsive.dart';

/// Screen that displays all available keyboard shortcuts
///
/// This screen shows a categorized list of all keyboard shortcuts
/// available in the application. It's accessible via the Cmd/Ctrl+Shift+/
/// shortcut or from the Help menu.
class KeyboardShortcutsScreen extends StatelessWidget {
  const KeyboardShortcutsScreen({super.key});

  static const String routeName = '/keyboard-shortcuts';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shortcuts = KeyboardShortcutManager.instance.getShortcutsByCategory();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keyboard Shortcuts'),
        centerTitle: true,
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(context, theme, shortcuts),
        tablet: _buildTabletLayout(context, theme, shortcuts),
        desktop: _buildDesktopLayout(context, theme, shortcuts),
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    ThemeData theme,
    Map<String, List<ShortcutAction>> shortcuts,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Keyboard shortcuts are available on desktop and web platforms.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ...shortcuts.entries.map((entry) => _buildCategory(
          context,
          theme,
          entry.key,
          entry.value,
        )),
      ],
    );
  }

  Widget _buildTabletLayout(
    BuildContext context,
    ThemeData theme,
    Map<String, List<ShortcutAction>> shortcuts,
  ) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Keyboard Shortcuts',
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Use these shortcuts to navigate and interact with Zeus GPT more efficiently.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ...shortcuts.entries.map((entry) => _buildCategory(
              context,
              theme,
              entry.key,
              entry.value,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    ThemeData theme,
    Map<String, List<ShortcutAction>> shortcuts,
  ) {
    final categories = shortcuts.entries.toList();
    final halfwayPoint = (categories.length / 2).ceil();
    final leftColumn = categories.sublist(0, halfwayPoint);
    final rightColumn = categories.sublist(halfwayPoint);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: ListView(
          padding: const EdgeInsets.all(32),
          children: [
            Text(
              'Keyboard Shortcuts',
              style: theme.textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Use these shortcuts to navigate and interact with Zeus GPT more efficiently.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            // Two-column layout for desktop
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: leftColumn.map((entry) => _buildCategory(
                        context,
                        theme,
                        entry.key,
                        entry.value,
                      )).toList(),
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: rightColumn.map((entry) => _buildCategory(
                        context,
                        theme,
                        entry.key,
                        entry.value,
                      )).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(
    BuildContext context,
    ThemeData theme,
    String categoryName,
    List<ShortcutAction> shortcuts,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            categoryName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        ...shortcuts.map((action) => _buildShortcutRow(context, theme, action)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildShortcutRow(
    BuildContext context,
    ThemeData theme,
    ShortcutAction action,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              action.displayName,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: _buildKeyboardKey(context, theme, action.keyboardDisplay),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyboardKey(BuildContext context, ThemeData theme, String keys) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Text(
        keys,
        style: theme.textTheme.bodySmall?.copyWith(
          fontFamily: 'monospace',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Dialog version of the keyboard shortcuts screen
///
/// Use this to show shortcuts in a dialog instead of navigating to a new screen.
class KeyboardShortcutsDialog extends StatelessWidget {
  const KeyboardShortcutsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const KeyboardShortcutsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shortcuts = KeyboardShortcutManager.instance.getShortcutsByCategory();

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 800,
          maxHeight: 600,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Text(
                    'Keyboard Shortcuts',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: shortcuts.entries.map((entry) => _buildCategory(
                  context,
                  theme,
                  entry.key,
                  entry.value,
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(
    BuildContext context,
    ThemeData theme,
    String categoryName,
    List<ShortcutAction> shortcuts,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            categoryName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        ...shortcuts.map((action) => _buildShortcutRow(context, theme, action)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildShortcutRow(
    BuildContext context,
    ThemeData theme,
    ShortcutAction action,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action.displayName,
                  style: theme.textTheme.bodyMedium,
                ),
                if (action.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      action.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: _buildKeyboardKey(context, theme, action.keyboardDisplay),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyboardKey(BuildContext context, ThemeData theme, String keys) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Text(
        keys,
        style: theme.textTheme.bodySmall?.copyWith(
          fontFamily: 'monospace',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
