# AUTOHIVE Authentication & User Management System
## Technical Documentation for Backend API Database Functionality

### Table of Contents
1. [System Architecture Overview](#system-architecture-overview)
2. [Authentication Flow](#authentication-flow)
3. [Registration Process](#registration-process)
4. [Login Process](#login-process)
5. [User Approval Workflow](#user-approval-workflow)
6. [Notification System](#notification-system)
7. [Database Schema](#database-schema)
8. [Package Dependencies](#package-dependencies)
9. [Middleware Security](#middleware-security)
10. [API Endpoints](#api-endpoints)
11. [Event Broadcasting](#event-broadcasting)
12. [Error Handling](#error-handling)

---

## System Architecture Overview

The AUTOHIVE authentication system is built on Laravel 12 framework with a sophisticated multi-role user management system. The architecture implements a stateless API authentication using Laravel Sanctum with real-time notifications via WebSocket broadcasting.

### Core Components:
- **Authentication Controller**: `App\Http\Controllers\Api\AuthController`
- **User Model**: `App\Models\User` (Eloquent ORM)
- **Notification Service**: `App\Services\NotificationService`
- **Admin Approval System**: `App\Http\Controllers\Api\UserApprovalController`
- **Middleware Stack**: Role-based access control and approval verification
- **Broadcasting System**: Real-time notifications via Laravel Echo

---

## Authentication Flow

### 1. User Registration → Admin Approval → User Login

```
[User Registration] → [Pending Status] → [Admin Review] → [Approval/Rejection] → [User Login Access]
```

### 2. Technical Implementation Stack:

**Frontend Request** → **API Routes** → **Form Request Validation** → **Controller Logic** → **Database Operations** → **Notification Broadcasting** → **Response**

---

## Registration Process

### Entry Point: `POST /api/register`

#### Controller Method: `AuthController::register()`

```php
public function register(Request $request)
{
    // 1. Input Validation
    $request->validate([
        'phone' => 'required|string|unique:users',
        'password' => 'required|string|min:6|confirmed',
        'role' => 'required|in:tenant,landlord',
        'first_name' => 'required|string|max:255',
        'last_name' => 'required|string|max:255',
        'birth_date' => 'required|date',
        'profile_image' => 'required|image|max:2048',
        'id_image' => 'required|image|max:2048',
    ]);
    
    // 2. File Upload Processing
    $profileImagePath = $request->file('profile_image')->store('profiles', 'public');
    $idImagePath = $request->file('id_image')->store('ids', 'public');
    
    // 3. Re-registration Logic for Rejected Users
    $existingUser = User::withTrashed()->where('phone', $request->phone)->first();
    if ($existingUser && $existingUser->status === 'rejected') {
        $existingUser->restore();
        $existingUser->update([...]);
        $user = $existingUser;
    } else {
        // 4. New User Creation
        $user = User::create([...]);
    }
    
    // 5. Admin Notification Trigger
    $this->notifyAdminsOfNewRegistration($user);
    
    return response()->json([...], 201);
}
```

### Validation Rules Breakdown:

#### Laravel Validation Functions Used:
- **`required`**: Ensures field presence (Laravel's `Illuminate\Validation\Validator::validateRequired()`)
- **`string`**: Validates string type (`Validator::validateString()`)
- **`unique:users`**: Database uniqueness check (`Validator::validateUnique()`)
- **`min:6`**: Minimum length validation (`Validator::validateMin()`)
- **`confirmed`**: Password confirmation matching (`Validator::validateConfirmed()`)
- **`in:tenant,landlord`**: Enum validation (`Validator::validateIn()`)
- **`date`**: Date format validation (`Validator::validateDate()`)
- **`image`**: File type validation (`Validator::validateImage()`)
- **`max:2048`**: File size limit in KB (`Validator::validateMax()`)

### File Storage Implementation:

#### Laravel Storage Functions:
- **`$request->file('profile_image')`**: Retrieves uploaded file (`Illuminate\Http\UploadedFile`)
- **`->store('profiles', 'public')`**: Stores file using Laravel's Storage facade
  - Uses `Illuminate\Filesystem\FilesystemAdapter::store()`
  - Generates unique filename with `Str::random(40)`
  - Returns relative path for database storage

### Database Operations:

#### Eloquent ORM Methods:
- **`User::withTrashed()`**: Includes soft-deleted records (`Illuminate\Database\Eloquent\SoftDeletes`)
- **`->where('phone', $request->phone)`**: Query builder condition
- **`->first()`**: Retrieves single record or null
- **`User::create([])`**: Mass assignment creation (`Illuminate\Database\Eloquent\Model::create()`)
- **`Hash::make($password)`**: Bcrypt password hashing (`Illuminate\Support\Facades\Hash`)

---

## Login Process

### Entry Point: `POST /api/login`

#### Controller Method: `AuthController::login()`

```php
public function login(Request $request)
{
    // 1. Credential Validation
    $request->validate([
        'phone' => 'required|string',
        'password' => 'required|string',
    ]);
    
    // 2. User Retrieval
    $user = User::where('phone', $request->phone)->first();
    
    // 3. Password Verification
    if (!$user || !Hash::check($request->password, $user->password)) {
        throw ValidationException::withMessages([
            'phone' => ['Invalid credentials.'],
        ]);
    }
    
    // 4. Approval Status Check
    if (!$user->is_approved) {
        return response()->json([
            'success' => false,
            'message' => 'Account pending approval.',
            'errors' => ['approval' => ['Account not approved']]
        ], 403);
    }
    
    // 5. Token Generation
    $token = $user->createToken('api-token')->plainTextToken;
    
    return response()->json([
        'success' => true,
        'message' => 'Login successful',
        'data' => [
            'user' => $user,
            'token' => $token
        ]
    ]);
}
```

### Authentication Functions Breakdown:

#### Laravel Sanctum Token System:
- **`$user->createToken('api-token')`**: Creates personal access token
  - Uses `Laravel\Sanctum\HasApiTokens::createToken()`
  - Generates token via `Str::random(80)`
  - Stores hashed version in `personal_access_tokens` table
- **`->plainTextToken`**: Returns unhashed token for client storage

#### Password Verification:
- **`Hash::check($password, $hashedPassword)`**: Bcrypt verification
  - Uses `Illuminate\Hashing\BcryptHasher::check()`
  - Constant-time comparison to prevent timing attacks

---

## User Approval Workflow

### Admin Dashboard Integration

#### Pending Users Retrieval: `UserApprovalController::getPendingUsers()`

```php
public function getPendingUsers(Request $request)
{
    $pendingUsers = User::whereIn('role', ['tenant', 'landlord'])
        ->where('is_approved', false)
        ->where('status', 'pending')
        ->orderBy('created_at', 'desc')
        ->get();
        
    return response()->json([
        'success' => true,
        'data' => [
            'pending_users' => $pendingUsers,
            'count' => $pendingUsers->count()
        ]
    ]);
}
```

#### User Approval Process: `UserApprovalController::approveUser()`

```php
public function approveUser(Request $request, $userId)
{
    $user = User::find($userId);
    
    // 1. Status Update
    $user->update([
        'is_approved' => true,
        'status' => 'approved'
    ]);
    
    // 2. User Notification Creation
    $notification = Notification::create([
        'user_id' => $user->id,
        'type' => 'account_approved',
        'title' => 'Account Approved',
        'message' => 'Your account has been approved! You can now login and use the app.',
        'data' => ['approved_at' => now()->toISOString()],
        'read_at' => null
    ]);
    
    // 3. Real-time Broadcasting
    broadcast(new \App\Events\UserNotification($user->id, $notification));
    
    // 4. Activity Logging
    \App\Models\Activity::log('user_approved', "Approved user {$user->first_name} {$user->last_name} ({$user->role})", ['user_id' => $user->id]);
    
    return response()->json([...]);
}
```

#### User Rejection Process: `UserApprovalController::rejectUser()`

```php
public function rejectUser(Request $request, $userId)
{
    $user = User::find($userId);
    
    // 1. Status Update to Rejected
    $user->update([
        'status' => 'rejected',
        'is_approved' => false
    ]);
    
    // 2. Rejection Notification
    $notification = Notification::create([
        'user_id' => $user->id,
        'type' => 'account_rejected',
        'title' => 'Account Rejected',
        'message' => 'Your account registration has been rejected. You can register again with updated information.',
        'data' => ['rejected_at' => now()->toISOString()]
    ]);
    
    // 3. Broadcasting
    broadcast(new \App\Events\UserNotification($user->id, $notification));
    
    // 4. Soft Delete (Allows Re-registration)
    $user->delete();
    
    return response()->json([...]);
}
```

---

## Notification System

### Service Class: `NotificationService`

#### Admin Notification Broadcasting:

```php
public static function sendUserApprovalNotification($user)
{
    self::sendToAllAdmins(
        'user_registration',
        'New User Registration',
        "{$user->first_name} {$user->last_name} ({$user->role}) has registered and needs approval.",
        [
            'user_id' => $user->id,
            'user_name' => $user->first_name . ' ' . $user->last_name,
            'user_role' => $user->role,
            'user_phone' => $user->phone,
            'action_required' => true,
            'actions' => ['approve', 'reject']
        ]
    );
}

public static function sendToAllAdmins($type, $title, $message, $data = [])
{
    $admins = User::where('role', 'admin')->get();
    
    foreach ($admins as $admin) {
        $notification = self::send($admin->id, $type, $title, $message, $data);
        
        // Real-time Broadcasting
        broadcast(new \App\Events\AdminNotification($admin->id, $notification));
    }
}
```

### Notification Model Structure:

```php
class Notification extends Model
{
    protected $fillable = [
        'user_id',
        'type',
        'title', 
        'message',
        'data',
        'read_at',
    ];
    
    protected $casts = [
        'data' => 'array',        // JSON casting
        'read_at' => 'datetime',  // Carbon instance
    ];
}
```

---

## Database Schema

### Users Table Migration:

```php
Schema::create('users', function (Blueprint $table) {
    $table->id();                                    // Primary key (BIGINT UNSIGNED AUTO_INCREMENT)
    $table->string('phone')->unique();               // VARCHAR(255) UNIQUE
    $table->string('password');                      // VARCHAR(255) - Bcrypt hashed
    $table->enum('role', ['tenant', 'landlord', 'admin'])->default('tenant');
    $table->string('first_name');                    // VARCHAR(255)
    $table->string('last_name');                     // VARCHAR(255)
    $table->string('profile_image')->nullable();     // VARCHAR(255) NULL
    $table->date('birth_date');                      // DATE
    $table->string('id_image')->nullable();          // VARCHAR(255) NULL
    $table->boolean('is_approved')->default(false);  // TINYINT(1) DEFAULT 0
    $table->enum('status', ['pending', 'approved', 'rejected'])->default('pending');
    $table->rememberToken();                         // VARCHAR(100) NULL
    $table->timestamps();                            // created_at, updated_at TIMESTAMP
    $table->softDeletes();                           // deleted_at TIMESTAMP NULL
});
```

### Notifications Table Migration:

```php
Schema::create('notifications', function (Blueprint $table) {
    $table->id();                                    // Primary key
    $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
    $table->string('type');                          // notification type identifier
    $table->string('title');                         // notification title
    $table->text('message');                         // notification content
    $table->json('data')->nullable();                // additional metadata
    $table->timestamp('read_at')->nullable();        // read timestamp
    $table->timestamps();                            // created_at, updated_at
});
```

### Personal Access Tokens Table (Laravel Sanctum):

```php
Schema::create('personal_access_tokens', function (Blueprint $table) {
    $table->id();
    $table->morphs('tokenable');                     // tokenable_type, tokenable_id
    $table->string('name');                          // token name
    $table->string('token', 64)->unique();           // hashed token
    $table->text('abilities')->nullable();           // token permissions
    $table->timestamp('last_used_at')->nullable();   // last usage timestamp
    $table->timestamp('expires_at')->nullable();     // expiration timestamp
    $table->timestamps();
});
```

---

## Package Dependencies

### Core Authentication Packages:

#### 1. Laravel Sanctum (`laravel/sanctum: ^4.0`)

**Purpose**: API token authentication for SPAs and mobile applications

**Key Classes Used**:
- `Laravel\Sanctum\HasApiTokens` - Trait for User model
- `Laravel\Sanctum\PersonalAccessToken` - Token model
- `Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful`

**Functions Utilized**:
- `createToken($name, $abilities = ['*'])` - Generates API tokens
- `tokens()` - Relationship to user's tokens
- `currentAccessToken()` - Current request token
- `tokenCan($ability)` - Permission checking

**Configuration**: `config/sanctum.php`
```php
'expiration' => null,                    // No token expiration
'stateful' => ['localhost', '127.0.0.1'], // Stateful domains
'guard' => ['web'],                      // Authentication guards
```

#### 2. Tymon JWT Auth (`tymon/jwt-auth: ^2.2`)

**Purpose**: JSON Web Token authentication (Alternative/backup to Sanctum)

**Key Classes**:
- `Tymon\JWTAuth\Facades\JWTAuth`
- `Tymon\JWTAuth\Contracts\JWTSubject`

**Functions**:
- `JWTAuth::attempt($credentials)` - Login with JWT
- `JWTAuth::fromUser($user)` - Generate token for user
- `JWTAuth::parseToken()->authenticate()` - Validate token

#### 3. Spatie Laravel Permission (`spatie/laravel-permission: ^6.23`)

**Purpose**: Role and permission management system

**Key Classes**:
- `Spatie\Permission\Models\Role`
- `Spatie\Permission\Models\Permission`
- `Spatie\Permission\Traits\HasRoles`

**Functions**:
- `assignRole($role)` - Assign role to user
- `hasRole($role)` - Check user role
- `can($permission)` - Permission checking
- `givePermissionTo($permission)` - Grant permission

### Laravel Framework Core (`laravel/framework: ^12.0`)

#### Authentication Components:

**Hash Facade** (`Illuminate\Support\Facades\Hash`):
- `Hash::make($password)` - Bcrypt password hashing
- `Hash::check($password, $hash)` - Password verification
- `Hash::needsRehash($hash)` - Check if rehashing needed

**Validation System** (`Illuminate\Validation\Validator`):
- `validate($rules, $messages = [])` - Input validation
- `ValidationException::withMessages()` - Validation error responses
- Custom validation rules and messages

**Eloquent ORM** (`Illuminate\Database\Eloquent\Model`):
- `create($attributes)` - Mass assignment creation
- `update($attributes)` - Model updating
- `delete()` - Soft deletion
- `restore()` - Restore soft-deleted models
- `withTrashed()` - Include soft-deleted records

**Broadcasting System** (`Illuminate\Broadcasting\BroadcastManager`):
- `broadcast($event)` - Event broadcasting
- `PrivateChannel` - Private channel creation
- `ShouldBroadcast` - Interface for broadcastable events

---

## Middleware Security

### 1. Authentication Middleware (`auth:sanctum`)

**Class**: `Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful`

**Function**: Validates API tokens and establishes user context

**Implementation**:
```php
public function handle($request, Closure $next, ...$guards)
{
    $this->authenticate($request, $guards);
    return $next($request);
}
```

### 2. User Approval Middleware (`approved`)

**Class**: `App\Http\Middleware\EnsureUserIsApproved`

**Purpose**: Blocks unapproved users from accessing protected routes

```php
public function handle(Request $request, Closure $next)
{
    if ($request->user() && !$request->user()->is_approved) {
        return response()->json([
            'message' => 'Account pending approval.'
        ], 403);
    }
    return $next($request);
}
```

### 3. Role-Based Middleware

**Admin Middleware** (`App\Http\Middleware\AdminMiddleware`):
```php
public function handle(Request $request, Closure $next)
{
    if (!$request->user() || $request->user()->role !== 'admin') {
        return response()->json(['message' => 'Unauthorized'], 403);
    }
    return $next($request);
}
```

**Landlord Middleware** (`App\Http\Middleware\LandlordMiddleware`):
```php
public function handle(Request $request, Closure $next)
{
    if (!$request->user() || $request->user()->role !== 'landlord') {
        return response()->json(['message' => 'Landlord access required'], 403);
    }
    return $next($request);
}
```

**Tenant Middleware** (`App\Http\Middleware\TenantOnlyMiddleware`):
```php
public function handle(Request $request, Closure $next)
{
    if (!$request->user() || $request->user()->role !== 'tenant') {
        return response()->json(['message' => 'Tenant access required'], 403);
    }
    return $next($request);
}
```

---

## API Endpoints

### Public Authentication Routes:

```php
// Registration
POST /api/register
Content-Type: multipart/form-data
Body: {
    phone: string (10-15 digits),
    password: string (min 6 chars),
    password_confirmation: string,
    role: enum(tenant|landlord),
    first_name: string (max 255),
    last_name: string (max 255),
    birth_date: date (YYYY-MM-DD),
    profile_image: file (image, max 2MB),
    id_image: file (image, max 2MB)
}

// Login
POST /api/login
Content-Type: application/json
Body: {
    phone: string,
    password: string
}
```

### Protected User Routes:

```php
// All require: Authorization: Bearer {token}

// Profile Management
GET /api/profile
PUT /api/profile
POST /api/change-password
DELETE /api/delete-account
POST /api/logout

// File Management
POST /api/upload-id
POST /api/files/profile-image
```

### Admin Routes:

```php
// User Management
GET /api/admin/pending-users
GET /api/admin/user-details/{id}
POST /api/admin/approve-user/{id}
POST /api/admin/reject-user/{id}

// Notifications
GET /api/admin/notifications
POST /api/admin/notifications/{id}/read
POST /api/admin/notifications/read-all
```

---

## Event Broadcasting

### Real-Time Notification System

#### Admin Notification Event:

```php
class AdminNotification implements ShouldBroadcast
{
    public $adminId;
    public $notification;
    
    public function broadcastOn()
    {
        return new PrivateChannel('admin.' . $this->adminId);
    }
    
    public function broadcastAs()
    {
        return 'notification';
    }
    
    public function broadcastWith()
    {
        return [
            'id' => $this->notification->id,
            'type' => $this->notification->type,
            'title' => $this->notification->title,
            'message' => $this->notification->message,
            'data' => $this->notification->data,
            'created_at' => $this->notification->created_at->toISOString(),
        ];
    }
}
```

#### User Notification Event:

```php
class UserNotification implements ShouldBroadcast
{
    public $userId;
    public $notification;
    
    public function broadcastOn()
    {
        return new PrivateChannel('user.' . $this->userId);
    }
}
```

### Broadcasting Configuration:

**Channels Definition** (`routes/channels.php`):
```php
Broadcast::channel('admin.{adminId}', function ($user, $adminId) {
    return $user->role === 'admin' && $user->id == $adminId;
});

Broadcast::channel('user.{userId}', function ($user, $userId) {
    return $user->id == $userId;
});
```

---

## Error Handling

### Validation Error Responses:

```php
// Registration validation failure
{
    "message": "The given data was invalid.",
    "errors": {
        "phone": ["The phone field is required."],
        "password": ["The password must be at least 6 characters."]
    }
}
```

### Authentication Error Responses:

```php
// Invalid credentials
{
    "success": false,
    "message": "Invalid credentials.",
    "errors": {
        "phone": ["Invalid credentials."]
    }
}

// Account pending approval
{
    "success": false,
    "message": "Account pending approval.",
    "errors": {
        "approval": ["Account not approved"]
    }
}
```

### Authorization Error Responses:

```php
// Unapproved user access
{
    "message": "Account pending approval."
}

// Role-based access denial
{
    "message": "Unauthorized"
}
```

---

## Security Considerations

### 1. Password Security:
- **Bcrypt Hashing**: All passwords hashed using `Hash::make()`
- **Minimum Length**: 6 characters enforced
- **Confirmation Required**: Password confirmation during registration

### 2. Token Security:
- **Sanctum Tokens**: Cryptographically secure random tokens
- **Token Scoping**: Ability-based token permissions
- **Token Revocation**: Logout invalidates current token

### 3. File Upload Security:
- **Type Validation**: Only image files accepted
- **Size Limits**: 2MB maximum file size
- **Storage Isolation**: Files stored in public disk with controlled access

### 4. Database Security:
- **Mass Assignment Protection**: Fillable attributes defined
- **Soft Deletes**: User data preserved for audit trails
- **Foreign Key Constraints**: Referential integrity maintained

### 5. API Security:
- **Rate Limiting**: Throttling on authentication endpoints
- **CORS Configuration**: Cross-origin request controls
- **Input Sanitization**: Laravel's built-in XSS protection

---

This documentation provides a comprehensive technical overview of the AUTOHIVE authentication system, covering every aspect from user registration to admin approval workflows, with detailed explanations of all functions, packages, and security measures implemented in the backend API.