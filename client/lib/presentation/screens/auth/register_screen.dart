import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/core.dart';
import '../../widgets/common/animated_input_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  DateTime? _selectedBirthDate;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isRegistering = false;
  String? _selectedGovernorate;
  String? _selectedCity;
  File? _profileImage;
  File? _idImage;
  final ImagePicker _picker = ImagePicker();

  final List<String> _governorates = [
    'Damascus',
    'Aleppo',
    'Homs',
    'Hama',
    'Lattakia',
    'Tartus',
  ];
  final Map<String, List<String>> _cities = {
    'Damascus': ['Damascus', 'Jaramana', 'Sahnaya'],
    'Aleppo': ['Aleppo', 'Afrin', 'Al-Bab'],
    'Homs': ['Homs', 'Palmyra', 'Qusayr'],
    'Hama': ['Hama', 'Salamiyah', 'Suqaylabiyah'],
    'Lattakia': ['Lattakia', 'Jableh', 'Qardaha'],
    'Tartus': ['Tartus', 'Banias', 'Safita'],
  };

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedGovernorate == null ||
        _selectedCity == null ||
        _selectedBirthDate == null ||
        _profileImage == null ||
        _idImage == null) {
      _showError(
        'Please fill all required fields and upload both profile and ID images',
      );
      return;
    }

    setState(() => _isRegistering = true);

    try {
      final result = await AuthService().register(
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
        _phoneController.text.trim(),
        _passwordController.text,
        _selectedCity!,
        _selectedGovernorate!,
        birthDate: _selectedBirthDate,
        profileImage: _profileImage,
        idImage: _idImage,
      );

      if (mounted) {
        setState(() => _isRegistering = false);

        if (result['success'] == true) {
          _showSuccessDialog();
        } else {
          _showError(result['message'] ?? 'Registration failed');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isRegistering = false);
        _showError('Registration failed: ${e.toString()}');
      }
    }
  }

  void _showError(String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              'Registration Error',
              style: TextStyle(
                color: AppTheme.getTextColor(isDark),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            color: AppTheme.getSubtextColor(isDark),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: AppTheme.primaryOrange)),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Text(
              'Registration Successful',
              style: TextStyle(
                color: AppTheme.getTextColor(isDark),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Your account has been created successfully! Please wait for admin approval before you can login.',
          style: TextStyle(
            color: AppTheme.getSubtextColor(isDark),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('OK', style: TextStyle(color: AppTheme.primaryOrange)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.getBackgroundGradient(isDark),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(isDark),
              Expanded(child: _buildRegistrationForm(isDark)),
              _buildRegisterButton(_isRegistering),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: AppTheme.getTextColor(isDark)),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getTextColor(isDark),
                  ),
                ),
                Text(
                  'Fill in your information to get started',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.getSubtextColor(isDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationForm(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: AnimatedInputField(
                    controller: _firstNameController,
                    label: 'First Name',
                    icon: Icons.person,
                    isDark: isDark,
                    hintText: 'Enter your first name',
                    primaryColor: AppTheme.primaryOrange,
                    secondaryColor: AppTheme.primaryBlue,
                    validator: (value) {
                      if (value?.isEmpty ?? true)
                        return 'First name is required';
                      if (value!.length < 2)
                        return 'Must be at least 2 characters';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AnimatedInputField(
                    controller: _lastNameController,
                    label: 'Last Name',
                    icon: Icons.person_outline,
                    isDark: isDark,
                    hintText: 'Enter your last name',
                    primaryColor: AppTheme.primaryOrange,
                    secondaryColor: AppTheme.primaryBlue,
                    validator: (value) {
                      if (value?.isEmpty ?? true)
                        return 'Last name is required';
                      if (value!.length < 2)
                        return 'Must be at least 2 characters';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            AnimatedInputField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              isDark: isDark,
              hintText: '09xxxxxxxx',
              primaryColor: AppTheme.primaryOrange,
              secondaryColor: AppTheme.primaryBlue,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Phone number is required';
                if (!RegExp(r'^09[0-9]{8}$').hasMatch(value!)) {
                  return 'Please enter a valid Syrian phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildLocationDropdowns(isDark),
            const SizedBox(height: 20),
            _buildBirthDatePicker(isDark),
            const SizedBox(height: 24),
            _buildImageUploadSection(isDark),
            const SizedBox(height: 24),
            AnimatedInputField(
              controller: _passwordController,
              label: 'Password',
              icon: Icons.lock,
              isDark: isDark,
              hintText: 'Enter your password',
              obscureText: _obscurePassword,
              primaryColor: AppTheme.primaryBlue,
              secondaryColor: AppTheme.primaryOrange,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Password is required';
                if (value!.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
              onTap: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            const SizedBox(height: 20),
            AnimatedInputField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              icon: Icons.lock_outline,
              isDark: isDark,
              hintText: 'Confirm your password',
              obscureText: _obscureConfirmPassword,
              primaryColor: AppTheme.primaryBlue,
              secondaryColor: AppTheme.primaryOrange,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
              onTap: () => setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationDropdowns(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: _selectedGovernorate,
            decoration: InputDecoration(
              labelText: 'Governorate',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: _governorates
                .map((gov) => DropdownMenuItem(value: gov, child: Text(gov)))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedGovernorate = value;
                _selectedCity = null;
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: _selectedCity,
            decoration: InputDecoration(
              labelText: 'City',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: _selectedGovernorate != null
                ? _cities[_selectedGovernorate]!
                      .map(
                        (city) =>
                            DropdownMenuItem(value: city, child: Text(city)),
                      )
                      .toList()
                : [],
            onChanged: _selectedGovernorate != null
                ? (value) => setState(() => _selectedCity = value)
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildBirthDatePicker(bool isDark) {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedBirthDate ?? DateTime(2000),
          firstDate: DateTime(1950),
          lastDate: DateTime.now().subtract(const Duration(days: 365 * 16)),
        );
        if (date != null) {
          setState(() => _selectedBirthDate = date);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.getBorderColor(isDark)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.cake),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedBirthDate != null
                    ? '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}'
                    : 'Select your birth date',
              ),
            ),
            const Icon(Icons.calendar_today, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadSection(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildImageUploadCard(
            'Profile Photo',
            Icons.person,
            _profileImage,
            () => _pickImage(true),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildImageUploadCard(
            'ID Image',
            Icons.credit_card,
            _idImage,
            () => _pickImage(false),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUploadCard(
    String title,
    IconData icon,
    File? image,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(16),
        ),
        child: image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(image, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 24),
                  const SizedBox(height: 8),
                  Text(title, style: const TextStyle(fontSize: 12)),
                  const Text('Tap to upload', style: TextStyle(fontSize: 10)),
                ],
              ),
      ),
    );
  }

  Future<void> _pickImage(bool isProfile) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isProfile) {
          _profileImage = File(image.path);
        } else {
          _idImage = File(image.path);
        }
      });
    }
  }

  Widget _buildRegisterButton(bool isLoading) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: isLoading ? null : _register,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryOrange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
