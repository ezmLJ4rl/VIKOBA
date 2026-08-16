<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreMemberRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'full_name' => ['required', 'string', 'max:120'],
            'phone' => ['required', 'string', 'max:20', 'regex:/^(\+?255|0)?[1-9][0-9]{8}$/'],
            'role' => ['required', 'in:chairperson,treasurer,secretary,member'],
            'joined_date' => ['nullable', 'date'],
            'initial_shares' => ['nullable', 'integer', 'min:0'],
        ];
    }

    public function messages(): array
    {
        return [
            'phone.regex' => 'Phone must be a valid Tanzanian number (e.g. +255712345678 or 0712345678).',
        ];
    }
}
