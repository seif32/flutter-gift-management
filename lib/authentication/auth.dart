import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hedieaty/screens/home_screen.dart';
import 'package:hedieaty/models/app_user.dart';
import 'package:hedieaty/style/app_colors.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();

  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredName = '';
  var _enteredPhoneNumber = '';

  void _submit() async {
    final isValid = _form.currentState!.validate();

    if (!isValid) return;

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

        if (!userDoc.exists)
          throw Exception('User data not found in Firestore.');

        // Convert Firestore data into Dart object (AppUser)
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
          phone: _enteredPhoneNumber,
        );

        // Save user to Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.id).set({
          'name': user.name,
          'email': user.email,
          'phone': user.phone,
        });

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
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: _isLogin ? "Welcome " : 'Create an ',
                      style: TextStyle(fontSize: 24),
                    ),
                    TextSpan(
                      text: _isLogin ? "Back!" : '',
                      style: TextStyle(fontSize: 29, color: Colors.red),
                    ),
                    TextSpan(
                      text: _isLogin ? "\n    Please Login" : '',
                      style: TextStyle(fontSize: 24),
                    ),
                    TextSpan(
                      text: _isLogin ? "\n    " : 'Account',
                      style: TextStyle(fontSize: 29, color: Colors.red),
                    ),
                  ],
                ),
                textAlign: TextAlign.left,
              ),
              SizedBox(
                height: _isLogin ? 24 : 10,
              ),
              SvgPicture.asset(
                'assets/images/login.svg',
                width: 300,
                height: 300,
              ),
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _form,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Show name and phone number fields in signup mode only
                        if (!_isLogin) ...[
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
                                labelText: 'Phone Number'),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your phone number.';
                              }
                              if (value.trim().length < 10) {
                                return 'Phone number must be at least 10 digits.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredPhoneNumber = value!;
                            },
                          ),
                        ],
                        TextFormField(
                          decoration:
                              const InputDecoration(labelText: 'Email Address'),
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
                        SizedBox(
                          width: 300, // Set your desired width here
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                            ),
                            child: Text(
                              _isLogin ? 'Login' : 'Signup',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                          },
                          child: Text(
                            _isLogin
                                ? "Don't have an account? Sign Up"
                                : 'Already have an account? Login',
                            style: TextStyle(color: AppColors.primaryVariant),
                          ),
                        ),
                      ],
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
