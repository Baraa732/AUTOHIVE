# AUTOHIVE

A comprehensive automotive management system with Flutter mobile client and Laravel backend.

## Project Structure

```
AUTOHIVE/
├── client/          # Flutter mobile application
└── server/          # Laravel backend API + Admin Dashboard
```

## Features

- Mobile application built with Flutter
- RESTful API backend with Laravel
- Authentication system
- Notification system
- Cross-platform support (iOS, Android, Web)

## Prerequisites

### For Backend (Laravel)
- PHP >= 8.1
- Composer
- MySQL/PostgreSQL
- Node.js & npm (for asset compilation)

### For Frontend (Flutter)
- Flutter SDK >= 3.0
- Dart SDK
- Android Studio / Xcode (for mobile development)

## Installation & Setup

### Backend Setup

1. Navigate to the server directory:
```bash
cd server
```

2. Install PHP dependencies:
```bash
composer install
```

3. Copy environment file:
```bash
cp .env.example .env
```

4. Generate application key:
```bash
php artisan key:generate
```

5. Configure your database in `.env` file

6. Run migrations:
```bash
php artisan migrate
```

7. Start the development server:
```bash
php artisan serve
```

### Frontend Setup

1. Navigate to the client directory:
```bash
cd client
```

2. Install Flutter dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run
```

## API Documentation

The backend includes Postman collection for API testing:
- `AUTOHIVE_Notifications.postman_collection.json`

## Authentication

Detailed authentication system documentation is available in:
- `server/AUTHENTICATION_SYSTEM_DOCUMENTATION.md`

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is proprietary software.

## Contact

For questions and support, please contact the development team.
