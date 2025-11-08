import 'package:flutter/material.dart';

/// A wrapper around tappable cards that includes semantic labels for screen readers.
///
/// This widget ensures interactive cards are accessible to users with visual
/// impairments by providing descriptive labels and proper button semantics.
///
/// Example usage:
/// ```dart
/// AccessibleCard(
///   label: 'GPT-4 model, Premium tier, $20 per month',
///   onTap: () => _selectModel(model),
///   child: ModelCard(model: model),
/// )
/// ```
class AccessibleCard extends StatelessWidget {
  /// The semantic label that describes the card's content and action.
  final String label;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  /// The child widget to display in the card.
  final Widget child;

  /// Optional hint text to provide additional context.
  /// Example: "Double tap to open details"
  final String? hint;

  /// Whether the card is currently selected.
  final bool selected;

  /// Optional long press handler.
  final VoidCallback? onLongPress;

  const AccessibleCard({
    Key? key,
    required this.label,
    required this.child,
    this.onTap,
    this.hint,
    this.selected = false,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      enabled: onTap != null,
      hint: hint,
      selected: selected,
      onTap: onTap,
      onLongPress: onLongPress,
      child: child,
    );
  }
}

/// A wrapper for list items that includes semantic labels for screen readers.
///
/// Use this for items in lists, grids, or any scrollable collection
/// to ensure they're properly announced by screen readers.
///
/// Example usage:
/// ```dart
/// AccessibleListItem(
///   label: 'Conversation with AI Assistant, 5 messages, last active 2 hours ago',
///   onTap: () => _openConversation(conversation),
///   child: ConversationListItem(conversation: conversation),
/// )
/// ```
class AccessibleListItem extends StatelessWidget {
  /// The semantic label that describes the list item's content.
  final String label;

  /// Called when the item is tapped.
  final VoidCallback? onTap;

  /// The child widget to display.
  final Widget child;

  /// Optional hint text to provide additional context.
  final String? hint;

  /// Whether the item is currently selected.
  final bool selected;

  /// Optional long press handler.
  final VoidCallback? onLongPress;

  /// The index of this item in the list (helps screen readers
  /// announce position, e.g., "Item 1 of 10").
  final int? index;

  /// The total count of items in the list.
  final int? totalCount;

  const AccessibleListItem({
    Key? key,
    required this.label,
    required this.child,
    this.onTap,
    this.hint,
    this.selected = false,
    this.onLongPress,
    this.index,
    this.totalCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String fullLabel = label;

    // Add position information if available
    if (index != null && totalCount != null) {
      fullLabel = '$label. Item ${index! + 1} of $totalCount';
    }

    return Semantics(
      label: fullLabel,
      button: true,
      enabled: onTap != null,
      hint: hint,
      selected: selected,
      onTap: onTap,
      onLongPress: onLongPress,
      child: child,
    );
  }
}

/// A wrapper for expandable widgets (like ExpansionTile) with accessibility support.
///
/// This ensures users with screen readers understand that the widget can
/// be expanded/collapsed and its current state.
///
/// Example usage:
/// ```dart
/// AccessibleExpandable(
///   label: 'Advanced settings',
///   expanded: _isExpanded,
///   onTap: () => setState(() => _isExpanded = !_isExpanded),
///   child: ExpansionTile(...),
/// )
/// ```
class AccessibleExpandable extends StatelessWidget {
  /// The semantic label describing the expandable section.
  final String label;

  /// Whether the section is currently expanded.
  final bool expanded;

  /// Called when the header is tapped.
  final VoidCallback? onTap;

  /// The child widget (typically an ExpansionTile or similar).
  final Widget child;

  const AccessibleExpandable({
    Key? key,
    required this.label,
    required this.expanded,
    required this.child,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      expanded: expanded,
      hint: expanded ? 'Double tap to collapse' : 'Double tap to expand',
      onTap: onTap,
      child: child,
    );
  }
}

/// A wrapper for checkbox/switch/radio widgets with proper semantic labels.
///
/// This ensures form controls are properly announced by screen readers
/// with their current state.
///
/// Example usage:
/// ```dart
/// AccessibleCheckbox(
///   label: 'Enable notifications',
///   value: _notificationsEnabled,
///   onChanged: (value) => setState(() => _notificationsEnabled = value),
/// )
/// ```
class AccessibleCheckbox extends StatelessWidget {
  /// The label describing what the checkbox controls.
  final String label;

  /// The current value of the checkbox.
  final bool value;

  /// Called when the checkbox is toggled.
  final ValueChanged<bool?>? onChanged;

  /// Optional additional context about the checkbox.
  final String? hint;

  const AccessibleCheckbox({
    Key? key,
    required this.label,
    required this.value,
    this.onChanged,
    this.hint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      checked: value,
      enabled: onChanged != null,
      hint: hint,
      child: Checkbox(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

/// A wrapper for switch widgets with proper semantic labels.
///
/// Example usage:
/// ```dart
/// AccessibleSwitch(
///   label: 'Dark mode',
///   value: _darkModeEnabled,
///   onChanged: (value) => setState(() => _darkModeEnabled = value),
/// )
/// ```
class AccessibleSwitch extends StatelessWidget {
  /// The label describing what the switch controls.
  final String label;

  /// The current value of the switch.
  final bool value;

  /// Called when the switch is toggled.
  final ValueChanged<bool>? onChanged;

  /// Optional additional context about the switch.
  final String? hint;

  const AccessibleSwitch({
    Key? key,
    required this.label,
    required this.value,
    this.onChanged,
    this.hint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      toggled: value,
      enabled: onChanged != null,
      hint: hint,
      child: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
