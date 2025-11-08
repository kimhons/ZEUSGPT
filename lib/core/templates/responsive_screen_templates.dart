import 'package:flutter/material.dart';
import '../widgets/responsive_screen.dart';
import '../widgets/adaptive_scaffold.dart';
import '../widgets/responsive_layout.dart';

/// Example templates for responsive screen implementations
///
/// These templates demonstrate how to use ResponsiveScreen and
/// AdaptiveScaffold to create adaptive UIs for different form factors.
///
/// Copy and modify these templates for your own screens.

// ==============================================================================
// TEMPLATE 1: Basic Responsive Screen with Different Layouts
// ==============================================================================

/// Template showing a basic responsive screen with different layouts
/// for mobile, tablet, and desktop
class BasicResponsiveScreenTemplate extends ResponsiveScreen {
  const BasicResponsiveScreenTemplate({super.key});

  @override
  Widget buildMobile(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mobile Layout'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Mobile Layout',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'This is optimized for small screens with vertical scrolling.',
          ),
          const SizedBox(height: 24),
          _buildContentCards(1), // Single column
        ],
      ),
    );
  }

  @override
  Widget buildTablet(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tablet Layout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tablet Layout',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'This uses more horizontal space with a two-column grid.',
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _buildContentCards(2), // Two columns
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget buildDesktop(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Desktop Layout'),
        elevation: 0,
      ),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sidebar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text('Desktop layouts can include sidebars.'),
                const SizedBox(height: 24),
                _buildSidebarMenu(),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Desktop Layout',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'This uses a multi-column layout with sidebar navigation.',
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: _buildContentCards(3), // Three columns
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCards(int columns) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Card ${index + 1}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Sample content for this card.'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSidebarMenu() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.home),
          title: const Text('Home'),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Settings'),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('About'),
          onTap: () {},
        ),
      ],
    );
  }
}

// ==============================================================================
// TEMPLATE 2: Screen with Adaptive Navigation
// ==============================================================================

/// Template showing how to use AdaptiveScaffold with navigation
class AdaptiveNavigationTemplate extends StatefulWidget {
  const AdaptiveNavigationTemplate({super.key});

  @override
  State<AdaptiveNavigationTemplate> createState() =>
      _AdaptiveNavigationTemplateState();
}

class _AdaptiveNavigationTemplateState
    extends State<AdaptiveNavigationTemplate> {
  int _currentIndex = 0;

  static const _destinations = [
    AdaptiveScaffoldDestination(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
    ),
    AdaptiveScaffoldDestination(
      icon: Icons.chat_outlined,
      selectedIcon: Icons.chat,
      label: 'Chat',
    ),
    AdaptiveScaffoldDestination(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      currentIndex: _currentIndex,
      onDestinationSelected: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      destinations: _destinations,
      appBar: AppBar(
        title: Text(_getTitle()),
      ),
      body: _buildCurrentScreen(),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Home';
      case 1:
        return 'Chat';
      case 2:
        return 'Settings';
      default:
        return 'App';
    }
  }

  Widget _buildCurrentScreen() {
    return ResponsiveCenter(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _destinations[_currentIndex].selectedIcon ??
                  _destinations[_currentIndex].icon,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              _destinations[_currentIndex].label,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Content for this screen goes here.'),
          ],
        ),
      ),
    );
  }
}

// ==============================================================================
// TEMPLATE 3: List-Detail Pattern for Tablet/Desktop
// ==============================================================================

/// Template showing the list-detail pattern for larger screens
class ListDetailTemplate extends ResponsiveScreen {
  const ListDetailTemplate({super.key});

  @override
  Widget buildMobile(BuildContext context) {
    // Mobile: Show list only, navigate to detail screen
    return Scaffold(
      appBar: AppBar(
        title: const Text('Items'),
      ),
      body: ListView.builder(
        itemCount: 20,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(child: Text('${index + 1}')),
            title: Text('Item ${index + 1}'),
            subtitle: const Text('Tap to view details'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to detail screen
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => _DetailScreen(index: index),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget buildDesktop(BuildContext context) {
    // Desktop: Show list and detail side-by-side
    return Scaffold(
      appBar: AppBar(
        title: const Text('Items'),
        elevation: 0,
      ),
      body: Row(
        children: [
          // List panel
          SizedBox(
            width: 320,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search items...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: 20,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(child: Text('${index + 1}')),
                        title: Text('Item ${index + 1}'),
                        subtitle: const Text('Click to view'),
                        onTap: () {
                          // Update detail panel
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          // Detail panel
          const Expanded(
            child: Center(
              child: Text('Select an item to view details'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailScreen extends StatelessWidget {
  const _DetailScreen({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Item ${index + 1}'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 48,
              child: Text('${index + 1}'),
            ),
            const SizedBox(height: 24),
            Text(
              'Item ${index + 1}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Details about this item would be displayed here.',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==============================================================================
// TEMPLATE 4: Form Layout Template
// ==============================================================================

/// Template showing responsive form layouts
class FormLayoutTemplate extends ResponsiveScreenWithAppBar {
  const FormLayoutTemplate({super.key});

  @override
  String getTitle(BuildContext context) => 'Form Example';

  @override
  Widget buildMobileContent(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _buildFormFields(1), // Single column
    );
  }

  @override
  Widget buildDesktopContent(BuildContext context) {
    return ResponsiveCenter(
      maxWidth: 800,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: _buildFormFields(2), // Two columns
        ),
      ),
    );
  }

  List<Widget> _buildFormFields(int columns) {
    final fields = [
      TextFormField(
        decoration: const InputDecoration(
          labelText: 'First Name',
          border: OutlineInputBorder(),
        ),
      ),
      TextFormField(
        decoration: const InputDecoration(
          labelText: 'Last Name',
          border: OutlineInputBorder(),
        ),
      ),
      TextFormField(
        decoration: const InputDecoration(
          labelText: 'Email',
          border: OutlineInputBorder(),
        ),
      ),
      TextFormField(
        decoration: const InputDecoration(
          labelText: 'Phone',
          border: OutlineInputBorder(),
        ),
      ),
    ];

    if (columns == 1) {
      // Single column: stack vertically with spacing
      return fields
          .map((field) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: field,
              ))
          .toList();
    } else {
      // Two columns: pair fields side by side
      final rows = <Widget>[];
      for (var i = 0; i < fields.length; i += 2) {
        rows.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Expanded(child: fields[i]),
                const SizedBox(width: 16),
                if (i + 1 < fields.length) Expanded(child: fields[i + 1]),
              ],
            ),
          ),
        );
      }
      return rows;
    }
  }
}
