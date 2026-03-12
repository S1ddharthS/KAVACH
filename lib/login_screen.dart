import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'guardian_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final AuthService _authService = AuthService();

  String _verificationId = ""; // This is now used below
  bool _isOtpSent = false;
  bool _isLoading = false;

  void _handleSendOtp() async {
    setState(() => _isLoading = true);
    await _authService.verifyPhoneNumber(
      _phoneController.text.trim(),
      (verId) {
        // Fix: Check if the widget is still "mounted" before calling setState
        if (!mounted) return; 
        setState(() {
          _verificationId = verId;
          _isOtpSent = true;
          _isLoading = false;
        });
      },
      (error) {
        // Fix: Check if the widget is still "mounted" before showing SnackBar
        if (!mounted) return; 
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      },
    );
  }

  void _handleVerifyOtp() async {
    setState(() => _isLoading = true);
    var user = await _authService.signInWithOTP(
      _verificationId, 
      _otpController.text.trim(),
    );
    
    // Fix: Check if the widget is still "mounted" before updating UI or Navigating
    if (!mounted) return; 

    setState(() => _isLoading = false);

    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("KAVACH: Login Successful")),
      );
      
      // ADD THIS LINE to take the user to the Guardian Setup screen
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => const GuardianScreen())
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("KAVACH - Secure Login")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.security, size: 100, color: Colors.blue),
              const SizedBox(height: 40),
              TextField(
                controller: _isOtpSent ? _otpController : _phoneController,
                decoration: InputDecoration(
                  labelText: _isOtpSent ? "Enter 6-digit OTP" : "Phone Number (+91)",
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 25),
              _isLoading 
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _isOtpSent ? _handleVerifyOtp : _handleSendOtp,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(_isOtpSent ? "VERIFY OTP" : "GET OTP"),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}