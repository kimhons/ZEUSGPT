# Integration Tests

This directory contains integration tests for ZeusGPT that test critical user flows and error recovery scenarios.

## Test Structure

### Test Files

1. **auth_flow_test.dart** (7 tests)
   - Login flow with successful authentication
   - Forgot password navigation
   - Sign up navigation
   - Form validation for sign up
   - Password reset functionality
   - Email validation
   - Password confirmation validation

2. **conversation_flow_test.dart** (8 tests)
   - Home screen empty state
   - Navigation to new chat
   - Model selection UI
   - Model selection interaction
   - Chat screen display
   - Message sending
   - Conversation list display
   - End-to-end conversation creation and messaging

3. **error_recovery_test.dart** (11 tests)
   - Invalid credentials handling
   - Network error handling
   - Message send failure recovery
   - Unexpected error screen
   - Error view widget with retry
   - Error view widget without retry
   - Custom error icons
   - Error state recovery
   - Failed message retry
   - Empty conversation list handling
   - Invalid route handling

### Helper Files

1. **integration_test_helpers.dart**
   - Utility functions for integration tests
   - Common actions: pumping app, entering text, tapping buttons
   - Verification helpers for routes, widgets, and messages
   - Navigation helpers
   - Loading indicator helpers

2. **mock_providers.dart**
   - Mock authentication repository
   - Mock conversation repository
   - Provider scope creation for testing

## Total Test Coverage

- **26 integration tests** across 3 test files
- Tests cover authentication, conversation management, and error recovery
- Comprehensive UI flow testing from login to message sending

## Running Tests

```bash
# Run all integration tests
flutter test test/integration/

# Run specific test file
flutter test test/integration/auth_flow_test.dart

# Run with coverage
flutter test --coverage test/integration/
```

## Note on Current Status

The integration tests are structurally complete but cannot currently run due to pre-existing compilation errors in the application code:

1. **Platform-specific imports**: The app imports `dart:js` and `dart:html` which are not available on non-web platforms
2. **Syntax errors**: `web_seo_service.dart` has duplicated parameter names
3. **Missing packages**: `desktop_drop` package reference issues

These application code issues need to be resolved before integration tests can run successfully.

## Test Implementation Notes

### Mocking Requirements

Several tests require mock providers to function properly:
- Auth flow tests need mocked authentication
- Conversation tests need mocked chat services
- Error recovery tests need simulated failures

The `mock_providers.dart` file provides scaffolding for these mocks, but full implementation requires:
1. Proper provider overrides in ProviderScope
2. Mock responses for repository methods
3. State management for test scenarios

### Future Enhancements

1. **Complete mock implementations**: Fully implement mock providers
2. **Add more scenarios**: Test edge cases and complex user flows
3. **Performance testing**: Add tests for app performance metrics
4. **Accessibility testing**: Verify screen reader support and accessibility features
5. **Multi-platform testing**: Test on web, mobile, and desktop platforms

## Test Maintenance

- Update tests when UI changes
- Add new tests for new features
- Keep mock data synchronized with actual data models
- Regularly review test coverage metrics

## Related Documentation

- See `/test/README.md` for overall testing strategy
- See individual test files for specific test scenarios
- See helper files for reusable test utilities
