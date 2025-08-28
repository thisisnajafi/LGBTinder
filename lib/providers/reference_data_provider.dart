import 'package:flutter/foundation.dart';
import '../models/reference_data.dart';
import '../services/reference_data_service.dart';
import '../utils/error_handler.dart';

class ReferenceDataProvider with ChangeNotifier {
  List<Education> _educationOptions = [];
  List<Gender> _genderOptions = [];
  List<Interest> _interestOptions = [];
  List<Job> _jobOptions = [];
  List<Language> _languageOptions = [];
  List<MusicGenre> _musicGenreOptions = [];
  List<PreferredGender> _preferredGenderOptions = [];
  List<RelationGoal> _relationGoalOptions = [];

  bool _isLoading = false;
  String? _error;

  // Getters
  List<Education> get educationOptions => _educationOptions;
  List<Gender> get genderOptions => _genderOptions;
  List<Interest> get interestOptions => _interestOptions;
  List<Job> get jobOptions => _jobOptions;
  List<Language> get languageOptions => _languageOptions;
  List<MusicGenre> get musicGenreOptions => _musicGenreOptions;
  List<PreferredGender> get preferredGenderOptions => _preferredGenderOptions;
  List<RelationGoal> get relationGoalOptions => _relationGoalOptions;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  /// Load all reference data at once
  Future<void> loadAllReferenceData() async {
    try {
      _setLoading(true);
      _clearError();

      await Future.wait([
        loadEducationOptions(),
        loadGenderOptions(),
        loadInterestOptions(),
        loadJobOptions(),
        loadLanguageOptions(),
        loadMusicGenreOptions(),
        loadPreferredGenderOptions(),
        loadRelationGoalOptions(),
      ]);
    } catch (e) {
      _setError('Failed to load reference data: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load education options
  Future<void> loadEducationOptions() async {
    try {
      if (_educationOptions.isEmpty) {
        final options = await ReferenceDataService.getEducationOptions();
        _educationOptions = options;
        notifyListeners();
      }
    } on AppException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to load education options: $e');
    }
  }

  /// Load gender options
  Future<void> loadGenderOptions() async {
    try {
      if (_genderOptions.isEmpty) {
        final options = await ReferenceDataService.getGenderOptions();
        _genderOptions = options;
        notifyListeners();
      }
    } on AppException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to load gender options: $e');
    }
  }

  /// Load interest options
  Future<void> loadInterestOptions() async {
    try {
      if (_interestOptions.isEmpty) {
        final options = await ReferenceDataService.getInterestOptions();
        _interestOptions = options;
        notifyListeners();
      }
    } on AppException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to load interest options: $e');
    }
  }

  /// Load job options
  Future<void> loadJobOptions() async {
    try {
      if (_jobOptions.isEmpty) {
        final options = await ReferenceDataService.getJobOptions();
        _jobOptions = options;
        notifyListeners();
      }
    } on AppException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to load job options: $e');
    }
  }

  /// Load language options
  Future<void> loadLanguageOptions() async {
    try {
      if (_languageOptions.isEmpty) {
        final options = await ReferenceDataService.getLanguageOptions();
        _languageOptions = options;
        notifyListeners();
      }
    } on AppException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to load language options: $e');
    }
  }

  /// Load music genre options
  Future<void> loadMusicGenreOptions() async {
    try {
      if (_musicGenreOptions.isEmpty) {
        final options = await ReferenceDataService.getMusicGenreOptions();
        _musicGenreOptions = options;
        notifyListeners();
      }
    } on AppException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to load music genre options: $e');
    }
  }

  /// Load preferred gender options
  Future<void> loadPreferredGenderOptions() async {
    try {
      if (_preferredGenderOptions.isEmpty) {
        final options = await ReferenceDataService.getPreferredGenderOptions();
        _preferredGenderOptions = options;
        notifyListeners();
      }
    } on AppException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to load preferred gender options: $e');
    }
  }

  /// Load relationship goal options
  Future<void> loadRelationGoalOptions() async {
    try {
      if (_relationGoalOptions.isEmpty) {
        final options = await ReferenceDataService.getRelationGoalOptions();
        _relationGoalOptions = options;
        notifyListeners();
      }
    } on AppException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to load relationship goal options: $e');
    }
  }

  /// Clear all cached data
  void clearCache() {
    _educationOptions.clear();
    _genderOptions.clear();
    _interestOptions.clear();
    _jobOptions.clear();
    _languageOptions.clear();
    _musicGenreOptions.clear();
    _preferredGenderOptions.clear();
    _relationGoalOptions.clear();
    _clearError();
    notifyListeners();
  }

  /// Find education by ID
  Education? findEducationById(int id) {
    try {
      return _educationOptions.firstWhere((education) => education.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Find gender by ID
  Gender? findGenderById(int id) {
    try {
      return _genderOptions.firstWhere((gender) => gender.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Find interest by ID
  Interest? findInterestById(int id) {
    try {
      return _interestOptions.firstWhere((interest) => interest.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Find job by ID
  Job? findJobById(int id) {
    try {
      return _jobOptions.firstWhere((job) => job.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Find language by ID
  Language? findLanguageById(int id) {
    try {
      return _languageOptions.firstWhere((language) => language.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Find music genre by ID
  MusicGenre? findMusicGenreById(int id) {
    try {
      return _musicGenreOptions.firstWhere((genre) => genre.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Find preferred gender by ID
  PreferredGender? findPreferredGenderById(int id) {
    try {
      return _preferredGenderOptions.firstWhere((gender) => gender.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Find relationship goal by ID
  RelationGoal? findRelationGoalById(int id) {
    try {
      return _relationGoalOptions.firstWhere((goal) => goal.id == id);
    } catch (e) {
      return null;
    }
  }
}
