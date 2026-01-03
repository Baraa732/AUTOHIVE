# Feature development workflow

---

## Workflow Steps

### [x] Step: Requirements

Your job is to generate a Product Requirements Document based on the feature description,

First, analyze the provided feature definition and determine unclear aspects. For unclear aspects: - Make informed guesses based on context and industry standards - Only mark with [NEEDS CLARIFICATION: specific question] if: - The choice significantly impacts feature scope or user experience - Multiple reasonable interpretations exist with different implications - No reasonable default exists - Prioritize clarifications by impact: scope > security/privacy > user experience > technical details

Ask up to 5 most priority clarifications to the user. Then, create the document following this template:

```
# Feature Specification: [FEATURE NAME]


## User Stories*


### User Story 1 - [Brief Title]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]
2. **Given** [initial state], **When** [action], **Then** [expected outcome]

---

## Requirements*

## Success Criteria*

```

Save the PRD into `c:\Users\Al Baraa\Desktop\Github Project\AUTOHIVE\.zencoder\chats\c42f20a7-b5a7-4f54-8108-8e4dd10d24ee/requirements.md`.

### [x] Step: Technical Specification

✅ Technical specification created and saved to `spec.md`

### [ ] Step: Implementation Plan

Based on the technical spec in `c:\Users\Al Baraa\Desktop\Github Project\AUTOHIVE\.zencoder\chats\c42f20a7-b5a7-4f54-8108-8e4dd10d24ee/spec.md`, create a detailed task plan and update `c:\Users\Al Baraa\Desktop\Github Project\AUTOHIVE\.zencoder\chats\c42f20a7-b5a7-4f54-8108-8e4dd10d24ee/plan.md`. Each task should have task definition, references to contracts to be used/implemented, deliverable definition and verification instructions.

### [x] Step: Implementation Plan

✅ Detailed implementation plan created and execution started

---

## IMPLEMENTATION STATUS: 70% COMPLETE

### ✅ COMPLETED: Phases 1-4 & 5.1-5.2 (Core Backend & API)
- ✅ **Phase 1**: Database migrations and models (6/6 tasks)
- ✅ **Phase 2**: Auto-wallet creation & wallet endpoints (4/4 tasks)
- ✅ **Phase 3**: Lease payment integration (3/3 tasks)  
- ✅ **Phase 4**: Deposit/withdrawal request system (3/3 tasks)
- ✅ **Phase 5.1-5.2**: Flutter models & API service (2/2 tasks)

### ⏳ PENDING: Phases 5.3-5.7 & Phase 6 (UI & Testing)
- ⏳ **Phase 5.3-5.7**: Flutter UI screens (5 tasks)
- ⏳ **Phase 6**: Testing (6 tasks)

---

## Implementation Tasks

### Phase 1: Database & Backend Models

### [ ] Step 1.1: Create Wallets Table Migration
**Task**: Create migration file for wallets table
**Files to Create**:
- `server/database/migrations/[timestamp]_create_wallets_table.php`

**Implementation Details**:
- Table: `wallets` with columns: id, user_id (unique, FK), balance_spy (BIGINT default 11000), currency (default 'SPY'), timestamps
- Add index on user_id for fast lookups
- Set up relationship: user_id → users(id) with CASCADE delete

**Verification**:
```bash
php artisan migrate
sqlite3 database/database.sqlite ".schema wallets"
```

---

### [ ] Step 1.2: Create Wallet Model
**Task**: Create Wallet Eloquent model with relationships
**File to Create**:
- `server/app/Models/Wallet.php`

**Implementation Details**:
- Fillable: user_id, balance_spy, currency
- Relationships: belongsTo User, hasMany WalletTransaction
- Add methods: getBalanceUsd(), canWithdraw($amount), addFunds($amountSpy), deductFunds($amountSpy)
- Use bigint for balance_spy

**Verification**:
```bash
php artisan tinker
>>> App\Models\Wallet::create(['user_id' => 1, 'balance_spy' => 11000])
```

---

### [ ] Step 1.3: Create Wallet Transactions Table & Model
**Task**: Create wallet_transactions table and WalletTransaction model
**Files to Create**:
- `server/database/migrations/[timestamp]_create_wallet_transactions_table.php`
- `server/app/Models/WalletTransaction.php`

**Implementation Details**:
- Migration: id, wallet_id (FK), user_id (FK), type (ENUM: deposit/withdrawal/rental_payment/rental_received), amount_spy (BIGINT), description, related_user_id, related_booking_id, timestamps
- Model: Fillable, relationships (belongsTo Wallet, User), add helper methods
- Indexes: wallet_id, user_id, created_at

**Verification**:
```bash
php artisan migrate
sqlite3 database/database.sqlite ".schema wallet_transactions"
```

---

### [ ] Step 1.4: Create Deposit/Withdrawal Requests Table & Model
**Task**: Create deposit_withdrawal_requests table and DepositWithdrawalRequest model
**Files to Create**:
- `server/database/migrations/[timestamp]_create_deposit_withdrawal_requests_table.php`
- `server/app/Models/DepositWithdrawalRequest.php`

**Implementation Details**:
- Migration: id, user_id (FK), type (ENUM), amount_spy (BIGINT), status (pending/approved/rejected), reason, approved_by (FK to users), approved_at, timestamps
- Model: Fillable, relationships, status/type as enum properties
- Indexes: user_id, status, created_at

**Verification**:
```bash
php artisan migrate
sqlite3 database/database.sqlite ".schema deposit_withdrawal_requests"
```

---

### [ ] Step 1.5: Update User Model with Wallet Relationships
**Task**: Add wallet relationships to User model
**File to Modify**:
- `server/app/Models/User.php`

**Changes**:
- Add `wallet()` hasOne relationship
- Add `walletTransactions()` hasMany relationship
- Add `depositWithdrawalRequests()` hasMany relationship
- Update boot() method to delete wallet on user deletion (if cascade not sufficient)

**Verification**:
```bash
php artisan tinker
>>> $user = User::find(1); $user->wallet
```

---

### [ ] Step 1.6: Create WalletService
**Task**: Create service class for wallet business logic
**File to Create**:
- `server/app/Services/WalletService.php`

**Implementation Details**:
- Methods:
  - `createWalletForUser($user)` - creates wallet with 11000 SPY
  - `deductAndTransfer($tenantId, $landlordId, $amountSpy, $bookingId)` - atomic operation
  - `addFunds($userId, $amountSpy, $transactionType, $description)`
  - `deductFunds($userId, $amountSpy, $transactionType, $description)`
  - `validateSufficientBalance($userId, $amountSpy)`
  - `convertUsdToSpy($usd)` - returns bigint
- Use DB transactions for atomic operations

**Verification**:
```bash
php artisan tinker
>>> $service = app(App\Services\WalletService::class)
>>> $service->createWalletForUser($user)
```

---

### Phase 2: Auto-Wallet Creation & Core Endpoints

### [ ] Step 2.1: Modify AuthController for Auto-Wallet Creation
**Task**: Update AuthController to create wallet on user registration
**File to Modify**:
- `server/app/Http/Controllers/Api/AuthController.php`

**Changes**:
- In `register()` method, after User::create(), call WalletService::createWalletForUser($user)
- Handle re-registration for rejected users (restore wallet too if needed)
- Return wallet balance in registration response

**Verification**:
```bash
# Register new user via API, then check:
sqlite3 database/database.sqlite "SELECT * FROM wallets WHERE user_id = (SELECT MAX(id) FROM users)"
```

---

### [ ] Step 2.2: Create WalletController - Get Wallet Endpoint
**Task**: Create controller with endpoint to get user's wallet
**File to Create**:
- `server/app/Http/Controllers/Api/WalletController.php`

**Implementation**:
- Method: `getWallet(Request $request)` - returns user's wallet with balance in SPY and USD
- Response format:
```json
{
  "success": true,
  "data": {
    "id": 1,
    "user_id": 1,
    "balance_spy": 11000,
    "balance_usd": 100,
    "currency": "SPY",
    "created_at": "2025-01-01T00:00:00"
  }
}
```

**Verification**:
```bash
curl -H "Authorization: Bearer {token}" http://localhost:8000/api/wallet
```

---

### [ ] Step 2.3: Create WalletController - Transaction History Endpoint
**Task**: Add endpoint to get wallet transaction history
**File to Modify**:
- `server/app/Http/Controllers/Api/WalletController.php`

**Implementation**:
- Method: `getTransactions(Request $request)` with pagination (50 per page)
- Response includes transaction type, amount, description, related user info, timestamp
- Sort by created_at DESC

**Verification**:
```bash
curl -H "Authorization: Bearer {token}" "http://localhost:8000/api/wallet/transactions?page=1"
```

---

### [ ] Step 2.4: Update Login Response with Wallet Balance
**Task**: Include wallet balance in login response
**File to Modify**:
- `server/app/Http/Controllers/Api/AuthController.php`

**Changes**:
- In `login()` method, load wallet relationship
- Add wallet data to response: balance_spy, balance_usd

**Verification**:
```bash
# Login and check response includes wallet data
curl -X POST http://localhost:8000/api/login \
  -d '{"phone":"...","password":"..."}'
```

---

### Phase 3: Lease Payment Integration

### [ ] Step 3.1: Find and Analyze Lease Finalization Endpoint
**Task**: Identify which controller/method handles lease finalization
**Investigation**:
- Search for "lease" or "booking" finalization in controllers
- Look for status update to 'finalized' or 'completed'
- Document the current flow

**Verification**:
```bash
# Search codebase
grep -r "finalize\|completed" server/app/Http/Controllers --include="*.php"
```

---

### [ ] Step 3.2: Add Wallet Validation to Lease Finalization
**Task**: Check tenant's wallet balance before finalizing lease
**File to Modify**:
- Identified controller from Step 3.1 (likely BookingController or RentalApplicationController)

**Changes**:
- Before finalizing, get rental amount from apartment/booking
- Call WalletService::validateSufficientBalance($tenantId, $rentalAmountSpy)
- If insufficient, return error response (422) with message about insufficient funds
- Suggest deposit request option

**Verification**:
```bash
# Create booking without sufficient balance and try to finalize
# Should get error response
```

---

### [ ] Step 3.3: Implement Atomic Wallet Deduction & Transfer
**Task**: Deduct from tenant, add to landlord on lease finalization
**File to Modify**:
- Identified controller from Step 3.1

**Changes**:
- After validation passes, call WalletService::deductAndTransfer()
- Wrap in DB transaction to ensure atomicity
- If successful, create wallet transactions for both tenant and landlord
- Update booking status to finalized
- If WalletService fails, return 422 error

**Verification**:
```bash
# Create booking, finalize it, check both wallets updated
sqlite3 database/database.sqlite "SELECT user_id, balance_spy FROM wallets WHERE user_id IN (1,2)"
sqlite3 database/database.sqlite "SELECT user_id, type, amount_spy FROM wallet_transactions ORDER BY created_at DESC LIMIT 5"
```

---

### Phase 4: Deposit/Withdrawal Request System

### [ ] Step 4.1: Create DepositWithdrawalController
**Task**: Create controller for deposit/withdrawal request management
**File to Create**:
- `server/app/Http/Controllers/Api/DepositWithdrawalController.php`

**Implementation**:
- Methods:
  - `submitDepositRequest(Request $request)` - POST /api/wallet/deposit-request
  - `submitWithdrawalRequest(Request $request)` - POST /api/wallet/withdrawal-request
  - `getPendingRequests()` - GET /api/wallet/my-requests (user can see their own requests)
  - `getAllRequests()` - GET /api/admin/deposit-requests (admin only)
  - `approveRequest($id, Request $request)` - POST /api/admin/deposit-requests/{id}/approve
  - `rejectRequest($id, Request $request)` - POST /api/admin/deposit-requests/{id}/reject

**Request Validation**:
- amount_usd: required, numeric, > 0
- Convert to SPY before storing

**Verification**:
```bash
curl -X POST http://localhost:8000/api/wallet/deposit-request \
  -H "Authorization: Bearer {token}" \
  -d '{"amount_usd": 50}'
```

---

### [ ] Step 4.2: Implement Approval Logic
**Task**: Implement wallet updates when deposits/withdrawals are approved
**File to Modify**:
- `server/app/Http/Controllers/Api/DepositWithdrawalController.php`

**Implementation Details**:
- In `approveRequest()`:
  - Check request exists and is pending
  - Check authorization (admin only)
  - Call WalletService based on request type (addFunds or deductFunds)
  - Update request status to 'approved', set approved_by and approved_at
  - Return success response with updated wallet
- In `rejectRequest()`:
  - Similar checks
  - Update status to 'rejected', set reason
  - No wallet change

**Verification**:
```bash
# Submit request, approve it, check wallet balance updated
sqlite3 database/database.sqlite \
  "SELECT * FROM deposit_withdrawal_requests ORDER BY id DESC LIMIT 1"
```

---

### [ ] Step 4.3: Add Validation for Withdrawal Requests
**Task**: Ensure withdrawal requests don't exceed available balance
**File to Modify**:
- `server/app/Http/Controllers/Api/DepositWithdrawalController.php`

**Changes**:
- In `submitWithdrawalRequest()`, validate that amount_usd doesn't exceed user's balance
- If trying to withdraw more than balance, return validation error
- Return current balance in error response

**Verification**:
```bash
# Try to withdraw more than balance
# Should get validation error with current balance
```

---

### Phase 5: Frontend Wallet UI

### [ ] Step 5.1: Create Flutter Wallet Data Models
**Task**: Create Dart model classes for wallet data
**Files to Create**:
- `client/lib/data/models/wallet.dart`
- `client/lib/data/models/wallet_transaction.dart`
- `client/lib/data/models/deposit_withdrawal_request.dart`

**Implementation**:
- Wallet: id, userId, balanceSpy (BigInt), balanceUsd (computed), currency, timestamps
- WalletTransaction: type enum, amounts, descriptions, foreign keys
- DepositWithdrawalRequest: type, status enums, amounts, approval info

**Verification**:
```bash
# Check models compile
flutter pub get
flutter analyze
```

---

### [ ] Step 5.2: Update API Service with Wallet Endpoints
**Task**: Add wallet API methods to Flutter API service
**File to Modify**:
- `client/lib/core/network/api_service.dart`

**Methods to Add**:
- `getWallet()` - GET /api/wallet
- `getWalletTransactions({int page = 1})` - GET /api/wallet/transactions
- `submitDepositRequest(double amountUsd)` - POST /api/wallet/deposit-request
- `submitWithdrawalRequest(double amountUsd)` - POST /api/wallet/withdrawal-request
- `getMyRequests()` - GET /api/wallet/my-requests
- `getAdminRequests()` - GET /api/admin/deposit-requests (admin)
- `approveRequest(int requestId)` - POST /api/admin/deposit-requests/{id}/approve
- `rejectRequest(int requestId, String reason)` - POST /api/admin/deposit-requests/{id}/reject

**Verification**:
```bash
flutter analyze
# Check no errors in API service
```

---

### [ ] Step 5.3: Create Wallet Provider/State Management
**Task**: Create provider for managing wallet state
**File to Create**:
- `client/lib/providers/wallet_provider.dart` (if using Provider pattern)
  OR
- Update existing state management solution

**Implementation**:
- Load wallet on app start
- Refresh wallet after transactions
- Handle errors gracefully
- Provide methods to submit requests

**Verification**:
```bash
flutter analyze
```

---

### [ ] Step 5.4: Create WalletScreen
**Task**: Create main screen displaying wallet balance
**File to Create**:
- `client/lib/presentation/screens/wallet/wallet_screen.dart`

**UI Components**:
- Display balance in USD and SPY
- "Transaction History" button
- "Request Deposit" button
- "Request Withdrawal" button
- Loading/error states
- Refresh indicator

**Verification**:
```bash
# Run app and navigate to wallet screen
flutter run
```

---

### [ ] Step 5.5: Create Transaction History Screen
**Task**: Create screen showing transaction history
**File to Create**:
- `client/lib/presentation/screens/wallet/transaction_history_screen.dart`

**UI Components**:
- Paginated list of transactions
- Transaction type badge
- Amount, date, description
- Filter by type (optional)

**Verification**:
```bash
# Navigate to transaction history
# Check transactions display correctly
```

---

### [ ] Step 5.6: Create Deposit/Withdrawal Request Screen
**Task**: Create screens for submitting and viewing requests
**Files to Create**:
- `client/lib/presentation/screens/wallet/deposit_request_screen.dart`
- `client/lib/presentation/screens/wallet/withdrawal_request_screen.dart`

**UI Components**:
- Input field for amount (USD)
- Submit button
- Show current balance
- Success/error messages
- List of previous requests with status

**Verification**:
```bash
# Submit request, verify it shows in pending list
```

---

### [ ] Step 5.7: Create Admin Deposit Management Screen
**Task**: Create admin screen to view and manage requests
**File to Create**:
- `client/lib/presentation/screens/admin/manage_deposits_screen.dart`

**UI Components**:
- List of pending requests
- Filter by type and status
- Approve/Reject buttons
- Reason field for rejections
- Transaction amount display

**Verification**:
```bash
# Login as admin
# Check pending requests display
# Approve/reject requests
```

---

### Phase 6: Testing & Integration

### [ ] Step 6.1: Test Wallet Creation on Registration
**Task**: Verify all new users get $100 wallet
**Verification Steps**:
1. Register new user via app
2. Check database: SELECT * FROM wallets WHERE user_id = ?
3. Verify balance_spy = 11000
4. Check API response includes wallet balance

**Success Criteria**:
- 100% of new registrations create wallet
- Balance always 11000 SPY

---

### [ ] Step 6.2: Test Lease Payment Workflow
**Task**: End-to-end test of lease finalization and payment
**Verification Steps**:
1. Create two test users (tenant + landlord)
2. Create apartment listing by landlord
3. Tenant applies for rental
4. Landlord approves application
5. Tenant finalizes lease
6. Check both wallets updated correctly
7. Check transaction records created

**Success Criteria**:
- Tenant balance decreased by rental amount
- Landlord balance increased by rental amount
- Transaction records created for both
- No data corruption

---

### [ ] Step 6.3: Test Insufficient Funds Scenario
**Task**: Verify lease finalization blocked when funds insufficient
**Verification Steps**:
1. Create tenant with balance < rental amount (or drain their wallet)
2. Try to finalize lease
3. Check error response returned
4. Verify balance unchanged

**Success Criteria**:
- Error message clear
- No partial transactions
- Balance untouched

---

### [ ] Step 6.4: Test Deposit/Withdrawal Request Workflow
**Task**: Complete workflow testing
**Verification Steps**:
1. User submits deposit request
2. Admin views pending requests
3. Admin approves deposit
4. Check balance updated
5. Test rejection flow (balance unchanged)
6. Test withdrawal request (check balance validation)

**Success Criteria**:
- All states work correctly
- No balance manipulation
- Audit trail complete

---

### [ ] Step 6.5: Test Currency Display
**Task**: Verify USD/SPY display throughout app
**Verification Steps**:
1. Check all screens show both USD and SPY
2. Verify conversion: SPY ÷ 110 = USD
3. Test transactions show both currencies
4. Test request amounts convert correctly

**Success Criteria**:
- All displays correct
- No rounding errors
- Conversion consistent

---

### [ ] Step 6.6: Run Lint and Type Checks
**Task**: Ensure code quality
**Commands**:
```bash
# Backend
cd server
php artisan lint
# Or your linter

# Frontend
cd client
flutter analyze
flutter format --set-exit-if-changed lib
```

**Success Criteria**:
- No lint errors
- No type errors
- Code formatted consistently
