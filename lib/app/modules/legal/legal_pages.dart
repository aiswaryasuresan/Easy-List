import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme/app_theme.dart';

void showAppAboutDialog(BuildContext context) {
  final t = AppTokens.of(context);
  Get.dialog(
    AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      icon: CircleAvatar(
        backgroundColor: t.lightSage,
        child: Icon(Icons.shopping_basket_outlined, color: t.primaryDark),
      ),
      title: const Text(
        'Shopping List',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
      ),
      content: const Text(
        'Remember. Add. Buy. Done.\n\n'
        'A minimal offline shopping list. '
        'Your items stay on this device.',
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

class LegalSection {
  final String heading;
  final String body;

  const LegalSection(this.heading, this.body);
}

class LegalPage extends StatelessWidget {
  final String title;
  final String intro;
  final List<LegalSection> sections;

  const LegalPage({
    super.key,
    required this.title,
    required this.intro,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        backgroundColor: t.background,
        foregroundColor: t.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 4,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Text(
            'Last updated: October 2026',
            style: TextStyle(fontSize: 12.5, color: t.textSecondary),
          ),
          const SizedBox(height: 12),
          _LegalCard(child: Text(intro, style: _bodyStyle(t))),
          for (final s in sections)
            _LegalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.heading,
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      color: t.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(s.body, style: _bodyStyle(t)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  TextStyle _bodyStyle(AppTokens t) => TextStyle(
        fontSize: 14,
        height: 1.5,
        color: t.textSecondary,
      );
}

class _LegalCard extends StatelessWidget {
  final Widget child;

  const _LegalCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.divider),
      ),
      child: child,
    );
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalPage(
      title: 'Privacy Policy',
      intro:
          'Shopping List is a fully offline app. This policy explains what '
          'the app stores and, more importantly, what it never collects.',
      sections: const [
        LegalSection(
          'Data we store',
          'Everything you create stays on your device: item names, optional '
              'quantities and units, purchased status, your autocomplete '
              'history, theme preference and the haptics setting. This data '
              'is saved in the app\'s private storage inside the Android app '
              'sandbox.',
        ),
        LegalSection(
          'Data we do not collect',
          'The app has no account or sign-up. We do not collect your name, '
              'email, phone number, contacts, location, photos or any other '
              'personal information. There are no ads, no analytics and no '
              'tracking of any kind.',
        ),
        LegalSection(
          'Network access',
          'Shopping List works completely offline. It does not send your '
              'data anywhere, and nothing is uploaded to a server or shared '
              'with third parties.',
        ),
        LegalSection(
          'Data deletion',
          'You can delete individual items, clear purchased items, or remove '
              'all data at any time by uninstalling the app or clearing its '
              'storage in Android system settings. Autocomplete suggestions '
              'are stored locally with the same mechanism and are removed '
              'the same way.',
        ),
        LegalSection(
          'Backups',
          'If Android\'s own device backup is enabled on your phone, the app '
              'data may be included in that backup. That backup is controlled '
              'by you and your device manufacturer, not by us.',
        ),
        LegalSection(
          'Children',
          'Because the app collects no personal data and has no internet '
              'features, it is safe for users of all ages.',
        ),
        LegalSection(
          'Changes to this policy',
          'If this policy changes in a future update, the revised version '
              'will ship with the app update and the date above will change.',
        ),
      ],
    );
  }
}

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalPage(
      title: 'Terms & Conditions',
      intro:
          'By installing and using Shopping List you agree to these terms. '
          'They are written to be as short and plain as possible.',
      sections: const [
        LegalSection(
          'What the app does',
          'Shopping List lets you keep a simple list of items to buy, with '
              'optional quantity and unit, purchased status, filters and '
              'name suggestions. All processing happens on your device.',
        ),
        LegalSection(
          'Your data and responsibility',
          'Your list is stored only on this device. There is no cloud sync, '
              'so if you lose the device, reset it, or clear the app storage, '
              'your list cannot be recovered from us. Please keep any '
              'important lists backed up yourself through your device '
              'settings.',
        ),
        LegalSection(
          'No warranty',
          'The app is provided "as is", without warranty of any kind. We do '
              'not guarantee that it will be error-free or uninterrupted. '
              'Use of the app is at your own risk.',
        ),
        LegalSection(
          'Acceptable use',
          'You may use the app for your personal shopping needs. Do not use '
              'it for unlawful purposes, and do not attempt to modify, '
              'reverse-engineer or redistribute the app without permission.',
        ),
        LegalSection(
          'Intellectual property',
          'The app name, interface design and bundled illustrations belong '
              'to the developer. The grocery names and suggestions are '
              'generic product terms and are not affiliated with any brand.',
        ),
        LegalSection(
          'Changes and termination',
          'These terms may be updated with future releases. You can end this '
              'agreement at any time simply by uninstalling the app.',
        ),
      ],
    );
  }
}
