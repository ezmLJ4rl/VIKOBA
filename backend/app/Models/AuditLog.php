<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AuditLog extends Model
{
    protected $fillable = [
        'group_id',
        'user_id',
        'entity_type',
        'entity_id',
        'action',
        'old',
        'new',
        'ip',
    ];

    protected function casts(): array
    {
        return ['old' => 'array', 'new' => 'array'];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function group(): BelongsTo
    {
        return $this->belongsTo(Group::class);
    }
}
