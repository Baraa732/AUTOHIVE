# 📱 MOBILE IMAGE UPLOAD SYSTEM

## 🎯 **COMPLETE MOBILE IMAGE UPLOAD WORKFLOW**

### **Step 1: Upload Images from Mobile**
**Endpoint:** `POST /api/images/upload`
**Headers:** `Authorization: Bearer {landlord_token}`
**Content-Type:** `multipart/form-data`

```javascript
// Mobile App (React Native / Flutter)
const formData = new FormData();
formData.append('images[0]', {
    uri: 'file://path/to/image1.jpg',
    type: 'image/jpeg',
    name: 'apartment1.jpg'
});
formData.append('images[1]', {
    uri: 'file://path/to/image2.jpg', 
    type: 'image/jpeg',
    name: 'apartment2.jpg'
});

fetch('/api/images/upload', {
    method: 'POST',
    headers: {
        'Authorization': 'Bearer ' + token,
        'Content-Type': 'multipart/form-data'
    },
    body: formData
});
```

**Response:**
```json
{
    "success": true,
    "message": "Images uploaded successfully",
    "data": {
        "images": [
            {
                "path": "apartments/abc123.jpg",
                "url": "/storage/apartments/abc123.jpg",
                "size": 1024000,
                "original_name": "apartment1.jpg"
            }
        ],
        "paths": ["apartments/abc123.jpg", "apartments/def456.jpg"]
    }
}
```

### **Step 2: Create Apartment with Uploaded Images**
**Endpoint:** `POST /api/apartments`
**Content-Type:** `multipart/form-data`

```javascript
const apartmentData = new FormData();
apartmentData.append('title', 'Luxury Apartment');
apartmentData.append('description', 'Beautiful apartment');
apartmentData.append('governorate', 'Cairo');
apartmentData.append('city', 'Zamalek');
apartmentData.append('address', '26th July Street');
apartmentData.append('price_per_night', '150.00');
apartmentData.append('max_guests', '4');
apartmentData.append('rooms', '3');
apartmentData.append('bedrooms', '2');
apartmentData.append('bathrooms', '2');
apartmentData.append('area', '120');
apartmentData.append('features[0]', 'wifi');
apartmentData.append('features[1]', 'air_conditioning');

// Add images directly from mobile
apartmentData.append('images[0]', {
    uri: 'file://path/to/image1.jpg',
    type: 'image/jpeg',
    name: 'apartment1.jpg'
});
apartmentData.append('images[1]', {
    uri: 'file://path/to/image2.jpg',
    type: 'image/jpeg', 
    name: 'apartment2.jpg'
});
```

### **Step 3: Display Images in Dashboard**
**Endpoint:** `GET /api/apartments/{id}`

**Response includes:**
```json
{
    "success": true,
    "data": {
        "id": 6,
        "title": "Luxury Apartment",
        "images": ["apartments/abc123.jpg", "apartments/def456.jpg"],
        "image_urls": [
            "http://your-domain/storage/apartments/abc123.jpg",
            "http://your-domain/storage/apartments/def456.jpg"
        ]
    }
}
```

---

## 🔧 **TECHNICAL SPECIFICATIONS**

### **Image Requirements:**
- **Formats:** JPEG, PNG, JPG, WEBP
- **Max Size:** 5MB per image
- **Max Count:** 10 images per apartment
- **Storage:** Laravel Storage (public disk)

### **Mobile Upload Process:**
1. **Select Images** - User picks photos from gallery/camera
2. **Upload Images** - Send to `/api/images/upload`
3. **Get Paths** - Receive storage paths
4. **Create Apartment** - Use paths in apartment creation
5. **Display Images** - Show using `image_urls` attribute

---

## 📱 **MOBILE APP INTEGRATION**

### **React Native Example:**
```javascript
import { launchImageLibrary } from 'react-native-image-picker';

const selectImages = () => {
    launchImageLibrary({
        mediaType: 'photo',
        selectionLimit: 10,
        quality: 0.8
    }, (response) => {
        if (response.assets) {
            uploadImages(response.assets);
        }
    });
};

const uploadImages = async (images) => {
    const formData = new FormData();
    
    images.forEach((image, index) => {
        formData.append(`images[${index}]`, {
            uri: image.uri,
            type: image.type,
            name: image.fileName || `image${index}.jpg`
        });
    });
    
    const response = await fetch('/api/images/upload', {
        method: 'POST',
        headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'multipart/form-data'
        },
        body: formData
    });
    
    const result = await response.json();
    return result.data.paths; // Use these paths for apartment creation
};
```

### **Flutter Example:**
```dart
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

Future<List<String>> uploadImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    
    var request = http.MultipartRequest(
        'POST', 
        Uri.parse('/api/images/upload')
    );
    
    request.headers['Authorization'] = 'Bearer $token';
    
    for (int i = 0; i < images.length; i++) {
        request.files.add(await http.MultipartFile.fromPath(
            'images[$i]', 
            images[i].path
        ));
    }
    
    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    var jsonData = json.decode(responseData);
    
    return List<String>.from(jsonData['data']['paths']);
}
```

---

## 🖼️ **IMAGE MANAGEMENT ENDPOINTS**

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/images/upload` | Upload multiple images |
| `GET` | `/api/images/{path}` | Get image URL |
| `DELETE` | `/api/images/delete` | Delete specific image |
| `POST` | `/api/apartments` | Create apartment with images |
| `PUT` | `/api/apartments/{id}` | Update apartment images |

---

## 🔒 **SECURITY & VALIDATION**

- ✅ **File Type Validation** - Only image formats allowed
- ✅ **Size Limits** - 5MB max per image
- ✅ **Authentication** - Landlord token required
- ✅ **Storage Security** - Files stored in public disk
- ✅ **Path Validation** - Secure file path handling

---

## 📊 **DASHBOARD DISPLAY**

**Frontend can access images via:**
```javascript
// From apartment data
apartment.images // ["apartments/abc123.jpg"]
apartment.image_urls // ["http://domain/storage/apartments/abc123.jpg"]

// Display in HTML
apartment.image_urls.map(url => 
    `<img src="${url}" alt="Apartment" />`
)
```

---

## ✅ **SYSTEM READY FOR MOBILE**

The complete mobile image upload system is now operational:
- 📱 **Mobile Upload** - Direct from phone camera/gallery
- 🏠 **Apartment Creation** - With uploaded images
- 🖥️ **Dashboard Display** - Full image URLs provided
- 🔄 **Image Management** - Upload, view, delete functionality
- 🔒 **Security** - Proper validation and authentication

**Mobile teams can now integrate image uploads seamlessly!** 📸✨