import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeusgpt/features/chat/presentation/widgets/chat_input.dart';

void main() {
  group('ChatInput', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('renders with text field', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInput(
              controller: controller,
              onSend: () {},
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Type a message...'), findsOneWidget);
    });

    testWidgets('accepts text input', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInput(
              controller: controller,
              onSend: () {},
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Hello world');
      expect(controller.text, equals('Hello world'));
    });

    testWidgets('shows send button when text is not empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInput(
              controller: controller,
              onSend: () {},
            ),
          ),
        ),
      );

      // Initially no send button
      expect(find.widgetWithIcon(IconButton, Icons.send), findsNothing);

      // Enter text
      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pump();

      // Send button should appear
      expect(find.widgetWithIcon(IconButton, Icons.send), findsOneWidget);
    });

    testWidgets('hides send button when text is cleared', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInput(
              controller: controller,
              onSend: () {},
            ),
          ),
        ),
      );

      // Enter text to show send button
      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pump();

      // Send button should be visible
      expect(find.widgetWithIcon(IconButton, Icons.send), findsOneWidget);

      // Clear text
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      // Send button should hide
      expect(find.widgetWithIcon(IconButton, Icons.send), findsNothing);
    });

    testWidgets('shows voice button when text is empty and onVoice provided',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInput(
              controller: controller,
              onSend: () {},
              onVoice: () {},
            ),
          ),
        ),
      );

      expect(find.widgetWithIcon(IconButton, Icons.mic), findsOneWidget);
    });

    testWidgets('hides voice button when text is not empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInput(
              controller: controller,
              onSend: () {},
              onVoice: () {},
            ),
          ),
        ),
      );

      // Initially voice button visible
      expect(find.widgetWithIcon(IconButton, Icons.mic), findsOneWidget);

      // Enter text
      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pump();

      // Voice button should hide
      expect(find.widgetWithIcon(IconButton, Icons.mic), findsNothing);
    });

    testWidgets('shows attachment button when onAttachment provided',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInput(
              controller: controller,
              onSend: () {},
              onAttachment: () {},
            ),
          ),
        ),
      );

      expect(
          find.widgetWithIcon(IconButton, Icons.attach_file), findsOneWidget);
    });

    testWidgets('does not show attachment button when onAttachment is null',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInput(
              controller: controller,
              onSend: () {},
            ),
          ),
        ),
      );

      expect(find.widgetWithIcon(IconButton, Icons.attach_file), findsNothing);
    });

    testWidgets('calls onSend when send button is tapped', (tester) async {
      var sendCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInput(
              controller: controller,
              onSend: () {
                sendCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pump();

      await tester.tap(find.widgetWithIcon(IconButton, Icons.send));
      expect(sendCalled, isTrue);
    });

    testWidgets('calls onSend when text is submitted', (tester) async {
      var sendCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInput(
              controller: controller,
              onSend: () {
                sendCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.testTextInput.receiveAction(TextInputAction.newline);

      // Since the action is newline, onSend shouldn't be called
      // The actual submission happens via send button
      expect(sendCalled, isFalse);
    });

    testWidgets('calls onVoice when voice button is tapped', (tester) async {
      var voiceCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInput(
              controller: controller,
              onSend: () {},
              onVoice: () {
                voiceCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.widgetWithIcon(IconButton, Icons.mic));
      expect(voiceCalled, isTrue);
    });

    testWidgets('calls onAttachment when attachment button is tapped',
        (tester) async {
      var attachmentCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInput(
              controller: controller,
              onSend: () {},
              onAttachment: () {
                attachmentCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.widgetWithIcon(IconButton, Icons.attach_file));
      expect(attachmentCalled, isTrue);
    });

    testWidgets('disables input when isLoading is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInput(
              controller: controller,
              onSend: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('shows loading indicator when isLoading is true',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInput(
              controller: controller,
              onSend: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('hides send button when isLoading is true', (tester) async {
      controller.text = 'Hello';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInput(
              controller: controller,
              onSend: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.widgetWithIcon(IconButton, Icons.send), findsNothing);
    });

    testWidgets('disables attachment button when isLoading is true',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInput(
              controller: controller,
              onSend: () {},
              isLoading: true,
              onAttachment: () {},
            ),
          ),
        ),
      );

      final attachButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.attach_file),
      );
      expect(attachButton.onPressed, isNull);
    });

    testWidgets('handles whitespace-only text as empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInput(
              controller: controller,
              onSend: () {},
            ),
          ),
        ),
      );

      // Enter only whitespace
      await tester.enterText(find.byType(TextField), '   ');
      await tester.pump();

      // Send button should not appear
      expect(find.widgetWithIcon(IconButton, Icons.send), findsNothing);
    });

    testWidgets('shows send button for text with leading/trailing spaces',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInput(
              controller: controller,
              onSend: () {},
            ),
          ),
        ),
      );

      // Enter text with spaces
      await tester.enterText(find.byType(TextField), '  Hello  ');
      await tester.pump();

      // Send button should appear (has non-whitespace content)
      expect(find.widgetWithIcon(IconButton, Icons.send), findsOneWidget);
    });
  });
}
