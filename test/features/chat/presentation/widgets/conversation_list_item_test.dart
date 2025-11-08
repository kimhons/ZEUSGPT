import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeusgpt/features/chat/data/models/conversation_model.dart';
import 'package:zeusgpt/features/chat/presentation/widgets/conversation_list_item.dart';

void main() {
  group('ConversationListItem', () {
    late ConversationModel conversation;

    setUp(() {
      conversation = ConversationModel(
        conversationId: 'conv1',
        userId: 'user1',
        title: 'Test Conversation',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1, 10, 30),
        modelId: 'gpt-4',
        provider: 'OpenAI',
        lastMessage: 'This is the last message content',
        lastMessageAt: DateTime.now().subtract(const Duration(minutes: 5)),
        messageCount: 10,
      );
    });

    testWidgets('renders conversation title', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ConversationListItem(
                conversation: conversation,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Conversation'), findsOneWidget);
    });

    testWidgets('renders conversation preview', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ConversationListItem(
                conversation: conversation,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('This is the last message content'), findsOneWidget);
    });

    testWidgets('renders model ID badge', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ConversationListItem(
                conversation: conversation,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('gpt-4'), findsOneWidget);
    });

    testWidgets('renders message count', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ConversationListItem(
                conversation: conversation,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('10'), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
    });

    testWidgets('renders time ago', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ConversationListItem(
                conversation: conversation,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.access_time), findsOneWidget);
      // Time ago should show something like "5m ago"
      expect(find.textContaining('ago'), findsOneWidget);
    });

    testWidgets('shows pin icon when conversation is pinned', (tester) async {
      final pinnedConversation = conversation.copyWith(isPinned: true);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ConversationListItem(
                conversation: pinnedConversation,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.push_pin), findsOneWidget);
    });

    testWidgets('does not show pin icon when conversation is not pinned',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ConversationListItem(
                conversation: conversation,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.push_pin), findsNothing);
    });

    testWidgets('shows OpenAI provider icon', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ConversationListItem(
                conversation: conversation,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.psychology), findsOneWidget);
    });

    testWidgets('shows Anthropic provider icon', (tester) async {
      final anthropicConversation = conversation.copyWith(provider: 'Anthropic');

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ConversationListItem(
                conversation: anthropicConversation,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.smart_toy), findsOneWidget);
    });

    testWidgets('shows Google provider icon', (tester) async {
      final googleConversation = conversation.copyWith(provider: 'Google');

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ConversationListItem(
                conversation: googleConversation,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.school), findsOneWidget);
    });

    testWidgets('shows default provider icon for unknown provider',
        (tester) async {
      final unknownConversation = conversation.copyWith(provider: 'Unknown');

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ConversationListItem(
                conversation: unknownConversation,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.psychology_outlined), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapCalled = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ConversationListItem(
                conversation: conversation,
                onTap: () {
                  tapCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Test Conversation'));
      expect(tapCalled, isTrue);
    });

    testWidgets('is wrapped in Dismissible widget', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ConversationListItem(
                conversation: conversation,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Dismissible), findsOneWidget);
    });

    testWidgets('truncates long conversation title', (tester) async {
      final longTitleConversation = conversation.copyWith(
        title: 'This is a very long conversation title that should be truncated',
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 320,
                child: ConversationListItem(
                  conversation: longTitleConversation,
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),
      );

      final titleText = tester.widget<Text>(
        find.text(
            'This is a very long conversation title that should be truncated'),
      );
      expect(titleText.maxLines, equals(1));
      expect(titleText.overflow, equals(TextOverflow.ellipsis));
    });

    testWidgets('truncates long conversation preview', (tester) async {
      final longPreviewConversation = conversation.copyWith(
        lastMessage:
            'This is a very long last message that should be truncated in the preview section of the conversation list item widget',
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 320,
                child: ConversationListItem(
                  conversation: longPreviewConversation,
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),
      );

      final previewFinder = find.textContaining(
          'This is a very long last message that should be truncated');
      expect(previewFinder, findsOneWidget);

      final previewText = tester.widget<Text>(previewFinder);
      expect(previewText.maxLines, equals(2));
      expect(previewText.overflow, equals(TextOverflow.ellipsis));
    });

    testWidgets('shows "No messages yet" when lastMessage is null',
        (tester) async {
      final emptyConversation = conversation.copyWith(
        lastMessage: null,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ConversationListItem(
                conversation: emptyConversation,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('No messages yet'), findsOneWidget);
    });

    testWidgets('handles zero message count', (tester) async {
      final zeroMessageConversation = conversation.copyWith(messageCount: 0);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ConversationListItem(
                conversation: zeroMessageConversation,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
    });
  });
}
