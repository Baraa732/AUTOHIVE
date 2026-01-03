# Technical Specification: User Wallet System

## Technical Context

- **Backend**: Laravel 11 (PHP)
- **Frontend**: Flutter (Dart)
- **Database**: SQLite (development) / can use PostgreSQL (production)
- **API**: RESTful API with Laravel Sanctum authentication
- **Key Dependencies**: Eloquent ORM, Laravel migrations, HTTP client (dart http package)

---

## Technical Implementation Brief

### Architecture Overview
1. **Database Layer**: Create `wallets`, `wallet_transactions`, and `deposit_withdrawal_requests` tables
2. **Model Layer**: Create Wallet, WalletTransaction, and DepositWithdrawalRequest models with relationships
3. **API Layer**: Create dedicated controllers for wallet and deposit/withdrawal request management
4. **Service Layer**: Create WalletService to handle wallet operations and business logic
5. **Frontend Layer**: Create Flutter screens for wallet display, transaction history, and requests
6. **Integration Points**:
   - Auto-create wallet in AuthController during registration
   - Check wallet balance during lease finalization
   - Deduct from tenant, add to landlord during lease completion

### Key Technical Decisions
- **Currency Storage**: Store all amounts in SPY (Syrian Pound) internally for precision (avoid float arithmetic issues)
- **Transactions**: Use database transactions for atomic operations (wallet deduction + landlord addition)
- **Exchange Rate**: Hard-coded as 1 USD = 110 SPY (can be moved to settings table later)
- **Request Workflow**: Deposit/Withdrawal requests stored with status (pending/approved/rejected)
- **User Constraints**: Each user has exactly one wallet (one-to-one relationship)
- **Audit Trail**: All transactions logged in wallet_transactions table for compliance

---

## Source Code Structure

### Backend Structure
```
server/
├── app/
│   ├── Models/
│   │   ├── Wallet.php (new)
│   │   ├── WalletTransaction.php (new)
│   │   ├── DepositWithdrawalRequest.php (new)
│   │   └── User.php (modified)
│   ├── Http/
│   │   ├── Controllers/
│   │   │   ├── Api/
│   │   │   │   ├── AuthController.php (modified)
│   │   │   │   ├── WalletController.php (new)
│   │   │   │   └── DepositWithdrawalController.php (new)
│   ├── Services/
│   │   └── WalletService.php (new)
│   └── Events/
│       └── WalletTransactionCreated.php (new - optional for logging)
├── database/
│   └── migrations/
│       ├── [timestamp]_create_wallets_table.php (new)
│       ├── [timestamp]_create_wallet_transactions_table.php (new)
│       ├── [timestamp]_create_deposit_withdrawal_requests_table.php (new)
│       └── [timestamp]_add_rental_amount_to_bookings_table.php (modified)
└── routes/
    └── api.php (modified)
```

### Frontend Structure
```
client/lib/
├── data/
│   └── models/
│       ├── wallet.dart (new)
│       ├── wallet_transaction.dart (new)
│       └── deposit_withdrawal_request.dart (new)
├── presentation/
│   ├── screens/
│   │   ├── wallet/
│   │   │   ├── wallet_screen.dart (new)
│   │   │   ├── transaction_history_screen.dart (new)
│   │   │   └── deposit_request_screen.dart (new)
│   │   └── admin/
│   │       └── manage_deposits_screen.dart (new)
│   └── widgets/
│       ├── wallet_balance_card.dart (new)
│       └── transaction_item.dart (new)
├── core/
│   └── network/
│       └── api_service.dart (modified)
└── providers/
    └── wallet_provider.dart (new)
```

---

## Contracts

### Database Schema

#### wallets table
```sql
CREATE TABLE wallets (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL UNIQUE,
    balance_spy BIGINT NOT NULL DEFAULT 11000,  -- 100 USD * 110 = 11000 SPY
    currency VARCHAR(3) DEFAULT 'SPY',
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

#### wallet_transactions table
```sql
CREATE TABLE wallet_transactions (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    wallet_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    type ENUM('deposit', 'withdrawal', 'rental_payment', 'rental_received'),
    amount_spy BIGINT NOT NULL,
    description VARCHAR(255),
    related_user_id BIGINT UNSIGNED,  -- For peer-to-peer transactions
    related_booking_id BIGINT UNSIGNED,  -- For rental payments
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (wallet_id) REFERENCES wallets(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (related_user_id) REFERENCES users(id),
    FOREIGN KEY (related_booking_id) REFERENCES bookings(id)
);
```

#### deposit_withdrawal_requests table
```sql
CREATE TABLE deposit_withdrawal_requests (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL,
    type ENUM('deposit', 'withdrawal') NOT NULL,
    amount_spy BIGINT NOT NULL,
    status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    reason VARCHAR(255),  -- For rejections
    approved_by BIGINT UNSIGNED,  -- Admin who approved
    approved_at TIMESTAMP NULL,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (approved_by) REFERENCES users(id)
);
```

### API Endpoints

#### Wallet Management
- **GET** `/api/wallet` - Get current user's wallet info (balance, currency)
- **GET** `/api/wallet/transactions` - Get transaction history with pagination
- **POST** `/api/wallet/deposit-request` - Submit deposit request (amount in USD)
- **POST** `/api/wallet/withdrawal-request` - Submit withdrawal request (amount in USD)

#### Admin Deposit/Withdrawal Management
- **GET** `/api/admin/deposit-requests` - List all pending deposit/withdrawal requests
- **POST** `/api/admin/deposit-requests/{id}/approve` - Approve request
- **POST** `/api/admin/deposit-requests/{id}/reject` - Reject request with reason

#### Internal (Backend to Backend)
- **POST** `/api/wallet/deduct` - Deduct amount from wallet (with booking ID)
- **POST** `/api/wallet/add` - Add amount to wallet (with transaction type)

### Model Relationships

#### User Model (modified)
```php
public function wallet()
{
    return $this->hasOne(Wallet::class);
}

public function walletTransactions()
{
    return $this->hasMany(WalletTransaction::class);
}

public function depositWithdrawalRequests()
{
    return $this->hasMany(DepositWithdrawalRequest::class);
}
```

#### Wallet Model (new)
```php
public function user()
{
    return $this->belongsTo(User::class);
}

public function transactions()
{
    return $this->hasMany(WalletTransaction::class);
}
```

### Frontend Model Contracts

#### Wallet (Dart)
```dart
class Wallet {
    final int id;
    final int userId;
    final BigInt balanceSpy;
    final String currency;
    final DateTime createdAt;
    final DateTime updatedAt;
    
    double get balanceUsd => balanceSpy / 110;
}
```

#### WalletTransaction (Dart)
```dart
enum TransactionType { deposit, withdrawal, rentalPayment, rentalReceived }

class WalletTransaction {
    final int id;
    final int walletId;
    final int userId;
    final TransactionType type;
    final BigInt amountSpy;
    final String description;
    final int? relatedUserId;
    final int? relatedBookingId;
    final DateTime createdAt;
}
```

#### DepositWithdrawalRequest (Dart)
```dart
enum RequestType { deposit, withdrawal }
enum RequestStatus { pending, approved, rejected }

class DepositWithdrawalRequest {
    final int id;
    final int userId;
    final RequestType type;
    final BigInt amountSpy;
    final RequestStatus status;
    final String? reason;
    final int? approvedBy;
    final DateTime? approvedAt;
    final DateTime createdAt;
}
```

---

## Delivery Phases

### Phase 1: Database & Backend Models
**Goal**: Create database schema and core models
**Tasks**:
1. Create wallet migration and model
2. Create wallet_transactions migration and model
3. Create deposit_withdrawal_requests migration and model
4. Add relationships to User model
5. Create WalletService with core logic
**Deliverable**: Database schema in place, models with relationships working
**Verification**: Run migrations, verify tables exist with correct structure

### Phase 2: Auto-Wallet Creation & Core Endpoints
**Goal**: Auto-create wallet on user registration, create basic wallet endpoints
**Tasks**:
1. Modify AuthController to create wallet during registration
2. Create WalletController with GET wallet endpoint
3. Create WalletController with transaction history endpoint
4. Add wallet balance to login response
**Deliverable**: New users get $100 wallet, users can view their balance
**Verification**: Register new user, verify wallet created, check balance via API

### Phase 3: Lease Payment Integration
**Goal**: Deduct funds from tenant, add to landlord on lease finalization
**Tasks**:
1. Identify lease finalization endpoint in backend
2. Add wallet balance validation before finalization
3. Implement atomic wallet transaction (deduct + add)
4. Create WalletTransaction records
5. Return error if insufficient funds
**Deliverable**: Lease finalization checks wallet, deducts/adds correctly
**Verification**: Create booking, finalize it, verify both wallets updated

### Phase 4: Deposit/Withdrawal Request System
**Goal**: Users request deposits/withdrawals, admins approve/reject
**Tasks**:
1. Create DepositWithdrawalController
2. Implement POST endpoints for requesting deposits/withdrawals
3. Implement admin approval/rejection endpoints
4. Create service logic to apply approved requests to wallets
5. Add validation for withdrawal (check balance)
**Deliverable**: Users can request, admins can approve/reject
**Verification**: Submit requests, approve/reject, verify wallet updated

### Phase 5: Frontend Wallet UI
**Goal**: Create Flutter screens for wallet management
**Tasks**:
1. Create Wallet data model in Flutter
2. Create WalletProvider for state management
3. Create WalletScreen to display balance
4. Create TransactionHistoryScreen
5. Create DepositWithdrawalRequestScreen
6. Add wallet integration to API service
7. Create admin deposit management screen
**Deliverable**: Users can view wallet, transaction history, submit requests
**Verification**: Login, navigate to wallet, view balance and transactions

### Phase 6: Testing & Integration
**Goal**: End-to-end testing and bug fixes
**Tasks**:
1. Test wallet creation for all new users
2. Test lease payment workflow
3. Test deposit/withdrawal requests
4. Test edge cases (insufficient funds, concurrent requests)
5. Test currency display (USD/SPY)
**Deliverable**: Full feature working end-to-end
**Verification**: Complete E2E test scenarios

---

## Verification Strategy

### Testing Approach

#### Unit Tests (Backend)
- Test WalletService methods (calculate amounts, validate balance)
- Test model relationships
- Test API request validation

#### Integration Tests (Backend)
- Test wallet creation during registration
- Test lease finalization with wallet deduction
- Test deposit/withdrawal request workflow
- Test admin approval/rejection

#### API Tests
- Verify all endpoints return correct response format
- Test authentication/authorization
- Test error cases (insufficient funds, invalid amounts)

#### E2E Tests (Frontend)
- User registration → wallet creation → view balance
- Submit rental → lease finalization → funds deducted
- Submit deposit request → admin approves → balance updated

### Verification Commands

#### Backend Verification
```bash
# Run migrations
php artisan migrate

# Check database
sqlite3 database/database.sqlite ".schema wallets"
sqlite3 database/database.sqlite ".schema wallet_transactions"
sqlite3 database/database.sqlite ".schema deposit_withdrawal_requests"

# Run tests
php artisan test

# Check API with sample requests
curl -X GET http://localhost:8000/api/wallet \
  -H "Authorization: Bearer {token}" \
  -H "Accept: application/json"
```

#### Frontend Verification
```bash
# Run Flutter tests
flutter test

# Check API integration
# (Verify by running the app and checking wallet screen)
```

### Helper Scripts
Create `server/scripts/test-wallet-flow.php` to:
1. Create test users (tenant + landlord)
2. Verify wallet creation
3. Create a booking
4. Finalize booking
5. Verify wallet transactions

### Sample Data
- Test Tenant: Phone: 09111111111, Initial Balance: 11000 SPY
- Test Landlord: Phone: 09122222222, Initial Balance: 11000 SPY
- Test Apartment Rent: 50000 SPY (approx $454 USD)

---

## Implementation Notes

### Currency Conversion
- Exchange Rate: 1 USD = 110 SPY (constant)
- All internal storage: SPY
- Frontend display: Show both USD and SPY
- API Input: Accept USD, convert to SPY internally
- API Output: Return SPY, frontend displays both

### Security Considerations
- Wallet balance cannot be negative (reject requests exceeding balance)
- Lease payment is atomic (both succeed or both fail)
- Admin actions logged with admin ID and timestamp
- All transactions immutable (no deletion, only adjustment via new transactions)
- Withdrawal requests require admin approval (prevent fraud)

### Performance Considerations
- Index on user_id in wallets table
- Index on user_id and status in deposit_withdrawal_requests
- Paginate transaction history (50 items per page)
- Cache wallet balance in response headers if needed
