<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreLoanRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'member_id' => ['required', 'integer', 'exists:members,id'],
            'principal' => ['required', 'integer', 'min:1'],
            'loan_product_id' => ['nullable', 'integer', 'exists:loan_products,id'],
            'term_months' => ['nullable', 'integer', 'min:1', 'max:120'],
            'guarantor_member_ids' => ['nullable', 'array', 'max:2'],
            'guarantor_member_ids.*' => ['integer', 'exists:members,id'],
            'repayment_days' => ['nullable', 'integer', 'in:30,60,90'],
            'idempotency_key' => ['nullable', 'string', 'max:64'],
            'note' => ['nullable', 'string', 'max:500'],
        ];
    }

    public function messages(): array
    {
        return ['principal.min' => 'Loan amount must be a positive whole number in shillings.'];
    }
}
