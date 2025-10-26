import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../components/profile/profile_header.dart';
import '../components/profile/profile_info_sections.dart';
import '../components/profile/photo_gallery.dart';
import '../models/models.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final List<Map<String, dynamic>> users = [
    {
      'name': 'Emma',
      'age': 30,
      'location': 'New York',
      'image': 'https://randomuser.me/api/portraits/women/10.jpg',
      'bio': 'Designer | Cat lover',
      'gender': 'Female',
      'orientation': 'Lesbian',
      'relationship': 'Single',
      'images': ['https://randomuser.me/api/portraits/women/10.jpg'],
    },
    {
      'name': 'Sarah',
      'age': 26,
      'location': 'Los Angeles',
      'image': 'https://randomuser.me/api/portraits/women/20.jpg',
      'bio': 'Photographer | Vegan',
      'gender': 'Female',
      'orientation': 'Bisexual',
      'relationship': 'Single',
      'images': ['https://randomuser.me/api/portraits/women/20.jpg'],
    },
    {
      'name': 'Alex',
      'age': 27,
      'location': 'Los Angeles',
      'image': 'https://randomuser.me/api/portraits/men/30.jpg',
      'bio': 'Musician | Coffee addict',
      'gender': 'Male',
      'orientation': 'Gay',
      'relationship': 'Single',
      'images': ['https://randomuser.me/api/portraits/men/30.jpg'],
    },
    {
      'name': 'James',
      'age': 31,
      'location': 'San Francisco',
      'image': 'https://randomuser.me/api/portraits/men/40.jpg',
      'bio': 'Writer | Bookworm',
      'gender': 'Male',
      'orientation': 'Bisexual',
      'relationship': 'Single',
      'images': ['https://randomuser.me/api/portraits/men/40.jpg'],
    },
    {
      'name': 'James',
      'age': 31,
      'location': 'San Francisco',
      'image': 'https://randomuser.me/api/portraits/men/40.jpg',
      'bio': 'Writer | Bookworm',
      'gender': 'Male',
      'orientation': 'Bisexual',
      'relationship': 'Single',
      'images': ['https://randomuser.me/api/portraits/men/40.jpg'],
    },
    {
      'name': 'James',
      'age': 31,
      'location': 'San Francisco',
      'image': 'https://randomuser.me/api/portraits/men/40.jpg',
      'bio': 'Writer | Bookworm',
      'gender': 'Male',
      'orientation': 'Bisexual',
      'relationship': 'Single',
      'images': ['https://randomuser.me/api/portraits/men/40.jpg'],
    },
    {
      'name': 'James',
      'age': 31,
      'location': 'San Francisco',
      'image': 'https://randomuser.me/api/portraits/men/40.jpg',
      'bio': 'Writer | Bookworm',
      'gender': 'Male',
      'orientation': 'Bisexual',
      'relationship': 'Single',
      'images': ['https://randomuser.me/api/portraits/men/40.jpg'],
    },
    {
      'name': 'James',
      'age': 31,
      'location': 'San Francisco',
      'image': 'https://randomuser.me/api/portraits/men/40.jpg',
      'bio': 'Writer | Bookworm',
      'gender': 'Male',
      'orientation': 'Bisexual',
      'relationship': 'Single',
      'images': ['https://randomuser.me/api/portraits/men/40.jpg'],
    },
    {
      'name': 'James',
      'age': 31,
      'location': 'San Francisco',
      'image': 'https://randomuser.me/api/portraits/men/40.jpg',
      'bio': 'Writer | Bookworm',
      'gender': 'Male',
      'orientation': 'Bisexual',
      'relationship': 'Single',
      'images': ['https://randomuser.me/api/portraits/men/40.jpg'],
    },
    {
      'name': 'James',
      'age': 31,
      'location': 'San Francisco',
      'image': 'https://randomuser.me/api/portraits/men/40.jpg',
      'bio': 'Writer | Bookworm',
      'gender': 'Male',
      'orientation': 'Bisexual',
      'relationship': 'Single',
      'images': ['https://randomuser.me/api/portraits/men/40.jpg'],
    },
  ];

  // Filter state
  RangeValues ageRange = const RangeValues(24, 34);
  String gender = 'Men, Women';
  double distance = 50;

  void _showProfileDetails(BuildContext context, Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.appBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Create a mock User object for the ProfileHeader
                    ProfileHeader(
                      user: User(
                        id: user['id'] ?? 1,
                        firstName: user['name']?.split(' ').first ?? '',
                        lastName: user['name']?.split(' ').last ?? '',
                        fullName: user['name'] ?? '',
                        email: '',
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                        avatarUrl: user['image'],
                        city: user['location'],
                        isVerified: true,
                        isOnline: true,
                      ),
                      onEditPressed: () {},
                    ),
                    const SizedBox(height: 24),
                    // Create a mock User object for ProfileInfoSections
                    ProfileInfoSections(
                      user: User(
                        id: user['id'] ?? 1,
                        firstName: user['name']?.split(' ').first ?? '',
                        lastName: user['name']?.split(' ').last ?? '',
                        fullName: user['name'] ?? '',
                        email: '',
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                        profileBio: user['bio'],
                        gender: user['gender'],
                        sexualOrientation: user['orientation'],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Create a mock list of UserImage objects for PhotoGallery
                    PhotoGallery(
                      images: (user['images'] as List<dynamic>? ?? []).map((image) => UserImage(
                        id: 1,
                        url: image.toString(),
                        type: 'gallery',
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      )).toList(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        RangeValues tempAge = ageRange;
        String tempGender = gender;
        double tempDistance = distance;
        return AlertDialog(
          backgroundColor: AppColors.appBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Filters', style: TextStyle(color: Colors.white)),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Text('Age Range', style: TextStyle(color: Colors.white)),
                RangeSlider(
                  values: tempAge,
                  min: 18,
                  max: 60,
                  divisions: 42,
                  activeColor: AppColors.primaryLight,
                  inactiveColor: AppColors.primaryLight.withOpacity(0.2),
                  labels: RangeLabels(
                    tempAge.start.round().toString(),
                    tempAge.end.round().toString(),
                  ),
                  onChanged: (v) => setState(() => tempAge = v),
                ),
                const SizedBox(height: 8),
                Text('Gender', style: TextStyle(color: Colors.white)),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Men'),
                      selected: tempGender.contains('Men'),
                      onSelected: (selected) {
                        setState(() => tempGender = selected ? 'Men, Women' : 'Women');
                      },
                      selectedColor: AppColors.primaryLight,
                    ),
                    ChoiceChip(
                      label: const Text('Women'),
                      selected: tempGender.contains('Women'),
                      onSelected: (selected) {
                        setState(() => tempGender = selected ? 'Men, Women' : 'Men');
                      },
                      selectedColor: AppColors.primaryLight,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Distance (km)', style: TextStyle(color: Colors.white)),
                Slider(
                  value: tempDistance,
                  min: 1,
                  max: 200,
                  divisions: 199,
                  activeColor: AppColors.primaryLight,
                  inactiveColor: AppColors.primaryLight.withOpacity(0.2),
                  label: '< ${tempDistance.round()} km',
                  onChanged: (v) => setState(() => tempDistance = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                setState(() {
                  ageRange = tempAge;
                  gender = tempGender;
                  distance = tempDistance;
                });
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: AppColors.appBackground.withOpacity(0.7),
          border: Border.all(color: AppColors.primaryLight, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryLight.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primaryLight, size: 18),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'LGBTinder',
                  style: AppTypography.headlineLarge.copyWith(
                    color: AppColors.primaryLight,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        color: AppColors.primaryLight.withOpacity(0.5),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _showFilterDialog,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryLight.withOpacity(0.5),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Icon(Icons.search, color: AppColors.primaryLight, size: 32),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip(
                  icon: Icons.radio_button_checked,
                  label: 'Age ${ageRange.start.round()}-${ageRange.end.round()}',
                  onTap: _showFilterDialog,
                ),
                _buildFilterChip(
                  icon: Icons.people,
                  label: 'Gender: $gender',
                  onTap: _showFilterDialog,
                ),
                _buildFilterChip(
                  icon: Icons.location_on,
                  label: 'Distance: < ${distance.round()} km',
                  onTap: _showFilterDialog,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 0.75,
              ),
              itemCount: users.length,
              itemBuilder: (context, i) {
                final user = users[i];
                return GestureDetector(
                  onTap: () => _showProfileDetails(context, user),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primaryLight,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryLight.withOpacity(0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryLight.withOpacity(0.12),
                          Colors.transparent,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                          child: Image.network(
                            user['image'],
                            height: 140,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${user['name']}, ${user['age']}',
                                style: AppTypography.titleMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.location_on, color: AppColors.primaryLight, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    user['location'],
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 