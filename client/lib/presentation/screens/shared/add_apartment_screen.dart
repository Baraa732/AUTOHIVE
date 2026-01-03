import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/core.dart';
import '../../providers/apartment_provider.dart';
import '../../widgets/common/animated_input_field.dart' show AnimatedInputField;

class AddApartmentScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? apartment;

  const AddApartmentScreen({super.key, this.apartment});

  @override
  ConsumerState<AddApartmentScreen> createState() => _AddApartmentScreenState();
}

class _AddApartmentScreenState extends ConsumerState<AddApartmentScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _maxGuestsController = TextEditingController();
  final _roomsController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _areaController = TextEditingController();

  String? _selectedGovernorate;
  String? _selectedCity;
  List<File> _selectedImages = [];
  List<String> _selectedFeatures = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  List<Map<String, String>> _availableFeatures = [];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_animationController);
    _animationController.forward();
    _loadAvailableFeatures();
    if (widget.apartment != null) {
      _loadApartmentData();
    }
  }

  void _loadApartmentData() {
    final apt = widget.apartment!;
    _titleController.text = apt['title'] ?? '';
    _descriptionController.text = apt['description'] ?? '';
    _priceController.text = apt['price_per_night']?.toString() ?? '';
    _maxGuestsController.text = apt['max_guests']?.toString() ?? '';
    _roomsController.text = apt['rooms']?.toString() ?? '';
    _bedroomsController.text = apt['bedrooms']?.toString() ?? '';
    _bathroomsController.text = apt['bathrooms']?.toString() ?? '';
    _areaController.text = apt['area']?.toString() ?? '';

    setState(() {
      _selectedGovernorate = apt['governorate'];
      _selectedCity = apt['city'];
      if (apt['features'] != null) {
        _selectedFeatures = List<String>.from(apt['features'] ?? []);
      }
    });
  }

  Future<void> _loadAvailableFeatures() async {
    try {
      final apiService = ApiService();
      final result = await apiService.getApartmentFeatures();
      if (result['success'] == true && result['data'] != null) {
        if (mounted) {
          setState(() {
            _availableFeatures = List<Map<String, String>>.from(
              (result['data'] as List).map(
                (feature) => {
                  'value': feature['value']?.toString() ?? '',
                  'label': feature['label']?.toString() ?? '',
                },
              ),
            );
          });
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to load available features');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _maxGuestsController.dispose();
    _roomsController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImages.add(File(image.path));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitApartment() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedGovernorate == null || _selectedCity == null) {
      _showError('Please select governorate and city');
      return;
    }

    if (widget.apartment == null && _selectedImages.isEmpty) {
      _showError('Please select at least one image');
      return;
    }

    setState(() => _isLoading = true);

    final apartmentData = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'city': _selectedCity!,
      'governorate': _selectedGovernorate!,
      'address': '$_selectedCity, $_selectedGovernorate',
      'price_per_night': double.tryParse(_priceController.text) ?? 0.0,
      'max_guests': int.tryParse(_maxGuestsController.text) ?? 1,
      'rooms': int.tryParse(_roomsController.text) ?? 1,
      'bedrooms': int.tryParse(_bedroomsController.text) ?? 1,
      'bathrooms': int.tryParse(_bathroomsController.text) ?? 1,
      'area': double.tryParse(_areaController.text) ?? 0.0,
      'features': _selectedFeatures,
    };

    try {
      if (widget.apartment != null) {
        await ref
            .read(apartmentProvider.notifier)
            .updateApartment(
              widget.apartment!['id'].toString(),
              apartmentData,
              _selectedImages,
            );
        if (mounted) {
          _showSuccessDialog(isEdit: true);
          Navigator.pop(context, true);
        }
      } else {
        await ref
            .read(apartmentProvider.notifier)
            .addApartment(apartmentData, _selectedImages);
        if (mounted) {
          _clearForm();
          _showSuccessDialog();
        }
      }
    } catch (e) {
      if (mounted) {
        final action = widget.apartment != null ? 'update' : 'add';
        _showError('Failed to $action apartment: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _maxGuestsController.clear();
    _roomsController.clear();
    _bedroomsController.clear();
    _bathroomsController.clear();
    _areaController.clear();
    setState(() {
      _selectedGovernorate = null;
      _selectedCity = null;
      _selectedImages = [];
      _selectedFeatures = [];
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessDialog({bool isEdit = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Text(
              'Success!',
              style: TextStyle(
                color: AppTheme.getTextColor(isDark),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          isEdit
              ? 'Your apartment has been updated successfully!'
              : 'Your apartment has been created successfully and is now live!',
          style: TextStyle(
            color: AppTheme.getSubtextColor(isDark),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (!isEdit) {
                if (mounted) {
                  _clearForm();
                }
              } else {
                if (mounted && Navigator.canPop(context)) {
                  Navigator.of(context).pop(true);
                }
              }
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
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildBasicInfoSection(isDark),
                          const SizedBox(height: 24),
                          _buildLocationSection(isDark),
                          const SizedBox(height: 24),
                          _buildDetailsSection(isDark),
                          const SizedBox(height: 24),
                          _buildFeaturesSection(isDark),
                          const SizedBox(height: 24),
                          _buildImageSection(isDark),
                          const SizedBox(height: 32),
                          _buildSubmitButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final isEdit = widget.apartment != null;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEdit ? 'Edit Apartment' : 'Add Apartment',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.getTextColor(isDark),
            ),
          ),
          Text(
            isEdit
                ? 'Update your apartment details'
                : 'Create your apartment listing',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.getSubtextColor(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection(bool isDark) {
    return _buildSection('Basic Information', isDark, [
      TextFormField(
        controller: _titleController,
        decoration: _getInputDecoration('Title', Icons.home, isDark),
        validator: (value) {
          if (value?.isEmpty ?? true) return 'Title is required';
          if (value!.length < 3) return 'Title must be at least 3 characters';
          return null;
        },
      ),
      const SizedBox(height: 20),
      TextFormField(
        controller: _descriptionController,
        decoration: _getInputDecoration(
          'Description',
          Icons.description,
          isDark,
        ),
        maxLines: 4,
        validator: (value) {
          if (value?.isEmpty ?? true) return 'Description is required';
          if (value!.length < 10) {
            return 'Description must be at least 10 characters';
          }
          return null;
        },
      ),
    ]);
  }

  Widget _buildLocationSection(bool isDark) {
    return _buildSection('Location', isDark, [
      Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _selectedGovernorate,
              decoration: _getInputDecoration(
                'Governorate',
                Icons.location_city,
                isDark,
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
              validator: (value) =>
                  value == null ? 'Please select governorate' : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _selectedCity,
              decoration: _getInputDecoration(
                'City',
                Icons.location_on,
                isDark,
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
              validator: (value) => value == null ? 'Please select city' : null,
            ),
          ),
        ],
      ),
    ]);
  }

  Widget _buildDetailsSection(bool isDark) {
    return _buildSection('Details', isDark, [
      AnimatedInputField(
        controller: _priceController,
        label: 'Price per Night (\$)',
        icon: Icons.attach_money,
        isDark: isDark,
        hintText: 'Enter price per night',
        keyboardType: TextInputType.number,
        primaryColor: AppTheme.primaryOrange,
        secondaryColor: AppTheme.primaryBlue,
        validator: (value) {
          if (value?.isEmpty ?? true) return 'Price is required';
          final price = double.tryParse(value!);
          if (price == null || price <= 0) return 'Enter a valid price';
          return null;
        },
      ),
      const SizedBox(height: 20),
      Row(
        children: [
          Expanded(
            child: AnimatedInputField(
              controller: _maxGuestsController,
              label: 'Max Guests',
              icon: Icons.people,
              isDark: isDark,
              hintText: '1',
              keyboardType: TextInputType.number,
              primaryColor: AppTheme.primaryOrange,
              secondaryColor: AppTheme.primaryBlue,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Required';
                final guests = int.tryParse(value!);
                if (guests == null || guests <= 0) return 'Invalid';
                return null;
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AnimatedInputField(
              controller: _roomsController,
              label: 'Rooms',
              icon: Icons.meeting_room,
              isDark: isDark,
              hintText: '1',
              keyboardType: TextInputType.number,
              primaryColor: AppTheme.primaryOrange,
              secondaryColor: AppTheme.primaryBlue,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Required';
                final rooms = int.tryParse(value!);
                if (rooms == null || rooms <= 0) return 'Invalid';
                return null;
              },
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      Row(
        children: [
          Expanded(
            child: AnimatedInputField(
              controller: _bedroomsController,
              label: 'Bedrooms',
              icon: Icons.bed,
              isDark: isDark,
              hintText: '1',
              keyboardType: TextInputType.number,
              primaryColor: AppTheme.primaryOrange,
              secondaryColor: AppTheme.primaryBlue,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Required';
                final bedrooms = int.tryParse(value!);
                if (bedrooms == null || bedrooms <= 0) return 'Invalid';
                return null;
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AnimatedInputField(
              controller: _bathroomsController,
              label: 'Bathrooms',
              icon: Icons.bathtub,
              isDark: isDark,
              hintText: '1',
              keyboardType: TextInputType.number,
              primaryColor: AppTheme.primaryOrange,
              secondaryColor: AppTheme.primaryBlue,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Required';
                final bathrooms = int.tryParse(value!);
                if (bathrooms == null || bathrooms <= 0) return 'Invalid';
                return null;
              },
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      AnimatedInputField(
        controller: _areaController,
        label: 'Area (m²)',
        icon: Icons.square_foot,
        isDark: isDark,
        hintText: 'Enter area in square meters',
        keyboardType: TextInputType.number,
        primaryColor: AppTheme.primaryOrange,
        secondaryColor: AppTheme.primaryBlue,
        validator: (value) {
          if (value?.isEmpty ?? true) return 'Area is required';
          final area = double.tryParse(value!);
          if (area == null || area <= 0) return 'Enter a valid area';
          return null;
        },
      ),
    ]);
  }

  Widget _buildFeaturesSection(bool isDark) {
    return _buildSection('Features & Amenities', isDark, [
      if (_availableFeatures.isEmpty)
        Center(
          child: Text(
            'Loading features...',
            style: TextStyle(color: AppTheme.getSubtextColor(isDark)),
          ),
        )
      else
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableFeatures.map((feature) {
            final featureValue = feature['value'] ?? '';
            final featureLabel = feature['label'] ?? '';
            final isSelected = _selectedFeatures.contains(featureValue);
            return FilterChip(
              label: Text(featureLabel),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedFeatures.add(featureValue);
                  } else {
                    _selectedFeatures.remove(featureValue);
                  }
                });
              },
              selectedColor: AppTheme.primaryOrange.withValues(alpha: 0.3),
              checkmarkColor: AppTheme.primaryOrange,
              backgroundColor: AppTheme.getCardColor(isDark),
              labelStyle: TextStyle(
                color: isSelected
                    ? AppTheme.primaryOrange
                    : AppTheme.getTextColor(isDark),
              ),
            );
          }).toList(),
        ),
    ]);
  }

  Widget _buildImageSection(bool isDark) {
    return _buildSection('Images', isDark, [
      GestureDetector(
        onTap: _pickImages,
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.getBorderColor(isDark)),
            borderRadius: BorderRadius.circular(12),
            color: AppTheme.getCardColor(isDark),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate,
                size: 40,
                color: AppTheme.getSubtextColor(isDark),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap to add images',
                style: TextStyle(color: AppTheme.getSubtextColor(isDark)),
              ),
            ],
          ),
        ),
      ),
      if (_selectedImages.isNotEmpty) ...[
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _selectedImages.length,
          itemBuilder: (context, index) {
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _selectedImages[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => _removeImage(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          '${_selectedImages.length} image(s) selected',
          style: TextStyle(
            color: AppTheme.getSubtextColor(isDark),
            fontSize: 12,
          ),
        ),
      ],
    ]);
  }

  Widget _buildSubmitButton() {
    final isEdit = widget.apartment != null;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitApartment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryOrange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                isEdit ? 'Update Apartment' : 'Submit Apartment',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildSection(String title, bool isDark, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(isDark).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.getBorderColor(isDark), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.getTextColor(isDark),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  InputDecoration _getInputDecoration(
    String label,
    IconData icon,
    bool isDark,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppTheme.primaryOrange),
      labelStyle: TextStyle(color: AppTheme.getSubtextColor(isDark)),
      filled: true,
      fillColor: AppTheme.getCardColor(isDark),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.getBorderColor(isDark)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.getBorderColor(isDark)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.primaryOrange, width: 2),
      ),
    );
  }
}
