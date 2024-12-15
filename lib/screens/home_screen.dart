import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/authentication/auth.dart';
import 'package:hedieaty/models/app_user.dart';
import 'package:hedieaty/services/db_helper.dart';

class HomeScreen extends StatelessWidget {
  final AppUser user;

  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${user.name}!'),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              await LocalDatabase.deleteUser();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AuthScreen()),
              );
            },
            icon: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
      body: Center(
        child: Text('Hello, ${user.name}!'),
      ),
    );
  }
}
