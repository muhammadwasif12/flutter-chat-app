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

<img width="1366" height="768" alt="Screenshot (1769)" src="https://github.com/user-attachments/assets/1ad47865-52cf-4409-b255-ee81c3facd89" />

Login

<img width="1366" height="768" alt="Screenshot (1770)" src="https://github.com/user-attachments/assets/94f04e04-4a4a-4d98-b467-88742e7dda4e" />

Sign Up

<img width="1366" height="768" alt="Screenshot (1771)" src="https://github.com/user-attachments/assets/a43536ca-791e-460c-8dd8-6f1edc03e0fd" />

Chat UI

<img width="1366" height="768" alt="Screenshot (1772)" src="https://github.com/user-attachments/assets/2d29f9f5-8149-4afb-b19e-87a8734d7ff6" />

<img width="1366" height="768" alt="Screenshot (1773)" src="https://github.com/user-attachments/assets/efccaf9a-712c-4629-bf59-46a08bc05b57" />

<img width="1366" height="768" alt="Screenshot (1774)" src="https://github.com/user-attachments/assets/c36f749e-e639-4b8e-a348-336650d1949f" />


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




