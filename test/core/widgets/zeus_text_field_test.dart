import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeusgpt/core/widgets/zeus_text_field.dart';

void main() {
  group('ZeusTextField', () {
    testWidgets('renders with label and hint', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusTextField(
              label: 'Test Label',
              hint: 'Test Hint',
            ),
          ),
        ),
      );

      expect(find.text('Test Label'), findsOneWidget);
      expect(find.text('Test Hint'), findsOneWidget);
    });

    testWidgets('accepts text input', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusTextField(
              controller: controller,
              hint: 'Enter text',
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Hello World');
      expect(controller.text, equals('Hello World'));
    });

    testWidgets('calls onChanged when text changes', (tester) async {
      String? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusTextField(
              hint: 'Test',
              onChanged: (value) {
                changedValue = value;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Test Input');
      expect(changedValue, equals('Test Input'));
    });

    testWidgets('calls onSubmitted when submitted', (tester) async {
      String? submittedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusTextField(
              hint: 'Test',
              onSubmitted: (value) {
                submittedValue = value;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Submit Test');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      expect(submittedValue, equals('Submit Test'));
    });

    testWidgets('displays error text when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusTextField(
              hint: 'Test',
              errorText: 'Error message',
            ),
          ),
        ),
      );

      expect(find.text('Error message'), findsOneWidget);
    });

    testWidgets('displays helper text when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusTextField(
              hint: 'Test',
              helperText: 'Helper message',
            ),
          ),
        ),
      );

      expect(find.text('Helper message'), findsOneWidget);
    });

    testWidgets('validates input with validator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusTextField(
              hint: 'Test',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                return null;
              },
            ),
          ),
        ),
      );

      // First enter some text
      await tester.enterText(find.byType(TextFormField), 'test');
      await tester.pump();

      // No error should be shown
      expect(find.text('Required'), findsNothing);

      // Now clear the text to trigger validation error
      await tester.enterText(find.byType(TextFormField), '');
      await tester.pump();

      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('shows prefix icon when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusTextField(
              hint: 'Test',
              prefixIcon: Icons.person,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('shows suffix icon when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusTextField(
              hint: 'Test',
              suffixIcon: const Icon(Icons.check),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('obscures text when obscureText is true', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusTextField(
              controller: controller,
              hint: 'Password',
              obscureText: true,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'secret');

      // Verify text is entered in controller
      expect(controller.text, equals('secret'));
    });

    testWidgets('toggles password visibility icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusTextField(
              hint: 'Password',
              obscureText: true,
            ),
          ),
        ),
      );

      // Initially shows visibility icon (to show password)
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      // Tap visibility toggle
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      // Now shows visibility_off icon (to hide password)
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

      // Tap again to hide
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();

      // Back to visibility icon
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('allows text input when enabled', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusTextField(
              controller: controller,
              hint: 'Test',
              enabled: true,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'enabled text');
      expect(controller.text, equals('enabled text'));
    });

    testWidgets('updates error text when widget updates', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusTextField(
              hint: 'Test',
              errorText: 'First error',
            ),
          ),
        ),
      );

      expect(find.text('First error'), findsOneWidget);

      // Update with new error
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusTextField(
              hint: 'Test',
              errorText: 'Second error',
            ),
          ),
        ),
      );

      expect(find.text('Second error'), findsOneWidget);
      expect(find.text('First error'), findsNothing);
    });
  });

  group('ZeusSearchField', () {
    testWidgets('renders with search icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusSearchField(
              onChanged: (value) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('shows default hint text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusSearchField(
              onChanged: (value) {},
            ),
          ),
        ),
      );

      expect(find.text('Search...'), findsOneWidget);
    });

    testWidgets('shows custom hint text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusSearchField(
              hint: 'Custom search hint',
              onChanged: (value) {},
            ),
          ),
        ),
      );

      expect(find.text('Custom search hint'), findsOneWidget);
    });

    testWidgets('calls onChanged when text changes', (tester) async {
      String? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusSearchField(
              onChanged: (value) {
                changedValue = value;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'search query');
      expect(changedValue, equals('search query'));
    });

    testWidgets('shows clear button when text is not empty', (tester) async {
      final controller = TextEditingController(text: 'test');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusSearchField(
              controller: controller,
              onChanged: (value) {},
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('clears text when clear button is tapped', (tester) async {
      final controller = TextEditingController(text: 'test');
      String? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusSearchField(
              controller: controller,
              onChanged: (value) {
                changedValue = value;
              },
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      expect(controller.text, equals(''));
      expect(changedValue, equals(''));
    });
  });

  group('ZeusEmailField', () {
    testWidgets('renders with default label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusEmailField(),
          ),
        ),
      );

      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('renders with custom label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusEmailField(
              label: 'Work Email',
            ),
          ),
        ),
      );

      expect(find.text('Work Email'), findsOneWidget);
    });

    testWidgets('shows email icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusEmailField(),
          ),
        ),
      );

      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    });

    testWidgets('accepts email input', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusEmailField(
              controller: controller,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      expect(controller.text, equals('test@example.com'));
    });

    testWidgets('calls onChanged when text changes', (tester) async {
      String? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusEmailField(
              onChanged: (value) {
                changedValue = value;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      expect(changedValue, equals('test@example.com'));
    });

    testWidgets('calls validator when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusEmailField(
              validator: (value) {
                if (value == null || !value.contains('@')) {
                  return 'Invalid email';
                }
                return null;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'invalid');
      await tester.pump();

      expect(find.text('Invalid email'), findsOneWidget);
    });
  });

  group('ZeusPasswordField', () {
    testWidgets('renders with default label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusPasswordField(),
          ),
        ),
      );

      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('renders with custom label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusPasswordField(
              label: 'New Password',
            ),
          ),
        ),
      );

      expect(find.text('New Password'), findsOneWidget);
    });

    testWidgets('shows lock icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusPasswordField(),
          ),
        ),
      );

      expect(find.byIcon(Icons.lock_outlined), findsOneWidget);
    });

    testWidgets('shows visibility toggle icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusPasswordField(),
          ),
        ),
      );

      // Password field should have visibility toggle icon
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('toggles password visibility icon on tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusPasswordField(),
          ),
        ),
      );

      // Initially shows visibility icon (to reveal password)
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      // Tap to show password
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      // Now shows visibility_off icon (to hide password)
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

      // Tap to hide password again
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();

      // Back to visibility icon
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('calls onChanged when text changes', (tester) async {
      String? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusPasswordField(
              onChanged: (value) {
                changedValue = value;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'secret123');
      expect(changedValue, equals('secret123'));
    });

    testWidgets('accepts password input', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusPasswordField(
              controller: controller,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'secret123');
      expect(controller.text, equals('secret123'));
    });

    testWidgets('calls validator when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZeusPasswordField(
              validator: (value) {
                if (value == null || value.length < 8) {
                  return 'Password too short';
                }
                return null;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'short');
      await tester.pump();

      expect(find.text('Password too short'), findsOneWidget);
    });
  });
}
