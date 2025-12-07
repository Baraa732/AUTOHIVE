<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Activity extends Model
{
    protected $fillable = [
        'admin_id',
        'action',
        'description',
        'data'
    ];

    protected $casts = [
        'data' => 'array'
    ];

    public function admin()
    {
        return $this->belongsTo(User::class, 'admin_id');
    }

    public static function log($action, $description, $data = null)
    {
        return self::create([
            'admin_id' => auth()->id(),
            'action' => $action,
            'description' => $description,
            'data' => $data
        ]);
    }
}
