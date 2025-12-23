<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Setting;
use Illuminate\Http\Request;

class SettingController extends Controller
{
    public function index()
    {
        $settings = Setting::pluck('value', 'key');
        return response()->json($settings);
    }

    public function update(Request $request)
    {
        $request->validate([
            'language' => 'in:en,ar',
            'theme' => 'in:light,dark',
        ]);

        $userId = $request->user()->id;

        if ($request->has('language')) {
            Setting::updateOrCreate(
                ['key' => "user_{$userId}_language"],
                ['value' => $request->language]
            );
        }

        if ($request->has('theme')) {
            Setting::updateOrCreate(
                ['key' => "user_{$userId}_theme"],
                ['value' => $request->theme]
            );
        }

        return response()->json(['message' => 'Settings updated successfully']);
    }
}
