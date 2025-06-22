import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sdg/core/theme/app_colors.dart'; // Für Farben
// Pfad anpassen
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart'; // Für E-Mail
import '../providers/user_profile_provider.dart'; // Der neue Provider
// Für Typisierung

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
  // final _aboutController = TextEditingController(); // Falls du 'about' hast

  File? _selectedImageFile; // Hält die ausgewählte Bilddatei

  late UserProfileProvider _profileProvider; // Wird in didChangeDependencies initialisiert
  late AuthenticationProvider _authProvider;       // Wird in didChangeDependencies initialisiert

  bool _isInitialized = false; // Um mehrfache Initialisierung zu vermeiden

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _authProvider = Provider.of<AuthenticationProvider>(context, listen: false);
      _profileProvider = Provider.of<UserProfileProvider>(context, listen: false);

      // Lade initiale Profildaten, falls noch nicht geschehen oder User gewechselt hat
      // Der UserProfileProvider sollte dies idealerweise schon im Konstruktor oder via Listener tun.
      // Ein expliziter Aufruf hier kann als Fallback dienen oder wenn der Screen direkt aufgerufen wird.
      if (_profileProvider.userProfile == null && _authProvider.isLoggedIn) {
        _profileProvider.fetchUserProfileManually(); // Methode im Provider, die getUserProfileUseCase aufruft
      }
      _initializeControllers();
      _isInitialized = true;
    }
  }

  // Listener für Änderungen im UserProfileProvider, um Controller zu aktualisieren
  // wenn sich die Daten ändern (z.B. durch den Stream im Provider)
  @override
  void initState() {
    super.initState();
    // Wir können hier einen Listener hinzufügen, um die Controller zu aktualisieren,
    // wenn sich userProfile im Provider ändert.
    // Aber da der Provider selbst notifyListeners() ruft, wird das Widget neu gebaut
    // und die Controller werden im build() sowieso neu befüllt.
    // Ein expliziter Listener ist oft nur nötig, wenn man etwas tun will,
    // *bevor* der build stattfindet.
    // Fürs Erste reicht das Neubefüllen im build oder eine einmalige Initialisierung.
    // Wenn `watchUserProfile` im Provider den State aktualisiert, wird `build` getriggert.
  }


  void _initializeControllers() {
    final profile = _profileProvider.userProfile;
    if (profile != null) {
      _nameController.text = profile.name;
      _ageController.text = profile.age.toString();
      _studyFieldController.text = profile.studyField;
      _schoolController.text = profile.school;
      // _aboutController.text = profile.about ?? '';
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

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (!_authProvider.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to save.')));
      return;
    }

    final success = await _profileProvider.updateProfile(
      name: _nameController.text,
      age: int.tryParse(_ageController.text) ?? (_profileProvider.userProfile?.age ?? 0),
      studyField: _studyFieldController.text,
      school: _schoolController.text,
      imageFileToUpload: _selectedImageFile,
      // about: _aboutController.text,
    );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_profileProvider.profileError ?? 'Failed to update profile.')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _studyFieldController.dispose();
    _schoolController.dispose();
    // _aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Verwende Consumer, um auf Änderungen im Provider zu reagieren und die UI neu zu bauen
    return Consumer<UserProfileProvider>(
      builder: (context, profileProvider, child) {
        // Befülle Controller, wenn sich userProfile ändert und das Widget neu gebaut wird
        // Dies stellt sicher, dass die Felder aktuell sind, wenn der Stream im Provider neue Daten liefert.
        // Aber nur, wenn der User nicht gerade tippt (um Cursor-Sprünge zu vermeiden).
        // Eine bessere Lösung wäre, die Controller nur einmal in initState/didChangeDependencies
        // zu füllen und für Updates auf den Stream zu hören und ggf. die Felder
        // zu aktualisieren, wenn sie nicht den Fokus haben.
        // Fürs Erste, wenn das Profil geladen wird:
        if (profileProvider.userProfile != null && !_isLoadingSomething()) { // _isLoadingSomething() wäre eine Kombi aus profileProvider.isLoadingProfile und profileProvider.isUpdatingProfile
          // Nur aktualisieren, wenn die Controller nicht den Fokus haben, um Tippen nicht zu stören
          if (!FocusScope.of(context).hasFocus) {
            _initializeControllers(); // Befüllt die Controller mit den neuesten Daten
          }
        }


        ImageProvider? avatarImageProvider;
        if (_selectedImageFile != null) {
          avatarImageProvider = FileImage(_selectedImageFile!);
        } else if (profileProvider.userProfile?.profileImageUrl != null &&
            profileProvider.userProfile!.profileImageUrl!.isNotEmpty) {
          avatarImageProvider = NetworkImage(profileProvider.userProfile!.profileImageUrl!);
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (profileProvider.isLoadingProfile && profileProvider.userProfile == null)
                    const Center(child: CircularProgressIndicator())
                  else if (profileProvider.profileError != null && profileProvider.userProfile == null)
                    Center(child: Text('Error: ${profileProvider.profileError}', style: TextStyle(color: AppColors.accentRed)))
                  else if (profileProvider.userProfile == null && !_authProvider.isLoggedIn)
                      const Center(child: Text('Please log in to edit your profile.', style: TextStyle(color: AppColors.primaryText)))
                    else ...[ // Spread Operator, um die Liste von Widgets hier einzufügen
                        GestureDetector(
                          onTap: _openImagePicker,
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey.shade700,
                            backgroundImage: avatarImageProvider,
                            child: avatarImageProvider == null
                                ? const Icon(Icons.camera_alt, color: Colors.white, size: 30)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text('Email: ${_authProvider.currentUserEmail ?? 'N/A'}',
                            style: const TextStyle(color: AppColors.primaryText, fontFamily: 'OswaldLight')),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: AppColors.primaryText),
                          decoration: _inputDecoration('Name'),
                          validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _ageController,
                          style: const TextStyle(color: AppColors.primaryText),
                          decoration: _inputDecoration('Age'),
                          keyboardType: TextInputType.number,
                          validator: (value) => value == null || value.isEmpty ? 'Please enter an age' : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _studyFieldController,
                          style: const TextStyle(color: AppColors.primaryText),
                          decoration: _inputDecoration('Study Field'),
                          validator: (value) => value == null || value.isEmpty ? 'Please enter a study field' : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _schoolController,
                          style: const TextStyle(color: AppColors.primaryText),
                          decoration: _inputDecoration('School'),
                          validator: (value) => value == null || value.isEmpty ? 'Please enter a school' : null,
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentGreen),
                          onPressed: profileProvider.isUpdatingProfile ? null : _saveProfile,
                          child: profileProvider.isUpdatingProfile
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Save Changes', style: TextStyle(color: AppColors.primaryText, fontFamily: 'OswaldLight')),
                        ),
                        const SizedBox(height: 16),
                        // Center(child: DeleteButton()), // Dein DeleteButton, Logik dafür muss auch in den Provider
                      ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppColors.cardBackground, // Theme-Farbe verwenden
      labelStyle: TextStyle(fontFamily: 'OswaldLight', color: AppColors.primaryText.withOpacity(0.7)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.accentGreen.withOpacity(0.5))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.accentGreen, width: 2)),
    );
  }
  bool _isLoadingSomething() {
    return _profileProvider.isLoadingProfile || _profileProvider.isUpdatingProfile;
  }
}