import 'package:mockito/mockito.dart';
import 'package:lgbtinder/services/api_services/matching_api_service.dart';
import 'package:lgbtinder/models/api_models/matching_models.dart';

class MockMatchingApiService extends Mock implements MatchingApiService {
  @override
  Future<LikeResponse> likeUser(LikeRequest request) async {
    return super.noSuchMethod(
      Invocation.method(#likeUser, [request]),
      returnValue: LikeResponse(
        success: true,
        message: 'User liked successfully',
        data: LikeResponseData(
          userId: request.userId,
          likedUserId: request.likedUserId,
          isMatch: false,
          match: null,
        ),
      ),
    );
  }

  @override
  Future<LikeResponse> superLikeUser(LikeRequest request) async {
    return super.noSuchMethod(
      Invocation.method(#superLikeUser, [request]),
      returnValue: LikeResponse(
        success: true,
        message: 'User super liked successfully',
        data: LikeResponseData(
          userId: request.userId,
          likedUserId: request.likedUserId,
          isMatch: false,
          match: null,
        ),
      ),
    );
  }

  @override
  Future<void> passUser(PassRequest request) async {
    return super.noSuchMethod(
      Invocation.method(#passUser, [request]),
      returnValue: null,
    );
  }

  @override
  Future<MatchesResponse> getMatches(MatchesRequest request) async {
    return super.noSuchMethod(
      Invocation.method(#getMatches, [request]),
      returnValue: MatchesResponse(
        success: true,
        data: MatchesResponseData(
          matches: [],
          pagination: PaginationData(
            currentPage: 1,
            totalPages: 1,
            totalItems: 0,
            itemsPerPage: 20,
          ),
        ),
      ),
    );
  }

  @override
  Future<PotentialMatchesResponse> getPotentialMatches(PotentialMatchesRequest request) async {
    return super.noSuchMethod(
      Invocation.method(#getPotentialMatches, [request]),
      returnValue: PotentialMatchesResponse(
        success: true,
        data: PotentialMatchesResponseData(
          users: [],
          pagination: PaginationData(
            currentPage: 1,
            totalPages: 1,
            totalItems: 0,
            itemsPerPage: 20,
          ),
        ),
      ),
    );
  }
}
