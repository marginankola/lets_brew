import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lets_brew/constants/theme_constants.dart';

class FirebaseSetupGuide extends StatelessWidget {
  const FirebaseSetupGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.darkBackground,
      appBar: AppBar(
        title: const Text('Firebase Setup Guide'),
        backgroundColor: ThemeConstants.darkBackground,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),

            // Step 1: Create Firebase Account and Project
            _buildSection(
              title: '1. Create Firebase Project',
              content: [
                _buildStep(
                  1,
                  'Go to firebase.google.com and sign in with your Google account',
                ),
                _buildStep(2, 'Click "Add project" and name it "LetsBrewApp"'),
                _buildStep(3, 'Enable Google Analytics if desired'),
                _buildStep(
                  4,
                  'Click "Create project" and wait for it to be ready',
                ),
              ],
            ),

            // Step 2: Add Android App
            _buildSection(
              title: '2. Add Android App',
              content: [
                _buildStep(
                  1,
                  'In the Firebase console, click the Android icon to add an Android app',
                ),
                _buildStep(
                  2,
                  'Enter package name "com.example.lets_brew" (as in your AndroidManifest.xml)',
                ),
                _buildStep(
                  3,
                  'Enter a nickname (optional) like "Let\'s Brew Android"',
                ),
                _buildStep(4, 'Download the google-services.json file'),
                _buildStep(
                  5,
                  'Place the file in the android/app directory of your Flutter project',
                ),
              ],
            ),

            // Step 3: Add iOS App
            _buildSection(
              title: '3. Add iOS App',
              content: [
                _buildStep(
                  1,
                  'In the Firebase console, click the iOS icon to add an iOS app',
                ),
                _buildStep(
                  2,
                  'Enter bundle ID from your Info.plist (e.g., "com.example.letsBrew")',
                ),
                _buildStep(
                  3,
                  'Enter a nickname (optional) like "Let\'s Brew iOS"',
                ),
                _buildStep(4, 'Download the GoogleService-Info.plist file'),
                _buildStep(5, 'Add the file to your iOS app using Xcode'),
              ],
            ),

            // Step 4: Add Web App
            _buildSection(
              title: '4. Add Web App',
              content: [
                _buildStep(
                  1,
                  'In the Firebase console, click the Web icon (</>)',
                ),
                _buildStep(2, 'Register app with nickname "Let\'s Brew Web"'),
                _buildStep(3, 'Copy the Firebase configuration object'),
              ],
            ),

            // Web Config Display
            _buildCodeSection(
              title: 'Web Firebase Config',
              code:
                  'await Firebase.initializeApp(\n'
                  '  options: FirebaseOptions(\n'
                  '    apiKey: "YOUR_API_KEY",\n'
                  '    appId: "YOUR_APP_ID",\n'
                  '    messagingSenderId: "YOUR_SENDER_ID",\n'
                  '    projectId: "YOUR_PROJECT_ID",\n'
                  '    authDomain: "YOUR_AUTH_DOMAIN",\n'
                  '    storageBucket: "YOUR_STORAGE_BUCKET",\n'
                  '  ),\n'
                  ');',
              onCopy: () {
                Clipboard.setData(
                  const ClipboardData(
                    text:
                        'await Firebase.initializeApp(\n'
                        '  options: FirebaseOptions(\n'
                        '    apiKey: "YOUR_API_KEY",\n'
                        '    appId: "YOUR_APP_ID",\n'
                        '    messagingSenderId: "YOUR_SENDER_ID",\n'
                        '    projectId: "YOUR_PROJECT_ID",\n'
                        '    authDomain: "YOUR_AUTH_DOMAIN",\n'
                        '    storageBucket: "YOUR_STORAGE_BUCKET",\n'
                        '  ),\n'
                        ');',
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Firebase config copied to clipboard'),
                  ),
                );
              },
            ),

            // Step 5: Set Up Authentication
            _buildSection(
              title: '5. Set Up Authentication',
              content: [
                _buildStep(1, 'Go to Authentication in the Firebase console'),
                _buildStep(
                  2,
                  'Click "Get started" and enable Email/Password, Google, and Apple providers',
                ),
                _buildStep(
                  3,
                  'For Google Auth, follow the steps to configure your OAuth consent screen',
                ),
                _buildStep(
                  4,
                  'For Apple Auth, follow the steps to set up Sign in with Apple',
                ),
              ],
            ),

            // Step 6: Set Up Firestore Database
            _buildSection(
              title: '6. Set Up Firestore Database',
              content: [
                _buildStep(
                  1,
                  'Go to Firestore Database in the Firebase console',
                ),
                _buildStep(2, 'Click "Create database" and start in test mode'),
                _buildStep(3, 'Choose a location closest to your users'),
                _buildStep(4, 'Create collections: "users" and "coffees"'),
              ],
            ),

            // Setup Firestore Rules
            _buildCodeSection(
              title: 'Firestore Security Rules',
              code:
                  'rules_version = \'2\';\n'
                  'service cloud.firestore {\n'
                  '  match /databases/{database}/documents {\n'
                  '    match /users/{userId} {\n'
                  '      allow read: if request.auth != null;\n'
                  '      allow write: if request.auth != null && request.auth.uid == userId ||\n'
                  '                     get(/databases/{database}/documents/users/{request.auth.uid}).data.isAdmin == true;\n'
                  '    }\n'
                  '    match /coffees/{coffeeId} {\n'
                  '      allow read: if true;\n'
                  '      allow write: if request.auth != null && \n'
                  '                     get(/databases/{database}/documents/users/{request.auth.uid}).data.isAdmin == true;\n'
                  '    }\n'
                  '  }\n'
                  '}',
              onCopy: () {
                Clipboard.setData(
                  const ClipboardData(
                    text:
                        'rules_version = \'2\';\n'
                        'service cloud.firestore {\n'
                        '  match /databases/{database}/documents {\n'
                        '    match /users/{userId} {\n'
                        '      allow read: if request.auth != null;\n'
                        '      allow write: if request.auth != null && request.auth.uid == userId ||\n'
                        '                     get(/databases/{database}/documents/users/{request.auth.uid}).data.isAdmin == true;\n'
                        '    }\n'
                        '    match /coffees/{coffeeId} {\n'
                        '      allow read: if true;\n'
                        '      allow write: if request.auth != null && \n'
                        '                     get(/databases/{database}/documents/users/{request.auth.uid}).data.isAdmin == true;\n'
                        '    }\n'
                        '  }\n'
                        '}',
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Firestore rules copied to clipboard'),
                  ),
                );
              },
            ),

            // Step 7: Update the App
            _buildSection(
              title: '7. Update the App',
              content: [
                _buildStep(1, 'Open your main.dart file'),
                _buildStep(
                  2,
                  'Replace the mock Firebase options with the real ones from your web app',
                ),
                _buildStep(
                  3,
                  'Make sure FirebaseCore.initializeApp() is called before any Firebase usage',
                ),
                _buildStep(4, 'Run the app and test the authentication'),
              ],
            ),

            // Step 8: Admin User Setup
            _buildSection(
              title: '8. Admin User Setup',
              content: [
                _buildStep(
                  1,
                  'Sign up with your admin email (marginankola@gmail.com)',
                ),
                _buildStep(2, 'Use a strong password (M@rgin123 as specified)'),
                _buildStep(
                  3,
                  'The app will automatically set admin privileges for this email',
                ),
                _buildStep(
                  4,
                  'You can now manage coffees and users from the admin dashboard',
                ),
              ],
            ),

            // Resources
            _buildSection(
              title: 'Additional Resources',
              content: [
                _buildLink(
                  'Firebase Flutter Documentation',
                  'https://firebase.google.com/docs/flutter/setup',
                  context,
                ),
                _buildLink(
                  'Flutter Firebase Codelab',
                  'https://firebase.google.com/codelabs/firebase-get-to-know-flutter',
                  context,
                ),
                _buildLink(
                  'Firestore Security Rules',
                  'https://firebase.google.com/docs/firestore/security/get-started',
                  context,
                ),
              ],
            ),

            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConstants.brown,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: Text(
                  'Back to Admin Dashboard',
                  style: TextStyle(color: ThemeConstants.cream),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeConstants.darkGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.fireplace, color: ThemeConstants.brown, size: 36),
              const SizedBox(width: 12),
              Text(
                'Firebase Setup Guide',
                style: TextStyle(
                  color: ThemeConstants.cream,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'This guide will help you set up Firebase for Let\'s Brew app. Follow each step carefully to enable authentication, database, and admin features.',
            style: TextStyle(
              color: ThemeConstants.cream.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: ThemeConstants.lightBrown,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...content,
        ],
      ),
    );
  }

  Widget _buildStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ThemeConstants.brown,
              shape: BoxShape.circle,
            ),
            child: Text(
              number.toString(),
              style: TextStyle(
                color: ThemeConstants.cream,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: ThemeConstants.cream, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeSection({
    required String title,
    required String code,
    required VoidCallback onCopy,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: ThemeConstants.darkGrey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ThemeConstants.brown.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: ThemeConstants.lightBrown,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.content_copy, size: 18),
                  color: ThemeConstants.cream.withOpacity(0.7),
                  onPressed: onCopy,
                  tooltip: 'Copy to clipboard',
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: SelectableText(
              code,
              style: const TextStyle(
                color: Colors.green,
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLink(String title, String url, BuildContext context) {
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: url));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Link copied: $url')));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(Icons.link, color: ThemeConstants.lightBrown, size: 18),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                color: ThemeConstants.cream,
                decoration: TextDecoration.underline,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
