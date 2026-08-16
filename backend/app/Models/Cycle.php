<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Cycle extends Model
{
    use HasFactory;

    public const STATUS_ACTIVE = 'active';

    public const STATUS_CLOSED = 'closed';

    protected $fillable = [
        'group_id',
        'name',
        'starts_on',
        'ends_on',
        'status',
        'interest_earned',
        'total_share_out',
        'closed_by',
        'closed_at',
    ];

    protected function casts(): array
    {
        return [
            'starts_on' => 'date',
            'ends_on' => 'date',
            'interest_earned' => 'integer',
            'total_share_out' => 'integer',
            'closed_at' => 'datetime',
        ];
    }

    public function group(): BelongsTo
    {
        return $this->belongsTo(Group::class);
    }

    public function shareOuts(): HasMany
    {
        return $this->hasMany(ShareOut::class);
    }

    public function getIsOpenAttribute(): bool
    {
        return $this->status === self::STATUS_ACTIVE;
    }
}
