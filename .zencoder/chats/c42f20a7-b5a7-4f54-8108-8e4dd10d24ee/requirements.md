# Feature Specification: User Wallet System

## Overview
A wallet system that enables users to manage funds for apartment rentals. The system supports automatic wallet creation on user registration, automatic fund deductions during lease finalization, and admin-managed deposit/withdrawal requests.

---

## User Stories

### User Story 1 - Account Creation with Auto Wallet
**Acceptance Scenarios**:
1. **Given** a new user registers for an account, **When** the registration completes successfully, **Then** a wallet is automatically created with an initial balance of $100 (11,000 SPY)
2. **Given** a user completes registration, **When** they access their dashboard, **Then** they can see their wallet balance

---

### User Story 2 - Automatic Deduction on Lease Finalization
**Acceptance Scenarios**:
1. **Given** a tenant has an approved rental application and sufficient funds in their wallet, **When** the lease agreement is finalized, **Then** the rental amount is automatically deducted from the tenant's wallet
2. **Given** a tenant tries to finalize a lease with insufficient funds, **When** the finalization is triggered, **Then** the lease finalization is blocked and an error message is shown
3. **Given** a lease is finalized and funds are deducted from the tenant's wallet, **When** the transaction completes, **Then** the deducted amount is automatically added to the landlord's wallet

---

### User Story 3 - Deposit/Withdrawal Request System
**Acceptance Scenarios**:
1. **Given** a user (tenant/landlord) wants to deposit money, **When** they submit a deposit request with an amount, **Then** a request is created pending admin approval
2. **Given** a user wants to withdraw money, **When** they submit a withdrawal request with an amount, **Then** a request is created pending admin approval
3. **Given** an admin receives a deposit/withdrawal request, **When** they approve it, **Then** the wallet is updated with the approved amount
4. **Given** an admin receives a deposit/withdrawal request, **When** they reject it, **Then** the request is marked as rejected and the wallet is unchanged
5. **Given** a user submits a withdrawal request larger than their wallet balance, **When** an admin tries to approve it, **Then** the approval is rejected due to insufficient funds

---

## Requirements

### Functional Requirements

#### Wallet Creation
- FR-1: Wallet must be automatically created when a user registers successfully
- FR-2: Initial wallet balance must be set to $100 USD (equivalent to 11,000 SPY)
- FR-3: Each user can have only one active wallet

#### Currency & Exchange
- FR-4: System must support USD ($) and Syrian Pound (SPY) currencies
- FR-5: Exchange rate must be fixed at 1 USD = 110 SPY
- FR-6: All internal calculations must use SPY for precision
- FR-7: Display amounts in both USD and SPY to the user

#### Lease Finalization & Payment
- FR-8: When a lease is finalized, the system must check tenant's wallet balance
- FR-9: If tenant has insufficient funds, lease finalization must be blocked
- FR-10: If tenant has sufficient funds, rental amount must be automatically deducted from tenant's wallet
- FR-11: Deducted amount must be automatically added to landlord's wallet
- FR-12: Transaction must be atomic (all-or-nothing)

#### Deposit/Withdrawal Requests
- FR-13: Users (tenants and landlords) can submit deposit requests to admin
- FR-14: Users (tenants and landlords) can submit withdrawal requests to admin
- FR-15: Deposit/withdrawal requests must include: amount, request type (deposit/withdrawal), user ID, timestamp, and status
- FR-16: Only admins can approve or reject deposit/withdrawal requests
- FR-17: Admin can view all pending deposit/withdrawal requests
- FR-18: When admin approves a deposit request, funds are added to the user's wallet
- FR-19: When admin approves a withdrawal request, funds are deducted from the user's wallet (if sufficient balance exists)
- FR-20: When admin rejects a request, status is updated to rejected and no wallet change occurs
- FR-21: Users can view their deposit/withdrawal request history

### Non-Functional Requirements
- NFR-1: All wallet transactions must be logged for audit purposes
- NFR-2: Wallet operations must be thread-safe to prevent race conditions
- NFR-3: Wallet balance updates must happen in real-time across the application

---

## Success Criteria

1. **Wallet Creation**: 100% of new user registrations result in automatic wallet creation with $100 balance
2. **Lease Payment**: All lease finalizations properly check wallet balance and deduct/transfer funds correctly
3. **Admin Requests**: Admins can view, approve, and reject deposit/withdrawal requests; all transactions are recorded
4. **Data Integrity**: Transaction logs are complete and accurate; no balance discrepancies
5. **Currency Handling**: All calculations use SPY internally; display shows both USD and SPY equivalents
6. **User Experience**: Users can view wallet balance, transaction history, and request status at all times
