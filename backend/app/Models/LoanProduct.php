<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class LoanProduct extends Model
{
    use HasFactory;

    public const METHOD_FLAT = 'flat';

    public const METHOD_REDUCING = 'reducing';

    public const PENALTY_FLAT = 'flat';

    public const PENALTY_PERCENT = 'percent';

    protected $fillable = [
        'group_id',
        'name',
        'description',
        'interest_rate',
        'interest_method',
        'max_term_months',
        'max_multiplier',
        'min_amount',
        'penalty_type',
        'penalty_value',
        'penalty_grace_days',
        'penalty_period_days',
        'installment_interval_days',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'interest_rate' => 'decimal:2',
            'max_term_months' => 'integer',
            'max_multiplier' => 'integer',
            'min_amount' => 'integer',
            'penalty_value' => 'integer',
            'penalty_grace_days' => 'integer',
            'penalty_period_days' => 'integer',
            'installment_interval_days' => 'integer',
            'is_active' => 'boolean',
        ];
    }

    public function group(): BelongsTo
    {
        return $this->belongsTo(Group::class);
    }

    public function loans(): HasMany
    {
        return $this->hasMany(Loan::class);
    }
}
