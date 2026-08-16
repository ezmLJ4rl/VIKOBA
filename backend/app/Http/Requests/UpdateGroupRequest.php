<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateGroupRequest extends FormRequest
{
    public function authorize(): bool
    {
        return auth()->user()?->canConfigureGroup() ?? false;
    }

    public function rules(): array
    {
        return [
            'group_name' => ['nullable', 'string', 'max:120'],
            'share_value' => ['nullable', 'integer', 'min:1', 'max:10000000'],
            'default_interest_rate' => ['nullable', 'numeric', 'min:0', 'max:100'],
            'interest_method' => ['nullable', 'in:flat,reducing'],
            'max_loan_multiple' => ['nullable', 'integer', 'min:1', 'max:20'],
            'contribution_cycle' => ['nullable', 'in:weekly,monthly'],
            'min_membership_days' => ['nullable', 'integer', 'min:0', 'max:3650'],
        ];
    }
}
