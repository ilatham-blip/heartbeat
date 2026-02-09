import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const kBrandBlue = Color(0xFF1E40AF);
const kBackgroundWhite = Color(0xFFFAFAFA);

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundWhite,
      appBar: AppBar(
        title: const Text(
          "About Us",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Logo & Version Header
            _buildAppHeader(),
            const SizedBox(height: 24),

            // Development Team
            _buildSection(
              title: 'Development Team',
              icon: Icons.code,
              iconColor: kBrandBlue,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kBrandBlue.withAlpha(13),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kBrandBlue.withAlpha(51)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: kBrandBlue.withAlpha(26),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.school, color: kBrandBlue, size: 24),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Built by an undergraduate research group under Professor Richard Kitney from Imperial College London.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Legal Documents Section
            _buildSection(
              title: 'Legal',
              icon: Icons.gavel,
              iconColor: Colors.teal,
              child: Column(
                children: [
                  _buildDocumentRow(
                    context,
                    icon: Icons.privacy_tip,
                    title: 'Privacy Policy',
                    subtitle: 'How we handle your data (GDPR compliant)',
                    onTap: () => _showPrivacyPolicy(context),
                  ),
                  const Divider(height: 1),
                  _buildDocumentRow(
                    context,
                    icon: Icons.description,
                    title: 'Terms of Service',
                    subtitle: 'Rules for using HeartBIT',
                    onTap: () => _showTermsOfService(context),
                  ),
                  const Divider(height: 1),
                  _buildDocumentRow(
                    context,
                    icon: Icons.inventory_2,
                    title: 'Open Source Licenses',
                    subtitle: 'Credits for libraries we use',
                    onTap: () => _showLicenses(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Contact Support
            _buildSection(
              title: 'Support',
              icon: Icons.support_agent,
              iconColor: Colors.orange,
              child: InkWell(
                onTap: () => _sendEmail(context, 'support@heartbit.app'),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withAlpha(13),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withAlpha(51)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange.withAlpha(26),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.email, color: Colors.orange, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Contact Support',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              'support@heartbit.app',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'For technical help only, not medical advice',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward, color: Colors.orange.shade300),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Footer
            Center(
              child: Column(
                children: [
                  Icon(Icons.favorite, color: Colors.red.shade300, size: 24),
                  const SizedBox(height: 8),
                  Text(
                    'Made with care for the POTS community',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '© 2026 Imperial College London',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAppHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kBrandBlue.withAlpha(77),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.favorite,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'HeartBIT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'v1.0.2',
                style: TextStyle(
                  color: Colors.white.withAlpha(204),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.teal.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.teal, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _buildDocumentSheet(
          scrollController: scrollController,
          title: 'Privacy Policy',
          content: '''
HeartBIT Privacy Policy
Last Updated: February 2026

1. DATA WE COLLECT
• Health data: Heart rate measurements, symptom logs, lifestyle information
• Account data: Email address, profile information
• Usage data: App interactions, session logs

2. HOW WE USE YOUR DATA
• To provide the HeartBIT service
• For research purposes (anonymized)
• To improve app functionality

3. DATA STORAGE & SECURITY
• All data is encrypted in transit and at rest
• Data is stored on secure Supabase servers
• Access is restricted to authorized researchers

4. YOUR RIGHTS (GDPR)
• Access your data at any time
• Request data deletion
• Export your data
• Withdraw from the study

5. DATA SHARING
• We do not sell your data
• Anonymized data may be used in research publications
• We may share data with ethics-approved research partners

6. CONTACT
For privacy inquiries: support@heartbit.app
''',
        ),
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _buildDocumentSheet(
          scrollController: scrollController,
          title: 'Terms of Service',
          content: '''
HeartBIT Terms of Service
Last Updated: February 2026

1. ACCEPTANCE
By using HeartBIT, you agree to these terms.

2. ELIGIBILITY
• You must be 18+ or have parental consent
• You must be enrolled in an approved research study

3. PERMITTED USE
• Personal health tracking
• Participation in research
• Educational purposes

4. PROHIBITED USE
• Sharing login credentials
• Attempting to reverse engineer the app
• Using for commercial purposes

5. MEDICAL DISCLAIMER
HeartBIT is a research tool, NOT a medical device. It does not provide medical advice, diagnosis, or treatment. Always consult a healthcare professional.

6. INTELLECTUAL PROPERTY
HeartBIT and its contents are owned by Imperial College London.

7. LIMITATION OF LIABILITY
We are not liable for any damages arising from app use.

8. TERMINATION
We may terminate access for violation of these terms.

9. CONTACT
questions: support@heartbit.app
''',
        ),
      ),
    );
  }

  void _showLicenses(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: 'HeartBIT',
      applicationVersion: 'v1.0.2',
      applicationIcon: Container(
        padding: const EdgeInsets.all(16),
        child: const Icon(Icons.favorite, color: kBrandBlue, size: 48),
      ),
      applicationLegalese: '© 2026 Imperial College London',
    );
  }

  Widget _buildDocumentSheet({
    required ScrollController scrollController,
    required String title,
    required String content,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                content,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _sendEmail(BuildContext context, String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Email us at: $email')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email us at: $email')),
        );
      }
    }
  }
}