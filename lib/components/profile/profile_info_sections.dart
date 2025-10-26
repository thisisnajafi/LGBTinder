import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

class ProfileInfoSections extends StatelessWidget {
  final User user;
  final UserPreferences? preferences;

  const ProfileInfoSections({
    Key? key,
    required this.user,
    this.preferences,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Basic Information Section
        _buildSection(
          title: 'Basic Information',
          icon: Icons.person,
          children: [
            _buildInfoRow('Gender Identity', user.gender ?? 'Not specified'),
            _buildInfoRow('Sexual Orientation', user.sexualOrientation ?? 'Not specified'),
            if (user.relationGoals.isNotEmpty)
              _buildInfoRow('Relationship Goals', _formatList(user.relationGoals.map((g) => g.title).toList())),
            if (user.preferredGenders.isNotEmpty)
              _buildInfoRow('Looking for', _formatList(user.preferredGenders.map((g) => g.title).toList())),
          ],
        ),
        const SizedBox(height: 16),

        // Personal Details Section
        _buildSection(
          title: 'Personal Details',
          icon: Icons.fitness_center,
          children: [
            if (user.height != null)
              _buildInfoRow('Height', '${user.height} cm'),
            if (user.weight != null)
              _buildInfoRow('Weight', '${user.weight} kg'),
            if (user.smokingStatus != null)
              _buildInfoRow('Smoking', user.smokingStatus!),
            if (user.gymStatus != null)
              _buildInfoRow('Gym', user.gymStatus!),
            if (user.drinkingStatus != null)
              _buildInfoRow('Drinking', user.drinkingStatus!),
          ],
        ),
        const SizedBox(height: 16),

        // Background Information Section
        _buildSection(
          title: 'Background Information',
          icon: Icons.school,
          children: [
            if (user.educations.isNotEmpty)
              _buildInfoRow('Education', _formatList(user.educations.map((e) => e.title).toList())),
            if (user.jobs.isNotEmpty)
              _buildInfoRow('Job/Profession', _formatList(user.jobs.map((j) => j.title).toList())),
            if (user.languages.isNotEmpty)
              _buildInfoRow('Languages', _formatList(user.languages.map((l) => l.title).toList())),
            if (user.musicGenres.isNotEmpty)
              _buildInfoRow('Music Genres', _formatList(user.musicGenres.map((m) => m.title).toList())),
            if (user.interests.isNotEmpty)
              _buildInfoRow('Interests/Hobbies', _formatList(user.interests.map((i) => i.title).toList())),
          ],
        ),
        const SizedBox(height: 16),

        // Matching Preferences Section (Collapsible)
        if (preferences != null)
          _buildCollapsibleSection(
            title: 'Matching Preferences',
            icon: Icons.tune,
            children: [
              _buildInfoRow('Age Range', preferences!.ageRangeText),
              _buildInfoRow('Distance', preferences!.distanceText),
            ],
          ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTypography.titleMedium.copyWith(
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Section Content
          ...children,
        ],
      ),
    );
  }

  Widget _buildCollapsibleSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return ExpansionTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: AppTypography.titleMedium.copyWith(
          color: Colors.black87,
        ),
      ),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[200]!,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatList(List<String> items) {
    if (items.isEmpty) return 'Not specified';
    if (items.length == 1) return items.first;
    if (items.length == 2) return '${items.first} and ${items.last}';
    return '${items.take(items.length - 1).join(', ')}, and ${items.last}';
  }
}
