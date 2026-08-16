<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

/**
 * Server-side loan quote request. The schedule and totals in the response are
 * the ONLY numbers the client may show — the request form never computes
 * interest itself once it talks to a backend.
 */
class LoanQuoteRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'loan_product_id' => ['required', 'integer', 'exists:loan_products,id'],
            'member_id' => ['required', 'integer', 'exists:members,id'],
            'principal' => ['required', 'integer', 'min:1'],
            'term_months' => ['required', 'integer', 'min:1', 'max:120'],
        ];
    }
}
