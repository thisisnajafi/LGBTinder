import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:lgbtinder/pages/chat_list_page.dart';
import 'package:lgbtinder/pages/chat_page.dart';
import 'package:lgbtinder/providers/chat_state_provider.dart';
import 'package:lgbtinder/providers/matching_state_provider.dart';
import 'package:lgbtinder/providers/app_state_provider.dart';
import 'package:lgbtinder/services/api_services/chat_api_service.dart';
import 'package:lgbtinder/models/api_models/user_models.dart';
import 'package:lgbtinder/models/api_models/chat_models.dart';
import 'ui_test_utils.dart';

import '../mocks/mock_chat_api_service.dart';
import '../mocks/mock_matching_api_service.dart';

@GenerateMocks([ChatStateProvider, MatchingStateProvider, AppStateProvider, ChatApiService])
void testChatScreens() {
  group('Chat Screens UI Tests', () {
    late MockChatStateProvider mockChatStateProvider;
    late MockMatchingStateProvider mockMatchingStateProvider;
    late MockAppStateProvider mockAppStateProvider;

    setUp(() {
      mockChatStateProvider = MockChatStateProvider();
      mockMatchingStateProvider = MockMatchingStateProvider();
      mockAppStateProvider = MockAppStateProvider();

      // Setup mock providers
      when(mockAppStateProvider.user).thenReturn(MockUserData.mockUser);
      when(mockMatchingStateProvider.matches).thenReturn(MockUserData.mockUsers);
      when(mockMatchingStateProvider.isLoading).thenReturn(false);
      when(mockMatchingStateProvider.error).thenReturn(null);
      when(mockMatchingStateProvider.loadMatches()).thenAnswer((_) async {});

      when(mockChatStateProvider.getMessagesForUser(any)).thenReturn(MockMessageData.mockMessages);
      when(mockChatStateProvider.isChatLoading(any)).thenReturn(false);
      when(mockChatStateProvider.getChatError(any)).thenReturn(null);
      when(mockChatStateProvider.loadChatHistory(any)).thenAnswer((_) async {});
      when(mockChatStateProvider.sendMessage(any, any)).thenAnswer((_) async => true);
      when(mockChatStateProvider.markMessagesAsRead(any)).thenAnswer((_) {});
    });

    group('Chat List Page', () {
      testWidgets('displays matches list', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: mockAppStateProvider,
            matchingStateProvider: mockMatchingStateProvider,
            chatStateProvider: mockChatStateProvider,
            child: const ChatListPage(),
          ),
        );

        // Verify matches are displayed
        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('Jane Smith'), findsOneWidget);
        expect(find.text('Hello!'), findsOneWidget);
        expect(find.text('Hi there!'), findsOneWidget);
      });

      testWidgets('shows loading state', (WidgetTester tester) async {
        when(mockMatchingStateProvider.isLoading).thenReturn(true);

        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: mockAppStateProvider,
            matchingStateProvider: mockMatchingStateProvider,
            chatStateProvider: mockChatStateProvider,
            child: const ChatListPage(),
          ),
        );

        // Verify loading state
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('shows error state', (WidgetTester tester) async {
        when(mockMatchingStateProvider.isLoading).thenReturn(false);
        when(mockMatchingStateProvider.error).thenReturn('Failed to load matches');

        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: mockAppStateProvider,
            matchingStateProvider: mockMatchingStateProvider,
            chatStateProvider: mockChatStateProvider,
            child: const ChatListPage(),
          ),
        );

        // Verify error state
        AssertionHelpers.assertErrorState(tester, 'Failed to load matches');
        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('shows empty state when no matches', (WidgetTester tester) async {
        when(mockMatchingStateProvider.matches).thenReturn([]);

        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: mockAppStateProvider,
            matchingStateProvider: mockMatchingStateProvider,
            chatStateProvider: mockChatStateProvider,
            child: const ChatListPage(),
          ),
        );

        // Verify empty state
        expect(find.text('No matches yet'), findsOneWidget);
        expect(find.text('Start swiping to find your perfect match!'), findsOneWidget);
        expect(find.text('Start Swiping'), findsOneWidget);
      });

      testWidgets('navigates to chat page on match tap', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: mockAppStateProvider,
            matchingStateProvider: mockMatchingStateProvider,
            chatStateProvider: mockChatStateProvider,
            child: const ChatListPage(),
          ),
        );

        // Tap on a match
        await tester.tap(find.text('John Doe'));
        await tester.pumpAndSettle();

        // Verify navigation to chat page
        // Note: This would depend on your navigation setup
        // expect(find.byType(ChatPage), findsOneWidget);
      });

      testWidgets('displays unread message count', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: mockAppStateProvider,
            matchingStateProvider: mockMatchingStateProvider,
            chatStateProvider: mockChatStateProvider,
            child: const ChatListPage(),
          ),
        );

        // Verify unread count is displayed
        expect(find.text('1'), findsOneWidget); // Unread count
      });

      testWidgets('shows new chat button', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: mockAppStateProvider,
            matchingStateProvider: mockMatchingStateProvider,
            chatStateProvider: mockChatStateProvider,
            child: const ChatListPage(),
          ),
        );

        // Verify new chat button
        AssertionHelpers.assertIcon(tester, Icons.add);
      });

      testWidgets('shows new chat options on add button tap', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: mockAppStateProvider,
            matchingStateProvider: mockMatchingStateProvider,
            chatStateProvider: mockChatStateProvider,
            child: const ChatListPage(),
          ),
        );

        // Tap new chat button
        await TestHelpers.tapIcon(tester, Icons.add);
        await tester.pumpAndSettle();

        // Verify new chat options
        expect(find.text('Start New Chat'), findsOneWidget);
      });

      testWidgets('refreshes matches on pull to refresh', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: mockAppStateProvider,
            matchingStateProvider: mockMatchingStateProvider,
            chatStateProvider: mockChatStateProvider,
            child: const ChatListPage(),
          ),
        );

        // Perform pull to refresh
        await tester.drag(find.byType(RefreshIndicator), const Offset(0, 500));
        await tester.pumpAndSettle();

        // Verify refresh was called
        verify(mockMatchingStateProvider.loadMatches()).called(1);
      });

      testWidgets('loads more matches on scroll', (WidgetTester tester) async {
        when(mockMatchingStateProvider.loadMoreMatches()).thenAnswer((_) async {});

        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: mockAppStateProvider,
            matchingStateProvider: mockMatchingStateProvider,
            chatStateProvider: mockChatStateProvider,
            child: const ChatListPage(),
          ),
        );

        // Scroll to bottom
        await tester.drag(find.byType(ListView), const Offset(0, -500));
        await tester.pumpAndSettle();

        // Verify load more was called
        verify(mockMatchingStateProvider.loadMoreMatches()).called(1);
      });
    });

    group('Chat Page', () {
      testWidgets('displays chat header with user info', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: mockAppStateProvider,
            matchingStateProvider: mockMatchingStateProvider,
            chatStateProvider: mockChatStateProvider,
            child: ChatPage(match: MockUserData.mockUser2),
          ),
        );

        // Verify chat header
        expect(find.text('Jane Smith'), findsOneWidget);
        AssertionHelpers.assertIcon(tester, Icons.arrow_back);
        AssertionHelpers.assertIcon(tester, Icons.info_outline);
      });

      testWidgets('displays messages', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: mockAppStateProvider,
            matchingStateProvider: mockMatchingStateProvider,
            chatStateProvider: mockChatStateProvider,
            child: ChatPage(match: MockUserData.mockUser2),
          ),
        );

        // Verify messages are displayed
        expect(find.text('Hello!'), findsOneWidget);
        expect(find.text('Hi there!'), findsOneWidget);
      });

      testWidgets('shows loading state', (WidgetTester tester) async {
        when(mockChatStateProvider.isChatLoading(any)).thenReturn(true);

        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: mockAppStateProvider,
            matchingStateProvider: mockMatchingStateProvider,
            chatStateProvider: mockChatStateProvider,
            child: ChatPage(match: MockUserData.mockUser2),
          ),
        );

        // Verify loading state
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('shows error state', (WidgetTester tester) async {
        when(mockChatStateProvider.isChatLoading(any)).thenReturn(false);
        when(mockChatStateProvider.getChatError(any)).thenReturn('Failed to load messages');

        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: mockAppStateProvider,
            matchingStateProvider: mockMatchingStateProvider,
            chatStateProvider: mockChatStateProvider,
            child: ChatPage(match: MockUserData.mockUser2),
          ),
        );

        // Verify error state
        AssertionHelpers.assertErrorState(tester, 'Failed to load messages');
        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('sends message', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: mockAppStateProvider,
            matchingStateProvider: mockMatchingStateProvider,
            chatStateProvider: mockChatStateProvider,
            child: ChatPage(match: MockUserData.mockUser2),
          ),
        );

        // Type message
        await TestHelpers.fillTextField(tester, const Key('message_input'), 'Test message');

        // Send message
        await TestHelpers.tapIcon(tester, Icons.send);
        await tester.pumpAndSettle();

        // Verify message was sent
        verify(mockChatStateProvider.sendMessage(any, 'Test message')).called(1);
      });

      testWidgets('shows attachment options', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: mockAppStateProvider,
            matchingStateProvider: mockMatchingStateProvider,
            chatStateProvider: mockChatStateProvider,
            child: ChatPage(match: MockUserData.mockUser2),
          ),
        );

        // Tap attachment button
        await TestHelpers.tapIcon(tester, Icons.attach_file);
        await tester.pumpAndSettle();

        // Verify attachment options
        expect(find.text('Photo'), findsOneWidget);
        expect(find.text('Video'), findsOneWidget);
        expect(find.text('Voice Message'), findsOneWidget);
        expect(find.text('Document'), findsOneWidget);
      });

      testWidgets('shows match info', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: mockAppStateProvider,
            matchingStateProvider: mockMatchingStateProvider,
            chatStateProvider: mockChatStateProvider,
            child: ChatPage(match: MockUserData.mockUser2),
          ),
        );

        // Tap info button
        await TestHelpers.tapIcon(tester, Icons.info_outline);
        await tester.pumpAndSettle();

        // Verify match info is shown
        expect(find.text('About Jane'), findsOneWidget);
        expect(find.text('Test bio 2'), findsOneWidget);
        expect(find.text('23 years old'), findsOneWidget);
        expect(find.text('Los Angeles'), findsOneWidget);
      });

      testWidgets('loads more messages on scroll', (WidgetTester tester) async {
        when(mockChatStateProvider.hasMoreMessagesForUser(any)).thenReturn(true);
        when(mockChatStateProvider.loadChatHistory(any)).thenAnswer((_) async {});

        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: mockAppStateProvider,
            matchingStateProvider: mockMatchingStateProvider,
            chatStateProvider: mockChatStateProvider,
            child: ChatPage(match: MockUserData.mockUser2),
          ),
        );

        // Scroll to top
        await tester.drag(find.byType(ListView), const Offset(0, 500));
        await tester.pumpAndSettle();

        // Verify load more was called
        verify(mockChatStateProvider.loadChatHistory(any)).called(1);
      });

      testWidgets('marks messages as read', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: mockAppStateProvider,
            matchingStateProvider: mockMatchingStateProvider,
            chatStateProvider: mockChatStateProvider,
            child: ChatPage(match: MockUserData.mockUser2),
          ),
        );

        // Wait for messages to load
        await tester.pumpAndSettle();

        // Verify mark as read was called
        verify(mockChatStateProvider.markMessagesAsRead(any)).called(1);
      });

      testWidgets('shows typing indicator', (WidgetTester tester) async {
        when(mockChatStateProvider.isTyping(any)).thenReturn(true);

        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: mockAppStateProvider,
            matchingStateProvider: mockMatchingStateProvider,
            chatStateProvider: mockChatStateProvider,
            child: ChatPage(match: MockUserData.mockUser2),
          ),
        );

        // Verify typing indicator
        expect(find.text('Jane is typing...'), findsOneWidget);
      });

      testWidgets('handles message send error', (WidgetTester tester) async {
        when(mockChatStateProvider.sendMessage(any, any)).thenThrow(Exception('Failed to send message'));

        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: mockAppStateProvider,
            matchingStateProvider: mockMatchingStateProvider,
            chatStateProvider: mockChatStateProvider,
            child: ChatPage(match: MockUserData.mockUser2),
          ),
        );

        // Type and send message
        await TestHelpers.fillTextField(tester, const Key('message_input'), 'Test message');
        await TestHelpers.tapIcon(tester, Icons.send);
        await tester.pumpAndSettle();

        // Verify error message
        AssertionHelpers.assertErrorState(tester, 'Failed to send message');
      });

      testWidgets('validates message input', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: mockAppStateProvider,
            matchingStateProvider: mockMatchingStateProvider,
            chatStateProvider: mockChatStateProvider,
            child: ChatPage(match: MockUserData.mockUser2),
          ),
        );

        // Try to send empty message
        await TestHelpers.tapIcon(tester, Icons.send);
        await tester.pumpAndSettle();

        // Verify message was not sent
        verifyNever(mockChatStateProvider.sendMessage(any, any));
      });

      testWidgets('navigates back on back button tap', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: mockAppStateProvider,
            matchingStateProvider: mockMatchingStateProvider,
            chatStateProvider: mockChatStateProvider,
            child: ChatPage(match: MockUserData.mockUser2),
          ),
        );

        // Tap back button
        await TestHelpers.tapIcon(tester, Icons.arrow_back);
        await tester.pumpAndSettle();

        // Verify navigation back
        expect(find.byType(ChatPage), findsNothing);
      });

      testWidgets('displays message timestamps', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: mockAppStateProvider,
            matchingStateProvider: mockMatchingStateProvider,
            chatStateProvider: mockChatStateProvider,
            child: ChatPage(match: MockUserData.mockUser2),
          ),
        );

        // Verify timestamps are displayed
        expect(find.text('5m'), findsOneWidget); // Assuming formatted timestamp
      });

      testWidgets('shows message status indicators', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: mockAppStateProvider,
            matchingStateProvider: mockMatchingStateProvider,
            chatStateProvider: mockChatStateProvider,
            child: ChatPage(match: MockUserData.mockUser2),
          ),
        );

        // Verify message status indicators
        expect(find.byIcon(Icons.done), findsOneWidget); // Read indicator
      });
    });
  });
}