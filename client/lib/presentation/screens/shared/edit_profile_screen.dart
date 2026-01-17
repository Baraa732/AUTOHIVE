import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/core.dart';
import '../../providers/auth_provider.dart';
import '../auth/welcome_screen.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _birthDateController;
  late TextEditingController _cityController;
  late TextEditingController _governorateController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  String? _selectedBirthDate;
  File? _profileImageFile;
  File? _idImageFile;
  bool _isLoading = false;
  bool _showPasswordSection = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;

    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _birthDateController = TextEditingController(
      text: user?.birthDate != null ? user!.birthDate! : '',
    );
    _cityController = TextEditingController(text: user?.city ?? '');
    _governorateController = TextEditingController(
      text: user?.governorate ?? '',
    );
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    if (user?.birthDate != null && user!.birthDate!.isNotEmpty) {
      _selectedBirthDate = user.birthDate;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _birthDateController.dispose();
    _cityController.dispose();
    _governorateController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _profileImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickIdImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _idImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate != null
          ? DateTime.parse(_selectedBirthDate!)
          : DateTime.now().subtract(const Duration(days: 18 * 365)),
      firstDate: DateTime.now().subtract(const Duration(days: 100 * 365)),
      lastDate: DateTime.now().subtract(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked.toString().split(' ')[0];
        _birthDateController.text = _selectedBirthDate!;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) throw Exception('Not authenticated');

      // Update basic profile information
      final profileData = {
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'birth_date': _birthDateController.text,
        'city': _cityController.text.trim(),
        'governorate': _governorateController.text.trim(),
      };

      final profileResponse = await http.put(
        Uri.parse('${await AppConfig.baseUrl}/profile/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(profileData),
      );

      if (!profileResponse.statusCode.toString().startsWith('2')) {
        throw Exception('Failed to update profile');
      }

      // Upload profile image if selected
      if (_profileImageFile != null) {
        final profileImageRequest = http.MultipartRequest(
          'POST',
          Uri.parse('${await AppConfig.baseUrl}/profile/upload-image'),
        );
        profileImageRequest.headers['Authorization'] = 'Bearer $token';
        profileImageRequest.files.add(
          await http.MultipartFile.fromPath('image', _profileImageFile!.path),
        );

        final profileImageResponse = await profileImageRequest.send();
        if (!profileImageResponse.statusCode.toString().startsWith('2')) {
          throw Exception('Failed to upload profile image');
        }
      }

      // Upload ID image if selected
      if (_idImageFile != null) {
        final idImageRequest = http.MultipartRequest(
          'POST',
          Uri.parse('${await AppConfig.baseUrl}/profile/upload-id'),
        );
        idImageRequest.headers['Authorization'] = 'Bearer $token';
        idImageRequest.files.add(
          await http.MultipartFile.fromPath('image', _idImageFile!.path),
        );

        final idImageResponse = await idImageRequest.send();
        if (!idImageResponse.statusCode.toString().startsWith('2')) {
          throw Exception('Failed to upload ID image');
        }
      }

      // Update password if provided
      if (_showPasswordSection && _currentPasswordController.text.isNotEmpty) {
        final passwordData = {
          'current_password': _currentPasswordController.text,
          'new_password': _newPasswordController.text,
          'new_password_confirmation': _confirmPasswordController.text,
        };

        final passwordResponse = await http.post(
          Uri.parse('${await AppConfig.baseUrl}/profile/change-password'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(passwordData),
        );

        if (!passwordResponse.statusCode.toString().startsWith('2')) {
          final errorData = json.decode(passwordResponse.body);
          throw Exception(errorData['message'] ?? 'Failed to change password');
        }
      }

      // Refresh user data by fetching updated profile
      try {
        final profileResponse = await http.get(
          Uri.parse('${await AppConfig.baseUrl}/profile/show'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (profileResponse.statusCode.toString().startsWith('2')) {
          final profileData = json.decode(profileResponse.body);
          if (profileData['success'] == true && profileData['data'] != null) {
            final updatedUser = User.fromJson(profileData['data']['user']);
            ref.read(authProvider.notifier).updateUser(updatedUser);
          }
        }
      } catch (e) {
        // If refresh fails, continue with success message
        print('Failed to refresh user data: $e');
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
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
    final isDarkMode = ref.watch(themeProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(isDarkMode),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppTheme.getTextColor(isDarkMode),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: AppTheme.getTextColor(isDarkMode),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.getBackgroundGradient(isDarkMode),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Image Section
                _buildImageSection(isDarkMode, user),
                const SizedBox(height: 32),

                // Personal Information Section
                _buildSectionTitle('Personal Information', isDarkMode),
                const SizedBox(height: 16),
                _buildPersonalInfoSection(isDarkMode),
                const SizedBox(height: 32),

                // Location Information Section
                _buildSectionTitle('Location Information', isDarkMode),
                const SizedBox(height: 16),
                _buildLocationSection(isDarkMode),
                const SizedBox(height: 32),

                // Password Section
                _buildSectionTitle('Password', isDarkMode),
                const SizedBox(height: 16),
                _buildPasswordSection(isDarkMode),
                const SizedBox(height: 40),

                // Save Button
                _buildSaveButton(isDarkMode),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.getTextColor(isDarkMode),
      ),
    );
  }

  Widget _buildImageSection(bool isDarkMode, User? user) {
    return Column(
      children: [
        Center(
          child: Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFff6f2d), width: 3),
                ),
                child: ClipOval(
                  child: _profileImageFile != null
                      ? Image.file(_profileImageFile!, fit: BoxFit.cover)
                      : (user?.profileImageUrl != null)
                      ? Image.network(
                          user!.profileImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey[600],
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey[600],
                          ),
                        ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickProfileImage,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFff6f2d),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ID Image Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(isDarkMode),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.getBorderColor(isDarkMode)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ID Document',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getTextColor(isDarkMode),
                ),
              ),
              const SizedBox(height: 12),
              if (_idImageFile != null)
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.getBorderColor(isDarkMode),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(_idImageFile!, fit: BoxFit.cover),
                  ),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _pickIdImage,
                  icon: const Icon(Icons.upload_file, size: 20),
                  label: Text(
                    _idImageFile != null
                        ? 'Change ID Document'
                        : 'Upload ID Document',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4a90e2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoSection(bool isDarkMode) {
    return Column(
      children: [
        _buildTextField(
          controller: _firstNameController,
          label: 'First Name',
          icon: Icons.person,
          isDarkMode: isDarkMode,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your first name';
            }
            if (value.trim().length < 2) {
              return 'First name must be at least 2 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _lastNameController,
          label: 'Last Name',
          icon: Icons.person_outline,
          isDarkMode: isDarkMode,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your last name';
            }
            if (value.trim().length < 2) {
              return 'Last name must be at least 2 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildDateField(
          controller: _birthDateController,
          label: 'Birth Date',
          icon: Icons.calendar_today,
          isDarkMode: isDarkMode,
          onTap: _selectBirthDate,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select your birth date';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLocationSection(bool isDarkMode) {
    return Column(
      children: [
        _buildTextField(
          controller: _governorateController,
          label: 'Governorate',
          icon: Icons.location_city,
          isDarkMode: isDarkMode,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your governorate';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _cityController,
          label: 'City',
          icon: Icons.location_on,
          isDarkMode: isDarkMode,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your city';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordSection(bool isDarkMode) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _showPasswordSection = !_showPasswordSection;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.getCardColor(isDarkMode),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.getBorderColor(isDarkMode)),
            ),
            child: Row(
              children: [
                Icon(Icons.lock, color: AppTheme.getTextColor(isDarkMode)),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Change Password',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.getTextColor(isDarkMode),
                    ),
                  ),
                ),
                Icon(
                  _showPasswordSection ? Icons.expand_less : Icons.expand_more,
                  color: AppTheme.getTextColor(isDarkMode),
                ),
              ],
            ),
          ),
        ),
        if (_showPasswordSection) ...[
          const SizedBox(height: 16),
          _buildTextField(
            controller: _currentPasswordController,
            label: 'Current Password',
            icon: Icons.lock_outline,
            isDarkMode: isDarkMode,
            obscureText: true,
            validator: (value) {
              if (_showPasswordSection && (value == null || value.isEmpty)) {
                return 'Please enter your current password';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _newPasswordController,
            label: 'New Password',
            icon: Icons.lock,
            isDarkMode: isDarkMode,
            obscureText: true,
            validator: (value) {
              if (_showPasswordSection && (value == null || value.isEmpty)) {
                return 'Please enter a new password';
              }
              if (_showPasswordSection && value != null && value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _confirmPasswordController,
            label: 'Confirm New Password',
            icon: Icons.lock,
            isDarkMode: isDarkMode,
            obscureText: true,
            validator: (value) {
              if (_showPasswordSection && (value == null || value.isEmpty)) {
                return 'Please confirm your new password';
              }
              if (_showPasswordSection &&
                  value != _newPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDarkMode,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: TextStyle(color: AppTheme.getTextColor(isDarkMode), fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFff6f2d)),
        filled: true,
        fillColor: AppTheme.getCardColor(isDarkMode),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.getBorderColor(isDarkMode)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.getBorderColor(isDarkMode)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFff6f2d), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        labelStyle: TextStyle(color: AppTheme.getSubtextColor(isDarkMode)),
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDarkMode,
    required VoidCallback onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      validator: validator,
      onTap: onTap,
      style: TextStyle(color: AppTheme.getTextColor(isDarkMode), fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFff6f2d)),
        filled: true,
        fillColor: AppTheme.getCardColor(isDarkMode),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.getBorderColor(isDarkMode)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.getBorderColor(isDarkMode)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFff6f2d), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        labelStyle: TextStyle(color: AppTheme.getSubtextColor(isDarkMode)),
        suffixIcon: Icon(Icons.calendar_today, color: const Color(0xFFff6f2d)),
      ),
    );
  }

  Widget _buildSaveButton(bool isDarkMode) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFff6f2d), Color(0xFF4a90e2)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFff6f2d).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _updateProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
