import 'package:flutter/material.dart';
import '../../core/services/shortcut_manager.dart';
import '../../core/responsive.dart';

/// Screen displaying all available keyboard shortcuts
///
/// Shows shortcuts organized by category with search functionality.
/// Accessible via AppShortcut.showShortcuts (Cmd/Ctrl+Shift+?).
///
/// Example usage:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(builder: (context) => KeyboardShortcutsScreen()),
/// );
/// ```
class KeyboardShortcutsScreen extends ResponsiveScreenWithAppBar {
  const KeyboardShortcutsScreen({super.key});

  @override
  String getTitle(BuildContext context) => 'Keyboard Shortcuts';

  @override
  List<Widget>? getActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => Navigator.pop(context),
        tooltip: 'Close',
      ),
    ];
  }

  @override
  Widget buildMobileContent(BuildContext context) {
    return const _ShortcutsContent(compact: true);
  }

  @override
  Widget buildDesktopContent(BuildContext context) {
    return ResponsiveCenter(
      maxWidth: 1000,
      child: const Padding(
        padding: EdgeInsets.all(32),
        child: _ShortcutsContent(compact: false),
      ),
    );
  }
}

/// Internal widget for displaying shortcuts content
class _ShortcutsContent extends StatefulWidget {
  const _ShortcutsContent({
    required this.compact,
  });

  final bool compact;

  @override
  State<_ShortcutsContent> createState() => _ShortcutsContentState();
}

class _ShortcutsContentState extends State<_ShortcutsContent> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Group shortcuts by category
    final groupedShortcuts = <ShortcutCategory, List<AppShortcut>>{};
    for (final category in ShortcutCategory.values) {
      groupedShortcuts[category] = AppShortcut.values
          .where((s) => s.category == category)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      for (final category in groupedShortcuts.keys) {
        groupedShortcuts[category] = groupedShortcuts[category]!
            .where((s) =>
                s.label.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                s.description
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                s.displayString
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()))
            .toList();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar
        Padding(
          padding: EdgeInsets.all(widget.compact ? 16 : 0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search shortcuts...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _searchController.clear();
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),

        const SizedBox(height: 24),

        // Shortcuts list
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(widget.compact ? 16 : 0),
            children: [
              for (final category in ShortcutCategory.values)
                if (groupedShortcuts[category]!.isNotEmpty) ...[
                  _CategorySection(
                    category: category,
                    shortcuts: groupedShortcuts[category]!,
                    compact: widget.compact,
                  ),
                  const SizedBox(height: 32),
                ],
            ],
          ),
        ),

        // Footer
        Padding(
          padding: EdgeInsets.all(widget.compact ? 16 : 0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Shortcuts work on desktop and web platforms. '
                      'Press ${AppShortcut.showShortcuts.displayString} to show this screen anytime.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Category section widget
class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.category,
    required this.shortcuts,
    required this.compact,
  });

  final ShortcutCategory category;
  final List<AppShortcut> shortcuts;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category header
        Row(
          children: [
            Icon(
              category.icon,
              size: 24,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Text(
              category.label,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Shortcuts in this category
        if (compact)
          // Mobile: Stack vertically
          ...shortcuts.map(
            (shortcut) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ShortcutItem(
                shortcut: shortcut,
                compact: true,
              ),
            ),
          )
        else
          // Desktop: Two-column grid
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: shortcuts.map((shortcut) {
              return SizedBox(
                width: (MediaQuery.of(context).size.width - 96) / 2,
                child: _ShortcutItem(
                  shortcut: shortcut,
                  compact: false,
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

/// Individual shortcut item widget
class _ShortcutItem extends StatelessWidget {
  const _ShortcutItem({
    required this.shortcut,
    required this.compact,
  });

  final AppShortcut shortcut;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      // Mobile: Vertical layout
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      shortcut.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  _KeyboardKeyChip(
                    displayString: shortcut.displayString,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                shortcut.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Desktop: Horizontal layout
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shortcut.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      shortcut.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _KeyboardKeyChip(
                displayString: shortcut.displayString,
              ),
            ],
          ),
        ),
      );
    }
  }
}

/// Widget displaying keyboard shortcut keys
class _KeyboardKeyChip extends StatelessWidget {
  const _KeyboardKeyChip({
    required this.displayString,
  });

  final String displayString;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Text(
        displayString,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}
