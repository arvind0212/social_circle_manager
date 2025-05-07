import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

import '../../../../core/theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  final String? initialFullName;
  final String? initialAvatarUrl;
  final File? pickedImageFile;

  const EditProfileScreen({
    Key? key,
    this.initialFullName,
    this.initialAvatarUrl,
    this.pickedImageFile,
  }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _avatarUrlController;

  File? _pickedImageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String _initials = '';

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.initialFullName ?? '');
    _emailController = TextEditingController(text: Supabase.instance.client.auth.currentUser?.email ?? '');
    _avatarUrlController = TextEditingController(text: widget.initialAvatarUrl ?? '');
    
    if (widget.pickedImageFile != null) {
      _pickedImageFile = widget.pickedImageFile;
    }
    _updateInitials();
  }
  
  void _updateInitials() {
    final name = _fullNameController.text;
    if (name.isNotEmpty) {
      _initials = name
          .split(' ')
          .where((s) => s.isNotEmpty)
          .map((s) => s[0].toUpperCase())
          .take(2)
          .join();
    } else if (_emailController.text.isNotEmpty) {
      _initials = _emailController.text[0].toUpperCase();
    } else {
      _initials = '';
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      setState(() {
        _pickedImageFile = File(image.path);
        _avatarUrlController.text = '';
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      String? newAvatarUrl = _avatarUrlController.text.isNotEmpty ? _avatarUrlController.text : widget.initialAvatarUrl;

      if (_pickedImageFile != null) {
        final file = _pickedImageFile!;
        final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}${p.extension(file.path)}';
        final filePath = 'public/$userId/$fileName';

        await Supabase.instance.client.storage
            .from('user_avatars')
            .upload(filePath, file);
        
        newAvatarUrl = Supabase.instance.client.storage
            .from('user_avatars')
            .getPublicUrl(filePath);
      }

      final Map<String, dynamic> updates = {
        'full_name': _fullNameController.text,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (newAvatarUrl != null && newAvatarUrl.isNotEmpty) {
        updates['avatar_url'] = newAvatarUrl;
      } else if (_pickedImageFile == null && _avatarUrlController.text.isEmpty) {
        updates['avatar_url'] = null; 
      }

      await Supabase.instance.client
          .from('user_profiles')
          .update(updates)
          .eq('id', userId);

      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast(
            title: const Text('Profile Updated'),
            description: const Text('Your profile has been successfully updated.'),
          )
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Error Updating Profile'),
            description: Text(e.toString()),
          )
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))),
            )
          else
            ShadButton.ghost(
              onPressed: _saveProfile,
              child: Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ShadForm(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickAvatar,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.secondary.withOpacity(0.1),
                          border: Border.all(color: theme.colorScheme.primary, width: 2)
                        ),
                        child: ClipOval(
                          child: _pickedImageFile != null
                              ? Image.file(_pickedImageFile!, fit: BoxFit.cover)
                              : (_avatarUrlController.text.isNotEmpty
                                  ? Image.network(
                                      _avatarUrlController.text,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => ShadAvatar(
                                        '',
                                        placeholder: Text(
                                          _initials,
                                          style: theme.textTheme.h1.copyWith(color: theme.colorScheme.primaryForeground),
                                        ),
                                        backgroundColor: theme.colorScheme.primary,
                                      ),
                                    )
                                  : ShadAvatar(
                                      '',
                                      placeholder: Text(
                                        _initials,
                                        style: theme.textTheme.h1.copyWith(color: theme.colorScheme.primaryForeground),
                                      ),
                                      backgroundColor: theme.colorScheme.primary,
                                    )),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.edit, color: theme.colorScheme.primaryForeground, size: 20),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ShadInputFormField(
                  controller: _fullNameController,
                  id: 'full-name',
                  label: const Text('Full Name'),
                  placeholder: const Text('Enter full name'),
                  validator: (val) => val?.isEmpty == true ? 'Please enter your full name' : null,
                  onChanged: (_) => setState(_updateInitials),
                ),
                const SizedBox(height: 16),
                ShadInputFormField(
                  controller: _emailController,
                  id: 'email',
                  label: const Text('Email (cannot be changed)'),
                  readOnly: true,
                  enabled: false,
                  style: TextStyle(color: theme.colorScheme.mutedForeground),
                ),
                const SizedBox(height: 16),
                ShadInputFormField(
                  controller: _avatarUrlController,
                  id: 'avatar-url',
                  label: const Text('Avatar URL (or pick image above)'),
                  placeholder: const Text('Enter avatar URL'),
                  onChanged: (_) => setState((){_pickedImageFile = null;}),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 