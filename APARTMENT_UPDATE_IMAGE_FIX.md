# Apartment Update Image Fix

## Problem
When editing an apartment, the existing images were not displayed, and adding new images didn't work properly. Users couldn't see what images were already uploaded or manage them during the update process.

## Solution

### Frontend Changes (`client/lib/presentation/screens/shared/add_apartment_screen.dart`)

#### 1. Added Existing Images Tracking
```dart
List<String> _existingImageUrls = []; // Track existing images from server
```

#### 2. Load Existing Images on Edit
```dart
void _loadApartmentData() {
  // ... existing code ...
  
  // Load existing images
  if (apt['images'] != null) {
    _existingImageUrls = List<String>.from(apt['images'] ?? []);
  }
}
```

#### 3. Added Method to Remove Existing Images
```dart
void _removeExistingImage(int index) {
  setState(() {
    _existingImageUrls.removeAt(index);
  });
}
```

#### 4. Updated Validation Logic
```dart
// For editing, allow if there are existing images or new images
if (widget.apartment != null && _existingImageUrls.isEmpty && _selectedImages.isEmpty) {
  _showError('Please keep at least one image or add new images');
  return;
}
```

#### 5. Include Existing Images in Update Request
```dart
final apartmentData = {
  // ... other fields ...
  if (widget.apartment != null) 'existing_images': _existingImageUrls,
};
```

#### 6. Rebuilt Image Section UI
The image section now:
- Shows existing images from the server (using `Image.network`)
- Shows newly selected images (using `Image.file`)
- Displays total count of both existing and new images
- Allows removing both existing and new images
- Shows loading indicator for network images
- Shows error placeholder if image fails to load
- Marks the first image as "Cover"

```dart
Widget _buildImageSection(bool isDark) {
  final totalImages = _existingImageUrls.length + _selectedImages.length;
  
  // Display existing images first, then new images
  // Each with appropriate remove handler
}
```

### Backend Changes (`server/app/Http/Controllers/Api/ApartmentController.php`)

#### 1. Updated Validation Rules
```php
$request->validate([
    // ... existing rules ...
    'bedrooms' => 'integer|min:1',
    'bathrooms' => 'integer|min:1',
    'area' => 'numeric|min:10',
    'existing_images' => 'array',
    'images' => 'array',
    'images.*' => 'image|mimes:jpeg,png,jpg,webp|max:5120'
]);
```

#### 2. Proper Image Handling
```php
// Handle images: combine existing images with new uploads
$finalImages = [];

// Add existing images that weren't removed
if ($request->has('existing_images')) {
    $finalImages = $request->existing_images;
}

// Add new uploaded images
if ($request->hasFile('images')) {
    foreach ($request->file('images') as $image) {
        $path = $image->store('apartments', 'public');
        $finalImages[] = $path;
    }
}

// Update images only if there are changes
if (!empty($finalImages) || $request->has('existing_images')) {
    $data['images'] = $finalImages;
}
```

## How It Works

### Editing Flow

1. **User Opens Edit Screen**
   - Existing apartment data is loaded
   - Existing images are fetched and stored in `_existingImageUrls`
   - Images are displayed in the grid

2. **User Can:**
   - View all existing images
   - Remove existing images (click X button)
   - Add new images (click "Add More" button)
   - Remove newly added images

3. **Image Grid Display**
   - Existing images shown first (loaded from network)
   - New images shown after (loaded from local file)
   - First image always marked as "Cover"
   - Each image has a remove button

4. **On Submit**
   - Frontend sends:
     - `existing_images`: Array of image URLs to keep
     - `images`: Array of new image files to upload
   - Backend:
     - Keeps the existing images from `existing_images` array
     - Uploads new images and adds their paths
     - Combines both into final images array
     - Updates the apartment record

## Key Features

### Visual Feedback
- **Loading State**: Shows spinner while network images load
- **Error Handling**: Shows error icon if image fails to load
- **Cover Badge**: First image clearly marked as cover photo
- **Image Count**: Shows total number of images
- **Remove Buttons**: Clear X button on each image

### Validation
- **New Apartment**: Must have at least 1 new image
- **Edit Apartment**: Must have at least 1 image (existing or new)
- **Clear Error Messages**: Tells user exactly what's wrong

### User Experience
- Existing images load automatically when editing
- Can mix existing and new images
- Can remove any image (existing or new)
- Can add multiple new images at once
- See exactly what will be saved before submitting

## Testing Scenarios

### Test 1: View Existing Images
1. Create apartment with 3 images
2. Edit the apartment
3. **Expected**: All 3 images displayed in grid
4. **Expected**: First image marked as "Cover"

### Test 2: Remove Existing Image
1. Edit apartment with 3 images
2. Click X on second image
3. **Expected**: Image removed from grid
4. **Expected**: Count updates to "2 Photos"
5. Submit update
6. **Expected**: Apartment now has 2 images

### Test 3: Add New Images
1. Edit apartment with 2 existing images
2. Click "Add More"
3. Select 2 new images
4. **Expected**: Grid shows 4 images total
5. **Expected**: First 2 are existing (network), last 2 are new (file)
6. Submit update
7. **Expected**: Apartment now has 4 images

### Test 4: Replace All Images
1. Edit apartment with 3 images
2. Remove all 3 existing images
3. Add 2 new images
4. Submit update
5. **Expected**: Apartment now has 2 new images

### Test 5: Validation - No Images
1. Edit apartment with 1 image
2. Remove the image
3. Try to submit
4. **Expected**: Error "Please keep at least one image or add new images"

### Test 6: Network Error Handling
1. Edit apartment with images
2. Turn off internet
3. **Expected**: Error icon shown for images that fail to load
4. **Expected**: Can still add new images and submit

## API Request Format

### Update Apartment Request
```
PUT /api/apartments/{id}
Content-Type: multipart/form-data

Fields:
- title: string
- description: string
- city: string
- governorate: string
- price_per_night: number
- max_guests: number
- rooms: number
- bedrooms: number
- bathrooms: number
- area: number
- features: array
- existing_images: array (URLs of images to keep)
- images[0]: file (new image 1)
- images[1]: file (new image 2)
- ...
```

### Response
```json
{
  "success": true,
  "message": "Apartment updated successfully",
  "data": {
    "id": 1,
    "title": "Updated Apartment",
    "images": [
      "apartments/existing1.jpg",
      "apartments/existing2.jpg",
      "apartments/new1.jpg",
      "apartments/new2.jpg"
    ],
    ...
  }
}
```

## Files Modified

### Frontend
- `client/lib/presentation/screens/shared/add_apartment_screen.dart`
  - Added `_existingImageUrls` list
  - Updated `_loadApartmentData()` method
  - Added `_removeExistingImage()` method
  - Updated `_submitApartment()` validation
  - Completely rebuilt `_buildImageSection()` widget

### Backend
- `server/app/Http/Controllers/Api/ApartmentController.php`
  - Updated `update()` method validation rules
  - Improved image handling logic
  - Added support for `existing_images` parameter
  - Proper combination of existing and new images

## Benefits

1. **User Can See What They Have**: Existing images displayed clearly
2. **Full Control**: Can remove or keep any existing image
3. **Flexible Updates**: Can add new images without losing existing ones
4. **Better UX**: Visual feedback for loading and errors
5. **Data Integrity**: Backend properly handles image updates
6. **No Data Loss**: Existing images preserved unless explicitly removed

## Future Enhancements

1. **Drag to Reorder**: Allow users to change image order
2. **Crop/Edit**: Built-in image editing before upload
3. **Bulk Actions**: Select multiple images to remove at once
4. **Image Optimization**: Compress images before upload
5. **Progress Indicator**: Show upload progress for each image
6. **Image Preview**: Full-screen preview on tap
