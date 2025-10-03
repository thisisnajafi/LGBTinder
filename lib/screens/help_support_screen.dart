import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final List<Map<String, dynamic>> _faqItems = [
    {
      'question': 'How do I create an account?',
      'answer': 'To create an account, tap "Create Account" on the welcome screen, enter your email and password, then verify your email address.',
    },
    {
      'question': 'How do I complete my profile?',
      'answer': 'After email verification, you\'ll be guided through a profile completion wizard where you can add photos, personal information, and preferences.',
    },
    {
      'question': 'How do I find matches?',
      'answer': 'Use the Discovery page to swipe through potential matches. Swipe right to like, left to pass, and up for super like.',
    },
    {
      'question': 'How do I start a conversation?',
      'answer': 'Once you match with someone, you can start chatting by tapping on their profile in your matches list.',
    },
    {
      'question': 'How do I report someone?',
      'answer': 'Go to their profile, tap the three dots menu, and select "Report User". You can also block them from the same menu.',
    },
    {
      'question': 'How do I change my privacy settings?',
      'answer': 'Go to Settings > Privacy Settings to control who can see your profile, location, and contact you.',
    },
    {
      'question': 'How do I delete my account?',
      'answer': 'Go to Settings > Account Actions > Delete Account. This action is permanent and cannot be undone.',
    },
    {
      'question': 'How do I get verified?',
      'answer': 'Complete your profile with accurate information and add multiple photos. Verification helps build trust in the community.',
    },
  ];

  final List<Map<String, dynamic>> _contactOptions = [
    {
      'title': 'Email Support',
      'subtitle': 'Get help via email',
      'icon': Icons.email,
      'action': 'support@lgbtinder.com',
    },
    {
      'title': 'Live Chat',
      'subtitle': 'Chat with our support team',
      'icon': Icons.chat,
      'action': 'Start Chat',
    },
    {
      'title': 'Phone Support',
      'subtitle': 'Call us for urgent issues',
      'icon': Icons.phone,
      'action': '+1 (555) 123-4567',
    },
    {
      'title': 'Community Forum',
      'subtitle': 'Get help from other users',
      'icon': Icons.forum,
      'action': 'Visit Forum',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: AppColors.navbarBackground,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            const SizedBox(height: 24),
            _buildQuickActionsSection(),
            const SizedBox(height: 24),
            _buildFAQSection(),
            const SizedBox(height: 24),
            _buildContactSection(),
            const SizedBox(height: 24),
            _buildSafetySection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.help_outline,
                color: AppColors.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'How can we help you?',
                style: AppTypography.h4.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'We\'re here to help you have the best experience on LGBTinder. Find answers to common questions or contact our support team.',
            style: AppTypography.body1.copyWith(
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTypography.titleSmallStyle.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                'Report User',
                Icons.report_problem,
                Colors.red,
                () => _showReportDialog(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                'Block User',
                Icons.block,
                Colors.orange,
                () => _showBlockDialog(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                'Safety Tips',
                Icons.security,
                Colors.green,
                () => _showSafetyTips(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                'Emergency Help',
                Icons.emergency,
                Colors.red,
                () => _showEmergencyHelp(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.navbarBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTypography.body2.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequently Asked Questions',
          style: AppTypography.titleSmallStyle.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.navbarBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            children: _faqItems.map((item) => _buildFAQItem(item)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFAQItem(Map<String, dynamic> item) {
    return ExpansionTile(
      title: Text(
        item['question'],
        style: AppTypography.body1.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            item['answer'],
            style: AppTypography.body2.copyWith(
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ),
      ],
      iconColor: AppColors.primary,
      collapsedIconColor: Colors.white54,
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Support',
          style: AppTypography.titleSmallStyle.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.navbarBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            children: _contactOptions.map((option) => _buildContactOption(option)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildContactOption(Map<String, dynamic> option) {
    return InkWell(
      onTap: () => _handleContactAction(option),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                option['icon'],
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option['title'],
                    style: AppTypography.body1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    option['subtitle'],
                    style: AppTypography.body2.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              option['action'],
              style: AppTypography.body2.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: Colors.white54,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.security,
                color: Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Safety First',
                style: AppTypography.body1.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'If you feel unsafe or need immediate help, contact local authorities or use our emergency resources.',
            style: AppTypography.body2.copyWith(
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _launchEmergencyNumber(),
                  icon: const Icon(Icons.phone, size: 16),
                  label: const Text('Emergency'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    backgroundColor: Colors.red.withOpacity(0.1),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _showSafetyResources(),
                  icon: const Icon(Icons.info, size: 16),
                  label: const Text('Resources'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    backgroundColor: Colors.red.withOpacity(0.1),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleContactAction(Map<String, dynamic> option) {
    switch (option['title']) {
      case 'Email Support':
        _launchEmail(option['action']);
        break;
      case 'Live Chat':
        _showLiveChatDialog();
        break;
      case 'Phone Support':
        _launchPhone(option['action']);
        break;
      case 'Community Forum':
        _showForumDialog();
        break;
    }
  }

  void _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=LGBTinder Support Request',
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      _showErrorSnackBar('Could not open email client');
    }
  }

  void _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      _showErrorSnackBar('Could not open phone dialer');
    }
  }

  void _launchEmergencyNumber() async {
    final Uri emergencyUri = Uri(scheme: 'tel', path: '911');
    
    if (await canLaunchUrl(emergencyUri)) {
      await launchUrl(emergencyUri);
    } else {
      _showErrorSnackBar('Could not open phone dialer');
    }
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          'Report User',
          style: AppTypography.h4.copyWith(color: Colors.white),
        ),
        content: Text(
          'To report a user, go to their profile and tap the three dots menu, then select "Report User". You can also block them from the same menu.',
          style: AppTypography.body1.copyWith(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: AppTypography.body1.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          'Block User',
          style: AppTypography.h4.copyWith(color: Colors.white),
        ),
        content: Text(
          'To block a user, go to their profile and tap the three dots menu, then select "Block User". Blocked users cannot contact you or see your profile.',
          style: AppTypography.body1.copyWith(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: AppTypography.body1.copyWith(color: AppColors.primary),
            ),
          ),
        ],
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
          child: Text(
            '• Meet in public places for first dates\n'
            '• Tell a friend or family member about your plans\n'
            '• Trust your instincts - if something feels wrong, leave\n'
            '• Don\'t share personal information too quickly\n'
            '• Use the app\'s messaging system before sharing phone numbers\n'
            '• Report any suspicious behavior immediately\n'
            '• Never send money to someone you haven\'t met\n'
            '• Be cautious of users who avoid meeting in person',
            style: AppTypography.body1.copyWith(color: Colors.white70),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: AppTypography.body1.copyWith(color: AppColors.primary),
            ),
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
          style: AppTypography.h4.copyWith(color: Colors.red),
        ),
        content: Text(
          'If you are in immediate danger, call 911 or your local emergency number. For non-emergency support, contact our safety team.',
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
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _launchEmergencyNumber();
            },
            child: Text(
              'Call 911',
              style: AppTypography.body1.copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showLiveChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          'Live Chat',
          style: AppTypography.h4.copyWith(color: Colors.white),
        ),
        content: Text(
          'Live chat is available Monday-Friday, 9 AM - 6 PM EST. Our support team will respond within 5 minutes during business hours.',
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
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement live chat functionality
              _showInfoSnackBar('Live chat coming soon!');
            },
            child: Text(
              'Start Chat',
              style: AppTypography.body1.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showForumDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          'Community Forum',
          style: AppTypography.h4.copyWith(color: Colors.white),
        ),
        content: Text(
          'Join our community forum to get help from other users, share tips, and connect with the LGBTinder community.',
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
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement forum navigation
              _showInfoSnackBar('Community forum coming soon!');
            },
            child: Text(
              'Visit Forum',
              style: AppTypography.body1.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showSafetyResources() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          'Safety Resources',
          style: AppTypography.h4.copyWith(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'National Resources:',
                style: AppTypography.body1.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• National Domestic Violence Hotline: 1-800-799-7233\n'
                '• National Suicide Prevention Lifeline: 988\n'
                '• LGBT National Help Center: 1-888-843-4564\n'
                '• Trans Lifeline: 1-877-565-8860',
                style: AppTypography.body2.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              Text(
                'Online Safety:',
                style: AppTypography.body1.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• Use strong, unique passwords\n'
                '• Enable two-factor authentication\n'
                '• Be cautious of phishing attempts\n'
                '• Report suspicious activity immediately',
                style: AppTypography.body2.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: AppTypography.body1.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
