import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:lgbtinder/providers/app_state_provider.dart';
import 'package:lgbtinder/providers/profile_state_provider.dart';
import 'package:lgbtinder/providers/matching_state_provider.dart';
import 'package:lgbtinder/providers/chat_state_provider.dart';
import 'package:lgbtinder/models/api_models/user_models.dart';
import 'package:lgbtinder/models/api_models/chat_models.dart';
import 'package:lgbtinder/models/api_models/reference_data_models.dart';
import 'package:lgbtinder/models/user_state_models.dart';

/// UI Test Utilities
/// 
/// This file contains utility functions and mock data for UI tests including:
/// - Mock user data
/// - Mock provider setup
/// - Common test helpers
/// - Widget test utilities

// Mock User Data
class MockUserData {
  static User get mockUser => User(
    id: 1,
    firstName: 'John',
    lastName: 'Doe',
    email: 'john.doe@example.com',
    profilePictures: ['https://example.com/photo1.jpg'],
    bio: 'Test bio',
    age: 25,
    location: 'New York',
    job: 'Software Engineer',
    education: 'Bachelor\'s Degree',
    interests: [],
    musicGenres: [],
    languages: [],
    relationshipGoals: [],
    preferredGenders: [],
    minAge: 18,
    maxAge: 30,
    height: 180,
    weight: 70,
    birthDate: DateTime(1999, 1, 1),
    isVerified: false,
    isOnline: true,
    lastSeen: DateTime.now(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  static User get mockUser2 => User(
    id: 2,
    firstName: 'Jane',
    lastName: 'Smith',
    email: 'jane.smith@example.com',
    profilePictures: ['https://example.com/photo2.jpg'],
    bio: 'Test bio 2',
    age: 23,
    location: 'Los Angeles',
    job: 'Designer',
    education: 'Master\'s Degree',
    interests: [],
    musicGenres: [],
    languages: [],
    relationshipGoals: [],
    preferredGenders: [],
    minAge: 20,
    maxAge: 35,
    height: 165,
    weight: 55,
    birthDate: DateTime(2001, 1, 1),
    isVerified: true,
    isOnline: false,
    lastSeen: DateTime.now(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  static List<User> get mockUsers => [mockUser, mockUser2];
}

// Mock Message Data
class MockMessageData {
  static MessageData get mockMessage1 => MessageData(
    messageId: 1,
    senderId: 1,
    receiverId: 2,
    message: 'Hello!',
    messageType: MessageType.text,
    sentAt: DateTime.now().toIso8601String(),
    isRead: true,
  );

  static MessageData get mockMessage2 => MessageData(
    messageId: 2,
    senderId: 2,
    receiverId: 1,
    message: 'Hi there!',
    messageType: MessageType.text,
    sentAt: DateTime.now().toIso8601String(),
    isRead: false,
  );

  static List<MessageData> get mockMessages => [mockMessage1, mockMessage2];
}

// Mock Reference Data
class MockReferenceData {
  static List<Country> get mockCountries => [
    Country(id: 1, name: 'United States', code: 'US'),
    Country(id: 2, name: 'Canada', code: 'CA'),
    Country(id: 3, name: 'United Kingdom', code: 'GB'),
  ];

  static List<City> get mockCities => [
    City(id: 1, name: 'New York', countryId: 1),
    City(id: 2, name: 'Los Angeles', countryId: 1),
    City(id: 3, name: 'Toronto', countryId: 2),
  ];

  static List<ReferenceDataItem> get mockGenders => [
    ReferenceDataItem(id: 1, name: 'Male'),
    ReferenceDataItem(id: 2, name: 'Female'),
    ReferenceDataItem(id: 3, name: 'Non-binary'),
  ];

  static List<ReferenceDataItem> get mockInterests => [
    ReferenceDataItem(id: 1, name: 'Music'),
    ReferenceDataItem(id: 2, name: 'Sports'),
    ReferenceDataItem(id: 3, name: 'Travel'),
    ReferenceDataItem(id: 4, name: 'Photography'),
  ];

  static List<ReferenceDataItem> get mockPreferredGenders => [
    ReferenceDataItem(id: 1, name: 'Female'),
    ReferenceDataItem(id: 2, name: 'Non-binary'),
  ];
}

// Mock Provider Setup
class MockProviderSetup {
  static Widget createAppWithProviders({
    required Widget child,
    AppStateProvider? appStateProvider,
    ProfileStateProvider? profileStateProvider,
    MatchingStateProvider? matchingStateProvider,
    ChatStateProvider? chatStateProvider,
  }) {
    final providers = <ChangeNotifierProvider>[];

    if (appStateProvider != null) {
      providers.add(ChangeNotifierProvider<AppStateProvider>.value(value: appStateProvider));
    }

    if (profileStateProvider != null) {
      providers.add(ChangeNotifierProvider<ProfileStateProvider>.value(value: profileStateProvider));
    }

    if (matchingStateProvider != null) {
      providers.add(ChangeNotifierProvider<MatchingStateProvider>.value(value: matchingStateProvider));
    }

    if (chatStateProvider != null) {
      providers.add(ChangeNotifierProvider<ChatStateProvider>.value(value: chatStateProvider));
    }

    return MaterialApp(
      home: providers.isEmpty
          ? child
          : MultiProvider(
              providers: providers,
              child: child,
            ),
    );
  }

  static void setupMockAppStateProvider(AppStateProvider mockProvider) {
    when(mockProvider.isLoading).thenReturn(false);
    when(mockProvider.error).thenReturn(null);
    when(mockProvider.user).thenReturn(MockUserData.mockUser);
    when(mockProvider.countries).thenReturn(MockReferenceData.mockCountries);
    when(mockProvider.genders).thenReturn(MockReferenceData.mockGenders);
    when(mockProvider.interests).thenReturn(MockReferenceData.mockInterests);
    when(mockProvider.preferredGenders).thenReturn(MockReferenceData.mockPreferredGenders);
    when(mockProvider.citiesByCountry).thenReturn({
      1: MockReferenceData.mockCities.where((city) => city.countryId == 1).toList(),
      2: MockReferenceData.mockCities.where((city) => city.countryId == 2).toList(),
    });
  }

  static void setupMockProfileStateProvider(ProfileStateProvider mockProvider) {
    when(mockProvider.isLoading).thenReturn(false);
    when(mockProvider.error).thenReturn(null);
    when(mockProvider.currentUser).thenReturn(MockUserData.mockUser);
  }

  static void setupMockMatchingStateProvider(MatchingStateProvider mockProvider) {
    when(mockProvider.isLoading).thenReturn(false);
    when(mockProvider.error).thenReturn(null);
    when(mockProvider.potentialMatches).thenReturn(MockUserData.mockUsers);
    when(mockProvider.matches).thenReturn(MockUserData.mockUsers);
  }

  static void setupMockChatStateProvider(ChatStateProvider mockProvider) {
    when(mockProvider.getMessagesForUser(any)).thenReturn(MockMessageData.mockMessages);
    when(mockProvider.isLoadingMessages(any)).thenReturn(false);
    when(mockProvider.hasMoreMessagesForUser(any)).thenReturn(false);
  }
}

// Common Test Helpers
class TestHelpers {
  static Future<void> fillTextField(WidgetTester tester, Key key, String text) async {
    await tester.enterText(find.byKey(key), text);
    await tester.pumpAndSettle();
  }

  static Future<void> tapButton(WidgetTester tester, String text) async {
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  static Future<void> tapIcon(WidgetTester tester, IconData icon) async {
    await tester.tap(find.byIcon(icon));
    await tester.pumpAndSettle();
  }

  static Future<void> selectDropdownItem(WidgetTester tester, Key dropdownKey, String itemText) async {
    await tester.tap(find.byKey(dropdownKey));
    await tester.pumpAndSettle();
    await tester.tap(find.text(itemText));
    await tester.pumpAndSettle();
  }

  static Future<void> selectDate(WidgetTester tester, Key dateFieldKey, DateTime date) async {
    await tester.tap(find.byKey(dateFieldKey));
    await tester.pumpAndSettle();
    
    // Navigate to the correct year
    while (tester.widget<DatePicker>(find.byType(DatePicker)).initialDate.year != date.year) {
      if (tester.widget<DatePicker>(find.byType(DatePicker)).initialDate.year < date.year) {
        await tester.tap(find.byIcon(Icons.keyboard_arrow_up));
      } else {
        await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
      }
      await tester.pumpAndSettle();
    }
    
    // Navigate to the correct month
    while (tester.widget<DatePicker>(find.byType(DatePicker)).initialDate.month != date.month) {
      if (tester.widget<DatePicker>(find.byType(DatePicker)).initialDate.month < date.month) {
        await tester.tap(find.byIcon(Icons.keyboard_arrow_up));
      } else {
        await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
      }
      await tester.pumpAndSettle();
    }
    
    // Select the date
    await tester.tap(find.text(date.day.toString()));
    await tester.pumpAndSettle();
    
    // Confirm selection
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
  }

  static Future<void> scrollToWidget(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(finder, 500.0);
    await tester.pumpAndSettle();
  }

  static Future<void> waitForWidget(WidgetTester tester, Finder finder, {Duration timeout = const Duration(seconds: 5)}) async {
    final endTime = DateTime.now().add(timeout);
    
    while (DateTime.now().isBefore(endTime)) {
      if (finder.evaluate().isNotEmpty) {
        return;
      }
      await tester.pump(const Duration(milliseconds: 100));
    }
    
    throw TimeoutException('Widget not found within timeout', timeout);
  }

  static void expectValidationError(WidgetTester tester, String errorText) {
    expect(find.text(errorText), findsOneWidget);
  }

  static void expectNoValidationError(WidgetTester tester, String errorText) {
    expect(find.text(errorText), findsNothing);
  }

  static void expectLoadingState(WidgetTester tester, String loadingText) {
    expect(find.text(loadingText), findsOneWidget);
  }

  static void expectErrorState(WidgetTester tester, String errorText) {
    expect(find.text(errorText), findsOneWidget);
  }

  static void expectSuccessMessage(WidgetTester tester, String successText) {
    expect(find.text(successText), findsOneWidget);
  }
}

// Form Filling Helpers
class FormHelpers {
  static Future<void> fillLoginForm(WidgetTester tester, {String email = 'test@example.com', String password = 'password123'}) async {
    await TestHelpers.fillTextField(tester, const Key('email_field'), email);
    await TestHelpers.fillTextField(tester, const Key('password_field'), password);
  }

  static Future<void> fillRegisterForm(WidgetTester tester, {
    String firstName = 'John',
    String lastName = 'Doe',
    String email = 'john.doe@example.com',
    String password = 'password123',
    String referralCode = 'ABC123',
  }) async {
    await TestHelpers.fillTextField(tester, const Key('first_name_field'), firstName);
    await TestHelpers.fillTextField(tester, const Key('last_name_field'), lastName);
    await TestHelpers.fillTextField(tester, const Key('email_field'), email);
    await TestHelpers.fillTextField(tester, const Key('password_field'), password);
    await TestHelpers.fillTextField(tester, const Key('referral_code_field'), referralCode);
  }

  static Future<void> fillEmailVerificationForm(WidgetTester tester, {String code = '123456'}) async {
    await TestHelpers.fillTextField(tester, const Key('verification_code_field'), code);
  }

  static Future<void> fillProfileCompletionStep1(WidgetTester tester) async {
    await TestHelpers.fillTextField(tester, const Key('first_name_field'), 'John');
    await TestHelpers.fillTextField(tester, const Key('last_name_field'), 'Doe');
    
    await TestHelpers.selectDate(tester, const Key('birth_date_field'), DateTime(1999, 1, 1));
    await TestHelpers.selectDropdownItem(tester, const Key('gender_dropdown'), 'Male');
    await TestHelpers.selectDropdownItem(tester, const Key('country_dropdown'), 'United States');
    await TestHelpers.selectDropdownItem(tester, const Key('city_dropdown'), 'New York');
  }

  static Future<void> fillProfileCompletionStep2(WidgetTester tester) async {
    await TestHelpers.fillTextField(tester, const Key('height_field'), '180');
    await TestHelpers.fillTextField(tester, const Key('weight_field'), '70');
    await TestHelpers.fillTextField(tester, const Key('bio_field'), 'Test bio');
  }

  static Future<void> fillProfileCompletionStep3(WidgetTester tester) async {
    await TestHelpers.selectDropdownItem(tester, const Key('preferred_gender_dropdown'), 'Female');
    await TestHelpers.selectDropdownItem(tester, const Key('interests_dropdown'), 'Music');
  }
}

// Navigation Helpers
class NavigationHelpers {
  static Future<void> navigateToRegister(WidgetTester tester) async {
    await TestHelpers.tapButton(tester, 'Sign Up');
  }

  static Future<void> navigateToLogin(WidgetTester tester) async {
    await TestHelpers.tapButton(tester, 'Sign In');
  }

  static Future<void> navigateBack(WidgetTester tester) async {
    await TestHelpers.tapIcon(tester, Icons.arrow_back);
  }

  static Future<void> navigateToProfileEdit(WidgetTester tester) async {
    await TestHelpers.tapIcon(tester, Icons.edit);
  }

  static Future<void> navigateToChat(WidgetTester tester, String userName) async {
    await TestHelpers.tapButton(tester, userName);
  }
}

// Assertion Helpers
class AssertionHelpers {
  static void assertScreenTitle(WidgetTester tester, String title) {
    expect(find.text(title), findsOneWidget);
  }

  static void assertFormField(WidgetTester tester, Key fieldKey) {
    expect(find.byKey(fieldKey), findsOneWidget);
  }

  static void assertButton(WidgetTester tester, String buttonText) {
    expect(find.text(buttonText), findsOneWidget);
  }

  static void assertIcon(WidgetTester tester, IconData icon) {
    expect(find.byIcon(icon), findsOneWidget);
  }

  static void assertLoadingState(WidgetTester tester, String loadingText) {
    expect(find.text(loadingText), findsOneWidget);
  }

  static void assertErrorState(WidgetTester tester, String errorText) {
    expect(find.text(errorText), findsOneWidget);
  }

  static void assertSuccessMessage(WidgetTester tester, String successText) {
    expect(find.text(successText), findsOneWidget);
  }

  static void assertValidationError(WidgetTester tester, String errorText) {
    expect(find.text(errorText), findsOneWidget);
  }

  static void assertNoValidationError(WidgetTester tester, String errorText) {
    expect(find.text(errorText), findsNothing);
  }
}
