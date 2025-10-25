# LGBTinder Flutter Tests

This directory contains unit tests, widget tests, and integration tests for the LGBTinder Flutter application.

## Test Structure

```
test/
├── services/               # Unit tests for services
│   ├── validation_service_test.dart
│   ├── sound_effects_service_test.dart
│   └── match_sharing_service_test.dart
├── providers/             # Unit tests for state providers
├── models/                # Unit tests for data models
├── utils/                 # Unit tests for utility functions
└── widgets/               # Widget tests for UI components
```

## Running Tests

### Run all tests
```bash
flutter test
```

### Run specific test file
```bash
flutter test test/services/validation_service_test.dart
```

### Run tests with coverage
```bash
flutter test --coverage
```

### View coverage report
```bash
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Test Categories

### Unit Tests
- **Services**: Business logic and API interactions
- **Providers**: State management logic
- **Models**: Data models and serialization
- **Utils**: Helper functions and utilities

### Widget Tests
- UI component rendering
- User interaction handling
- Visual appearance validation
- Accessibility testing

### Integration Tests
- Complete user flows
- Navigation testing
- Multi-screen interactions
- API integration validation

## Testing Guidelines

### Unit Tests
1. Test one thing at a time
2. Use descriptive test names
3. Follow AAA pattern (Arrange, Act, Assert)
4. Mock external dependencies
5. Test edge cases and error handling

### Widget Tests
1. Use `testWidgets` for widget testing
2. Test user interactions with `tester.tap()`, etc.
3. Verify UI updates with `expect(find...)`
4. Test accessibility features
5. Test responsive layouts

### Integration Tests
1. Test complete user journeys
2. Use real-world scenarios
3. Test with actual backend (staging environment)
4. Verify data persistence
5. Test offline scenarios

## Mocking

Use `mockito` for creating mocks:

```dart
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([MyService])
void main() {
  late MockMyService mockService;
  
  setUp(() {
    mockService = MockMyService();
  });
  
  test('should call service method', () {
    when(mockService.getData()).thenAnswer((_) async => 'data');
    // ... rest of test
  });
}
```

## Coverage Goals

- **Overall**: 80%+ code coverage
- **Services**: 90%+ coverage
- **Providers**: 85%+ coverage
- **Utils**: 95%+ coverage
- **Widgets**: 75%+ coverage

## Continuous Integration

Tests run automatically on:
- Every commit to main branch
- Pull requests
- Release branches

## Best Practices

1. **Write tests first** (TDD approach when possible)
2. **Keep tests fast** (mock slow operations)
3. **Maintain tests** (update when code changes)
4. **Use test groups** for organization
5. **Document complex tests** with comments
6. **Test error scenarios** not just happy paths
7. **Avoid test interdependence**
8. **Use setUp/tearDown** for common setup
9. **Test public APIs** not implementation details
10. **Keep tests simple** and readable

## Common Testing Patterns

### Testing Async Code
```dart
test('should handle async operation', () async {
  final result = await myAsyncFunction();
  expect(result, equals(expected));
});
```

### Testing Exceptions
```dart
test('should throw exception', () {
  expect(() => functionThatThrows(), throwsException);
});
```

### Testing Streams
```dart
test('should emit values', () {
  expectLater(
    myStream,
    emitsInOrder([value1, value2, emitsDone]),
  );
});
```

## Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Mockito Package](https://pub.dev/packages/mockito)
- [Flutter Test Package](https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html)

