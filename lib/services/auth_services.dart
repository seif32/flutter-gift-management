import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
import '../services/firestore_services.dart';

class AuthServices {
  final FirebaseAuth _firebase = FirebaseAuth.instance;

  Future<void> submit({
    required bool isLogin,
    required String email,
    required String password,
    String? name,
    String? phone,
    required Function(AppUser) onSuccess,
    required Function(String) onError,
  }) async {
    try {
      UserCredential userCredentials;
      if (isLogin) {
        // Log in existing user
        userCredentials = await _firebase.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        // Fetch user data from Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .get();
        if (!userDoc.exists)
          throw Exception('User data not found in Firestore.');

        // Convert Firestore data into Dart object (AppUser)
        final user = AppUser.fromFirestore(
          userDoc.data()!,
          userCredentials.user!.uid,
        );

        onSuccess(user);
      } else {
        // Sign up a new user
        userCredentials = await _firebase.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        // Create a new AppUser
        final user = AppUser(
          id: userCredentials.user!.uid,
          email: email,
          name: name!,
          phone: phone!,
        );

        // Save user to Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.id).set({
          'name': user.name,
          'email': user.email,
          'phone': user.phone,
        });

        await FirestoreService.saveUser(user);

        onSuccess(user);
      }
    } on FirebaseAuthException catch (error) {
      String errorMessage = 'Authentication failed. Please try again.';
      if (error.code == 'email-already-in-use') {
        errorMessage = 'Email already in use! Please try another.';
      } else if (error.code == 'invalid-email') {
        errorMessage = 'Invalid email format.';
      } else if (error.code == 'weak-password') {
        errorMessage = 'Password should be at least 6 characters.';
      }

      onError(errorMessage);
    } catch (e) {
      onError('An error occurred: $e');
    }
  }
}
