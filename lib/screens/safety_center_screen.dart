import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import 'emergency_contacts_screen.dart';

/// Safety Center Screen
/// 
/// Features:
/// - Safety tips and guidelines
/// - Reporting tools
/// - Emergency contacts access
/// - Community guidelines
/// - Safety resources
class SafetyCenterScreen extends StatefulWidget {
  const SafetyCenterScreen({Key? key}) : super(key: key);

  @override
  State<SafetyCenterScreen> createState() => _SafetyCenterScreenState();
}

class _SafetyCenterScreenState extends State<SafetyCenterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navbarBackground,
        elevation: 0,
        title: Text(
          'Safety Center',
          style: AppTypography.h4.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hero Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.3),
                  AppColors.secondary.withOpacity(0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.shield,
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Your Safety Matters',
                  style: AppTypography.h3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Find resources, tips, and tools to stay safe while using LGBTinder',
                  textAlign: TextAlign.center,
                  style: AppTypography.body2.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Quick Actions
          _buildSectionTitle('Quick Actions'),
          const SizedBox(height: 12),
          _buildQuickActionCard(
            icon: Icons.contacts,
            title: 'Emergency Contacts',
            subtitle: 'Manage your trusted contacts',
            color: Colors.red,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EmergencyContactsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildQuickActionCard(
            icon: Icons.report,
            title: 'Report & Block',
            subtitle: 'Report inappropriate behavior',
            color: Colors.orange,
            onTap: () => _showReportInfo(context),
          ),
          const SizedBox(height: 12),
          _buildQuickActionCard(
            icon: Icons.phone,
            title: 'Crisis Hotlines',
            subtitle: 'Get immediate help',
            color: Colors.purple,
            onTap: () => _showHotlines(context),
          ),

          const SizedBox(height: 24),

          // Safety Tips
          _buildSectionTitle('Safety Tips'),
          const SizedBox(height: 12),
          _buildTipCard(
            icon: Icons.person,
            title: 'Protect Your Identity',
            tips: [
              'Don\'t share personal information too quickly',
              'Use the in-app messaging until you feel comfortable',
              'Be cautious with photos that reveal your location',
              'Keep financial information private',
            ],
          ),
          const SizedBox(height: 12),
          _buildTipCard(
            icon: Icons.video_call,
            title: 'Meeting Safely',
            tips: [
              'Meet in public places for the first time',
              'Tell a friend where you\'re going',
              'Arrange your own transportation',
              'Trust your instincts - leave if uncomfortable',
            ],
          ),
          const SizedBox(height: 12),
          _buildTipCard(
            icon: Icons.lock,
            title: 'Online Safety',
            tips: [
              'Use strong, unique passwords',
              'Enable two-factor authentication',
              'Be cautious of phishing attempts',
              'Keep your app updated',
            ],
          ),
          const SizedBox(height: 12),
          _buildTipCard(
            icon: Icons.favorite,
            title: 'Consent & Respect',
            tips: [
              'Always respect boundaries',
              'Consent is ongoing - it can be withdrawn',
              'No means no, every time',
              'Report harassment immediately',
            ],
          ),

          const SizedBox(height: 24),

          // Resources
          _buildSectionTitle('Resources'),
          const SizedBox(height: 12),
          _buildResourceCard(
            title: 'Community Guidelines',
            description: 'Learn about our community standards',
            icon: Icons.policy,
            onTap: () => _openUrl('https://lgbtinder.com/guidelines'),
          ),
          const SizedBox(height: 12),
          _buildResourceCard(
            title: 'Safety Articles',
            description: 'Read more about staying safe',
            icon: Icons.article,
            onTap: () => _openUrl('https://lgbtinder.com/safety'),
          ),
          const SizedBox(height: 12),
          _buildResourceCard(
            title: 'LGBTQ+ Support Organizations',
            description: 'Find local and national resources',
            icon: Icons.support,
            onTap: () => _showSupportOrganizations(context),
          ),

          const SizedBox(height: 32),

          // Emergency Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.red.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning,
                  color: Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'If you\'re in immediate danger, call emergency services (911 in the US)',
                    style: AppTypography.caption.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: AppTypography.h5.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.navbarBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.body1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.white38,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard({
    required IconData icon,
    required String title,
    required List<String> tips,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.body1.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tip,
                        style: AppTypography.body2.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildResourceCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.navbarBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.body1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTypography.caption.copyWith(
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.open_in_new,
              color: Colors.white38,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showReportInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.navbarBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.report, color: Colors.orange, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Report & Block',
                  style: AppTypography.h4.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'How to Report Someone',
              style: AppTypography.body1.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoPoint('Tap the menu icon (⋮) on their profile'),
            _buildInfoPoint('Select "Report User"'),
            _buildInfoPoint('Choose the reason for reporting'),
            _buildInfoPoint('Provide additional details if needed'),
            const SizedBox(height: 16),
            Text(
              'When to Report',
              style: AppTypography.body1.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoPoint('Inappropriate photos or content'),
            _buildInfoPoint('Harassment or threatening behavior'),
            _buildInfoPoint('Spam or scam attempts'),
            _buildInfoPoint('Underage users'),
            _buildInfoPoint('Impersonation'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Got It',
                  style: AppTypography.button.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHotlines(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.navbarBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                children: [
                  const Icon(Icons.phone, color: Colors.purple, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Crisis Hotlines',
                    style: AppTypography.h4.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildHotlineCard(
                name: 'National Suicide Prevention Lifeline',
                number: '988',
                description: '24/7 crisis support',
              ),
              _buildHotlineCard(
                name: 'The Trevor Project',
                number: '1-866-488-7386',
                description: 'Crisis support for LGBTQ+ youth',
              ),
              _buildHotlineCard(
                name: 'Trans Lifeline',
                number: '1-877-565-8860',
                description: 'Support for transgender community',
              ),
              _buildHotlineCard(
                name: 'GLBT National Hotline',
                number: '1-888-843-4564',
                description: 'Peer support and resources',
              ),
              _buildHotlineCard(
                name: 'National Domestic Violence Hotline',
                number: '1-800-799-7233',
                description: '24/7 support for domestic violence',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.purple.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.purple,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'These hotlines provide confidential support 24/7',
                        style: AppTypography.caption.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSupportOrganizations(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.navbarBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                children: [
                  const Icon(Icons.support, color: AppColors.primary, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'LGBTQ+ Support Organizations',
                    style: AppTypography.h4.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildOrganizationCard(
                name: 'Human Rights Campaign',
                description:
                    'America\'s largest civil rights organization working for LGBTQ+ equality',
                website: 'https://www.hrc.org',
              ),
              _buildOrganizationCard(
                name: 'GLAAD',
                description:
                    'Working to accelerate acceptance for the LGBTQ+ community',
                website: 'https://www.glaad.org',
              ),
              _buildOrganizationCard(
                name: 'PFLAG',
                description:
                    'Supporting, educating, and advocating for LGBTQ+ people and their families',
                website: 'https://www.pflag.org',
              ),
              _buildOrganizationCard(
                name: 'The Trevor Project',
                description:
                    'Leading national organization providing crisis intervention for LGBTQ+ youth',
                website: 'https://www.thetrevorproject.org',
              ),
              _buildOrganizationCard(
                name: 'GLSEN',
                description:
                    'Working to create safe and inclusive schools for LGBTQ+ students',
                website: 'https://www.glsen.org',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTypography.body2.copyWith(
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotlineCard({
    required String name,
    required String number,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: AppTypography.body1.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _makePhoneCall(number),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.phone, color: Colors.purple, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    number,
                    style: AppTypography.body1.copyWith(
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTypography.caption.copyWith(
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizationCard({
    required String name,
    required String description,
    required String website,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: AppTypography.body1.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTypography.body2.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _openUrl(website),
            child: Row(
              children: [
                const Icon(Icons.open_in_new,
                    color: AppColors.primary, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Visit Website',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}


