# 💬 Flutter Chat App

A fully-featured real-time chat application built with **Flutter**, integrating both **Firebase** and **Supabase**. It delivers a seamless messaging experience with beautiful animations, strong authentication, real-time updates, and push notifications.

## 🚀 Features

### 🔐 Authentication
- Email & Password sign up/login
- Form validation with friendly error messages
- Glassmorphism UI with Lottie animations
- Auto login with session persistence

### 💬 Real-time Messaging
- Group chat (similar to WhatsApp)
- Sender-based message bubbles with timestamp
- Live chat updates using Firebase Firestore
- Auto-scroll on new message

### 📦 Backend Services
- **Firebase Auth** – Authentication
- **Firebase Firestore** – Message storage
- **Firebase Cloud Messaging (FCM)** – Push notifications
- **Supabase Storage** – Profile image storage

### 🎨 UI/UX
- Splash screen with animated Lottie logo
- Modern login/register design with glassmorphism
- Clean and responsive chat UI
- Adaptive layout for all screen sizes

### 🔔 Notifications
- Firebase push notifications for new messages
- Local notifications (for testing or offline alerts)

## 🛠️ Tech Stack

| Technology | Purpose |
|------------|---------|
| **Flutter** | Front-end mobile framework |
| **Firebase** | Auth, Firestore DB, FCM |
| **Supabase** | Media storage |
| **Riverpod / Provider** | State management |
| **Lottie** | Vector animations |
| **Dart** | Core language |
| **GitHub** | Version control |

## 📂 Folder Structure

lib/
┣ models/
┣ screens/
┣ widgets/
┣ services/
┗ main.dart
assets/
┣ animations/
┗ images/


## 📲 Getting Started

### 🔧 Setup Instructions

# 1. Clone the repo
git clone https://github.com/muhammadwasif12/flutter-chat-app.git
cd flutter-chat-app

# 2. Install dependencies
flutter pub get

# 3. Add your Firebase & Supabase keys

# Create a .env file in the root:
.env
SUPABASE_URL=your_supabase_url
SUPABASE_KEY=your_supabase_key


# 4. Configure Firebase (only once)
flutterfire configure

# 5. Run the app
flutter run

🧪 Screenshots
Splash Screen 

Login


Chat UI


📁 Sensitive Files (Not Pushed)
These are excluded via .gitignore:

lib/firebase_options.dart

.env

✅ To-Do (Planned Features)
 Add direct 1-on-1 chat

 Chat media support (images, audio)

 Message read/delivery status

 Typing indicator

 Search chat messages

 Dark mode toggle

 User presence (online/offline)

 Push notification action (reply from notification)

 Admin panel for moderation

🌟 Future Enhancements
📷 Add option to send images and emojis

🧠 Add AI-powered smart replies

📁 Store messages locally (offline sync)

🔍 Search users or groups

🕵️‍♂️ End-to-end encryption (E2EE)

📬 Contact
Muhammad Wasif Shah
📧 muhammadwasifshah629@gmail.com
🌐 GitHub Profile

⭐️ Support This Project
If you found this project helpful, please consider giving it a ⭐️ on GitHub!




