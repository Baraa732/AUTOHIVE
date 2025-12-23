<?php

namespace App\Helpers;

use Illuminate\Support\Facades\Storage;

class ImageHelper
{
    public static function getImageUrl($imagePath)
    {
        if (empty($imagePath)) {
            return null;
        }

        // If it's already a full URL, return as is
        if (str_starts_with($imagePath, 'http')) {
            return $imagePath;
        }

        // Generate the full URL using Laravel's asset helper
        return asset('storage/' . $imagePath);
    }

    public static function getImageUrls($imagePaths)
    {
        if (empty($imagePaths) || !is_array($imagePaths)) {
            return [];
        }

        return array_map([self::class, 'getImageUrl'], $imagePaths);
    }
}