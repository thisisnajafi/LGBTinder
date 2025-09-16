import 'dart:math';
import '../models/user.dart';
import '../models/reference_data.dart';

class MatchingAlgorithmService {
  /// Calculate compatibility score between two users
  static double calculateCompatibilityScore(User user1, User user2) {
    double score = 0.0;
    int factors = 0;

    // Age compatibility (prefer similar ages)
    if (user1.birthDate != null && user2.birthDate != null) {
      final age1 = _calculateAge(user1.birthDate!);
      final age2 = _calculateAge(user2.birthDate!);
      final ageDiff = (age1 - age2).abs();
      
      // Prefer age difference of 0-5 years
      if (ageDiff <= 5) {
        score += 20;
      } else if (ageDiff <= 10) {
        score += 15;
      } else if (ageDiff <= 15) {
        score += 10;
      } else {
        score += 5;
      }
      factors++;
    }

    // Gender preference compatibility
    if (user1.preferredGenders.isNotEmpty && user2.gender != null) {
      final isGenderMatch = user1.preferredGenders.any(
        (pref) => pref.name.toLowerCase() == user2.gender!.toLowerCase()
      );
      if (isGenderMatch) {
        score += 25;
      }
      factors++;
    }

    // Interest compatibility
    if (user1.interests.isNotEmpty && user2.interests.isNotEmpty) {
      final commonInterests = user1.interests.where((interest1) =>
        user2.interests.any((interest2) => interest1.name == interest2.name)
      ).length;
      
      final interestScore = (commonInterests / max(user1.interests.length, user2.interests.length)) * 20;
      score += interestScore;
      factors++;
    }

    // Music genre compatibility
    if (user1.musicGenres.isNotEmpty && user2.musicGenres.isNotEmpty) {
      final commonGenres = user1.musicGenres.where((genre1) =>
        user2.musicGenres.any((genre2) => genre1.name == genre2.name)
      ).length;
      
      final musicScore = (commonGenres / max(user1.musicGenres.length, user2.musicGenres.length)) * 15;
      score += musicScore;
      factors++;
    }

    // Language compatibility
    if (user1.languages.isNotEmpty && user2.languages.isNotEmpty) {
      final commonLanguages = user1.languages.where((lang1) =>
        user2.languages.any((lang2) => lang1.name == lang2.name)
      ).length;
      
      if (commonLanguages > 0) {
        score += 15;
      }
      factors++;
    }

    // Relationship goal compatibility
    if (user1.relationGoals.isNotEmpty && user2.relationGoals.isNotEmpty) {
      final commonGoals = user1.relationGoals.where((goal1) =>
        user2.relationGoals.any((goal2) => goal1.name == goal2.name)
      ).length;
      
      if (commonGoals > 0) {
        score += 20;
      }
      factors++;
    }

    // Education compatibility (bonus points for similar education levels)
    if (user1.educations.isNotEmpty && user2.educations.isNotEmpty) {
      final commonEducation = user1.educations.where((edu1) =>
        user2.educations.any((edu2) => edu1.name == edu2.name)
      ).length;
      
      if (commonEducation > 0) {
        score += 10;
      }
      factors++;
    }

    // Lifestyle compatibility
    score += _calculateLifestyleCompatibility(user1, user2);
    factors++;

    // Location compatibility (if available)
    if (user1.location != null && user2.location != null) {
      // This would typically use geolocation services
      // For now, we'll give a base score if both have locations
      score += 10;
      factors++;
    }

    // Return normalized score (0-100)
    return factors > 0 ? (score / factors) : 0.0;
  }

  /// Calculate lifestyle compatibility based on habits
  static double _calculateLifestyleCompatibility(User user1, User user2) {
    double score = 0.0;
    int factors = 0;

    // Smoking compatibility
    if (user1.smoke != null && user2.smoke != null) {
      if (user1.smoke == user2.smoke) {
        score += 10;
      } else {
        // Some combinations are more compatible than others
        if ((user1.smoke == 'Non-smoker' && user2.smoke == 'Occasionally') ||
            (user1.smoke == 'Occasionally' && user2.smoke == 'Non-smoker')) {
          score += 5;
        }
      }
      factors++;
    }

    // Drinking compatibility
    if (user1.drink != null && user2.drink != null) {
      if (user1.drink == user2.drink) {
        score += 10;
      } else {
        // Moderate drinking is generally compatible with most preferences
        if (user1.drink == 'Moderately' || user2.drink == 'Moderately') {
          score += 5;
        }
      }
      factors++;
    }

    // Gym/fitness compatibility
    if (user1.gym != null && user2.gym != null) {
      if (user1.gym == user2.gym) {
        score += 10;
      } else {
        // Regular gym-goers might be compatible with occasional gym-goers
        if ((user1.gym == 'Regularly' && user2.gym == 'Occasionally') ||
            (user1.gym == 'Occasionally' && user2.gym == 'Regularly')) {
          score += 5;
        }
      }
      factors++;
    }

    return factors > 0 ? score : 0.0;
  }

  /// Sort users by compatibility score
  static List<User> sortByCompatibility(User currentUser, List<User> potentialMatches) {
    final matchesWithScores = potentialMatches.map((user) {
      final score = calculateCompatibilityScore(currentUser, user);
      return {'user': user, 'score': score};
    }).toList();

    // Sort by score (highest first)
    matchesWithScores.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));

    return matchesWithScores.map((match) => match['user'] as User).toList();
  }

  /// Filter users based on basic criteria
  static List<User> filterUsers(User currentUser, List<User> potentialMatches) {
    return potentialMatches.where((user) {
      // Don't match with yourself
      if (user.id == currentUser.id) return false;

      // Age range filtering
      if (currentUser.birthDate != null && user.birthDate != null) {
        final currentAge = _calculateAge(currentUser.birthDate!);
        final userAge = _calculateAge(user.birthDate!);
        
        // Basic age range (18-65)
        if (userAge < 18 || userAge > 65) return false;
        
        // If user has age preferences, apply them
        // This would typically be stored in user preferences
        // For now, we'll use a reasonable range
        if ((userAge - currentAge).abs() > 20) return false;
      }

      // Gender preference filtering
      if (currentUser.preferredGenders.isNotEmpty && user.gender != null) {
        final isGenderMatch = currentUser.preferredGenders.any(
          (pref) => pref.name.toLowerCase() == user.gender!.toLowerCase()
        );
        if (!isGenderMatch) return false;
      }

      // Location filtering (if both users have locations)
      if (currentUser.location != null && user.location != null) {
        // This would typically use geolocation services
        // For now, we'll just check if they're in the same city/region
        final currentLocation = currentUser.location!.toLowerCase();
        final userLocation = user.location!.toLowerCase();
        
        // Simple city matching (could be enhanced with distance calculation)
        if (currentLocation != userLocation) {
          // Could add distance-based filtering here
        }
      }

      return true;
    }).toList();
  }

  /// Get personalized match suggestions
  static List<User> getPersonalizedMatches(User currentUser, List<User> allUsers) {
    // First filter users based on basic criteria
    final filteredUsers = filterUsers(currentUser, allUsers);
    
    // Then sort by compatibility
    final sortedUsers = sortByCompatibility(currentUser, filteredUsers);
    
    // Return top matches (limit to reasonable number)
    return sortedUsers.take(50).toList();
  }

  /// Calculate age from birth date
  static int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// Get match quality description
  static String getMatchQualityDescription(double score) {
    if (score >= 80) return 'Excellent Match';
    if (score >= 70) return 'Great Match';
    if (score >= 60) return 'Good Match';
    if (score >= 50) return 'Decent Match';
    if (score >= 40) return 'Fair Match';
    return 'Low Compatibility';
  }

  /// Get match quality color
  static int getMatchQualityColor(double score) {
    if (score >= 80) return 0xFF4CAF50; // Green
    if (score >= 70) return 0xFF8BC34A; // Light Green
    if (score >= 60) return 0xFFCDDC39; // Lime
    if (score >= 50) return 0xFFFFEB3B; // Yellow
    if (score >= 40) return 0xFFFF9800; // Orange
    return 0xFFF44336; // Red
  }
}
