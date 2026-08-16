<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Meeting extends Model
{
    use HasFactory;

    protected $fillable = [
        'group_id',
        'created_by',
        'held_at',
        'agenda',
        'minutes',
    ];

    protected function casts(): array
    {
        return ['held_at' => 'datetime'];
    }

    public function group(): BelongsTo
    {
        return $this->belongsTo(Group::class);
    }

    public function attendance(): HasMany
    {
        return $this->hasMany(MeetingAttendance::class);
    }

    /** Counts present members via the pivot. */
    public function presentCount(): int
    {
        return $this->attendance()->where('present', true)->count();
    }
}
