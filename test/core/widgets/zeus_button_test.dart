import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeusgpt/core/widgets/zeus_button.dart';

void main() {
  group('ZeusButton', () {
    testWidgets('renders with text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusButton(
              text: 'Test Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusButton(
              text: 'Test Button',
              onPressed: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Test Button'));
      expect(pressed, isTrue);
    });

    testWidgets('does not call onPressed when disabled', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusButton(
              text: 'Test Button',
              onPressed: () {
                pressed = true;
              },
              isDisabled: true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Test Button'));
      expect(pressed, isFalse);
    });

    testWidgets('does not call onPressed when loading', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusButton(
              text: 'Test Button',
              onPressed: () {
                pressed = true;
              },
              isLoading: true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ZeusButton));
      expect(pressed, isFalse);
    });

    testWidgets('shows loading indicator when loading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusButton(
              text: 'Test Button',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows loading text when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusButton(
              text: 'Submit',
              onPressed: () {},
              isLoading: true,
              loadingText: 'Submitting...',
            ),
          ),
        ),
      );

      expect(find.text('Submitting...'), findsOneWidget);
      expect(find.text('Submit'), findsNothing);
    });

    testWidgets('renders icon when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusButton(
              text: 'Test Button',
              onPressed: () {},
              icon: Icons.add,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('takes full width when fullWidth is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              child: ZeusButton(
                text: 'Test Button',
                onPressed: () {},
                fullWidth: true,
              ),
            ),
          ),
        ),
      );

      final button = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(ElevatedButton),
          matching: find.byType(SizedBox),
        ).first,
      );

      expect(button.width, equals(double.infinity));
    });

    group('Variants', () {
      testWidgets('renders primary button', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ZeusButton.primary(
                text: 'Primary',
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.text('Primary'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);
      });

      testWidgets('renders secondary button', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ZeusButton.secondary(
                text: 'Secondary',
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.text('Secondary'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);
      });

      testWidgets('renders outlined button', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ZeusButton.outlined(
                text: 'Outlined',
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.text('Outlined'), findsOneWidget);
        expect(find.byType(OutlinedButton), findsOneWidget);
      });

      testWidgets('renders text button', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ZeusButton.text(
                text: 'Text',
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.text('Text'), findsOneWidget);
        expect(find.byType(TextButton), findsOneWidget);
      });

      testWidgets('renders danger button', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ZeusButton.danger(
                text: 'Delete',
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.text('Delete'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);
      });

      testWidgets('renders success button', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ZeusButton.success(
                text: 'Confirm',
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.text('Confirm'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);
      });
    });

    group('Sizes', () {
      testWidgets('renders small button', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ZeusButton(
                text: 'Small',
                onPressed: () {},
                size: ZeusButtonSize.small,
              ),
            ),
          ),
        );

        expect(find.text('Small'), findsOneWidget);
      });

      testWidgets('renders medium button', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ZeusButton(
                text: 'Medium',
                onPressed: () {},
                size: ZeusButtonSize.medium,
              ),
            ),
          ),
        );

        expect(find.text('Medium'), findsOneWidget);
      });

      testWidgets('renders large button', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ZeusButton(
                text: 'Large',
                onPressed: () {},
                size: ZeusButtonSize.large,
              ),
            ),
          ),
        );

        expect(find.text('Large'), findsOneWidget);
      });
    });

    group('Loading State with Icon', () {
      testWidgets('shows loading indicator with icon', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ZeusButton(
                text: 'Submit',
                onPressed: () {},
                icon: Icons.send,
                isLoading: true,
              ),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byIcon(Icons.send), findsNothing);
      });
    });

    group('Accessibility', () {
      testWidgets('button is accessible', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ZeusButton(
                text: 'Accessible Button',
                onPressed: () {},
              ),
            ),
          ),
        );

        final buttonFinder = find.byType(ElevatedButton);
        expect(buttonFinder, findsOneWidget);

        // Verify button is tappable
        final button = tester.widget<ElevatedButton>(buttonFinder);
        expect(button.onPressed, isNotNull);
      });
    });
  });
}
