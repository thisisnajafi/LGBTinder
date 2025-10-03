import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:lgbtinder/pages/discovery_page.dart';
import 'package:lgbtinder/providers/matching_state_provider.dart';
import 'package:lgbtinder/services/api_services/matching_api_service.dart';
import 'package:lgbtinder/models/api_models/user_models.dart';
import 'package:lgbtinder/models/api_models/matching_models.dart';
import 'ui_test_utils.dart';

import '../mocks/mock_matching_api_service.dart';

@GenerateMocks([MatchingStateProvider, MatchingApiService])
void testMatchingScreens() {
  group('Matching Screens UI Tests', () {
    late MockMatchingStateProvider mockMatchingStateProvider;

    setUp(() {
      mockMatchingStateProvider = MockMatchingStateProvider();
      MockProviderSetup.setupMockMatchingStateProvider(mockMatchingStateProvider);
    });

    group('Discovery Page', () {
      testWidgets('displays potential matches', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            matchingStateProvider: mockMatchingStateProvider,
            child: const DiscoveryPage(),
          ),
        );

        // Verify potential matches are displayed
        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('Jane Smith'), findsOneWidget);
        expect(find.text('Test bio'), findsOneWidget);
        expect(find.text('Test bio 2'), findsOneWidget);
      });

      testWidgets('shows loading state', (WidgetTester tester) async {
        when(mockMatchingStateProvider.isLoading).thenReturn(true);

        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            matchingStateProvider: mockMatchingStateProvider,
            child: const DiscoveryPage(),
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
            matchingStateProvider: mockMatchingStateProvider,
            child: const DiscoveryPage(),
          ),
        );

        // Verify error state
        AssertionHelpers.assertErrorState(tester, 'Failed to load matches');
        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('shows empty state when no matches', (WidgetTester tester) async {
        when(mockMatchingStateProvider.isLoading).thenReturn(false);
        when(mockMatchingStateProvider.error).thenReturn(null);
        when(mockMatchingStateProvider.potentialMatches).thenReturn([]);

        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            matchingStateProvider: mockMatchingStateProvider,
            child: const DiscoveryPage(),
          ),
        );

        // Verify empty state
        expect(find.text('No more matches'), findsOneWidget);
        expect(find.text('Check back later for new potential matches!'), findsOneWidget);
      });

      testWidgets('handles like action', (WidgetTester tester) async {
        when(mockMatchingStateProvider.likeUser(any)).thenAnswer((_) async => MatchResult(isMatch: true));

        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            matchingStateProvider: mockMatchingStateProvider,
            child: const DiscoveryPage(),
          ),
        );

        // Find and tap like button
        await TestHelpers.tapIcon(tester, Icons.favorite);
        await tester.pumpAndSettle();

        // Verify like action was called
        verify(mockMatchingStateProvider.likeUser(any)).called(1);
      });

      testWidgets('handles super like action', (WidgetTester tester) async {
        when(mockMatchingStateProvider.superLikeUser(any)).thenAnswer((_) async => MatchResult(isMatch: true));

        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            matchingStateProvider: mockMatchingStateProvider,
            child: const DiscoveryPage(),
          ),
        );

        // Find and tap super like button
        await TestHelpers.tapIcon(tester, Icons.star);
        await tester.pumpAndSettle();

        // Verify super like action was called
        verify(mockMatchingStateProvider.superLikeUser(any)).called(1);
      });

      testWidgets('handles pass action', (WidgetTester tester) async {
        when(mockMatchingStateProvider.passUser(any)).thenAnswer((_) async {});

        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            matchingStateProvider: mockMatchingStateProvider,
            child: const DiscoveryPage(),
          ),
        );

        // Find and tap pass button
        await TestHelpers.tapIcon(tester, Icons.close);
        await tester.pumpAndSettle();

        // Verify pass action was called
        verify(mockMatchingStateProvider.passUser(any)).called(1);
      });

      testWidgets('shows match dialog on successful match', (WidgetTester tester) async {
        when(mockMatchingStateProvider.likeUser(any)).thenAnswer((_) async => MatchResult(isMatch: true));

        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            matchingStateProvider: mockMatchingStateProvider,
            child: const DiscoveryPage(),
          ),
        );

        // Perform like action
        await TestHelpers.tapIcon(tester, Icons.favorite);
        await tester.pumpAndSettle();

        // Verify match dialog is shown
        expect(find.text('It\'s a Match!'), findsOneWidget);
        expect(find.text('You and John Doe liked each other!'), findsOneWidget);
        expect(find.text('Send Message'), findsOneWidget);
        expect(find.text('Keep Swiping'), findsOneWidget);
      });

      testWidgets('navigates to chat on match dialog send message', (WidgetTester tester) async {
        when(mockMatchingStateProvider.likeUser(any)).thenAnswer((_) async => MatchResult(isMatch: true));

        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            matchingStateProvider: mockMatchingStateProvider,
            child: const DiscoveryPage(),
          ),
        );

        // Perform like action
        await TestHelpers.tapIcon(tester, Icons.favorite);
        await tester.pumpAndSettle();

        // Tap send message in match dialog
        await TestHelpers.tapButton(tester, 'Send Message');
        await tester.pumpAndSettle();

        // Verify navigation to chat
        // Note: This would depend on your navigation setup
        // expect(find.byType(ChatPage), findsOneWidget);
      });

      testWidgets('continues swiping on match dialog keep swiping', (WidgetTester tester) async {
        when(mockMatchingStateProvider.likeUser(any)).thenAnswer((_) async => MatchResult(isMatch: true));

        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            matchingStateProvider: mockMatchingStateProvider,
            child: const DiscoveryPage(),
          ),
        );

        // Perform like action
        await TestHelpers.tapIcon(tester, Icons.favorite);
        await tester.pumpAndSettle();

        // Tap keep swiping in match dialog
        await TestHelpers.tapButton(tester, 'Keep Swiping');
        await tester.pumpAndSettle();

        // Verify match dialog is dismissed
        expect(find.text('It\'s a Match!'), findsNothing);
      });

      testWidgets('shows profile details on tap', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            matchingStateProvider: mockMatchingStateProvider,
            child: const DiscoveryPage(),
          ),
        );

        // Tap on profile card
        await tester.tap(find.text('John Doe'));
        await tester.pumpAndSettle();

        // Verify profile details are shown
        expect(find.text('About John'), findsOneWidget);
        expect(find.text('Test bio'), findsOneWidget);
        expect(find.text('25 years old'), findsOneWidget);
        expect(find.text('New York'), findsOneWidget);
        expect(find.text('Software Engineer'), findsOneWidget);
        expect(find.text('Bachelor\'s Degree'), findsOneWidget);
      });

      testWidgets('loads more matches on scroll', (WidgetTester tester) async {
        when(mockMatchingStateProvider.loadMoreMatches()).thenAnswer((_) async {});

        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            matchingStateProvider: mockMatchingStateProvider,
            child: const DiscoveryPage(),
          ),
        );

        // Scroll to bottom
        await tester.drag(find.byType(ListView), const Offset(0, -500));
        await tester.pumpAndSettle();

        // Verify load more was called
        verify(mockMatchingStateProvider.loadMoreMatches()).called(1);
      });

      testWidgets('shows loading more indicator', (WidgetTester tester) async {
        when(mockMatchingStateProvider.isLoadingMore).thenReturn(true);

        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            matchingStateProvider: mockMatchingStateProvider,
            child: const DiscoveryPage(),
          ),
        );

        // Verify loading more indicator
        expect(find.text('Loading more matches...'), findsOneWidget);
      });

      testWidgets('handles swipe gestures', (WidgetTester tester) async {
        when(mockMatchingStateProvider.likeUser(any)).thenAnswer((_) async => MatchResult(isMatch: false));
        when(mockMatchingStateProvider.passUser(any)).thenAnswer((_) async {});

        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            matchingStateProvider: mockMatchingStateProvider,
            child: const DiscoveryPage(),
          ),
        );

        // Swipe right (like)
        await tester.drag(find.text('John Doe'), const Offset(300, 0));
        await tester.pumpAndSettle();

        // Verify like action was called
        verify(mockMatchingStateProvider.likeUser(any)).called(1);

        // Swipe left (pass)
        await tester.drag(find.text('Jane Smith'), const Offset(-300, 0));
        await tester.pumpAndSettle();

        // Verify pass action was called
        verify(mockMatchingStateProvider.passUser(any)).called(1);
      });

      testWidgets('shows super like animation', (WidgetTester tester) async {
        when(mockMatchingStateProvider.superLikeUser(any)).thenAnswer((_) async => MatchResult(isMatch: false));

        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            matchingStateProvider: mockMatchingStateProvider,
            child: const DiscoveryPage(),
          ),
        );

        // Swipe up (super like)
        await tester.drag(find.text('John Doe'), const Offset(0, -300));
        await tester.pumpAndSettle();

        // Verify super like action was called
        verify(mockMatchingStateProvider.superLikeUser(any)).called(1);
      });

      testWidgets('displays user photos in carousel', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            matchingStateProvider: mockMatchingStateProvider,
            child: const DiscoveryPage(),
          ),
        );

        // Verify photos are displayed
        expect(find.byType(Image), findsWidgets);
        expect(find.byType(PageView), findsOneWidget);
      });

      testWidgets('navigates between photos', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            matchingStateProvider: mockMatchingStateProvider,
            child: const DiscoveryPage(),
          ),
        );

        // Swipe horizontally on photo carousel
        await tester.drag(find.byType(PageView), const Offset(-200, 0));
        await tester.pumpAndSettle();

        // Verify photo changed (this would depend on your implementation)
        // expect(find.byType(Image), findsOneWidget);
      });

      testWidgets('shows user interests and preferences', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            matchingStateProvider: mockMatchingStateProvider,
            child: const DiscoveryPage(),
          ),
        );

        // Tap on profile to see details
        await tester.tap(find.text('John Doe'));
        await tester.pumpAndSettle();

        // Verify interests and preferences are shown
        expect(find.text('Interests'), findsOneWidget);
        expect(find.text('Music'), findsOneWidget);
        expect(find.text('Sports'), findsOneWidget);
        expect(find.text('Travel'), findsOneWidget);
      });

      testWidgets('handles network error gracefully', (WidgetTester tester) async {
        when(mockMatchingStateProvider.isLoading).thenReturn(false);
        when(mockMatchingStateProvider.error).thenReturn('Network error');

        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            matchingStateProvider: mockMatchingStateProvider,
            child: const DiscoveryPage(),
          ),
        );

        // Verify error state
        AssertionHelpers.assertErrorState(tester, 'Network error');
        expect(find.text('Retry'), findsOneWidget);

        // Test retry functionality
        when(mockMatchingStateProvider.loadPotentialMatches()).thenAnswer((_) async {});
        when(mockMatchingStateProvider.isLoading).thenReturn(false);
        when(mockMatchingStateProvider.error).thenReturn(null);

        await TestHelpers.tapButton(tester, 'Retry');
        await tester.pumpAndSettle();

        // Verify retry was called
        verify(mockMatchingStateProvider.loadPotentialMatches()).called(1);
      });
    });
  });
}