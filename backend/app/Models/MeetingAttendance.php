<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MeetingAttendance extends Model
{
    public $incrementing = false;

    public $timestamps = false;

    protected $fillable = ['meeting_id', 'member_id', 'present'];

    protected function casts(): array
    {
        return ['present' => 'boolean'];
    }
}
