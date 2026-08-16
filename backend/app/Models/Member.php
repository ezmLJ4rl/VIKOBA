<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Member extends Model
{
    use HasFactory;

    protected $fillable = [
        'group_id',
        'user_id',
        'full_name',
        'phone',
        'nida_number',
        'photo_path',
        'role',
        'joined_date',
        'total_shares',
        'share_value',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'joined_date' => 'date',
            'total_shares' => 'integer',
            'share_value' => 'integer',
            'is_active' => 'boolean',
        ];
    }

    public function group(): BelongsTo
    {
        return $this->belongsTo(Group::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function contributions(): HasMany
    {
        return $this->hasMany(Contribution::class);
    }

    public function loans(): HasMany
    {
        return $this->hasMany(Loan::class);
    }

    public function fines(): HasMany
    {
        return $this->hasMany(Fine::class);
    }

    public function penalties(): HasMany
    {
        return $this->hasMany(Penalty::class);
    }

    public function guarantorRecords(): HasMany
    {
        return $this->hasMany(LoanGuarantor::class);
    }

    /** Loans this member is backing as a guarantor. */
    public function guaranteedLoans(): BelongsToMany
    {
        return $this->belongsToMany(Loan::class, 'loan_guarantors');
    }

    /** Current saved capital in whole shillings. */
    public function getSavingsAttribute(): int
    {
        return $this->total_shares * $this->share_value;
    }

    /** Total outstanding balance this member is guaranteeing (their exposure). */
    public function getGuarantorExposureAttribute(): int
    {
        $total = 0;
        foreach ($this->guarantorRecords as $record) {
            $loan = $record->loan;
            if ($loan !== null && in_array($loan->status, [Loan::STATUS_APPROVED, Loan::STATUS_ACTIVE], true)) {
                $total += $loan->balance;
            }
        }

        return $total;
    }
}
