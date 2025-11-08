# ZeusGPT Test Suite

Comprehensive test coverage for the ZeusGPT application following industry best practices and Flutter testing standards.

## Test Structure

```
test/
├── core/                         # Core functionality tests
│   ├── utils/                    # Utility function tests
│   └── widgets/                  # Reusable widget tests (96 tests)
├── features/                     # Feature-specific tests
│   ├── auth/                     # Authentication feature tests
│   │   ├── data/                 # Auth repository tests (34 tests)
│   │   └── presentation/         # Auth provider tests (36 tests)
│   └── chat/                     # Chat feature tests
│       ├── data/                 # Conversation repository tests (30 tests)
│       ├── presentation/
│       │   ├── providers/        # Conversation provider tests (54 tests)
│       │   └── widgets/          # Chat widget tests (95 tests)
├── integration/                  # Integration tests (26 tests)
│   ├── helpers/                  # Test helpers and mocks
│   ├── auth_flow_test.dart
│   ├── conversation_flow_test.dart
│   └── error_recovery_test.dart
└── helpers/                      # Shared test utilities
    └── test_helpers.dart
```

## Test Coverage Summary

### Unit Tests

#### Core Tests (96 tests)
- **ZeusButton** (21 tests): Button variants, states, icons, loading
- **ZeusTextField** (31 tests): Input types, validation, obscuring, icons, character limits
- **ZeusCard** (26 tests): Standard and gradient cards, tap handling, styling
- **ErrorView** (18 tests): Error display, retry functionality, custom icons

#### Repository Tests (64 tests)
- **AuthRepository** (34 tests): All 12 authentication methods
  - signInWithEmail, signUpWithEmail, signOut
  - sendPasswordResetEmail, verifyEmail, updateProfile
  - deleteAccount, reauthenticate, changePassword
  - signInAnonymously, linkCredential, unlinkProvider

- **ConversationRepository** (30 tests): All 15 conversation methods
  - getConversations, getConversation, createConversation
  - updateConversation, deleteConversation, pinConversation
  - getMessages, getMessage, sendMessage, updateMessage
  - deleteMessage, regenerateMessage, exportConversation
  - searchConversations, getConversationStats

#### Provider Tests (90 tests)
- **AuthProvider** (36 tests): State management and transitions
  - Authentication states
  - Email verification flow
  - Onboarding completion
  - Profile updates
  - Error handling

- **ConversationProvider** (54 tests): Chat state management
  - Conversation list management
  - Message loading and sending
  - Real-time updates
  - Error recovery
  - State transitions

#### Widget Tests (95 tests)
- **MessageBubble** (30 tests): Message display, avatars, status indicators
- **ChatInput** (24 tests): Text input, send/voice/attachment buttons
- **ConversationListItem** (21 tests): Conversation preview, metadata, provider icons
- **EmptyConversationState** (20 tests): Welcome screen, feature cards, navigation

### Integration Tests (26 tests)

#### Auth Flow Tests (7 tests)
- Login with credentials
- Navigation to forgot password
- Navigation to sign up
- Form validation
- Password reset
- Email validation
- Password confirmation

#### Conversation Flow Tests (8 tests)
- Empty state display
- New chat navigation
- Model selection
- Chat screen display
- Message sending
- Conversation list
- End-to-end flows

#### Error Recovery Tests (11 tests)
- Invalid credentials handling
- Network errors
- Message failures
- Error screens
- Retry functionality
- State recovery
- Invalid routes

## Total Test Count

- **371 total tests** across all test files
- **96** core widget tests
- **64** repository unit tests
- **90** provider tests
- **95** chat widget tests
- **26** integration tests

## Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test Suites
```bash
# Core tests
flutter test test/core/

# Feature tests
flutter test test/features/

# Integration tests
flutter test test/integration/

# Specific feature
flutter test test/features/auth/
flutter test test/features/chat/
```

### Run with Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Run Specific Test File
```bash
flutter test test/features/auth/data/repositories/auth_repository_test.dart
```

### Run with Different Reporters
```bash
# Compact output
flutter test --reporter=compact

# Expanded output (default)
flutter test --reporter=expanded

# JSON output
flutter test --reporter=json
```

## Test Conventions

### Naming Conventions
- Test files end with `_test.dart`
- Test groups describe the class or feature being tested
- Test names are descriptive and start with a verb
- Use `testWidgets` for widget tests
- Use `test` for unit tests

### Test Structure
```dart
group('ClassName', () {
  // Setup
  setUp(() {
    // Initialize test dependencies
  });

  // Teardown
  tearDown(() {
    // Clean up resources
  });

  test('methodName - should behave in expected way', () {
    // Arrange
    final input = 'test input';

    // Act
    final result = methodName(input);

    // Assert
    expect(result, expectedValue);
  });
});
```

### Widget Test Pattern
```dart
testWidgets('widget - displays expected content', (tester) async {
  // Build widget
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: MyWidget(),
      ),
    ),
  );

  // Verify
  expect(find.text('Expected Text'), findsOneWidget);
});
```

## Test Helpers

### Integration Test Helpers
Located in `test/integration/helpers/integration_test_helpers.dart`:
- `pumpApp()` - Initialize app for testing
- `enterText()` - Enter text into fields
- `tapButton()` - Tap buttons by text
- `tapIconButton()` - Tap icon buttons
- `waitForWidget()` - Wait for widget to appear
- `scrollUntilVisible()` - Scroll to make widget visible
- `verifyRoute()` - Verify navigation
- `verifyText()` - Verify text is present
- `verifyWidget()` - Verify widget exists

### Mock Providers
Located in `test/integration/helpers/mock_providers.dart`:
- `MockAuthRepository` - Mock authentication
- `MockConversationRepository` - Mock chat services
- `createMockProviderScope()` - Create test provider scope

## Coverage Goals

- **Unit Tests**: 80%+ coverage for business logic
- **Widget Tests**: All user-facing widgets tested
- **Integration Tests**: All critical user flows covered
- **Repository Tests**: 100% coverage for data layer
- **Provider Tests**: All state transitions tested

## Current Status

✅ Unit tests complete (250 tests)
✅ Widget tests complete (95 tests)
✅ Integration tests structured (26 tests)
⚠️  Integration tests blocked by app compilation errors
⏳ CI/CD pipeline pending

## Known Issues

Integration tests cannot run due to pre-existing app code issues:
1. Platform-specific imports (`dart:js`, `dart:html`) not available on all platforms
2. Syntax errors in `web_seo_service.dart` (duplicated parameter names)
3. Missing `desktop_drop` package references

These app code issues need resolution before integration tests can execute.

## Future Enhancements

1. **Golden Tests**: Add visual regression testing
2. **Performance Tests**: Measure widget build times
3. **Accessibility Tests**: Verify screen reader support
4. **E2E Tests**: Full end-to-end scenarios with real backend
5. **Load Tests**: Test with large datasets
6. **Security Tests**: Validate input sanitization

## Maintenance

- Run tests before each commit
- Update tests when changing implementation
- Add tests for new features
- Review test coverage regularly
- Keep mock data synchronized with real models

## Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [flutter_test Package](https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html)
- [Effective Dart: Testing](https://dart.dev/guides/language/effective-dart/testing)
- [Widget Testing](https://docs.flutter.dev/cookbook/testing/widget/introduction)
- [Integration Testing](https://docs.flutter.dev/testing/integration-tests)
