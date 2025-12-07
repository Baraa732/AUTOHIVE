<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class RegisterRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'phone' => 'required|string|unique:users,phone|regex:/^[0-9]{10,15}$/',
            'password' => 'required|string|min:6',
            'role' => 'required|in:tenant,landlord',
            'first_name' => 'required|string|max:50',
            'last_name' => 'required|string|max:50',
            'birth_date' => 'required|date|before:today',
        ];
    }

    public function messages()
    {
        return [
            'phone.regex' => 'Phone number must be between 10 and 15 digits',
            'birth_date.before' => 'Birth date must be in the past',
        ];
    }
}
