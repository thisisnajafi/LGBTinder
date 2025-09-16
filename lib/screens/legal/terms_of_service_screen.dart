import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        title: const Text('Terms of Service'),
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
              title: '1. Acceptance of Terms',
              content: '''
By accessing and using LGBTinder ("the App"), you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by the above, please do not use this service.
              ''',
            ),
            _buildSection(
              title: '2. Description of Service',
              content: '''
LGBTinder is a dating and social networking application designed for the LGBTQ+ community. The App provides features including but not limited to:
• User profile creation and management
• Matching and discovery features
• Messaging and communication tools
• Social features including stories and feeds
• Video and voice calling capabilities
• Premium subscription services
              ''',
            ),
            _buildSection(
              title: '3. User Eligibility',
              content: '''
You must be at least 18 years old to use this App. By using LGBTinder, you represent and warrant that:
• You are at least 18 years of age
• You have the legal capacity to enter into this agreement
• You are not prohibited from using the App under applicable law
• You will provide accurate and truthful information
              ''',
            ),
            _buildSection(
              title: '4. User Accounts and Registration',
              content: '''
To access certain features of the App, you must register for an account. You agree to:
• Provide accurate, current, and complete information
• Maintain and update your information to keep it accurate
• Maintain the security of your password and account
• Accept responsibility for all activities under your account
• Notify us immediately of any unauthorized use of your account
              ''',
            ),
            _buildSection(
              title: '5. User Conduct and Prohibited Activities',
              content: '''
You agree not to use the App to:
• Harass, abuse, or harm other users
• Post false, misleading, or deceptive content
• Impersonate another person or entity
• Share inappropriate, offensive, or illegal content
• Violate any applicable laws or regulations
• Attempt to gain unauthorized access to the App
• Use automated systems to access the App
• Engage in commercial activities without permission
              ''',
            ),
            _buildSection(
              title: '6. Privacy and Data Protection',
              content: '''
Your privacy is important to us. Our Privacy Policy explains how we collect, use, and protect your information when you use our App. By using LGBTinder, you agree to the collection and use of information in accordance with our Privacy Policy.
              ''',
            ),
            _buildSection(
              title: '7. Premium Services and Payments',
              content: '''
LGBTinder offers premium subscription services. By subscribing to premium services, you agree to:
• Pay all applicable fees and charges
• Automatic renewal of subscriptions unless cancelled
• No refunds for unused portions of subscriptions
• Changes to pricing with 30 days notice
• Compliance with payment terms and conditions
              ''',
            ),
            _buildSection(
              title: '8. Intellectual Property Rights',
              content: '''
The App and its original content, features, and functionality are owned by LGBTinder and are protected by international copyright, trademark, patent, trade secret, and other intellectual property laws. You may not reproduce, distribute, modify, or create derivative works without our written permission.
              ''',
            ),
            _buildSection(
              title: '9. Termination',
              content: '''
We may terminate or suspend your account and access to the App immediately, without prior notice, for any reason, including if you breach these Terms. Upon termination, your right to use the App will cease immediately.
              ''',
            ),
            _buildSection(
              title: '10. Disclaimers and Limitation of Liability',
              content: '''
THE APP IS PROVIDED "AS IS" WITHOUT WARRANTIES OF ANY KIND. WE DISCLAIM ALL WARRANTIES, EXPRESS OR IMPLIED. IN NO EVENT SHALL LGBTINDER BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, OR CONSEQUENTIAL DAMAGES ARISING OUT OF YOUR USE OF THE APP.
              ''',
            ),
            _buildSection(
              title: '11. Safety and Reporting',
              content: '''
LGBTinder is committed to creating a safe environment for all users. We provide tools to report inappropriate behavior and content. We reserve the right to investigate and take appropriate action against users who violate our community guidelines.
              ''',
            ),
            _buildSection(
              title: '12. Changes to Terms',
              content: '''
We reserve the right to modify these Terms at any time. We will notify users of any material changes via the App or email. Your continued use of the App after such modifications constitutes acceptance of the updated Terms.
              ''',
            ),
            _buildSection(
              title: '13. Governing Law',
              content: '''
These Terms shall be governed by and construed in accordance with the laws of [Your Jurisdiction], without regard to its conflict of law provisions. Any disputes arising from these Terms shall be resolved in the courts of [Your Jurisdiction].
              ''',
            ),
            _buildSection(
              title: '14. Contact Information',
              content: '''
If you have any questions about these Terms of Service, please contact us at:
• Email: legal@lgbtinder.com
• Address: [Your Company Address]
• Phone: [Your Phone Number]
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
            Icons.description,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'Terms of Service',
            style: AppTypography.h3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please read these terms carefully before using LGBTinder',
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
            Icons.info_outline,
            color: AppColors.primary,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            'Important Notice',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'By using LGBTinder, you acknowledge that you have read, understood, and agree to be bound by these Terms of Service.',
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
