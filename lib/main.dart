import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/authentication/auth.dart';
import 'package:hedieaty/models/app_user.dart';
import 'package:hedieaty/screens/home_screen.dart';
import 'package:hedieaty/services/db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: "Poppins",
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasData) {
            // Firebase user is logged in
            final userId = snapshot.data!.uid; // Get Firebase user UID

            // Use FutureBuilder to get the user from local database by UID
            return FutureBuilder<AppUser?>(
              future: LocalDatabase.getUserById(
                  userId), // Pass userId to getUserById
              builder: (ctx, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (userSnapshot.hasData) {
                  return HomeScreen(user: userSnapshot.data!);
                }
                return const AuthScreen();
              },
            );
          }
          // No user logged in, show authentication screen
          return const AuthScreen();
        },
      ),
    );
  }
}
