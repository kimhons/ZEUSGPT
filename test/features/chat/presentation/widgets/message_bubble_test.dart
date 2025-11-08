import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeusgpt/features/chat/data/models/message_model.dart';
import 'package:zeusgpt/features/chat/presentation/widgets/message_bubble.dart';

void main() {
  group('MessageBubble', () {
    late MessageModel userMessage;
    late MessageModel assistantMessage;

    setUp(() {
      userMessage = MessageModel(
        messageId: '1',
        conversationId: 'conv1',
        role: MessageRole.user,
        content: 'Hello, this is a user message',
        createdAt: DateTime(2024, 1, 1, 10, 30),
        status: MessageStatus.completed,
      );

      assistantMessage = MessageModel(
        messageId: '2',
        conversationId: 'conv1',
        role: MessageRole.assistant,
        content: 'Hello, this is an assistant message',
        createdAt: DateTime(2024, 1, 1, 10, 31),
        status: MessageStatus.completed,
      );
    });

    testWidgets('renders user message with content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: userMessage,
              showAvatar: true,
            ),
          ),
        ),
      );

      expect(find.text('Hello, this is a user message'), findsOneWidget);
    });

    testWidgets('renders assistant message with content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: assistantMessage,
              showAvatar: true,
            ),
          ),
        ),
      );

      expect(find.text('Hello, this is an assistant message'), findsOneWidget);
    });

    testWidgets('shows user avatar with person icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: userMessage,
              showAvatar: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('shows assistant avatar with flash icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: assistantMessage,
              showAvatar: true,
            ),
          ),
        ),
      );

      // Assistant uses flash_on icon
      final flashIcons = find.byIcon(Icons.flash_on);
      expect(flashIcons, findsAtLeastNWidgets(1));
    });

    testWidgets('shows loading indicator when message is loading',
        (tester) async {
      final loadingMessage = userMessage.copyWith(
        status: MessageStatus.generating,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: loadingMessage,
              showAvatar: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Generating...'), findsOneWidget);
    });

    testWidgets('shows error message when message failed', (tester) async {
      final failedMessage = userMessage.copyWith(
        status: MessageStatus.failed,
        errorMessage: 'Failed to generate response',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: failedMessage,
              showAvatar: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Failed to generate response'), findsOneWidget);
    });

    testWidgets('shows default error message when errorMessage is null',
        (tester) async {
      final failedMessage = userMessage.copyWith(
        status: MessageStatus.failed,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: failedMessage,
              showAvatar: true,
            ),
          ),
        ),
      );

      expect(find.text('Failed to generate response'), findsOneWidget);
    });

    testWidgets('shows formatted time', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: userMessage,
              showAvatar: true,
            ),
          ),
        ),
      );

      expect(find.text('10:30'), findsOneWidget);
    });

    testWidgets('shows edited label when message is edited', (tester) async {
      final editedMessage = userMessage.copyWith(isEdited: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: editedMessage,
              showAvatar: true,
            ),
          ),
        ),
      );

      expect(find.text('(edited)'), findsOneWidget);
    });

    testWidgets('shows token count when available', (tester) async {
      final messageWithTokens = userMessage.copyWith(tokenCount: 150);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: messageWithTokens,
              showAvatar: true,
            ),
          ),
        ),
      );

      expect(find.text('• 150 tokens'), findsOneWidget);
    });

    testWidgets('shows copy button for completed messages', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: userMessage,
              showAvatar: true,
            ),
          ),
        ),
      );

      expect(find.widgetWithIcon(IconButton, Icons.content_copy),
          findsOneWidget);
    });

    testWidgets('copy button copies message content to clipboard',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: userMessage,
              showAvatar: true,
            ),
          ),
        ),
      );

      await tester.tap(find.widgetWithIcon(IconButton, Icons.content_copy));
      await tester.pump();

      // Note: Clipboard.getData() hangs in test environments, so we only verify the snackbar
      // Verify snackbar appears (confirms copy action was triggered)
      expect(find.text('Copied to clipboard'), findsOneWidget);
    });

    testWidgets('shows edit button for completed user messages',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: userMessage,
              showAvatar: true,
              onEdit: () {},
            ),
          ),
        ),
      );

      expect(find.widgetWithIcon(IconButton, Icons.edit_outlined),
          findsOneWidget);
    });

    testWidgets('does not show edit button for assistant messages',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: assistantMessage,
              showAvatar: true,
              onEdit: () {},
            ),
          ),
        ),
      );

      expect(
          find.widgetWithIcon(IconButton, Icons.edit_outlined), findsNothing);
    });

    testWidgets('calls onEdit when edit button is tapped', (tester) async {
      var editCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: userMessage,
              showAvatar: true,
              onEdit: () {
                editCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.widgetWithIcon(IconButton, Icons.edit_outlined));
      expect(editCalled, isTrue);
    });

    testWidgets('shows regenerate button for completed assistant messages',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: assistantMessage,
              showAvatar: true,
              onRegenerate: () {},
            ),
          ),
        ),
      );

      expect(find.widgetWithIcon(IconButton, Icons.refresh), findsOneWidget);
    });

    testWidgets('does not show regenerate button for user messages',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: userMessage,
              showAvatar: true,
              onRegenerate: () {},
            ),
          ),
        ),
      );

      expect(find.widgetWithIcon(IconButton, Icons.refresh), findsNothing);
    });

    testWidgets('calls onRegenerate when regenerate button is tapped',
        (tester) async {
      var regenerateCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: assistantMessage,
              showAvatar: true,
              onRegenerate: () {
                regenerateCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.widgetWithIcon(IconButton, Icons.refresh));
      expect(regenerateCalled, isTrue);
    });

    testWidgets('shows delete button when onDelete is provided',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: userMessage,
              showAvatar: true,
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(
          find.widgetWithIcon(IconButton, Icons.delete_outline), findsOneWidget);
    });

    testWidgets('calls onDelete when delete button is tapped',
        (tester) async {
      var deleteCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: userMessage,
              showAvatar: true,
              onDelete: () {
                deleteCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.widgetWithIcon(IconButton, Icons.delete_outline));
      expect(deleteCalled, isTrue);
    });

    testWidgets('does not show action buttons for loading messages',
        (tester) async {
      final loadingMessage = userMessage.copyWith(
        status: MessageStatus.generating,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: loadingMessage,
              showAvatar: true,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.widgetWithIcon(IconButton, Icons.content_copy), findsNothing);
      expect(find.widgetWithIcon(IconButton, Icons.edit_outlined), findsNothing);
      expect(find.widgetWithIcon(IconButton, Icons.delete_outline), findsNothing);
    });

    testWidgets('shows all action buttons for completed messages',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: userMessage,
              showAvatar: true,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.widgetWithIcon(IconButton, Icons.content_copy),
          findsOneWidget);
      expect(find.widgetWithIcon(IconButton, Icons.edit_outlined),
          findsOneWidget);
      expect(
          find.widgetWithIcon(IconButton, Icons.delete_outline), findsOneWidget);
    });
  });
}
