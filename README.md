# CareLoom App

CareLoom is a family safety app built with Flutter. It helps parents monitor and manage their children's device usage, enabling real-time synchronization and notifications via Firebase. The app allows parents to set restrictions, receive real-time updates, and stay connected with their children’s activities on their devices.

---

## Features

### Parent Features:
- **Add and manage multiple child devices**: Easily manage and add multiple child devices under one parent account.
- **Monitor device usage**: Track and view device usage statistics for each child.
- **Set device usage limits**: Set daily time limits to help children manage their screen time.
- **Send notifications**: Send notifications directly to your child's device to remind them of their usage limits or important alerts.
- **Set content and time restrictions**: Manage and restrict content access and screen time based on your preferences.

### Child Features:
- **Link device via QR code**: The child device links to the parent device using a QR code, ensuring seamless connection and monitoring.
- **Receive notifications**: Children can receive notifications from the parent device regarding usage limits, updates, and important messages.
- **Update profile settings**: Children can view and update their profile settings from their device, ensuring they have access to the information they need.

---

## Tech Stack

- **Flutter**: Cross-platform mobile development framework for iOS and Android.
- **Firebase**: Utilized for Authentication, Firestore (Database), and Cloud Messaging (for real-time notifications).
- **QR Code**: For linking parent and child devices seamlessly.
- **Firebase Cloud Messaging**: For sending real-time push notifications between devices.

---

## Getting Started

Follow these steps to get the CareLoom app up and running:

### Prerequisites:
Before you begin, ensure you have the following installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- A Firebase account to configure Firebase services (Authentication, Firestore, Cloud Messaging)
- An IDE for Flutter development (e.g., [Android Studio](https://developer.android.com/studio), [Visual Studio Code](https://code.visualstudio.com/))

### Setup:

1. **Create a Firebase Project:**
    - Go to the [Firebase Console](https://console.firebase.google.com/) and create a new Firebase project.

2. **Enable Firebase Services:**
    - **Authentication**: Enable Firebase Authentication (choose the authentication method such as Email/Password, Google Sign-In, etc.).
    - **Firestore**: Set up Firestore to store your app's data, such as user profiles and device information.
    - **Cloud Messaging**: Enable Firebase Cloud Messaging to send push notifications to your app's users.

3. **Download and Configure Firebase Files:**
    - **For Android**:
        - In the Firebase Console, go to Project settings, and under "Your apps," select Android.
        - Download the `google-services.json` file and place it in the `android/app/` directory.
    - **For iOS**:
        - In the Firebase Console, go to Project settings, and under "Your apps," select iOS.
        - Download the `GoogleService-Info.plist` file and place it in the `ios/Runner/` directory.
        - Make sure the `GoogleService-Info.plist` is added to your Xcode project by opening `ios/Runner.xcworkspace` in Xcode, right-clicking on the project navigator, and selecting **Add Files to "Runner"**.

4. **Update Project Dependencies:**
    - For Android, make sure that the Firebase services are properly integrated by checking that the following dependencies are present in your `android/build.gradle` file:

   ```gradle
   buildscript {
       dependencies {
           classpath 'com.google.gms:google-services:4.3.13' // Add this line
       }
   }
---

5. **flutter run**


## Additional Notes

- **QR Code Integration**:
    - The app uses QR codes to link parent and child devices. Make sure your device has a camera and that the necessary permissions are granted for scanning QR codes. You may need to adjust permission settings in both Android and iOS for camera access if not already set.

- **Cloud Messaging**:
    - Ensure that Firebase Cloud Messaging (FCM) is properly set up for sending push notifications. In order to send notifications, you might need to set up device tokens to identify devices and manage them in the Firebase Cloud Messaging system. Handle notification logic in the app to ensure messages are received correctly.

---

## Resources

- [Flutter Documentation](https://flutter.dev/docs) - The official Flutter documentation, providing installation guides, widget explanations, and in-depth development resources.

- [Firebase for Flutter](https://firebase.flutter.dev/docs/overview) - Official guide for integrating Firebase with Flutter apps, covering Authentication, Firestore, and Cloud Messaging setup.

- [Flutter Cookbook](https://docs.flutter.dev/cookbook) - A collection of practical recipes, sample code, and solutions for common Flutter challenges.

- [Write Your First Flutter App](https://docs.flutter.dev/get-started/codelab) - A step-by-step tutorial to help you create your first Flutter app.

---

## Contributing

We welcome contributions to the CareLoom app! If you would like to contribute, please fork the repository, make your changes, and submit a pull request. Before submitting, ensure your contributions adhere to the following guidelines:

- Follow the existing code style of the project.
- Ensure that your changes are well-tested.
- Provide a description of your changes in the pull request.

---

## License

This project is open-source and available under the [MIT License](LICENSE). Feel free to use, modify, and distribute this project as long as you adhere to the terms of the license.

---

Let us know if you encounter any issues or need further assistance while setting up CareLoom!

