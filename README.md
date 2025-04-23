# ChatApp - Real-Time AI-Powered Chat Application

ChatApp is a modern, feature-rich chat application built using Flutter and Dart, with Firebase as the backend. It offers real-time messaging, AI-powered features like image-to-text and speech-to-text generation, and seamless chat management functionalities. Whether you're looking to chat with friends or leverage AI capabilities, ChatApp has you covered!

## ✨ Features

- **User Authentication**

  - Secure login and registration using Firebase Authentication
  - Support for email/password, anonymous, and other authentication methods

- **Real-Time Messaging**

  - Instant messaging powered by Firebase Firestore
  - Smooth and responsive chat experience

- **AI-Powered Features**

  - Image-to-Text Generation: Upload images and extract text using AI
  - Speech-to-Text Generation: Convert spoken words into text
  - Stop Generation: Halt AI text generation mid-process
  - Copy AI Responses: Quick clipboard access to AI-generated text

- **Chat Management**
  - Share Chat as PDF: Export conversations as PDF files
  - Chat History: View past conversations with an intuitive interface

## 🛠️ Prerequisites

Before you begin, ensure you have the following installed:

- Flutter SDK (v3.x.x or later)
- Dart (included with Flutter)
- Firebase Account
- An IDE (Android Studio or VS Code)
- (Optional) Emulator or physical device for testing

## 📦 Dependencies

Key packages used in this project:

- `firebase_core`: Firebase initialization
- `firebase_auth`: User authentication
- `cloud_firestore`: Real-time database
- `firebase_storage`: Image uploads
- `speech_to_text`: Speech-to-text functionality
- `pdf`: PDF generation for chat export

For a complete list of dependencies, please refer to `pubspec.yaml`.

## 🚀 Getting Started

1. **Clone the Repository**

   ```bash
   git clone https://github.com/yourusername/chat_app.git
   cd chat_app
   ```

2. **Install Dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure Firebase**

   - Create a new Firebase project
   - Add your Android/iOS apps
   - Download and add the configuration files
   - Enable Authentication and Firestore

4. **Run the App**
   ```bash
   flutter run
   ```

## 📱 Usage

### Authentication

- Sign up with email/password or use anonymous authentication
- Log in to access your account

### Chat Features

- Start new conversations with other users
- Send real-time messages
- Use AI features:
  - Upload images for text extraction
  - Use voice input for speech-to-text
  - Export chats as PDF
  - Copy AI responses to clipboard
  - Stop AI generation when needed

### Chat Management

- View your chat history
- Export conversations as PDF
- Manage your conversations

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For support, email support@chatapp.com or open an issue in the repository.
