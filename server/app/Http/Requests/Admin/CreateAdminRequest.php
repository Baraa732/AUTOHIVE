<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Support\Facades\Auth;

class CreateAdminRequest extends FormRequest
{
    public function authorize()
    {
        return Auth::check() && Auth::user()->role === 'admin';
    }

    public function rules()
    {
        return [
            'phone' => 'required|string|regex:/^[0-9]{10}$/|unique:users,phone',
            'password' => 'required|string|min:6|max:50',
            'first_name' => 'required|string|min:2|max:50|regex:/^[a-zA-Z\s]+$/',
            'last_name' => 'required|string|min:2|max:50|regex:/^[a-zA-Z\s]+$/',
            'birth_day' => 'required|integer|min:1|max:31',
            'birth_month' => 'required|integer|min:1|max:12',
            'birth_year' => 'required|integer|min:1900|max:' . (date('Y') - 18),
        ];
    }

    public function messages()
    {
        return [
            'phone.regex' => 'Phone number must be exactly 10 digits.',
            'phone.unique' => 'This phone number is already registered.',
            'first_name.regex' => 'First name can only contain letters and spaces.',
            'last_name.regex' => 'Last name can only contain letters and spaces.',
            'birth_day.required' => 'Please select a birth day.',
            'birth_day.integer' => 'Birth day must be a valid number.',
            'birth_day.min' => 'Birth day must be at least 1.',
            'birth_day.max' => 'Birth day must be at most 31.',
            'birth_month.required' => 'Please select a birth month.',
            'birth_month.integer' => 'Birth month must be a valid number.',
            'birth_month.min' => 'Birth month must be at least 1.',
            'birth_month.max' => 'Birth month must be at most 12.',
            'birth_year.required' => 'Please select a birth year.',
            'birth_year.integer' => 'Birth year must be a valid number.',
            'birth_year.min' => 'Birth year must be at least 1900.',
            'birth_year.max' => 'You must be at least 18 years old.',
        ];
    }
}
