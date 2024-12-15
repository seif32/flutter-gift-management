import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hedieaty/screens/home_screen.dart';
import 'package:hedieaty/models/app_user.dart';
import 'package:hedieaty/services/db_helper.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();

  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredName = '';

  void _submit() async {
    final isValid = _form.currentState!.validate();

    if (!isValid) {
      return;
    }

    _form.currentState!.save();

    try {
      UserCredential userCredentials;

      if (_isLogin) {
        // Log in existing user
        userCredentials = await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );

        // Fetch user data from Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .get();

        if (!userDoc.exists) {
          throw Exception('User data not found in Firestore.');
        }

        // Create AppUser from Firestore data
        final user = AppUser.fromFirestore(
          userDoc.data()!,
          userCredentials.user!.uid,
        );

        // Navigate to HomeScreen with the AppUser
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(user: user)),
        );
      } else {
        // Sign up a new user
        userCredentials = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );

        // Create a new AppUser
        final user = AppUser(
          id: userCredentials.user!.uid,
          email: _enteredEmail,
          name: _enteredName,
        );

        // Save user data to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.id)
            .set(user.toFirestore());

        // Save user data locally to SQLite
        await LocalDatabase.saveUser(user);

        // Navigate to HomeScreen with the AppUser
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(user: user)),
        );
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 350,
                child: Image.asset('assets/images/login.svg'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _form,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isLogin)
                            TextFormField(
                              decoration:
                                  const InputDecoration(labelText: 'Name'),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your name.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredName = value!;
                              },
                            ),
                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Email Address'),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Please enter a valid email address.';
                              }

                              return null;
                            },
                            onSaved: (value) {
                              _enteredEmail = value!;
                            },
                          ),
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Password'),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Password must be at least 6 characters long.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredPassword = value!;
                            },
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                            child: Text(_isLogin ? 'Login' : 'Signup'),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                            child: Text(_isLogin
                                ? 'Create an account'
                                : 'I already have an account'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
