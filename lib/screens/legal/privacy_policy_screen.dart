import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: AppColors.navbarBackground,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildLastUpdated(),
            const SizedBox(height: 24),
            _buildSection(
              title: '1. Introduction',
              content: '''
At LGBTinder, we are committed to protecting your privacy and ensuring the security of your personal information. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our dating and social networking application.
              ''',
            ),
            _buildSection(
              title: '2. Information We Collect',
              content: '''
We collect information you provide directly to us, such as when you create an account, update your profile, or communicate with other users:

Personal Information:
• Name, email address, phone number
• Date of birth and gender identity
• Profile photos and videos
• Bio, interests, and preferences
• Location data (with your consent)

Usage Information:
• App usage patterns and interactions
• Messages and communications
• Photos and videos shared
• Device information and identifiers
• Log data and analytics
              ''',
            ),
            _buildSection(
              title: '3. How We Use Your Information',
              content: '''
We use the information we collect to:
• Provide and improve our services
• Create and maintain your account
• Facilitate matches and connections
• Enable messaging and communication features
• Provide customer support
• Send important updates and notifications
• Ensure safety and prevent abuse
• Analyze usage patterns and improve user experience
• Comply with legal obligations
              ''',
            ),
            _buildSection(
              title: '4. Information Sharing and Disclosure',
              content: '''
We may share your information in the following circumstances:

With Other Users:
• Profile information visible to potential matches
• Messages sent to other users
• Photos and content you choose to share

With Service Providers:
• Third-party services that help us operate the App
• Payment processors for subscription services
• Analytics and advertising partners (anonymized data)

Legal Requirements:
• When required by law or legal process
• To protect our rights and safety
• To prevent fraud or abuse
• In case of emergency or safety concerns
              ''',
            ),
            _buildSection(
              title: '5. Data Security',
              content: '''
We implement appropriate security measures to protect your information:
• Encryption of data in transit and at rest
• Secure authentication and access controls
• Regular security audits and updates
• Employee training on data protection
• Incident response procedures

However, no method of transmission over the internet is 100% secure, and we cannot guarantee absolute security.
              ''',
            ),
            _buildSection(
              title: '6. Your Privacy Rights',
              content: '''
You have the following rights regarding your personal information:

Access and Portability:
• Request a copy of your personal data
• Export your data in a portable format

Correction and Updates:
• Update your profile information
• Correct inaccurate data

Deletion:
• Delete your account and associated data
• Request deletion of specific information

Control and Preferences:
• Manage privacy settings
• Control who can see your information
• Opt out of certain data uses

Communication Preferences:
• Manage notification settings
• Unsubscribe from marketing communications
              ''',
            ),
            _buildSection(
              title: '7. Location Data',
              content: '''
We collect location data to provide location-based matching features:
• Precise location (with your explicit consent)
• Approximate location for matching
• Location history for safety features

You can control location sharing in your device settings and app preferences. Location data is encrypted and stored securely.
              ''',
            ),
            _buildSection(
              title: '8. Cookies and Tracking',
              content: '''
We use cookies and similar technologies to:
• Remember your preferences and settings
• Analyze app usage and performance
• Provide personalized content and features
• Ensure security and prevent fraud

You can control cookie settings through your device or browser preferences.
              ''',
            ),
            _buildSection(
              title: '9. Third-Party Services',
              content: '''
Our App may integrate with third-party services:
• Social media platforms (for social login)
• Payment processors (for subscriptions)
• Analytics services (for app improvement)
• Cloud storage providers (for data backup)

These services have their own privacy policies, and we encourage you to review them.
              ''',
            ),
            _buildSection(
              title: '10. Data Retention',
              content: '''
We retain your information for as long as necessary to:
• Provide our services to you
• Comply with legal obligations
• Resolve disputes and enforce agreements
• Maintain safety and security

When you delete your account, we will delete your personal information within 30 days, except where we are required to retain it for legal or safety reasons.
              ''',
            ),
            _buildSection(
              title: '11. International Data Transfers',
              content: '''
Your information may be transferred to and processed in countries other than your own. We ensure appropriate safeguards are in place for international transfers, including:
• Standard contractual clauses
• Adequacy decisions
• Other appropriate legal mechanisms
              ''',
            ),
            _buildSection(
              title: '12. Children\'s Privacy',
              content: '''
LGBTinder is not intended for users under 18 years of age. We do not knowingly collect personal information from children under 18. If we become aware that we have collected information from a child under 18, we will take steps to delete such information.
              ''',
            ),
            _buildSection(
              title: '13. Changes to This Policy',
              content: '''
We may update this Privacy Policy from time to time. We will notify you of any material changes by:
• Posting the updated policy in the App
• Sending you an email notification
• Displaying a prominent notice in the App

Your continued use of the App after changes become effective constitutes acceptance of the updated policy.
              ''',
            ),
            _buildSection(
              title: '14. Contact Us',
              content: '''
If you have any questions about this Privacy Policy or our privacy practices, please contact us:

• Email: privacy@lgbtinder.com
• Address: [Your Company Address]
• Phone: [Your Phone Number]
• Data Protection Officer: dpo@lgbtinder.com

We will respond to your inquiry within 30 days.
              ''',
            ),
            const SizedBox(height: 40),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.privacy_tip,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'Privacy Policy',
            style: AppTypography.h3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your privacy and data protection are our top priorities',
            style: AppTypography.body1.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLastUpdated() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Icon(
            Icons.update,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            'Last updated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
            style: AppTypography.body2.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content.trim(),
            style: AppTypography.body1.copyWith(
              color: Colors.white70,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Icon(
            Icons.security,
            color: AppColors.primary,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            'Your Privacy Matters',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We are committed to protecting your privacy and ensuring the security of your personal information. If you have any concerns or questions, please don\'t hesitate to contact us.',
            style: AppTypography.body1.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
