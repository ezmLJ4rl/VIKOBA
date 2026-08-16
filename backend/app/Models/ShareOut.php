<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ShareOut extends Model
{
    use HasFactory;

    public const STATUS_PENDING = 'pending';

    public const STATUS_PAID = 'paid';

    protected $fillable = [
        'group_id',
        'cycle_id',
        'member_id',
        'savings_paid',
        'interest_share',
        'total_paid',
        'paid_at',
        'status',
    ];

    protected function casts(): array
    {
        return [
            'savings_paid' => 'integer',
            'interest_share' => 'integer',
            'total_paid' => 'integer',
            'paid_at' => 'datetime',
        ];
    }

    public function group(): BelongsTo
    {
        return $this->belongsTo(Group::class);
    }

    public function cycle(): BelongsTo
    {
        return $this->belongsTo(Cycle::class);
    }

    public function member(): BelongsTo
    {
        return $this->belongsTo(Member::class);
    }
}
