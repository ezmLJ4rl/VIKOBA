<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Loan extends Model
{
    use HasFactory;

    public const STATUS_PENDING = 'pending';

    public const STATUS_APPROVED = 'approved';

    public const STATUS_ACTIVE = 'active';

    public const STATUS_REPAID = 'repaid';

    public const STATUS_REJECTED = 'rejected';

    protected $appends = ['balance', 'outstanding'];

    protected $fillable = [
        'group_id',
        'loan_product_id',
        'member_id',
        'requested_by',
        'decided_by',
        'principal',
        'interest_rate',
        'interest_method',
        'term_months',
        'installment_interval_days',
        'interest_amount',
        'total_payable',
        'amount_repaid',
        'penalty_accrued',
        'status',
        'issued_at',
        'disbursed_at',
        'disbursement_method',
        'due_date',
        'idempotency_key',
        'note',
    ];

    protected function casts(): array
    {
        return [
            'principal' => 'integer',
            'interest_amount' => 'integer',
            'total_payable' => 'integer',
            'amount_repaid' => 'integer',
            'penalty_accrued' => 'integer',
            'issued_at' => 'datetime',
            'disbursed_at' => 'datetime',
            'due_date' => 'date',
        ];
    }

    public function group(): BelongsTo
    {
        return $this->belongsTo(Group::class);
    }

    public function member(): BelongsTo
    {
        return $this->belongsTo(Member::class);
    }

    public function product(): BelongsTo
    {
        return $this->belongsTo(LoanProduct::class, 'loan_product_id');
    }

    public function repayments(): HasMany
    {
        return $this->hasMany(LoanRepayment::class);
    }

    public function schedules(): HasMany
    {
        return $this->hasMany(LoanSchedule::class)->orderBy('installment_no');
    }

    public function guarantors(): HasMany
    {
        return $this->hasMany(LoanGuarantor::class);
    }

    public function penalties(): HasMany
    {
        return $this->hasMany(Penalty::class);
    }

    /** Outstanding debt = principal + interest + accrued penalties - paid. */
    public function getBalanceAttribute(): int
    {
        return max(0, $this->total_payable + $this->penalty_accrued - $this->amount_repaid);
    }

    /** Amount owed against principal + interest only (penalties separate). */
    public function getOutstandingAttribute(): int
    {
        return max(0, $this->total_payable - $this->amount_repaid);
    }

    public function isOverdue(): bool
    {
        return $this->status === self::STATUS_ACTIVE
            && $this->due_date !== null
            && $this->due_date->isPast()
            && $this->balance > 0;
    }

    public function isFullyRepaid(): bool
    {
        return $this->amount_repaid >= $this->total_payable && $this->penalty_accrued <= 0;
    }
}
