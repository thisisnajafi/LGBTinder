import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../services/safety_service.dart';
import '../providers/auth_provider.dart';
import '../utils/api_error_handler.dart';

class SafetySettingsScreen extends StatefulWidget {
  const SafetySettingsScreen({Key? key}) : super(key: key);

  @override
  State<SafetySettingsScreen> createState() => _SafetySettingsScreenState();
}

class _SafetySettingsScreenState extends State<SafetySettingsScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _safetySettings = {};
  final List<String> _emergencyContacts = [];
  final TextEditingController _emergencyContactController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSafetySettings();
  }

  @override
  void dispose() {
    _emergencyContactController.dispose();
    super.dispose();
  }

  Future<void> _loadSafetySettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = authProvider.accessToken;

      if (accessToken != null) {
        final settings = await SafetyService.getSafetySettings(
          accessToken: accessToken,
        );
        
        setState(() {
          _safetySettings = settings;
          _emergencyContacts.clear();
          _emergencyContacts.addAll(
            List<String>.from(settings['emergency_contacts'] ?? [])
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load safety settings: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateSafetySetting(String key, dynamic value) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = authProvider.accessToken;

      if (accessToken != null) {
        await SafetyService.updateSafetySetting(
          key: key,
          value: value,
          accessToken: accessToken,
        );

        setState(() {
          _safetySettings[key] = value;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Safety setting updated'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update setting: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addEmergencyContact() async {
    final contact = _emergencyContactController.text.trim();
    if (contact.isEmpty) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = authProvider.accessToken;

      if (accessToken != null) {
        await SafetyService.addEmergencyContact(
          contact: contact,
          accessToken: accessToken,
        );

        setState(() {
          _emergencyContacts.add(contact);
        });

        _emergencyContactController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Emergency contact added'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add emergency contact: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _removeEmergencyContact(String contact) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = authProvider.accessToken;

      if (accessToken != null) {
        await SafetyService.removeEmergencyContact(
          contact: contact,
          accessToken: accessToken,
        );

        setState(() {
          _emergencyContacts.remove(contact);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Emergency contact removed'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove emergency contact: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        title: const Text('Safety Settings'),
        backgroundColor: AppColors.navbarBackground,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Privacy & Safety'),
                  _buildSafetyToggle(
                    'Share Location',
                    'Allow others to see your approximate location',
                    _safetySettings['share_location'] ?? false,
                    (value) => _updateSafetySetting('share_location', value),
                  ),
                  _buildSafetyToggle(
                    'Show Online Status',
                    'Let others know when you\'re online',
                    _safetySettings['show_online_status'] ?? true,
                    (value) => _updateSafetySetting('show_online_status', value),
                  ),
                  _buildSafetyToggle(
                    'Allow Messages from Strangers',
                    'Receive messages from people you haven\'t matched with',
                    _safetySettings['allow_stranger_messages'] ?? false,
                    (value) => _updateSafetySetting('allow_stranger_messages', value),
                  ),

                  const SizedBox(height: 32),

                  _buildSectionHeader('Blocking & Reporting'),
                  _buildActionButton(
                    'Blocked Users',
                    'Manage your blocked users list',
                    Icons.block,
                    () => _showBlockedUsers(),
                  ),
                  _buildActionButton(
                    'Report History',
                    'View your previous reports',
                    Icons.report,
                    () => _showReportHistory(),
                  ),

                  const SizedBox(height: 32),

                  _buildSectionHeader('Emergency Contacts'),
                  _buildEmergencyContactsSection(),

                  const SizedBox(height: 32),

                  _buildSectionHeader('Safety Resources'),
                  _buildSafetyResourcesSection(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: AppTypography.h4.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSafetyToggle(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.body1.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.body2.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
            inactiveThumbColor: Colors.white70,
            inactiveTrackColor: Colors.white24,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: AppTypography.body1.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTypography.body2.copyWith(
            color: Colors.white70,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: AppColors.navbarBackground,
      ),
    );
  }

  Widget _buildEmergencyContactsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Emergency Contacts',
            style: AppTypography.body1.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add trusted contacts who can be notified in case of emergency',
            style: AppTypography.body2.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          
          // Add contact input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _emergencyContactController,
                  style: AppTypography.body1.copyWith(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter phone number or email',
                    hintStyle: AppTypography.body1.copyWith(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _addEmergencyContact,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Text('Add'),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Emergency contacts list
          if (_emergencyContacts.isNotEmpty) ...[
            Text(
              'Your Emergency Contacts:',
              style: AppTypography.body2.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ..._emergencyContacts.map((contact) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.contact_phone, color: Colors.white70, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      contact,
                      style: AppTypography.body2.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () => _removeEmergencyContact(contact),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildSafetyResourcesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Safety Resources',
            style: AppTypography.body1.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildResourceButton(
            'Safety Tips',
            'Learn how to stay safe while dating',
            Icons.tips_and_updates,
            () => _showSafetyTips(),
          ),
          _buildResourceButton(
            'Report Inappropriate Behavior',
            'Report users who violate our community guidelines',
            Icons.report_problem,
            () => _showReportDialog(),
          ),
          _buildResourceButton(
            'Emergency Help',
            'Get help in case of emergency',
            Icons.emergency,
            () => _showEmergencyHelp(),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceButton(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.body2.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTypography.caption.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showBlockedUsers() {
    // TODO: Navigate to blocked users screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Blocked users feature coming soon!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showReportHistory() {
    // TODO: Navigate to report history screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Report history feature coming soon!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showSafetyTips() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          'Safety Tips',
          style: AppTypography.h4.copyWith(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTipItem('1. Meet in Public Places', 'Always meet in public, well-lit areas for your first few dates.'),
              _buildTipItem('2. Tell Someone', 'Let a friend or family member know where you\'re going and when you\'ll be back.'),
              _buildTipItem('3. Trust Your Instincts', 'If something feels wrong, trust your gut and leave the situation.'),
              _buildTipItem('4. Keep Personal Info Private', 'Don\'t share personal information like your address or workplace too early.'),
              _buildTipItem('5. Use Video Calls First', 'Consider video calling before meeting in person to verify the person.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: AppTypography.body1.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.body2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            description,
            style: AppTypography.body2.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          'Report Inappropriate Behavior',
          style: AppTypography.h4.copyWith(color: Colors.white),
        ),
        content: Text(
          'If someone is making you feel uncomfortable or violating our community guidelines, please report them immediately. Our safety team will review your report and take appropriate action.',
          style: AppTypography.body1.copyWith(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTypography.body1.copyWith(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to report screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Report feature coming soon!'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  void _showEmergencyHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          'Emergency Help',
          style: AppTypography.h4.copyWith(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'If you\'re in immediate danger, call emergency services:',
              style: AppTypography.body1.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: Column(
                children: [
                  const Icon(Icons.emergency, color: Colors.red, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'Emergency Services',
                    style: AppTypography.h4.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '911',
                    style: AppTypography.h2.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: AppTypography.body1.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
