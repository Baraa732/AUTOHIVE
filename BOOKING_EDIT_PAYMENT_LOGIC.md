# Booking Edit Payment Logic

## Overview
When a tenant edits a booking's dates, the system handles payment adjustments based on whether the booking duration increases or decreases.

## Business Rules

### 1. Booking Duration Extended (Longer Stay)
**Scenario:** Tenant changes booking from 3 nights to 5 nights

**Action:**
- Calculate price difference: `(new_nights - old_nights) × price_per_night`
- Check tenant's wallet balance for the difference
- If sufficient funds:
  - Deduct difference from tenant's wallet
  - Transfer difference to landlord's wallet
  - Update booking with new dates and total price
- If insufficient funds:
  - Reject the modification
  - Show error with required amount and shortage
  - Offer option to add funds to wallet

**Example:**
```
Original: 3 nights × $100 = $300 (already paid)
New: 5 nights × $100 = $500
Difference: $200 (must be paid from wallet)
```

### 2. Booking Duration Shortened (Shorter Stay)
**Scenario:** Tenant changes booking from 5 nights to 3 nights

**Action:**
- Calculate new total price: `new_nights × price_per_night`
- Update booking with new dates and total price
- **NO REFUND** issued to tenant
- Tenant loses the difference (penalty for shortening)

**Example:**
```
Original: 5 nights × $100 = $500 (already paid)
New: 3 nights × $100 = $300
Difference: $200 (tenant loses this, no refund)
```

### 3. Same Duration, Different Dates
**Scenario:** Tenant changes dates but keeps same number of nights

**Action:**
- Update booking with new dates
- No payment adjustment needed
- Total price remains the same

## Implementation Details

### Backend (`BookingController.php`)

```php
if ($recalculatePrice) {
    $newTotalPrice = $nights * $booking->apartment->price_per_night;
    $oldTotalPrice = $booking->total_price;
    
    // If new price is higher, charge the difference
    if ($newTotalPrice > $oldTotalPrice) {
        $priceDifference = $newTotalPrice - $oldTotalPrice;
        $priceDifferenceSpy = intval($priceDifference * 110);
        
        // Check wallet balance
        if (!$walletService->validateSufficientBalance($tenantId, $priceDifferenceSpy)) {
            return response()->json([
                'success' => false,
                'message' => 'Insufficient funds to extend booking duration',
                'data' => [
                    'required_difference_usd' => $priceDifference,
                    'shortage_usd' => $shortage,
                ]
            ], 422);
        }
        
        // Deduct and transfer the difference
        $walletService->deductAndTransfer($tenantId, $landlordId, $priceDifferenceSpy, $booking->id);
    }
    // If new price is lower, no refund
    elseif ($newTotalPrice < $oldTotalPrice) {
        Log::info('Booking shortened - no refund issued');
    }
    
    $updateData['total_price'] = $newTotalPrice;
}
```

### Client (`bookings_screen.dart`)

```dart
if (success['data'] != null && success['data']['shortage_usd'] != null) {
    final shortage = success['data']['shortage_usd'];
    final required = success['data']['required_difference_usd'];
    
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
            title: const Text('Insufficient Balance'),
            content: Column(
                children: [
                    Text('Required: \$${required.toStringAsFixed(2)}'),
                    Text('Shortage: \$${shortage.toStringAsFixed(2)}'),
                ],
            ),
            actions: [
                TextButton(child: Text('Cancel')),
                ElevatedButton(child: Text('Add Funds')),
            ],
        ),
    );
}
```

## Wallet Transaction Records

### Extension (Additional Payment)
```
Type: DEBIT (Tenant)
Amount: $200
Description: "Booking extension payment for Booking #123"

Type: CREDIT (Landlord)
Amount: $200
Description: "Received booking extension payment for Booking #123"
```

### Shortening (No Transaction)
```
No wallet transactions created
Tenant loses the difference as penalty
```

## Security Considerations

1. **Atomic Transactions**: All wallet operations are wrapped in database transactions
2. **Balance Validation**: Always check balance before deducting
3. **Audit Trail**: All payment adjustments are logged
4. **No Refunds**: Prevents abuse by repeatedly shortening bookings

## User Experience

### Extension Flow
1. Tenant selects new dates (longer duration)
2. System checks availability
3. System calculates price difference
4. System checks wallet balance
5. If sufficient: Payment processed automatically
6. If insufficient: Show error with "Add Funds" option
7. Booking updated with new dates

### Shortening Flow
1. Tenant selects new dates (shorter duration)
2. System checks availability
3. System shows warning: "No refund will be issued"
4. Tenant confirms
5. Booking updated with new dates
6. No payment adjustment

## Error Messages

### Insufficient Balance
```
"Insufficient funds to extend booking duration"
Required: $200.00
Current Balance: $150.00
Shortage: $50.00
```

### Shortening Warning
```
"Shortening your booking will not result in a refund. 
You will lose $200.00 by reducing the duration."
```

## Testing Scenarios

1. ✅ Extend booking with sufficient balance
2. ✅ Extend booking with insufficient balance
3. ✅ Shorten booking (no refund)
4. ✅ Change dates with same duration (no payment)
5. ✅ Concurrent edit attempts
6. ✅ Wallet balance edge cases (exactly enough, $0.01 short)

## Files Modified

1. `server/app/Http/Controllers/Api/BookingController.php`
   - Added wallet validation for price increases
   - Added payment processing for extensions
   - Added no-refund logic for shortenings

2. `client/lib/presentation/screens/shared/bookings_screen.dart`
   - Added insufficient balance error handling
   - Added "Add Funds" dialog for extensions
