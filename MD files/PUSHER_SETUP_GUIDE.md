# Pusher Setup Guide for Real-Time Notifications

## Step 1: Create Pusher Account

1. Go to https://pusher.com
2. Sign up for a free account
3. Click "Create app" or "Channels apps" → "Create app"

## Step 2: Configure Your Pusher App

### App Settings:
- **Name**: AUTOHIVE (or any name you prefer)
- **Cluster**: Choose closest to your location (e.g., eu, us2, ap1)
- **Frontend**: Select "React" or "Vanilla JS" (doesn't matter much)
- **Backend**: Select "Laravel"

Click "Create app"

## Step 3: Get Your Credentials

After creating the app, you'll see:
- **app_id**: e.g., 1234567
- **key**: e.g., a1b2c3d4e5f6g7h8i9j0
- **secret**: e.g., k1l2m3n4o5p6q7r8s9t0
- **cluster**: e.g., eu, us2, ap1

## Step 4: Update Your .env File

Add these lines to your `.env` file:

```env
# Broadcasting Configuration
BROADCAST_DRIVER=pusher

# Pusher Configuration
PUSHER_APP_ID=your_app_id_here
PUSHER_APP_KEY=your_key_here
PUSHER_APP_SECRET=your_secret_here
PUSHER_APP_CLUSTER=your_cluster_here
PUSHER_HOST=
PUSHER_PORT=443
PUSHER_SCHEME=https
```

### Example with Real Values:
```env
BROADCAST_DRIVER=pusher

PUSHER_APP_ID=1234567
PUSHER_APP_KEY=a1b2c3d4e5f6g7h8i9j0
PUSHER_APP_SECRET=k1l2m3n4o5p6q7r8s9t0
PUSHER_APP_CLUSTER=eu
PUSHER_HOST=
PUSHER_PORT=443
PUSHER_SCHEME=https
```

## Step 5: Update config/broadcasting.php (Already Done)

The file is already configured correctly. Just verify it looks like this:

```php
'pusher' => [
    'driver' => 'pusher',
    'key' => env('PUSHER_APP_KEY'),
    'secret' => env('PUSHER_APP_SECRET'),
    'app_id' => env('PUSHER_APP_ID'),
    'options' => [
        'cluster' => env('PUSHER_APP_CLUSTER'),
        'useTLS' => true,
    ],
],
```

## Step 6: Clear Configuration Cache

Run these commands in your terminal:

```bash
php artisan config:clear
php artisan cache:clear
```

## Step 7: Test the Connection

### Option 1: Using Pusher Debug Console

1. Go to your Pusher dashboard
2. Click on your app
3. Go to "Debug Console" tab
4. Keep this tab open

### Option 2: Test via Postman

1. Register a new user:
```http
POST http://localhost:8000/api/register
Content-Type: application/json

{
    "phone": "1234567890",
    "password": "password123",
    "password_confirmation": "password123",
    "role": "tenant",
    "first_name": "John",
    "last_name": "Doe",
    "birth_date": "1990-01-01"
}
```

2. Watch the Pusher Debug Console
3. You should see events on channels like: `private-admin.1`, `private-admin.2`, etc.

## Step 8: Verify Broadcasting is Working

### Check Laravel Logs
```bash
tail -f storage/logs/laravel.log
```

If you see errors like:
- "cURL error 6: Could not resolve host" → Check internet connection
- "Invalid signature" → Check PUSHER_APP_SECRET is correct
- "Invalid app_id" → Check PUSHER_APP_ID is correct

### Check Pusher Dashboard
1. Go to "Overview" tab
2. You should see:
   - **Connections**: Number of active connections
   - **Messages**: Number of messages sent
   - **Channels**: Active channels

## Alternative: Use Pusher Beams (Optional)

If you want push notifications on mobile devices, you can also set up Pusher Beams:

1. Go to Pusher dashboard
2. Click "Beams" → "Create instance"
3. Follow the setup for iOS/Android

## Troubleshooting

### Issue: "Class 'Pusher\Pusher' not found"
**Solution:**
```bash
composer require pusher/pusher-php-server
```

### Issue: "Broadcasting driver [pusher] is not supported"
**Solution:**
1. Check `.env` has `BROADCAST_DRIVER=pusher`
2. Run `php artisan config:clear`
3. Restart your Laravel server

### Issue: Events not showing in Debug Console
**Solution:**
1. Verify credentials are correct
2. Check `BROADCAST_DRIVER=pusher` (not `log`)
3. Check Laravel logs for errors
4. Verify internet connection

### Issue: "Unauthorized" when connecting
**Solution:**
1. Check `/api/broadcasting/auth` endpoint is accessible
2. Verify user token is valid
3. Check `routes/channels.php` authorization logic

## Free Tier Limits

Pusher free tier includes:
- ✅ 200,000 messages per day
- ✅ 100 concurrent connections
- ✅ Unlimited channels
- ✅ SSL included

This is more than enough for development and small production apps!

## Testing Checklist

- [ ] Pusher account created
- [ ] App created in Pusher dashboard
- [ ] Credentials added to `.env` file
- [ ] `BROADCAST_DRIVER=pusher` set in `.env`
- [ ] Config cache cleared
- [ ] Laravel server restarted
- [ ] Test user registration via Postman
- [ ] Events visible in Pusher Debug Console
- [ ] No errors in Laravel logs

## Next Steps

Once Pusher is configured:

1. ✅ Test user registration → Admin receives notification
2. ✅ Test user approval → User receives notification
3. ✅ Integrate frontend with Laravel Echo
4. ✅ Build notification UI component

## Quick Start Commands

```bash
# 1. Install Pusher PHP SDK (if not installed)
composer require pusher/pusher-php-server

# 2. Clear cache
php artisan config:clear
php artisan cache:clear

# 3. Start Laravel server
php artisan serve

# 4. Test with Postman
# Import: AUTOHIVE_Notifications.postman_collection.json
```

## Support

If you encounter issues:
1. Check Laravel logs: `storage/logs/laravel.log`
2. Check Pusher Debug Console
3. Verify all credentials are correct
4. Ensure `BROADCAST_DRIVER=pusher`

---

**Ready to test!** 🚀

Once you've added the Pusher credentials to your `.env` file, the real-time notification system will work automatically!
