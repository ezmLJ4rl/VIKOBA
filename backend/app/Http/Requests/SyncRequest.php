<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class SyncRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'operations' => ['required', 'array', 'max:500'],
            'operations.*.type' => ['required', 'string', 'max:60'],
            'operations.*.idempotency_key' => ['required', 'string', 'max:64'],
            'operations.*.payload' => ['required', 'array'],
            'operations.*.occurred_at' => ['nullable', 'date'],
        ];
    }
}
