import 'package:flutter/material.dart';
import 'auth_service.dart';

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
    setState(() => _isLoading = true);
    await _authService.verifyPhoneNumber(
      _phoneController.text.trim(),
      (verId) {
        setState(() {
          _verificationId = verId;
          _isOtpSent = true;
          _isLoading = false;
        });
      },
      (error) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      },
    );
  }

  void _handleVerifyOtp() async {
    setState(() => _isLoading = true);
    var user = await _authService.signInWithOTP(_verificationId, _otpController.text.trim());
    
    setState(() => _isLoading = false);
    if (user != null) {
      // Logic: Navigate to KAVACH Home Screen here
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login Successful!")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid OTP")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("KAVACH SECURITY")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shield, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            Text(
              _isOtpSent ? "Enter OTP" : "Phone Login",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _isOtpSent ? _otpController : _phoneController,
              decoration: InputDecoration(
                labelText: _isOtpSent ? "6-Digit Code" : "Phone Number (+91...)",
                border: const OutlineInputBorder(),
                prefixIcon: Icon(_isOtpSent ? Icons.lock : Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            _isLoading 
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _isOtpSent ? _handleVerifyOtp : _handleSendOtp,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    backgroundColor: Colors.blue,
                  ),
                  child: Text(
                    _isOtpSent ? "VERIFY & LOGIN" : "GET OTP",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}