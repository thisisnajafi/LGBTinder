import 'package:mockito/mockito.dart';
import 'package:lgbtinder/services/api_services/reference_data_api_service.dart';
import 'package:lgbtinder/models/api_models/reference_data_models.dart';

class MockReferenceDataApiService extends Mock implements ReferenceDataApiService {
  @override
  Future<ReferenceDataResponse<Country>> getCountries() async {
    return super.noSuchMethod(
      Invocation.method(#getCountries, []),
      returnValue: ReferenceDataResponse<Country>(
        success: true,
        data: [],
      ),
    );
  }

  @override
  Future<ReferenceDataResponse<City>> getCities(int countryId) async {
    return super.noSuchMethod(
      Invocation.method(#getCities, [countryId]),
      returnValue: ReferenceDataResponse<City>(
        success: true,
        data: [],
      ),
    );
  }

  @override
  Future<ReferenceDataResponse<ReferenceDataItem>> getGenders() async {
    return super.noSuchMethod(
      Invocation.method(#getGenders, []),
      returnValue: ReferenceDataResponse<ReferenceDataItem>(
        success: true,
        data: [],
      ),
    );
  }

  @override
  Future<ReferenceDataResponse<ReferenceDataItem>> getJobs() async {
    return super.noSuchMethod(
      Invocation.method(#getJobs, []),
      returnValue: ReferenceDataResponse<ReferenceDataItem>(
        success: true,
        data: [],
      ),
    );
  }

  @override
  Future<ReferenceDataResponse<ReferenceDataItem>> getEducation() async {
    return super.noSuchMethod(
      Invocation.method(#getEducation, []),
      returnValue: ReferenceDataResponse<ReferenceDataItem>(
        success: true,
        data: [],
      ),
    );
  }

  @override
  Future<ReferenceDataResponse<ReferenceDataItem>> getInterests() async {
    return super.noSuchMethod(
      Invocation.method(#getInterests, []),
      returnValue: ReferenceDataResponse<ReferenceDataItem>(
        success: true,
        data: [],
      ),
    );
  }

  @override
  Future<ReferenceDataResponse<ReferenceDataItem>> getLanguages() async {
    return super.noSuchMethod(
      Invocation.method(#getLanguages, []),
      returnValue: ReferenceDataResponse<ReferenceDataItem>(
        success: true,
        data: [],
      ),
    );
  }

  @override
  Future<ReferenceDataResponse<ReferenceDataItem>> getMusicGenres() async {
    return super.noSuchMethod(
      Invocation.method(#getMusicGenres, []),
      returnValue: ReferenceDataResponse<ReferenceDataItem>(
        success: true,
        data: [],
      ),
    );
  }

  @override
  Future<ReferenceDataResponse<ReferenceDataItem>> getRelationGoals() async {
    return super.noSuchMethod(
      Invocation.method(#getRelationGoals, []),
      returnValue: ReferenceDataResponse<ReferenceDataItem>(
        success: true,
        data: [],
      ),
    );
  }

  @override
  Future<ReferenceDataResponse<ReferenceDataItem>> getPreferredGenders() async {
    return super.noSuchMethod(
      Invocation.method(#getPreferredGenders, []),
      returnValue: ReferenceDataResponse<ReferenceDataItem>(
        success: true,
        data: [],
      ),
    );
  }
}
