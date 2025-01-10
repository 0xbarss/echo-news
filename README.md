# Echo News Project README

## Overview
This README provides step-by-step instructions on how to set up and run the Echo News mobile application project. It includes details on the project structure, the Flutter version used, and a link to the demonstration video.

---

## Prerequisites
1. Install Flutter: Ensure that Flutter is installed on your machine. Refer to the [Flutter installation guide](https://flutter.dev/docs/get-started/install) for detailed steps.
2. Install Android Studio or Visual Studio Code: These IDEs are recommended for running Flutter projects.
3. Install a compatible version of Dart SDK.
4. Ensure you have a mobile emulator (like Android Virtual Device) or a physical device connected to your machine for testing.

---

## Project Setup

1. **Download the Project Files**
   - Download the source code from the submission folder.
   - Extract the zip file (if applicable) into a local directory.

2. **Open the Project**
   - Open your IDE (Android Studio or VS Code).
   - In Android Studio: 
     - Go to `File` > `Open` and select the extracted folder.
   - In VS Code:
     - Open the folder using the `File` > `Open Folder` option.

3. **Install Dependencies**
   - Open a terminal in the project directory.
   - Run the following command to install required dependencies:
     ```
     flutter pub get
     ```

4. **Setup NewsAPI**
   - Sign up at [NewsAPI](https://newsapi.org/) to obtain an API key.
   - Locate the main file in the project folder where the API key is required.
   - Replace the placeholder with your NewsAPI key in the main:
     ```
     apiKey: "YOUR_API_KEY_HERE"
     ```
   - The application uses the "Top Headlines" endpoint to fetch news data.
     Refer to the [NewsAPI Documentation](https://newsapi.org/docs/endpoints/top-headlines) for details.

5. **Setup Firebase**
   - Follow the steps in the Firebase documentation to configure the app with your Firebase project:
     - Download the `google-services.json` file for Android.
     - Place it in the `android/app` folder.
     - If you are using iOS, follow similar steps for `GoogleService-Info.plist`.

6. **Run the Application**
   - Connect a physical device or start an emulator.
   - Run the following command to build and launch the app:
     ```
     flutter run
     ```

7. **Testing Features**
   - Log in or register a new account using Firebase Authentication.
   - Explore the homepage, categories, bookmarks, and search pages.
   - Test profile management, theme customization, and messaging features.

---

## Flutter Version
- **Flutter Version:** 3.24.3
  
Ensure that your Flutter version matches the above for compatibility. You can check your Flutter version by running:
```bash
flutter --version
```

---

## Libraries and APIs Used
- **`news_api_flutter_package`:** A Flutter package used to fetch news data from NewsAPI.
- **Firebase Authentication:** Used for secure user login and registration.
- **Firebase Firestore:** Used to store user data and preferences.
- **ShareLink:** Used for sharing links through other applications.

Refer to the official documentation of these libraries for further details on their usage and integration.

---

## YouTube Demonstration
View the demonstration of the Echo News application using the following link:
[Echo News Demo] https://youtu.be/alVuq6QpTeA

---

## Troubleshooting
1. **Flutter Version Mismatch**
   - If you encounter issues due to a Flutter version mismatch, switch to the compatible version by running:
     ```bash
     flutter upgrade 3.24.3
     ```

2. **Dependency Errors**
   - Run `flutter clean` and then `flutter pub get` to resolve dependency conflicts.

3. **Emulator/Device Issues**
   - Ensure that the emulator is running or the physical device is connected properly with USB debugging enabled.

For further assistance, refer to the [Flutter documentation](https://flutter.dev/docs) or contact the development team.

---

Thank you for reviewing the Echo News project!
