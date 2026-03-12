import 'package:flutter/material.dart';
import 'guardian_service.dart';

class GuardianScreen extends StatefulWidget {
  const GuardianScreen({super.key});

  @override
  State<GuardianScreen> createState() => _GuardianScreenState();
}

class _GuardianScreenState extends State<GuardianScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final GuardianService _service = GuardianService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("KAVACH - GUARDIANS")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Guardian Name")),
            TextField(controller: _phoneController, decoration: const InputDecoration(labelText: "Phone Number")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final currentContext = context;
                await _service.addGuardian(_nameController.text, _phoneController.text);
                if (currentContext.mounted) Navigator.pop(currentContext);
              },
              child: const Text("SAVE GUARDIAN"),
            ),
          ],
        ),
      ),
    );
  }
}