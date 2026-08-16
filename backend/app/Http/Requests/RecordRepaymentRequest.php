<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class RecordRepaymentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'amount' => ['required', 'integer', 'min:1'],
            'recorded_at' => ['nullable', 'date'],
            'idempotency_key' => ['nullable', 'string', 'max:64'],
        ];
    }
}
