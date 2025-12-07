<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Carbon\Carbon;

class BookingRequest extends FormRequest
{
    public function authorize()
    {
        return $this->user()->role === 'tenant';
    }

    public function rules()
    {
        return [
            'apartment_id' => 'required|exists:apartments,id',
            'check_in' => 'required|date|after_or_equal:today',
            'check_out' => 'required|date|after:check_in',
        ];
    }

    public function withValidator($validator)
    {
        $validator->after(function ($validator) {
            if ($this->check_in && $this->check_out) {
                $checkIn = Carbon::parse($this->check_in);
                $checkOut = Carbon::parse($this->check_out);

                if ($checkOut->diffInDays($checkIn) > 30) {
                    $validator->errors()->add('check_out', 'Maximum booking duration is 30 days.');
                }
            }
        });
    }
}
