<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class RentalApplication extends Model
{
    use HasFactory;

    const STATUS_PENDING = 'pending';
    const STATUS_APPROVED = 'approved';
    const STATUS_REJECTED = 'rejected';
    const STATUS_MODIFIED_PENDING = 'modified-pending';
    const STATUS_MODIFIED_APPROVED = 'modified-approved';

    protected $fillable = [
        'user_id',
        'apartment_id',
        'check_in',
        'check_out',
        'message',
        'submission_attempt',
        'status',
        'rejected_reason',
        'submitted_at',
        'responded_at',
        'previous_status',
        'previous_data',
        'current_data',
        'modification_reason',
        'modification_submitted_at',
    ];

    protected $casts = [
        'check_in' => 'date',
        'check_out' => 'date',
        'submitted_at' => 'datetime',
        'responded_at' => 'datetime',
        'modification_submitted_at' => 'datetime',
        'previous_data' => 'array',
        'current_data' => 'array',
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function apartment()
    {
        return $this->belongsTo(Apartment::class, 'apartment_id');
    }

    public function modifications()
    {
        return $this->hasMany(RentalApplicationModification::class, 'rental_application_id');
    }

    public function canBeModified(): bool
    {
        return in_array($this->status, [
            self::STATUS_PENDING,
            self::STATUS_APPROVED,
        ]);
    }

    public function getDiffWithPrevious(): array
    {
        if (!$this->previous_data || !$this->current_data) {
            return [];
        }

        $diff = [];
        foreach ($this->current_data as $key => $newValue) {
            $oldValue = $this->previous_data[$key] ?? null;
            if ($oldValue !== $newValue) {
                $diff[$key] = [
                    'old' => $oldValue,
                    'new' => $newValue,
                ];
            }
        }

        return $diff;
    }

    public function scopePending($query)
    {
        return $query->where('status', self::STATUS_PENDING);
    }

    public function scopeApproved($query)
    {
        return $query->where('status', self::STATUS_APPROVED);
    }

    public function scopeRejected($query)
    {
        return $query->where('status', self::STATUS_REJECTED);
    }

    public function scopeModifiedPending($query)
    {
        return $query->where('status', self::STATUS_MODIFIED_PENDING);
    }
}
