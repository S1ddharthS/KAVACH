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

  String _verificationId = "";
  bool _isOtpSent = false;
  bool _isLoading = false;

  void _handleSendOtp() async {
    final currentContext = context;
    setState(() => _isLoading = true);
    await _authService.verifyPhoneNumber(
      _phoneController.text.trim(),
      (verId) {
        if (!mounted) return;
        setState(() {
          _verificationId = verId;
          _isOtpSent = true;
          _isLoading = false;
        });
      },
      (error) {
        if (!currentContext.mounted) return;
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(currentContext).showSnackBar(SnackBar(content: Text(error)));
      },
    );
  }

  void _handleVerifyOtp() async {
    final currentContext = context;
    setState(() => _isLoading = true);
    var user = await _authService.signInWithOTP(_verificationId, _otpController.text.trim());
    
    if (!currentContext.mounted) return;
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (user != null) {
      Navigator.pushReplacement(
        currentContext,
        MaterialPageRoute(builder: (context) => const GuardianScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("KAVACH FLUTTER LOGIN")),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            TextField(
              controller: _isOtpSent ? _otpController : _phoneController,
              decoration: InputDecoration(
                labelText: _isOtpSent ? "Enter OTP" : "Phone Number",
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading 
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _isOtpSent ? _handleVerifyOtp : _handleSendOtp,
                  child: Text(_isOtpSent ? "VERIFY" : "GET OTP"),
                ),
          ],
        ),
      ),
    );
  }
}