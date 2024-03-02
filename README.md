# ChatGPT-EG

ChatGPT-EG is a Flutter application that simulates a chat experience with an AI, incorporating additional features such as speech-to-text, text-to-speech, generating AI images, and more. It also integrates with Firebase for authentication, database, storage, and OTP verification.

## Features

- **Chat Interface**: Engage in conversations with an AI modeled after OpenAI's GPT.
- **Speech-to-Text**: Convert spoken words into text messages for seamless communication.
- **Text-to-Speech**: Listen to AI responses in natural-sounding speech.
- **AI Image Generation**: Generate AI-based images for various purposes within the app.
- **Firebase Integration**:
  - **Firestore Database**: Store and retrieve chat history and user data.
  - **Firebase Storage**: Manage user-generated content like images.
  - **Firebase Authentication**: Secure user authentication and authorization.
  - **OTP Verification**: Verify user phone numbers for additional security.
  
## Dependencies

- **Flutter Plugins**:
  - Provider: State management solution for Flutter applications.
  - Shared Preferences: Store simple data persistently.
  - Country Picker: Provides a customizable country picker.
  - PInput: Customizable pin input widget.
  - Firebase plugins: Core, Auth, Storage, Firestore.
  - Image Cropper: Crop images with various configurations.
  - UUID: Generate unique identifiers.
  - HTTP: HTTP client for Dart.
  - Flutter Spinkit: Collection of loading indicators.
  - Path Provider: Find commonly used locations on the filesystem.
  - Flutter Image Compress: Compress images to reduce size.
  - Cached Network Image: Flutter library to load and cache network images.
  - Flutter Cache Manager: Cache network files.
  - Speech to Text: Transcribe speech to text.
  - Lottie: Render After Effects animations natively.
  - Text to Speech: Convert text to speech.
  - Audioplayers: Play audio files.
  - Grouped List: Create grouped list views.
  - Date Format: Format dates.
  - Flutter Dotenv: Load environment variables from a .env file.
  - Intl: Internationalization and localization support.
  - Image Picker: Select images from the device's gallery or camera.
- **Dev Dependencies**:
  - Flutter Test: Framework for writing and running Flutter tests.
  - Flutter Lints: Collection of lint rules to enforce in Flutter apps.

## Setup

1. Clone the repository.
2. Navigate to the project directory.
3. Run `flutter pub get` to install dependencies.
4. Ensure you have the necessary API keys:
    - Obtain an API key from OpenAI and replace `CHATGPTAPIKEY` in `.env` with your key.
    - Obtain an API key from Eleven Labs and replace `ELEVENLABSAPIBASEURLkey` in `.env` with your key.
5. Run the app on a simulator or physical device using `flutter run`.

## Configuration

- Update `.env` file with appropriate API keys and configuration parameters.

## Contributing

Contributions are welcome! If you have suggestions or find any issues, please open an issue or submit a pull request.

## License

This project is licensed under the [MIT License](LICENSE).
```

Make sure to replace placeholders like `BASEURL`, `CHATGPTAPIKEY`, `ELEVENLABSAPIBASEURL`, and `ELEVENLABSAPIBASEURLkey` with actual values .