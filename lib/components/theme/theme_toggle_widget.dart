import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

class ThemeToggleWidget extends StatelessWidget {
  const ThemeToggleWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Theme Settings',
                style: AppTypography.h5.copyWith(
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 16),
              
              // Theme mode selection
              _buildThemeModeTile(
                context,
                themeProvider,
                ThemeMode.light,
                'Light Theme',
                'Use light theme',
                Icons.light_mode,
              ),
              const SizedBox(height: 8),
              
              _buildThemeModeTile(
                context,
                themeProvider,
                ThemeMode.dark,
                'Dark Theme',
                'Use dark theme',
                Icons.dark_mode,
              ),
              const SizedBox(height: 8),
              
              _buildThemeModeTile(
                context,
                themeProvider,
                ThemeMode.system,
                'System Theme',
                'Follow system theme',
                Icons.settings_system_daydream,
              ),
              
              const SizedBox(height: 16),
              
              // Quick toggle button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => themeProvider.toggleTheme(),
                  icon: Icon(
                    themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  ),
                  label: Text(
                    themeProvider.isDarkMode ? 'Switch to Light' : 'Switch to Dark',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeModeTile(
    BuildContext context,
    ThemeProvider themeProvider,
    ThemeMode mode,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = themeProvider.themeMode == mode;
    
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primaryLight : Theme.of(context).iconTheme.color,
      ),
      title: Text(
        title,
        style: AppTypography.body1.copyWith(
          color: Theme.of(context).textTheme.titleMedium?.color,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.body2.copyWith(
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
      ),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: AppColors.primaryLight,
            )
          : null,
      onTap: () => themeProvider.setThemeMode(mode),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      tileColor: isSelected
          ? AppColors.primaryLight.withOpacity(0.1)
          : null,
    );
  }
}

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return IconButton(
          onPressed: () => themeProvider.toggleTheme(),
          icon: Icon(
            themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
          ),
          tooltip: themeProvider.isDarkMode ? 'Switch to Light Theme' : 'Switch to Dark Theme',
        );
      },
    );
  }
}

class ThemePreviewCard extends StatelessWidget {
  const ThemePreviewCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Theme Preview',
            style: AppTypography.h5.copyWith(
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 16),
          
          // Sample UI elements
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Primary Button'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('Secondary'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          TextField(
            decoration: const InputDecoration(
              labelText: 'Sample Input',
              hintText: 'Enter text here',
            ),
          ),
          const SizedBox(height: 12),
          
          Text(
            'Sample Text',
            style: AppTypography.body1.copyWith(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          Text(
            'Secondary Text',
            style: AppTypography.body2.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }
}
