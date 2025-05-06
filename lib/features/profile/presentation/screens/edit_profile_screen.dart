import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../../core/theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController(text: 'Taylor');
  final TextEditingController _lastNameController = TextEditingController(text: 'Smith');
  final TextEditingController _emailController = TextEditingController(text: 'taylor.smith@example.com');
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      // TODO: Save profile details to backend
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: ThemeProvider.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ShadForm(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShadInputFormField(
                  controller: _firstNameController,
                  id: 'first-name',
                  label: const Text('First Name'),
                  placeholder: const Text('Enter first name'),
                  validator: (val) => val?.isEmpty == true ? 'Please enter first name' : null,
                ),
                const SizedBox(height: 16),
                ShadInputFormField(
                  controller: _lastNameController,
                  id: 'last-name',
                  label: const Text('Last Name'),
                  placeholder: const Text('Enter last name'),
                  validator: (val) => val?.isEmpty == true ? 'Please enter last name' : null,
                ),
                const SizedBox(height: 16),
                ShadInputFormField(
                  controller: _emailController,
                  id: 'email',
                  label: const Text('Email'),
                  placeholder: const Text('Enter email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Please enter email';
                    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!regex.hasMatch(val)) return 'Enter valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ShadInputFormField(
                  controller: _phoneController,
                  id: 'phone',
                  label: const Text('Phone Number'),
                  placeholder: const Text('Enter phone number'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),
                Center(
                  child: ShadButton(
                    onPressed: _save,
                    child: const Text('Save'),
                  ).animate().fadeIn(duration: 400.ms),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 