import 'package:mockito/mockito.dart';
import 'package:lgbtinder/services/api_services/profile_api_service.dart';
import 'package:lgbtinder/models/api_models/profile_models.dart';

class MockProfileApiService extends Mock implements ProfileApiService {
  @override
  Future<ProfileUpdateResponse> updateProfile(ProfileUpdateRequest request) async {
    return super.noSuchMethod(
      Invocation.method(#updateProfile, [request]),
      returnValue: ProfileUpdateResponse(
        success: true,
        message: 'Profile updated successfully',
        data: ProfileUpdateResponseData(
          userId: 1,
          isUpdated: true,
        ),
      ),
    );
  }

  @override
  Future<ProfilePictureUploadResponse> uploadProfilePicture(ProfilePictureUploadRequest request) async {
    return super.noSuchMethod(
      Invocation.method(#uploadProfilePicture, [request]),
      returnValue: ProfilePictureUploadResponse(
        success: true,
        message: 'Profile picture uploaded successfully',
        data: ProfilePictureUploadResponseData(
          userId: 1,
          pictureUrl: 'https://example.com/uploaded_picture.jpg',
          isUploaded: true,
        ),
      ),
    );
  }
}
