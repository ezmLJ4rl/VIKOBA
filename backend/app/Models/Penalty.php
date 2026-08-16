<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Penalty extends Model
{
    use HasFactory;

    public const TYPE_FLAT = 'flat';

    public const TYPE_PERCENT = 'percent';

    public const STATUS_PENDING = 'pending';

    public const STATUS_PAID = 'paid';

    public const STATUS_WAIVED = 'waived';

    protected $fillable = [
        'group_id',
        'loan_id',
        'member_id',
        'type',
        'amount',
        'applied_for_date',
        'reason',
        'status',
        'waived_by',
        'waived_at',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'integer',
            'applied_for_date' => 'date',
            'waived_at' => 'datetime',
        ];
    }

    public function group(): BelongsTo
    {
        return $this->belongsTo(Group::class);
    }

    public function loan(): BelongsTo
    {
        return $this->belongsTo(Loan::class);
    }

    public function member(): BelongsTo
    {
        return $this->belongsTo(Member::class);
    }
}
