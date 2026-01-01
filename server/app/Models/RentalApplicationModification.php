<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class RentalApplicationModification extends Model
{
    use HasFactory;

    const STATUS_PENDING = 'pending';
    const STATUS_APPROVED = 'approved';
    const STATUS_REJECTED = 'rejected';

    protected $fillable = [
        'rental_application_id',
        'status',
        'previous_values',
        'new_values',
        'modification_reason',
        'rejection_reason',
        'submitted_at',
        'responded_at',
    ];

    protected $casts = [
        'previous_values' => 'array',
        'new_values' => 'array',
        'submitted_at' => 'datetime',
        'responded_at' => 'datetime',
    ];

    public function rentalApplication()
    {
        return $this->belongsTo(RentalApplication::class, 'rental_application_id');
    }

    public function getDiff(): array
    {
        $diff = [];
        foreach ($this->new_values as $key => $newValue) {
            $oldValue = $this->previous_values[$key] ?? null;
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
}
