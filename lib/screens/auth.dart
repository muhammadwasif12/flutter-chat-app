import '../widgets/user_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

final _firebase = FirebaseAuth.instance;
final _supabase = Supabase.instance.client;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var isLogin = true;
  var _enteredEmail = "";
  var _enteredPassw = "";
  var _enteredUsername = "";
  XFile? _selectedImage;
  var _isAuthenticating = false;

  final _form = GlobalKey<FormState>();

  // FIXED: Simplified image upload function
  Future<String?> _uploadImageToSupabase(XFile imageFile, String userId) async {
    try {
      print('🚀 Starting image upload for user: $userId');

      final imageData = await imageFile.readAsBytes();
      print('📷 Image size: ${imageData.length} bytes');

      if (imageData.isEmpty) {
        throw Exception('Image data is empty');
      }

      // Simple validation - check if it starts with valid image headers
      bool isValidImage = false;
      if (imageData.length >= 2) {
        // JPEG starts with 0xFF 0xD8
        if (imageData[0] == 0xFF && imageData[1] == 0xD8) isValidImage = true;
        // PNG starts with 0x89 0x50
        if (imageData[0] == 0x89 && imageData[1] == 0x50) isValidImage = true;
        // GIF starts with 0x47 0x49
        if (imageData[0] == 0x47 && imageData[1] == 0x49) isValidImage = true;
      }

      if (!isValidImage) {
        throw Exception('Invalid image file format');
      }

      // Create simple filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${userId}_$timestamp.jpg';
      final filePath = 'profiles/$fileName'; // Simple path structure

      print('📁 Uploading to path: $filePath');

      // SIMPLE UPLOAD - No authentication needed for public bucket
      await _supabase.storage
          .from('chat-images')
          .uploadBinary(
            filePath,
            imageData,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      print('✅ Upload successful');

      // Get public URL
      final imageUrl = _supabase.storage
          .from('chat-images')
          .getPublicUrl(filePath);

      print('🔗 Generated URL: $imageUrl');

      if (imageUrl.isEmpty) {
        throw Exception('Failed to generate URL');
      }

      return imageUrl;
    } catch (e) {
      print('❌ Image upload error: $e');

      // Show user-friendly error
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Image upload failed. Please try again."),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return null;
    }
  }

  void _submit() async {
    final isvalid = _form.currentState!.validate();

    if (!isvalid || (!isLogin && _selectedImage == null)) {
      if (!isLogin && _selectedImage == null) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please select a profile image"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    _form.currentState!.save();

    try {
      setState(() {
        _isAuthenticating = true;
      });

      if (isLogin) {
        // Login process
        final userCredentials = await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassw,
        );
      } else {
        // Signup process
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassw,
        );

        // Upload image if selected
        String? imageUrl;
        if (_selectedImage != null) {
          imageUrl = await _uploadImageToSupabase(
            _selectedImage!,
            userCredentials.user!.uid,
          );
        }

        // Save user data to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
              'username': _enteredUsername,
              'email': _enteredEmail,
              'image_url': imageUrl ?? '',
              'created_at': FieldValue.serverTimestamp(),
            });

        print('✅ User data saved to Firestore');

        // Success message
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                imageUrl != null
                    ? "Account created successfully!"
                    : "Account created! (Image upload failed)",
              ),
              backgroundColor: imageUrl != null ? Colors.green : Colors.orange,
            ),
          );
        }
      }
    } on FirebaseAuthException catch (error) {
      print('❌ Firebase Auth Error: ${error.code} - ${error.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message ?? "Authentication Failed"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      print('❌ General Error: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $error"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo Animation
              if (isLogin)
                Container(
                  margin: const EdgeInsets.only(
                    top: 25,
                    bottom: 20,
                    left: 20,
                    right: 20,
                  ),
                  alignment: Alignment.center,
                  width: 300,
                  child: Lottie.asset(
                    'assets/animations/chat_logo.json',
                    fit: BoxFit.contain,
                    repeat: true,
                    filterQuality: FilterQuality.high,
                    alignment: Alignment.center,
                  ),
                ),
              if (!isLogin)
                Container(
                  margin: const EdgeInsets.only(
                    top: 25,
                    bottom: 0,
                    left: 20,
                    right: 20,
                  ),
                  alignment: Alignment.center,
                  width: 300,
                  child: Lottie.asset(
                    'assets/animations/chat_logo.json',
                    fit: BoxFit.contain,
                    repeat: true,
                    filterQuality: FilterQuality.high,
                    alignment: Alignment.center,
                  ),
                ),

              // Image picker for signup only
              if (!isLogin)
                UserImagePicker(
                  onPickImage: (pickImage) => _selectedImage = pickImage,
                ),

              // Form
              Form(
                key: _form,
                child: Column(
                  children: [
                    // Email Field
                    SizedBox(
                      width: 300,
                      child: TextFormField(
                        style: const TextStyle(color: Colors.white),
                        autocorrect: false,
                        cursorColor: Colors.white,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimary.withOpacity(0.6),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimary.withOpacity(0.6),
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.email,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimary.withOpacity(0.6),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textCapitalization: TextCapitalization.none,
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty ||
                              !value.contains('@') ||
                              !value.contains('.')) {
                            return "Please enter a valid email address";
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          _enteredEmail = newValue!;
                        },
                      ),
                    ),

                    const SizedBox(height: 13.5),

                    // Username field for signup only
                    if (!isLogin) ...[
                      SizedBox(
                        width: 300,
                        child: TextFormField(
                          style: const TextStyle(color: Colors.white),
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.person,
                              color: Colors.white.withOpacity(0.6),
                            ),
                            labelText: 'Username',
                            labelStyle: const TextStyle(color: Colors.white),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimary.withOpacity(0.6),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimary.withOpacity(0.6),
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                value.trim().length < 4) {
                              return "Username must be at least 4 characters long";
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            _enteredUsername = newValue!;
                          },
                        ),
                      ),
                      const SizedBox(height: 13.5),
                    ],

                    // Password Field
                    SizedBox(
                      width: 300,
                      child: TextFormField(
                        cursorColor: Colors.white,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.password,
                            color: Colors.white.withOpacity(0.6),
                          ),
                          labelText: 'Password',
                          labelStyle: const TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimary.withOpacity(0.6),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimary.withOpacity(0.6),
                            ),
                          ),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.trim().length < 6) {
                            return "Password must be at least 6 characters long";
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          _enteredPassw = newValue!;
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Submit Button
              if (_isAuthenticating)
                const CircularProgressIndicator(color: Colors.white)
              else
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    alignment: Alignment.center,
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(200, 45),
                  ),
                  child: Text(
                    isLogin ? "Login" : "Sign up",
                    style: const TextStyle(
                      color: Color.fromARGB(204, 255, 255, 255),
                      fontSize: 16,
                    ),
                  ),
                ),

              const SizedBox(height: 10),

              // Toggle Button
              if (!_isAuthenticating)
                TextButton(
                  onPressed: () {
                    setState(() {
                      isLogin = !isLogin;
                    });
                  },
                  child: Text(
                    isLogin ? "Create an Account" : 'I already have an Account',
                    style: const TextStyle(
                      color: Color.fromARGB(193, 255, 255, 255),
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
