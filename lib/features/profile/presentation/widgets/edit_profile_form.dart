import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/user_profile_provider.dart';

class EditProfileForm extends StatefulWidget {
  const EditProfileForm({super.key});

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _studyFieldController = TextEditingController();
  final _schoolController = TextEditingController();

  File? _selectedImageFile;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final authProvider = context.read<AuthenticationProvider>();
      final profileProvider = context.read<UserProfileProvider>();

      if (profileProvider.userProfile == null && authProvider.isLoggedIn) {
        profileProvider.fetchUserProfileManually();
      }
      _initializeControllers(profileProvider);
      _isInitialized = true;
    }
  }

  void _initializeControllers(UserProfileProvider provider) {
    final profile = provider.userProfile;
    if (profile != null) {
      _nameController.text = profile.name;
      _ageController.text = profile.age.toString();
      _studyFieldController.text = profile.studyField;
      _schoolController.text = profile.school;
    }
  }

  Future<void> _openImagePicker() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedImage != null) {
      setState(() {
        _selectedImageFile = File(pickedImage.path);
      });
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    if (!mounted) return;
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? theme.colorScheme.error : theme.colorScheme.primary,
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final authProvider = context.read<AuthenticationProvider>();
    final profileProvider = context.read<UserProfileProvider>();

    if (!authProvider.isLoggedIn) {
      _showSnackbar('You must be logged in to save.', isError: true);
      return;
    }

    final success = await profileProvider.updateProfile(
      name: _nameController.text,
      age: int.tryParse(_ageController.text) ?? 0,
      studyField: _studyFieldController.text,
      school: _schoolController.text,
      imageFileToUpload: _selectedImageFile,
    );

    if (mounted) {
      if (success) {
        _showSnackbar('Profile updated successfully!');
        Navigator.pop(context);
      } else {
        _showSnackbar(profileProvider.profileError ?? 'Failed to update profile.', isError: true);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _studyFieldController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthenticationProvider>();

    return Consumer<UserProfileProvider>(
      builder: (context, profileProvider, child) {
        if (profileProvider.userProfile != null && !profileProvider.isUpdatingProfile && !profileProvider.isLoadingProfile) {
          if (!FocusScope.of(context).hasFocus) {
            _initializeControllers(profileProvider);
          }
        }

        ImageProvider? avatarImageProvider;
        if (_selectedImageFile != null) {
          avatarImageProvider = FileImage(_selectedImageFile!);
        } else if (profileProvider.userProfile?.profileImageUrl?.isNotEmpty ?? false) {
          avatarImageProvider = NetworkImage(profileProvider.userProfile!.profileImageUrl!);
        }

        if (profileProvider.isLoadingProfile && profileProvider.userProfile == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (profileProvider.profileError != null && profileProvider.userProfile == null) {
          return Center(child: Text('Error: ${profileProvider.profileError}', style: TextStyle(color: theme.colorScheme.error)));
        }

        if (!authProvider.isLoggedIn) {
          return Center(child: Text('Please log in to edit your profile.', style: theme.textTheme.bodyLarge));
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _openImagePicker,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      backgroundImage: avatarImageProvider,
                      child: avatarImageProvider == null ? Icon(Icons.camera_alt, color: theme.colorScheme.onSurfaceVariant, size: 30) : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Email: ${authProvider.currentUserEmail ?? 'N/A'}', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _ageController,
                    decoration: const InputDecoration(labelText: 'Age'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty ? 'Please enter an age' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _studyFieldController,
                    decoration: const InputDecoration(labelText: 'Study Field'),
                    validator: (value) => value == null || value.isEmpty ? 'Please enter a study field' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _schoolController,
                    decoration: const InputDecoration(labelText: 'School'),
                    validator: (value) => value == null || value.isEmpty ? 'Please enter a school' : null,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: profileProvider.isUpdatingProfile ? null : _saveProfile,
                    child: profileProvider.isUpdatingProfile
                        ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.onPrimary))
                        : const Text('Save Changes'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}