# Hedieaty

Hedieaty is a Flutter-based application designed to enhance the gift-giving experience by managing events, gifts, and friendships. The application leverages both local SQLite databases and cloud-based Firestore to provide seamless data management and synchronization. Users can create events, track gifts, manage friends, and more.

## Features

### Core Functionalities

- **User Management**: Users can register, log in, and update their profiles.
- **Events**:
  - Create, edit, and delete events.
  - View events associated with a user.
- **Gifts**:
  - Add, update, and delete gifts associated with events.
  - Manage gift pledges and statuses.
- **Friendship Management**:
  - Add and manage friends.
  - View friend details and their published events.

### Technology Highlights

- **Database**:
  - Local: SQLite for offline data storage.
  - Cloud: Firestore for real-time synchronization.
- **Authentication**: Firebase Authentication for secure user management.
- **UI**: Built with Flutter for a smooth and modern user experience.
- **Theming**: Customizable colors for a consistent design.

---

## Project Structure

### Local Database

The local database is implemented using SQLite. It consists of the following tables:

- **Users**: Stores user information such as `id`, `email`, `name`, and `phone`.
- **Events**: Stores event details including `name`, `date`, `location`, and `description`.
- **Gifts**: Tracks gifts with details such as `name`, `category`, `price`, and `pledgerId`.
- **Friends**: Manages friend relationships.

Key files:

- `local_database.dart`: Handles database initialization and CRUD operations for all tables.

### Firestore Integration

Firestore is used for cloud-based data storage and synchronization.

- **Users**: Stores user profile data.
- **Events**: Stores event data with sub-collections for associated gifts.
- **Gifts**: Nested within the `Events` collection to maintain relational integrity.
- **Friends**: Tracks friendships and allows retrieval of friend details and events.

Key files:

- `firestore_services.dart`: Handles Firestore operations for users, events, gifts, and friends.

---

## Installation

### Prerequisites

- Flutter SDK
- Firebase project setup with Firestore and Authentication enabled

### Steps

1. Clone the repository:
   ```bash
   git clone https://github.com/seif32/flutter-gift-management.git
   cd flutter-gift-management
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Configure Firebase:
   - Add the `google-services.json` file for Android in `android/app/`.
   - Add the `GoogleService-Info.plist` file for iOS in `ios/Runner/`.
4. Run the app:
   ```bash
   flutter run
   ```

---

## Usage

1. **Sign Up or Log In**: Start by creating an account or logging in using your credentials.
2. **Manage Events**:
   - Create events with relevant details.
   - View and delete events.
3. **Track Gifts**:
   - Add gifts to events.
   - Update gift details and manage pledges.
4. **Add Friends**:
   - Connect with other users.
   - View their published events.

---

## Code Overview

### LocalDatabase Class

- Handles all SQLite operations, including creating tables and managing `Events`, `Gifts`, and `Friends` tables.
- Example usage:
  ```dart
  await LocalDatabase.saveEvent(event);
  ```

### FirestoreService Class

- Manages Firestore operations such as saving and retrieving users, events, gifts, and friends.
- Example usage:
  ```dart
  await FirestoreService.saveUser(appUser);
  ```

---

## Theming

- Primary Color: `#6A1E55`
- Secondary Color: `#1A1A1D`
- Background Color: `#F9FAFB`
- Fonts: Poppins

---

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository.
2. Create a feature branch:
   ```bash
   git checkout -b feature-name
   ```
3. Commit your changes:
   ```bash
   git commit -m "Add feature description"
   ```
4. Push to the branch:
   ```bash
   git push origin feature-name
   ```
5. Open a pull request.

---

## Acknowledgments

- Flutter and Dart for the framework.
- Firebase for authentication and cloud services.
- SQLite for offline storage.
