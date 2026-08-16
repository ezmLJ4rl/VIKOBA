<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Contribution extends Model
{
    use HasFactory;

    protected $fillable = [
        'group_id',
        'member_id',
        'recorded_by',
        'shares',
        'share_value',
        'amount_total',
        'note',
        'recorded_at',
        'idempotency_key',
    ];

    protected function casts(): array
    {
        return [
            'shares' => 'integer',
            'share_value' => 'integer',
            'amount_total' => 'integer',
            'recorded_at' => 'datetime',
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

    public function recorder(): BelongsTo
    {
        return $this->belongsTo(User::class, 'recorded_by');
    }
}
