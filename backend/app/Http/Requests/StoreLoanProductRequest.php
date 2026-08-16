<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreLoanProductRequest extends FormRequest
{
    public function authorize(): bool
    {
        return auth()->user()?->canConfigureGroup() ?? false;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:80'],
            'description' => ['nullable', 'string', 'max:300'],
            'interest_rate' => ['required', 'numeric', 'min:0', 'max:100'],
            'interest_method' => ['required', 'in:flat,reducing'],
            'max_term_months' => ['required', 'integer', 'min:1', 'max:120'],
            'max_multiplier' => ['required', 'integer', 'min:1', 'max:20'],
            'min_amount' => ['nullable', 'integer', 'min:0'],
            'penalty_type' => ['required', 'in:flat,percent'],
            'penalty_value' => ['nullable', 'integer', 'min:0'],
            'penalty_grace_days' => ['nullable', 'integer', 'min:0'],
            'penalty_period_days' => ['nullable', 'integer', 'min:1'],
            'installment_interval_days' => ['nullable', 'integer', 'min:1'],
            'is_active' => ['nullable', 'boolean'],
        ];
    }
}
