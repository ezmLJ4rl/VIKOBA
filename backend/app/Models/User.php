<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasApiTokens, HasFactory, Notifiable;

    public const ROLE_ADMIN = 'admin';

    public const ROLE_CHAIRPERSON = 'chairperson';

    public const ROLE_TREASURER = 'treasurer';

    public const ROLE_SECRETARY = 'secretary';

    public const ROLE_MEMBER = 'member';

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'phone',
        'role',
        'group_id',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    public function group(): BelongsTo
    {
        return $this->belongsTo(Group::class);
    }

    public function member(): HasOne
    {
        return $this->hasOne(Member::class);
    }

    /** Roles that may approve/disburse loans (financial authority). */
    public function canAuthorizeFinance(): bool
    {
        return in_array($this->role, [
            self::ROLE_ADMIN,
            self::ROLE_CHAIRPERSON,
            self::ROLE_TREASURER,
        ], true);
    }

    /** Roles that may change group settings. */
    public function canConfigureGroup(): bool
    {
        return in_array($this->role, [
            self::ROLE_ADMIN,
            self::ROLE_TREASURER,
        ], true);
    }
}
