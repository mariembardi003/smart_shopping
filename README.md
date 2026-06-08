# Smart Shopping 🛒

A modern Flutter application for intelligent supermarket shopping with barcode scanning, real-time cart management, and Firebase integration.

## 📋 Overview

Smart Shopping is a comprehensive mobile shopping application that allows users to:
- Scan product barcodes using device camera
- Browse products with real-time search and filtering
- Manage shopping cart with persistent storage
- Complete secure checkout process
- Track order history
- Manage user profiles

## 🚀 Features

### Core Functionality
- **User Authentication**: Secure sign up/sign in with Firebase Auth
- **Barcode Scanning**: Real-time product scanning using mobile_scanner
- **Product Management**: Browse, search, and filter products
- **Shopping Cart**: Add/remove items, quantity management, persistent storage
- **Checkout Process**: Complete order placement with validation
- **Order History**: View past orders with detailed information
- **User Profile**: Manage personal information and preferences

### Technical Features
- **Real-time Sync**: Live cart and product updates via Firestore
- **Offline Support**: Local cart persistence during network issues
- **Security**: Firebase security rules and input validation
- **Responsive Design**: Material Design with consistent theming
- **Error Handling**: Comprehensive error management and user feedback

## 🛠️ Technology Stack

- **Framework**: Flutter 3.11+
- **Language**: Dart
- **Backend**: Firebase (Firestore, Auth, Storage)
- **State Management**: Provider Pattern
- **Barcode Scanning**: mobile_scanner
- **Image Caching**: cached_network_image
- **Architecture**: MVVM with Service Layer

## 📋 Prerequisites

Before running this application, ensure you have:

- **Flutter SDK**: 3.11.0 or higher
- **Dart SDK**: 3.0.0 or higher
- **Android Studio** or **VS Code** with Flutter extensions
- **Android/iOS device** or emulator for testing
- **Firebase Account** with billing enabled (for Firestore)

### System Requirements
- **Android**: API level 21+ (Android 5.0+)
- **iOS**: iOS 11.0+
- **Camera**: Required for barcode scanning functionality

## 🔧 Installation & Setup

### 1. Clone the Repository
```bash
git clone <repository-url>
cd smart-shopping
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Configuration

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter project name: `smart-shopping`
4. Enable Google Analytics (optional but recommended)
5. Choose default account for Firebase

#### Enable Authentication
1. In Firebase Console, go to **Authentication**
2. Click **Get started**
3. Go to **Sign-in method** tab
4. Enable **Email/Password** provider
5. (Optional) Configure additional providers

#### Set up Firestore Database
1. In Firebase Console, go to **Firestore Database**
2. Click **Create database**
3. Choose **Start in test mode** (for development)
4. Select a location for your database
5. Click **Done**

#### Configure Firebase Storage (Optional)
1. In Firebase Console, go to **Storage**
2. Click **Get started**
3. Choose default security rules for now
4. Set up storage location

#### Download Configuration Files

**For Android:**
1. In Firebase Console, go to **Project settings** (gear icon)
2. Scroll to "Your apps" section
3. Click **Add app** → **Android icon**
4. Enter package name: `com.example.smart_shopping`
5. Download `google-services.json`
6. Place the file in `android/app/` directory

**For iOS:**
1. In Firebase Console, go to **Project settings**
2. Click **Add app** → **iOS icon**
3. Enter bundle ID: `com.example.smartShopping`
4. Download `GoogleService-Info.plist`
5. Place the file in `ios/Runner/` directory

### 4. Environment Configuration

1. Copy the environment template:
```bash
cp .env.example .env
```

2. Fill in your Firebase configuration values in `.env`:
```env
FIREBASE_API_KEY=your_api_key_from_firebase
FIREBASE_AUTH_DOMAIN=your_project_id.firebaseapp.com
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_STORAGE_BUCKET=your_project_id.firebasestorage.app
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_APP_ID=your_app_id
```

### 5. Deploy Security Rules

Deploy Firestore security rules to protect your data:
```bash
firebase deploy --only firestore:rules
```

### 6. Seed Demo Data (Optional)

Run the seeding script to populate demo products:
```bash
# Install Firebase CLI if not already installed
npm install -g firebase-tools
firebase login

# Deploy demo data
node scripts/seed_firestore.js
```

## 🚀 Running the Application

### Development Mode
```bash
flutter run
```

### With Environment Variables
```bash
flutter run \
  --dart-define FIREBASE_API_KEY=your_api_key \
  --dart-define FIREBASE_AUTH_DOMAIN=your_domain \
  --dart-define FIREBASE_PROJECT_ID=your_project_id \
  --dart-define FIREBASE_STORAGE_BUCKET=your_bucket \
  --dart-define FIREBASE_MESSAGING_SENDER_ID=your_sender_id \
  --dart-define FIREBASE_APP_ID=your_app_id
```

### Build for Production

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle (for Google Play):**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

## 📱 Usage Guide

### First Time Setup
1. **Launch App**: Open the app on your device
2. **Sign Up**: Create a new account with email and password
3. **Grant Permissions**: Allow camera access for barcode scanning

### Shopping Flow
1. **Browse Products**: View available products on home screen
2. **Scan Products**: Use scanner to quickly add items to cart
3. **Manage Cart**: Adjust quantities or remove items
4. **Checkout**: Complete purchase with delivery information
5. **Track Orders**: View order history and status

### Key Features
- **Real-time Search**: Find products instantly
- **Persistent Cart**: Cart contents saved between sessions
- **Offline Mode**: Basic functionality works without internet
- **Secure Checkout**: Validated order processing

## 🏗️ Architecture Overview

### Project Structure
```
lib/
├── config/          # Firebase configuration
├── models/          # Data models (Product, CartItem, Order, User)
├── providers/       # State management (AppProvider)
├── services/        # Firebase services (Auth, Firestore)
├── screens/         # UI screens (8 main screens)
├── widgets/         # Reusable components
├── utils/           # Utilities (validators, exceptions)
└── main.dart        # Application entry point
```

### Design Patterns
- **Provider Pattern**: State management and dependency injection
- **Service Layer**: Abstraction of Firebase operations
- **Repository Pattern**: Data access abstraction
- **MVVM Architecture**: Separation of UI, business logic, and data

### Firestore Schema
- **Database document model**: `users`, `products`, `carts`, `orders`, `complaints`, `sales`
- **Role-based access**: `client`, `admin`, `caissier`
- **Schema reference**: See `FIRESTORE_SCHEMA.md` for collection structure, sample documents, and search/scan workflows

### Data Flow
1. **User Interaction** → Screen Widgets
2. **State Changes** → Provider (AppProvider)
3. **Data Operations** → Service Layer (AuthService, FirestoreService)
4. **Firebase** → Real-time updates via streams
5. **UI Updates** → Provider notifications

## 🔒 Security

### Firebase Security Rules
- **Users**: Can only access their own profile data
- **Products**: Read-only for all users, admin-only writes
- **Cart**: Private per user, only owner can modify
- **Orders**: Private per user with admin oversight

### Input Validation
- **Email**: RFC 5322 compliant validation
- **Password**: Minimum 8 characters with complexity requirements
- **Phone**: International format support
- **Address**: Minimum length and format validation

### Best Practices
- No hardcoded credentials in source code
- Environment-based configuration
- Secure token management
- Input sanitization and validation

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test/
```

### Code Analysis
```bash
flutter analyze
```

### Build Validation
```bash
flutter build apk --debug
```

## 📊 Firebase Collections Schema

### Users Collection
```json
{
  "userId": "string",
  "email": "string",
  "name": "string",
  "phone": "string",
  "address": "string",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### Products Collection
```json
{
  "id": "string",
  "name": "string",
  "description": "string",
  "price": "number",
  "barcode": "string",
  "imageUrl": "string",
  "category": "string",
  "stock": "number",
  "createdAt": "timestamp"
}
```

### Cart Collection
```json
{
  "userId": "string",
  "items": [
    {
      "productId": "string",
      "quantity": "number",
      "addedAt": "timestamp"
    }
  ],
  "updatedAt": "timestamp"
}
```

### Orders Collection
```json
{
  "id": "string",
  "userId": "string",
  "items": [
    {
      "productId": "string",
      "productName": "string",
      "quantity": "number",
      "price": "number"
    }
  ],
  "total": "number",
  "status": "string",
  "deliveryAddress": "string",
  "phone": "string",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

## 🚨 Troubleshooting

### Common Issues

**Camera Permission Denied**
- Ensure camera permission is granted in device settings
- Check AndroidManifest.xml for camera permission
- Restart app after granting permissions

**Firebase Connection Failed**
- Verify `.env` file contains correct Firebase config
- Check internet connection
- Ensure Firebase project is active and billing is enabled

**Build Failed**
- Run `flutter clean` then `flutter pub get`
- Check Flutter and Dart versions
- Verify all dependencies are compatible

**Barcode Not Scanning**
- Ensure good lighting conditions
- Hold device steady while scanning
- Check camera focus and distance from barcode

### Debug Commands
```bash
# Check Flutter installation
flutter doctor

# Clean and rebuild
flutter clean && flutter pub get && flutter run

# Check device logs
flutter logs

# Analyze code
flutter analyze
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style
- Follow Dart style guide
- Use meaningful variable and function names
- Add documentation comments for public APIs
- Write tests for new features

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Support

For support and questions:
- Create an issue on GitHub
- Check the troubleshooting section
- Review Firebase documentation

## 📈 Future Enhancements

- [ ] Push notifications for order updates
- [ ] Product recommendations based on history
- [ ] Loyalty program integration
- [ ] Multi-language support
- [ ] Dark mode theme
- [ ] Offline product browsing
- [ ] Social features (shared carts)
- [ ] Advanced search filters
- [ ] Inventory management for admins
- [ ] Payment gateway integration

---

**Happy Shopping! 🛒✨**
