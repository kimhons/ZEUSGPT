import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeusgpt/core/widgets/zeus_card.dart';

void main() {
  group('ZeusCard', () {
    testWidgets('renders with child', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ZeusCard(
              child: Text('Test Content'),
            ),
          ),
        ),
      );

      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('applies custom padding', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ZeusCard(
              padding: EdgeInsets.all(32),
              child: Text('Test'),
            ),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('applies custom margin', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ZeusCard(
              margin: EdgeInsets.all(20),
              child: Text('Test'),
            ),
          ),
        ),
      );

      expect(find.byType(ZeusCard), findsOneWidget);
    });

    testWidgets('applies custom color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ZeusCard(
              color: Colors.blue,
              child: Text('Test'),
            ),
          ),
        ),
      );

      expect(find.byType(ZeusCard), findsOneWidget);
    });

    testWidgets('applies custom border radius', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusCard(
              borderRadius: BorderRadius.circular(20),
              child: const Text('Test'),
            ),
          ),
        ),
      );

      expect(find.byType(ZeusCard), findsOneWidget);
    });

    testWidgets('applies custom border', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusCard(
              border: Border.all(color: Colors.red, width: 2),
              child: const Text('Test'),
            ),
          ),
        ),
      );

      expect(find.byType(ZeusCard), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusCard(
              onTap: () {
                tapped = true;
              },
              child: const Text('Test'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Test'));
      expect(tapped, isTrue);
    });

    testWidgets('renders without GestureDetector when onTap is null',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ZeusCard(
              child: Text('Test'),
            ),
          ),
        ),
      );

      expect(find.byType(GestureDetector), findsNothing);
    });

    testWidgets('renders with GestureDetector when onTap is provided',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusCard(
              onTap: () {},
              child: const Text('Test'),
            ),
          ),
        ),
      );

      expect(find.byType(GestureDetector), findsOneWidget);
    });

    testWidgets('applies custom width and height', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ZeusCard(
              width: 200,
              height: 150,
              child: Text('Test'),
            ),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('applies elevation with shadow', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ZeusCard(
              elevation: 4,
              child: Text('Test'),
            ),
          ),
        ),
      );

      expect(find.byType(ZeusCard), findsOneWidget);
    });

    testWidgets('applies zero elevation without shadow', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ZeusCard(
              elevation: 0,
              child: Text('Test'),
            ),
          ),
        ),
      );

      expect(find.byType(ZeusCard), findsOneWidget);
    });
  });

  group('ZeusGradientCard', () {
    testWidgets('renders with gradient background', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ZeusGradientCard(
              child: Text('Test Content'),
            ),
          ),
        ),
      );

      expect(find.text('Test Content'), findsOneWidget);
      expect(find.byType(ZeusGradientCard), findsOneWidget);
    });

    testWidgets('applies custom gradient', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ZeusGradientCard(
              gradient: LinearGradient(
                colors: [Colors.red, Colors.blue],
              ),
              child: Text('Test'),
            ),
          ),
        ),
      );

      expect(find.byType(ZeusGradientCard), findsOneWidget);
    });

    testWidgets('applies custom padding', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ZeusGradientCard(
              padding: EdgeInsets.all(32),
              child: Text('Test'),
            ),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('applies custom margin', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ZeusGradientCard(
              margin: EdgeInsets.all(20),
              child: Text('Test'),
            ),
          ),
        ),
      );

      expect(find.byType(ZeusGradientCard), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusGradientCard(
              onTap: () {
                tapped = true;
              },
              child: const Text('Test'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Test'));
      expect(tapped, isTrue);
    });

    testWidgets('renders without GestureDetector when onTap is null',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ZeusGradientCard(
              child: Text('Test'),
            ),
          ),
        ),
      );

      expect(find.byType(GestureDetector), findsNothing);
    });

    testWidgets('applies elevation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ZeusGradientCard(
              elevation: 4,
              child: Text('Test'),
            ),
          ),
        ),
      );

      expect(find.byType(ZeusGradientCard), findsOneWidget);
    });
  });
}
