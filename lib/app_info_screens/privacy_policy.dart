import 'package:cricverse/ads/inline_adaptive.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40,),
                _buildHeading('Privacy Policy for CricVerse'),
                // _buildSubheading('Last Updated: []'),
                _buildSection(
                  '1. Introduction',
                  'Welcome to CricVerse ("we," "our," or "us"). We are committed to protecting your privacy and providing transparency about how your personal information is collected and used. This Privacy Policy outlines the types of data we collect, how we use it, and your choices regarding your data.',
                ),
                _buildSection(
                    '2. Information We Collect',
                    [
                      _buildSubsection(
                        'a. Personal Information',
                        'We may collect the following personal information:',
                        [
                          'Device Information: We collect device-specific information, including the device model, operating system version, unique device identifiers, and IP address.',
                          'Usage Information: We collect information about how you interact with our app, such as the pages you visit, actions you take, and the dates and times of your interactions.',
                          'Location Information: With your consent, we may collect location data to provide location-based services.',
                          'Cookies and Similar Technologies: We may use cookies and similar technologies to collect data about your device and usage patterns.',
                        ],
                      ),
                      _buildSubsection(
                        'b. Firebase Analytics',
                        'We use Firebase Analytics, a service provided by Google, to collect and analyze app usage data. Firebase Analytics may collect information such as:',
                        [
                          'App screens viewed',
                          'User interactions within the app',
                          'Device and app performance data',
                        ],
                      ),
                    ]
                  // 'For more information on how Google collects and processes data, refer to Google\'s Privacy Policy.',
                ),
                _buildSection(
                    '3. Advertising',
                    [
                      _buildSubsection(
                        'a. Google Ads',
                        'Our app may display Google Ads. Google uses cookies to serve ads based on your prior visits to our app and other websites. You can opt out of personalized advertising by visiting Google\'s Ads Settings.',
                        [],
                      ),
                      _buildSubsection(
                        'b. Third-Party Ads',
                        'Our app may also display ads from third-party ad networks. These networks may collect and use information about your visits to our app and other websites for targeted advertising. Please review the privacy policies of these third-party networks for more information.',
                        [],
                      ),
                    ]
                ),

                _buildSection(
                  '4. Data Retention',
                  'We retain your personal information for as long as necessary to fulfill the purposes outlined in this Privacy Policy or as required by law.',
                ),

                _buildSection(
                    '5. Your Choices',
                    [
                      _buildSubsection(
                        'a. Opt-Out of Personalized Ads',
                        'You can opt out of personalized ads by adjusting your device settings or using opt-out mechanisms provided by ad networks.',
                        [],
                      ),
                      _buildSubsection(
                        'b. Access and Delete Data',
                        'You may request access to or deletion of your personal information by contacting us at [Your Contact Information].',
                        [],
                      ),
                    ]
                ),

                _buildSection(
                  '6. Security',
                  'We take reasonable measures to protect your personal information. However, no method of data transmission or storage is 100% secure. We cannot guarantee the security of your information.',
                ),

                _buildSection(
                  '7. Changes to this Privacy Policy',
                  'We may update this Privacy Policy from time to time to reflect changes in our practices or for legal reasons. We will notify you of any significant changes by posting the updated Privacy Policy in our app.',
                ),

                _buildSection(
                  '8. Contact Us',
                  'If you have any questions or concerns about this Privacy Policy or our data practices, please contact us at [Your Contact Information].',
                ),
              ],
            ),
          ),
          const Positioned(
            bottom: 5,
            child: BannerAdWidget(),
          )
        ],
      ),
    );
  }

  Widget _buildHeading(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
        color: Colors.white70
      ),
    );
  }

  Widget _buildSubheading(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 14.0,
        fontWeight: FontWeight.bold,
        color: Colors.white70
      ),
    );
  }

  Widget _buildSection(String title, dynamic content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeading(title),
        const SizedBox(height: 8.0),
        content is String
            ? _buildParagraph(content)
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: content,
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Widget _buildSubsection(String title, String introduction, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubheading(title),
        const SizedBox(height: 8.0),
        _buildParagraph(introduction),
        const SizedBox(height: 4.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items.map((item) => _buildBulletPoint(item)).toList(),
        ),
      ],
    );
  }

  Widget _buildParagraph(String text) {
    return Text(text, style: GoogleFonts.poppins(color: Colors.white70),);
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.format_list_bulleted,
            size: 14.0,
            color: Colors.white70,
          ),
          const SizedBox(width: 8.0),
          Expanded(child: Text(text, style: GoogleFonts.poppins(color: Colors.white70),)),
        ],
      ),
    );
  }
}
