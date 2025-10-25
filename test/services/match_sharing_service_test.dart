import 'package:flutter_test/flutter_test.dart';
import 'package:lgbtinder/services/match_sharing_service.dart';
import 'package:lgbtinder/models/user.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MatchSharingService', () {
    late User testUser;

    setUp(() {
      testUser = User(
        id: 1,
        firstName: 'TestUser',
        name: 'TestUser FullName',
        email: 'test@example.com',
      );
    });

    test('should check if sharing is available', () async {
      final canShare = await MatchSharingService.canShare();
      expect(canShare, true);
    });

    test('should generate shareable match card widget', () {
      final key = GlobalKey();
      final currentUser = User(
        id: 2,
        firstName: 'CurrentUser',
        name: 'Current User',
        email: 'current@example.com',
      );

      final widget = MatchSharingService.buildShareableMatchCard(
        currentUser: currentUser,
        matchedUser: testUser,
        key: key,
      );

      expect(widget, isNotNull);
    });

    test('shareMatchText should not throw with valid user', () {
      expect(
        () => MatchSharingService.shareMatchText(matchedUser: testUser),
        returnsNormally,
      );
    });

    test('shareMatchWithLink should not throw with valid user', () {
      expect(
        () => MatchSharingService.shareMatchWithLink(matchedUser: testUser),
        returnsNormally,
      );
    });

    test('shareMatchStats should not throw with valid stats', () {
      expect(
        () => MatchSharingService.shareMatchStats(
          totalMatches: 10,
          todayMatches: 2,
        ),
        returnsNormally,
      );
    });

    test('shareMatchText should include user name in message', () async {
      final customMessage = '🎉 Matched with ${testUser.firstName}!';
      
      expect(
        () => MatchSharingService.shareMatchText(
          matchedUser: testUser,
          customMessage: customMessage,
        ),
        returnsNormally,
      );
    });

    test('shareMatchStats should format stats correctly', () {
      const totalMatches = 50;
      const todayMatches = 5;
      
      expect(
        () => MatchSharingService.shareMatchStats(
          totalMatches: totalMatches,
          todayMatches: todayMatches,
        ),
        returnsNormally,
      );
    });

    test('should handle user without images', () {
      final userWithoutImages = User(
        id: 3,
        firstName: 'NoImage',
        name: 'No Image User',
        email: 'noimage@example.com',
        images: [],
      );

      expect(
        () => MatchSharingService.shareMatchText(matchedUser: userWithoutImages),
        returnsNormally,
      );
    });

    test('should handle user without first name', () {
      final userWithoutFirstName = User(
        id: 4,
        name: 'Full Name Only',
        email: 'fullname@example.com',
      );

      expect(
        () => MatchSharingService.shareMatchText(matchedUser: userWithoutFirstName),
        returnsNormally,
      );
    });
  });
}

