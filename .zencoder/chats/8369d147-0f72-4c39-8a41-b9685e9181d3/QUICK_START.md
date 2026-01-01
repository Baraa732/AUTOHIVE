# Quick Start Guide - Rental Application Management Feature

## 🚀 Getting Started

### 1. Build & Run the App
```bash
cd client
flutter clean
flutter pub get
flutter run
```

---

## ✅ Test Scenario 1: Full Approval Flow

### Prerequisites
- 2 user accounts: Tenant & Landlord
- One available apartment

### Steps

1. **As Tenant**:
   - Open app and login as tenant
   - Navigate to Apartments
   - Find an apartment and tap it
   - Fill rental application form:
     - Check-in date: Tomorrow
     - Check-out date: 7 days later
     - Optional message: "I am interested"
   - Tap "Submit Application"
   - See success message ✅

2. **As Landlord**:
   - Logout tenant
   - Login as landlord (apartment owner)
   - Navigate to **Incoming Applications**
   - Should see the application in the list with:
     - 🟡 **Yellow "Pending" badge** on the right
     - Tenant name with avatar
     - Rental period (tomorrow to 7 days later)
   - Tap "Review & Respond"

3. **Review Application Detail**:
   - Top shows: Apartment title + 🟡 **Pending status badge**
   - Card shows: Apartment name
   - Card shows: **Tenant Information** with:
     - Tenant avatar with initials
     - Full name
     - Email
     - Phone number
   - Card shows: **Rental Period** with dates and nights count
   - Scroll down to see:
     - 🟢 **Green "Approve Application" button**
     - 🔴 **Red "Reject Application" button**

4. **Approve Application**:
   - Tap **"Approve Application"** button
   - See spinning loading indicator on button
   - Wait for success message: "Application approved successfully!"
   - Auto-navigate back to list
   - Verify application status changed to **🟢 Approved** (green badge)

---

## ✅ Test Scenario 2: Rejection with Reason

### Prerequisites
- Similar to Scenario 1, but new application

### Steps

1. **Follow Scenario 1 steps 1-3**

2. **Reject Application**:
   - Tap **"Reject Application"** button
   - Dialog appears with:
     - Message: "Are you sure you want to reject?"
     - Text field for reason (optional)
   - Enter reason: "Not suitable for pets"
   - Tap "Reject" button in dialog
   - See loading indicator
   - Wait for success: "Application rejected"
   - Auto-navigate back to list

3. **Verify in Tenant View**:
   - Logout landlord
   - Login as tenant
   - Go to "My Rental Applications"
   - See application with 🔴 **Red "Rejected" badge**
   - Tap to open
   - See rejection reason: "Not suitable for pets"

---

## ✅ Test Scenario 3: Modification Request

### Prerequisites
- Completed Scenario 1 (Approved application)
- Same tenant & landlord accounts

### Steps

1. **As Tenant** - Modify Approved Application:
   - Go to "My Rental Applications"
   - Find the **Approved** application
   - Tap **"Modify Application"** button
   - Change dates:
     - New check-in: 10 days from now
     - New check-out: 17 days from now
   - Add message: "Need different dates"
   - Tap "Submit Modification"
   - See success: "Modification submitted"
   - Status now shows: 🟠 **Orange "Modified-Pending"**

2. **As Landlord** - Review Modification:
   - Go to "Incoming Applications"
   - See application with 🟠 **Orange "Modified-Pending" badge**
   - Tap to open details
   - Scroll down to **"Pending Modification"** section (purple card)
   - See 🟣 **"Review Modification"** button
   - Tap it

3. **Modification Review Screen**:
   - Top shows: Apartment title
   - Shows: **Modification Details** card with:
     - 🟠 Status badge: "Modified-Pending"
     - Submitted timestamp
     - Modification reason: "Need different dates"
     - **Changes section** showing:
       - **Check In**: 
         - Previous (red): Original date
         - New (green): New date
       - **Check Out**:
         - Previous (red): Original date
         - New (green): New date
   - Two buttons below:
     - 🟢 **"Approve Modification"** (green)
     - 🔴 **"Reject Modification"** (red)

4. **Approve Modification**:
   - Tap **"Approve Modification"**
   - Loading indicator shows
   - Success: "Modification approved successfully!"
   - Auto-navigate back
   - Status now: 🔷 **Teal "Modified-Approved"** (fully approved)

---

## ✅ Test Scenario 4: Reject Modification (Revert)

### Prerequisites
- Scenario 3 up to Modification Review Screen
- Different modification to test rejection

### Steps

1. **Follow Scenario 3 up to Modification Review Screen**

2. **Reject Modification**:
   - Tap **"Reject Modification"** button
   - Dialog appears with:
     - Message: "Application will revert to previous status"
     - Text field for rejection reason
   - Enter reason: "Dates don't work for my schedule"
   - Tap "Reject"
   - Loading shows
   - Success: "Modification rejected"
   - Auto-navigate back

3. **Verify Status Reverted**:
   - Check application status
   - Should be back to 🟢 **"Approved"** (previous status)
   - Modification history preserved

---

## 🔍 Debug Features

### Console Logging
When testing, check the device/emulator console (Run > Debug Console) for messages like:

```
🔍 DEBUG: Application Detail Screen Loaded
   - ID: 123
   - Status: pending
   - Tenant: John Doe
   - Apartment: Luxury Apartment
   - Status allows approve/reject: true

🔘 DEBUG: Button visibility check - Status: pending, Show: true

👍 DEBUG: Approve button pressed for application 123
   - Current status: pending
⏳ DEBUG: Starting approval API call...
📡 DEBUG: Approval API response: true
✅ DEBUG: Approval successful
```

### Status Badge Colors
- 🟡 Yellow (Pending)
- 🟢 Green (Approved)
- 🔴 Red (Rejected)
- 🟠 Orange (Modified-Pending)
- 🔷 Teal (Modified-Approved)

---

## ❌ Troubleshooting

### Buttons Not Visible
1. Check console for debug logs
2. Verify application status matches expected values
3. Ensure status validation shows "true" in logs

### API Errors
1. Check internet connection
2. Verify backend is running
3. Check error message in snackbar
4. See console logs for detailed errors

### Widget Errors
1. Ensure all imports are correct
2. Run `flutter pub get`
3. Run `flutter clean` if needed
4. Check that all new files exist

---

## 📋 Checklist for Full Testing

### Basic Functionality
- [ ] Login as landlord
- [ ] View incoming applications
- [ ] See status badges on list
- [ ] Tap application to view details
- [ ] See approve/reject buttons
- [ ] Approve an application
- [ ] See success message
- [ ] List refreshes automatically
- [ ] Status changed to "Approved"

### Tenant Workflow
- [ ] Login as tenant
- [ ] Submit new application
- [ ] Application appears in list
- [ ] See correct status badge
- [ ] For approved: tap "Modify Application"
- [ ] Change dates and submit
- [ ] Status changes to "Modified-Pending"

### Landlord Approves Modification
- [ ] Login as landlord
- [ ] See "Modified-Pending" application
- [ ] Review modification shows diff
- [ ] Old and new values visible
- [ ] Approve modification
- [ ] Status changes to "Modified-Approved"

### Edge Cases
- [ ] Cannot approve already approved application
- [ ] Cannot reject already approved application
- [ ] Reject shows correct reason dialog
- [ ] Can resubmit after rejection (up to 3 times)
- [ ] Back button during loading doesn't crash

---

## 🎯 Success Indicators

✅ **When Complete, You Should See**:

1. **Status Badges** on all applications with correct colors
2. **Approve/Reject Buttons** only showing for appropriate statuses
3. **Loading Indicators** during API calls
4. **Success Messages** after each action
5. **Automatic Refresh** after approval/rejection
6. **Modification Diffs** showing changes clearly
7. **Console Logs** with debug information
8. **Smooth Navigation** between screens

---

## 🚀 What's Next

After testing:
1. Review the IMPLEMENTATION_SUMMARY.md for detailed architecture
2. Check plan.md for all completed phases
3. Review requirements.md for acceptance criteria
4. Check spec.md for technical details

All features are complete and ready for production! 🎉
