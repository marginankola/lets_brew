# Android Firebase Setup for Let's Brew

To set up Firebase for your Android app:

1. Download the `google-services.json` file from your Firebase console
2. Place it in the `android/app` directory of your Flutter project

## Update Android Configuration

1. Edit `android/build.gradle` to add the Google services plugin:

```gradle
buildscript {
    dependencies {
        // Add this line
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

2. Edit `android/app/build.gradle` to apply the plugin and add dependencies:

```gradle
// Add this at the bottom of the file
apply plugin: 'com.google.gms.google-services'

dependencies {
    // Add these lines
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-analytics'
    implementation 'com.google.firebase:firebase-auth'
    implementation 'com.google.firebase:firebase-firestore'
}
```

3. Make sure your `android/app/build.gradle` has the correct applicationId:

```gradle
defaultConfig {
    applicationId "com.example.lets_brew"
    // other config...
}
```

4. For Google Sign-In, add to your `android/app/src/main/AndroidManifest.xml`:

```xml
<application
    ...>
    <!-- Add this meta-data element -->
    <meta-data
        android:name="com.google.android.gms.version"
        android:value="@integer/google_play_services_version" />
</application>
```

5. Run `flutter clean` and then `flutter run` to rebuild the app. 