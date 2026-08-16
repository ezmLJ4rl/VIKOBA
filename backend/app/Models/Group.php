<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Str;

class Group extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'name',
        'share_value',
        'default_interest_rate',
        'interest_method',
        'max_loan_multiple',
        'contribution_cycle',
        'min_membership_days',
        'invite_code',
        'created_by',
    ];

    protected function casts(): array
    {
        return [
            'share_value' => 'integer',
            'default_interest_rate' => 'decimal:2',
            'interest_method' => 'string',
            'max_loan_multiple' => 'integer',
            'contribution_cycle' => 'string',
            'min_membership_days' => 'integer',
        ];
    }

    protected static function booted(): void
    {
        static::creating(function (Group $group) {
            $group->slug = $group->slug ?: Str::slug($group->name).'-'.Str::lower(Str::random(5));
            $group->invite_code = $group->invite_code ?: strtoupper(Str::random(8));
        });
    }

    public function members(): HasMany
    {
        return $this->hasMany(Member::class);
    }

    public function loans(): HasMany
    {
        return $this->hasMany(Loan::class);
    }

    public function contributions(): HasMany
    {
        return $this->hasMany(Contribution::class);
    }

    public function meetings(): HasMany
    {
        return $this->hasMany(Meeting::class);
    }

    public function loanProducts(): HasMany
    {
        return $this->hasMany(LoanProduct::class);
    }

    public function cycles(): HasMany
    {
        return $this->hasMany(Cycle::class);
    }

    public function shareOuts(): HasMany
    {
        return $this->hasMany(ShareOut::class);
    }

    public function fines(): HasMany
    {
        return $this->hasMany(Fine::class);
    }

    public function penalties(): HasMany
    {
        return $this->hasMany(Penalty::class);
    }

    public function auditLogs(): HasMany
    {
        return $this->hasMany(AuditLog::class);
    }

    /** The single open cycle for this group, or null when none exists yet. */
    public function openCycle(): ?Cycle
    {
        return $this->cycles()->where('status', Cycle::STATUS_ACTIVE)->latest('id')->first();
    }
}
