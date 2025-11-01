import 'package:flutter/material.dart';
import '../../models/discovery_filters.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../services/cache_service.dart';

class FilterScreen extends StatefulWidget {
  final DiscoveryFilters initialFilters;
  final Function(DiscoveryFilters) onApply;

  const FilterScreen({
    Key? key,
    required this.initialFilters,
    required this.onApply,
  }) : super(key: key);

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late DiscoveryFilters _filters;
  
  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
  }

  void _updateFilters(DiscoveryFilters newFilters) {
    setState(() {
      _filters = newFilters;
    });
  }

  Future<void> _saveAndApply() async {
    // Save filters locally
    await CacheService.setData(
      'discovery_filters',
      _filters.toJson(),
    );
    
    widget.onApply(_filters);
    Navigator.pop(context);
  }

  void _resetFilters() {
    setState(() {
      _filters = DiscoveryFilters.defaultFilters;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Filters',
          style: AppTypography.heading2.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: _resetFilters,
            child: Text(
              'Reset',
              style: AppTypography.button.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter badge
          if (_filters.activeFilterCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: AppColors.primary.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(Icons.filter_list, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${_filters.activeFilterCount} active filter${_filters.activeFilterCount > 1 ? "s" : ""}',
                    style: AppTypography.body2.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          
          // Filter options
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Age range
                _buildSectionTitle('Age Range'),
                _buildAgeRangeSlider(),
                const SizedBox(height: 24),
                
                // Distance
                _buildSectionTitle('Maximum Distance'),
                _buildDistanceSlider(),
                const SizedBox(height: 24),
                
                // Privacy toggles
                _buildSectionTitle('Privacy'),
                _buildPrivacyToggles(),
                const SizedBox(height: 24),
                
                // Gender preferences
                _buildSectionTitle('Gender Preferences'),
                _buildGenderPreferences(),
                const SizedBox(height: 24),
                
                // Advanced filters
                ExpansionTile(
                  title: Text(
                    'Advanced Filters',
                    style: AppTypography.heading3.copyWith(color: AppColors.textPrimary),
                  ),
                  children: [
                    _buildHeightFilter(),
                    const SizedBox(height: 16),
                    _buildVerifiedOnlyToggle(),
                    _buildRecentlyActiveToggle(),
                  ],
                ),
                
                const SizedBox(height: 80), // Space for bottom button
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.navbarBackground,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _saveAndApply,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Apply Filters',
            style: AppTypography.button.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AppTypography.heading3.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAgeRangeSlider() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_filters.minAge} years',
              style: AppTypography.body1.copyWith(color: AppColors.textSecondary),
            ),
            Text(
              '${_filters.maxAge} years',
              style: AppTypography.body1.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        RangeSlider(
          values: RangeValues(_filters.minAge.toDouble(), _filters.maxAge.toDouble()),
          min: 18,
          max: 80,
          divisions: 62,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.border,
          onChanged: (RangeValues values) {
            _updateFilters(_filters.copyWith(
              minAge: values.start.round(),
              maxAge: values.end.round(),
            ));
          },
        ),
      ],
    );
  }

  Widget _buildDistanceSlider() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_filters.maxDistance.round()} km',
              style: AppTypography.body1.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        Slider(
          value: _filters.maxDistance,
          min: 1,
          max: 100,
          divisions: 99,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.border,
          label: '${_filters.maxDistance.round()} km',
          onChanged: (double value) {
            _updateFilters(_filters.copyWith(maxDistance: value));
          },
        ),
      ],
    );
  }

  Widget _buildPrivacyToggles() {
    return Column(
      children: [
        _buildToggleTile(
          'Show my age',
          _filters.showMyAge,
          (value) => _updateFilters(_filters.copyWith(showMyAge: value)),
        ),
        _buildToggleTile(
          'Show my distance',
          _filters.showMyDistance,
          (value) => _updateFilters(_filters.copyWith(showMyDistance: value)),
        ),
      ],
    );
  }

  Widget _buildToggleTile(String title, bool value, Function(bool) onChanged) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: AppTypography.body1.copyWith(color: AppColors.textPrimary),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildGenderPreferences() {
    // This would be populated from reference data
    final genders = ['Male', 'Female', 'Non-binary', 'Other'];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: genders.map((gender) {
        final isSelected = _filters.genderPreferences.contains(gender);
        return FilterChip(
          label: Text(gender),
          selected: isSelected,
          onSelected: (selected) {
            final prefs = List<String>.from(_filters.genderPreferences);
            if (selected) {
              prefs.add(gender);
            } else {
              prefs.remove(gender);
            }
            _updateFilters(_filters.copyWith(genderPreferences: prefs));
          },
          selectedColor: AppColors.primary,
          checkmarkColor: Colors.white,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHeightFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Height Range',
          style: AppTypography.body1.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Min (cm)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final height = int.tryParse(value);
                  if (height != null) {
                    _updateFilters(_filters.copyWith(minHeight: height));
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Max (cm)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final height = int.tryParse(value);
                  if (height != null) {
                    _updateFilters(_filters.copyWith(maxHeight: height));
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVerifiedOnlyToggle() {
    return _buildToggleTile(
      'Verified profiles only',
      _filters.verifiedOnly,
      (value) => _updateFilters(_filters.copyWith(verifiedOnly: value)),
    );
  }

  Widget _buildRecentlyActiveToggle() {
    return _buildToggleTile(
      'Recently active only',
      _filters.recentlyActiveOnly,
      (value) => _updateFilters(_filters.copyWith(recentlyActiveOnly: value)),
    );
  }
}

