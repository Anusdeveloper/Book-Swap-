import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isOldPasswordCorrect = false;
  bool _isLoading = false;

  Future<void> _validateOldPassword() async {
    setState(() {
      _isLoading = true;
    });

    final user = _auth.currentUser;
    final email = user?.email;

    if (email == null) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User email not found. Please log in again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Re-authenticate user with old password
      final credential = EmailAuthProvider.credential(
        email: email,
        password: _oldPasswordController.text.trim(),
      );

      await user?.reauthenticateWithCredential(credential);
      setState(() {
        _isOldPasswordCorrect = true;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isOldPasswordCorrect = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Old password is incorrect.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final user = _auth.currentUser;
      await user?.updatePassword(_newPasswordController.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Failed to change password.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: Colors.yellow,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_isOldPasswordCorrect) ...[
                const Text(
                  'Enter Old Password',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _oldPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Old Password',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your old password.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _validateOldPassword,
                        child: const Text('Validate Old Password'),
                      ),
              ] else ...[
                const Text(
                  'Enter New Password',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'New Password',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a new password.';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _changePassword,
                  child: const Text('Change Password'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
