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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;
          final statusBarHeight = MediaQuery.of(context).viewPadding.top;
          final width = constraints.maxWidth;
          final hPadding = width < 600 ? 12.0 : 20.0;
          return Stack(
            children: [
              Container(color: theme.colorScheme.background),
              Positioned(
                top: -screenHeight * 0.1,
                right: -screenHeight * 0.1,
                child: Container(
                  width: screenHeight * 0.4,
                  height: screenHeight * 0.4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ThemeProvider.successGreen.withOpacity(0.05),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(hPadding, statusBarHeight + 16, hPadding, 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
                        onPressed: () => Navigator.pop(context),
                        tooltip: 'Back',
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: ThemeProvider.successGreen.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.edit_outlined,
                          color: ThemeProvider.successGreen,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.foreground,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Spacer(),
                      if (_isLoading)
                        const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                      else
                        ShadButton.ghost(
                          onPressed: _saveProfile,
                          child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                top: statusBarHeight + 80,
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  top: false,
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
              ),
            ],
          );
        },
      ),
    );
  }
} 