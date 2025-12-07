<?php

use Illuminate\Support\Facades\Broadcast;

// Admin channels
Broadcast::channel('admin.{adminId}', function ($user, $adminId) {
    return $user->role === 'admin' && (int) $user->id === (int) $adminId;
});

// User channels
Broadcast::channel('user.{userId}', function ($user, $userId) {
    return (int) $user->id === (int) $userId;
});

// Booking channels for owners
Broadcast::channel('owner.{ownerId}', function ($user, $ownerId) {
    return $user->role === 'owner' && (int) $user->id === (int) $ownerId;
});