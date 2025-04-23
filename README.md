# HealthMate - Real-Time AI-Powered Health Chatbot

HealthMate is an intelligent, real-time health assistant built using Flutter and Dart with Firebase as the backend. Designed to provide instant support for users' health-related queries, HealthMate incorporates AI capabilities like symptom-based suggestions, speech-to-text consultation input, and OCR for reading prescriptions or health documents. Whether you're managing daily health or consulting AI-driven advice, HealthMate is your go-to digital companion.

## ✨ Features

- **User Authentication**

  - Secure login and registration via Firebase Authentication
  - Supports email/password, anonymous, and other secure login methods

- **Real-Time Health Chat**

  - Instantly send and receive health-related messages with real-time updates powered by Firebase Firestore
  - Interact with HealthMate AI or connect with health professionals (if integrated)

- **AI-Powered Health Assistance**

  - Prescription Reader (Image-to-Text): Upload prescriptions or lab reports to extract medical details using AI OCR
  - Voice Consultation Input (Speech-to-Text): Speak your symptoms or health issues for automatic transcription
  - Symptom Checker & Suggestions: Get AI-generated health advice based on symptoms entered
  - Stop AI Suggestion Midway: In case of incorrect context or user change of mind
  - Copy Suggestions: Instantly copy AI responses for saving or sharing

- **Chat and Health Record Management**
  - Export Consultation as PDF: Save AI or doctor interactions for reference
  - Health Chat History: View all past conversations and AI responses

## 🛠️ Prerequisites

Ensure you have the following before setup:

- Flutter SDK (v3.x.x or later)
- Dart SDK (comes with Flutter)
- Firebase Account
- IDE like Android Studio or VS Code
- Physical device or emulator for testing

## 📦 Dependencies

Key packages used:

- `firebase_core`: Firebase setup
- `firebase_auth`: Secure user authentication
- `cloud_firestore`: Health chat database
- `firebase_storage`: Prescription/image uploads
- `speech_to_text`: Voice input processing
- `pdf`: Exporting chat as PDF for health records

Refer to `pubspec.yaml` for the complete dependency list.

## 🚀 Getting Started

1. **Clone the Repository**

   ```bash
   git clone https://github.com/yourusername/healthmate_app.git
   cd healthmate_app
   ```

2. **Install Dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure Firebase**

   - Create Firebase project
   - Add Android/iOS apps
   - Download and integrate config files
   - Enable Auth & Firestore in Firebase console

4. **Run the App**
   ```bash
   flutter run
   ```

## 📱 Usage Guide

### User Authentication

- Register/login using email or anonymously
- Access AI health features securely

### Chat & AI Health Features

- Chat with HealthMate AI or health experts
- Upload images of prescriptions or reports
- Use voice for symptom entry
- Get AI health suggestions
- Export consultations as PDFs
- Copy AI suggestions
- Stop AI generation mid-way if needed

### Health History & Records

- Access past chats
- Export records for future reference
- Maintain your health journey in-app

## 🤝 Contributing

Have ideas to improve HealthMate? Contributions are welcome! Submit a pull request and help us grow.

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for full details.

## 📞 Support

Need help or want to give feedback?

- 📧 Email us at: support@healthmate.com
- Or open an issue in the repository.
