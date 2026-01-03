# AUTOHIVE Wallet System - Complete Documentation

## Overview
The AUTOHIVE wallet system is fully implemented with automatic wallet creation, initial balance, payment processing, and deposit/withdrawal request management.

## Features Implemented

### 1. Automatic Wallet Creation ✅
**Location**: `server/app/Http/Controllers/Api/AuthController.php` (Line 107)

When a user registers:
- A wallet is automatically created via `WalletService::createWalletForUser()`
- Initial balance: **$100 USD** (11,000 SPY)
- Exchange rate: 1 USD = 110 SPY

**Code**:
```php
// In AuthController::register()
$walletService = app(WalletService::class);
$walletService->createWalletForUser($user);
```

### 2. Automatic Payment Processing ✅
**Location**: `server/app/Http/Controllers/Api/RentalApplicationController.php` (Line 265-295)

When a landlord approves a rental application:
1. System checks if tenant has sufficient funds
2. If insufficient, approval is rejected with error message
3. If sufficient, payment is automatically processed:
   - Amount is deducted from tenant's wallet
   - Same amount is added to landlord's wallet
   - Transaction records are created for both parties
   - Booking is confirmed

**Code**:
```php
// In RentalApplicationController::approve()
$walletService = app(WalletService::class);
$rentalAmountUsd = floatval($totalPrice);
$rentalAmountSpy = intval($rentalAmountUsd * 110);

// Validate balance
if (!$walletService->validateSufficientBalance($tenantId, $rentalAmountSpy)) {
    // Return error
}

// Process payment
$walletService->deductAndTransfer($tenantId, $landlordId, $rentalAmountSpy, $booking->id);
```

### 3. Deposit Request System ✅
**Location**: `server/app/Http/Controllers/Api/DepositWithdrawalController.php`

Users can request to deposit money:
- Submit deposit request with amount in USD
- Request goes to admin for approval
- Admin can approve or reject with reason
- On approval, funds are added to user's wallet
- Transaction record is created

**API Endpoints**:
- `POST /api/wallet/deposit-request` - Submit deposit request
- `GET /api/wallet/my-requests` - View own requests
- `GET /api/admin/deposit-requests` - Admin view all requests
- `POST /api/admin/deposit-requests/{id}/approve` - Admin approve
- `POST /api/admin/deposit-requests/{id}/reject` - Admin reject

### 4. Withdrawal Request System ✅
**Location**: `server/app/Http/Controllers/Api/DepositWithdrawalController.php`

Users can request to withdraw money:
- Submit withdrawal request with amount in USD
- System validates sufficient balance
- Request goes to admin for approval
- Admin can approve or reject with reason
- On approval, funds are deducted from user's wallet
- Transaction record is created

**API Endpoints**:
- `POST /api/wallet/withdrawal-request` - Submit withdrawal request
- Same admin endpoints as deposit requests

## Database Schema

### Wallets Table
```sql
- id (primary key)
- user_id (foreign key to users)
- balance_spy (integer) - Balance in SPY currency
- currency (string) - Always 'SPY'
- created_at
- updated_at
```

### Wallet Transactions Table
```sql
- id (primary key)
- wallet_id (foreign key to wallets)
- user_id (foreign key to users)
- type (enum: deposit, withdrawal, rental_payment, rental_received)
- amount_spy (integer)
- description (text)
- related_user_id (nullable) - For transfers
- related_booking_id (nullable) - For rental payments
- created_at
```

### Deposit/Withdrawal Requests Table
```sql
- id (primary key)
- user_id (foreign key to users)
- type (enum: deposit, withdrawal)
- amount_spy (integer)
- status (enum: pending, approved, rejected)
- reason (text) - Rejection reason
- approved_by (foreign key to users) - Admin who approved/rejected
- approved_at (timestamp)
- created_at
- updated_at
```

## Wallet Service Methods

### Core Methods
```php
// Create wallet with initial $100
createWalletForUser(User $user)

// Convert currencies
convertUsdToSpy($usd) // Returns SPY amount
convertSpyToUsd($spy) // Returns USD amount

// Balance validation
validateSufficientBalance($userId, $amountSpy) // Returns boolean

// Add funds
addFunds($userId, $amountSpy, $transactionType, $description)

// Deduct funds
deductFunds($userId, $amountSpy, $transactionType, $description)

// Atomic transfer (tenant to landlord)
deductAndTransfer($tenantId, $landlordId, $amountSpy, $bookingId)
```

## Frontend Integration

### Mobile App (Flutter)

**Wallet Provider**: `client/lib/presentation/providers/wallet_provider.dart`
- Uses Riverpod for state management
- Manages wallet state, transactions, and requests

**Wallet Screens**:
1. `wallet_screen.dart` - Main wallet view
2. `deposit_request_screen.dart` - Submit deposit requests
3. `withdrawal_request_screen.dart` - Submit withdrawal requests
4. `transaction_history_screen.dart` - View transaction history

**Wallet Widget**: `wallet_balance_widget.dart`
- Displays wallet balance in compact or full mode
- Shows both USD and SPY amounts
- Clickable to navigate to full wallet screen

### Admin Dashboard (Web)

**Note**: Wallet management is currently only available via API. To add to web dashboard:

1. Create routes in `routes/web.php`:
```php
Route::get('/admin/wallet-requests', [WalletController::class, 'index']);
Route::post('/admin/wallet-requests/{id}/approve', [WalletController::class, 'approve']);
Route::post('/admin/wallet-requests/{id}/reject', [WalletController::class, 'reject']);
```

2. Create controller: `app/Http/Controllers/Admin/WalletController.php`

3. Create views in `resources/views/admin/wallet/`:
   - `index.blade.php` - List all requests
   - `show.blade.php` - View request details

## Transaction Types

1. **deposit** - User deposits money (admin approved)
2. **withdrawal** - User withdraws money (admin approved)
3. **rental_payment** - Tenant pays for rental (automatic)
4. **rental_received** - Landlord receives rental payment (automatic)

## Payment Flow

### Rental Application Approval Flow:
```
1. Tenant submits rental application
2. Landlord reviews application
3. Landlord clicks "Approve"
4. System checks tenant's wallet balance
   - If insufficient: Show error, don't approve
   - If sufficient: Continue
5. System creates booking
6. System processes payment:
   - Deduct from tenant wallet
   - Add to landlord wallet
   - Create transaction records
7. Mark apartment as unavailable
8. Update tenant rental status
9. Send notification to tenant
10. Return success response
```

### Deposit Request Flow:
```
1. User submits deposit request with amount
2. Request saved with status "pending"
3. Admin views pending requests
4. Admin approves or rejects:
   - Approve: Add funds to wallet, create transaction
   - Reject: Update status with reason
5. User sees updated request status
```

### Withdrawal Request Flow:
```
1. User submits withdrawal request with amount
2. System validates sufficient balance
3. Request saved with status "pending"
4. Admin views pending requests
5. Admin approves or rejects:
   - Approve: Deduct funds from wallet, create transaction
   - Reject: Update status with reason
6. User sees updated request status
```

## Security Features

1. **Transaction Atomicity**: All wallet operations use database transactions
2. **Balance Validation**: Always check balance before deductions
3. **Lock For Update**: Prevents race conditions in concurrent transactions
4. **Admin Authorization**: Only admins can approve/reject requests
5. **Ownership Validation**: Users can only view their own wallet data

## Testing

### Test Scenarios:

1. **User Registration**:
   - Register new user
   - Verify wallet created with $100

2. **Rental Payment**:
   - Create rental application
   - Approve as landlord
   - Verify tenant balance decreased
   - Verify landlord balance increased
   - Verify transaction records created

3. **Insufficient Funds**:
   - Create rental application with amount > tenant balance
   - Try to approve
   - Verify error returned
   - Verify no payment processed

4. **Deposit Request**:
   - Submit deposit request
   - Approve as admin
   - Verify balance increased
   - Verify transaction created

5. **Withdrawal Request**:
   - Submit withdrawal request
   - Approve as admin
   - Verify balance decreased
   - Verify transaction created

## API Endpoints Summary

### User Endpoints:
```
GET    /api/wallet                      - Get wallet info
GET    /api/wallet/transactions         - Get transaction history
POST   /api/wallet/deposit-request      - Submit deposit request
POST   /api/wallet/withdrawal-request   - Submit withdrawal request
GET    /api/wallet/my-requests          - Get own requests
```

### Admin Endpoints:
```
GET    /api/admin/deposit-requests                  - Get all requests
POST   /api/admin/deposit-requests/{id}/approve     - Approve request
POST   /api/admin/deposit-requests/{id}/reject      - Reject request
```

## Constants

```php
EXCHANGE_RATE = 110              // 1 USD = 110 SPY
INITIAL_BALANCE_USD = 100        // Initial wallet balance
INITIAL_BALANCE_SPY = 11000      // 100 * 110
```

## Error Handling

Common error responses:
- `404` - Wallet not found
- `422` - Insufficient balance / Validation error
- `403` - Unauthorized (not admin)
- `500` - Server error

## Future Enhancements

1. Add wallet management to web admin dashboard
2. Add transaction filtering and search
3. Add wallet balance history chart
4. Add email notifications for wallet events
5. Add support for multiple currencies
6. Add wallet top-up via payment gateway
7. Add refund functionality
8. Add wallet freeze/unfreeze for admin

## Conclusion

The wallet system is **fully functional** with:
- ✅ Automatic wallet creation with $100 initial balance
- ✅ Automatic payment processing on rental approval
- ✅ Deposit request system with admin approval
- ✅ Withdrawal request system with admin approval
- ✅ Complete transaction history
- ✅ Mobile app integration
- ✅ Secure and atomic operations

All features are working end-to-end from backend to frontend.
