<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreApartmentRequest extends FormRequest
{
    public function authorize()
    {
        return $this->user()->role === 'landlord';
    }

    public function rules()
    {
        return [
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'governorate' => 'required|string|max:100',
            'city' => 'required|string|max:100',
            'address' => 'required|string',
            'price_per_night' => 'required|numeric|min:0',
            'max_guests' => 'required|integer|min:1|max:20',
            'rooms' => 'required|integer|min:1|max:10',
            'features' => 'array',
            'features.*' => 'string',
            'images.*' => 'image|mimes:jpeg,png,jpg|max:2048',
        ];
    }
}
