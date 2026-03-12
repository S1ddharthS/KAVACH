import 'package:flutter/material.dart';
import 'firebase_config.dart';
import 'login_screen.dart'; // Import your login screen

void main() async {
  // Ensure Flutter is initialized before Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // Connect KAVACH to Firebase
  await FirebaseConfig.initialize(); 
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KAVACH',
      debugShowCheckedModeBanner: false, // Removes the red "Debug" banner
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true, // Uses modern Android/iOS design
      ),
      // This tells FLUTTER to show your Login Screen first
      home: const LoginScreen(), 
    );
  }
}