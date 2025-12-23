<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Services\NotificationService;

class AdminActivity extends Model
{
    protected $fillable = [
        'admin_id',
        'action',
        'description',
        'metadata',
        'ip_address',
        'user_agent',
    ];

    protected $casts = [
        'metadata' => 'array',
    ];

    public function admin()
    {
        return $this->belongsTo(User::class, 'admin_id');
    }

    public static function log($action, $description, $metadata = null)
    {
        $activity = self::create([
            'admin_id' => auth()->id(),
            'action' => $action,
            'description' => $description,
            'metadata' => $metadata,
            'ip_address' => request()->ip(),
            'user_agent' => request()->userAgent(),
        ]);

        // Send notification to other admins for important actions
        $importantActions = ['admin_created', 'admin_deleted', 'user_approved', 'user_rejected'];
        if (in_array($action, $importantActions)) {
            NotificationService::sendAdminActivityNotification($activity);
        }

        return $activity;
    }
}