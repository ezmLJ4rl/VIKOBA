<?php

namespace App\Services;

use App\Models\IdempotencyKey;
use Illuminate\Database\UniqueConstraintViolationException;

/**
 * Idempotency support for write endpoints.
 *
 * The offline-first Flutter app attaches a stable `idempotency_key` to each
 * queued action and retries until acknowledged. If a retry arrives after the
 * original was already recorded, this guard recognizes the key and the
 * endpoint returns the ORIGINAL result instead of double-recording (e.g. a
 * repayment applied twice would corrupt balances).
 *
 * Race-safety comes from the DB unique index on (key, group_id): two
 * concurrent attempts both insert, exactly one wins, the loser detects the
 * constraint violation and treats itself as the duplicate.
 */
final class IdempotencyGuard
{
    /**
     * Tries to claim [key] for the current request.
     *
     * @return array{duplicate: bool, entity_type: ?string, entity_id: ?int}
     */
    public static function claim(string $key, ?int $groupId, ?int $userId): array
    {
        $existing = IdempotencyKey::where('key', $key)
            ->where('group_id', $groupId)
            ->first();

        if ($existing) {
            return [
                'duplicate' => true,
                'entity_type' => $existing->entity_type,
                'entity_id' => $existing->entity_id,
            ];
        }

        try {
            IdempotencyKey::create([
                'key' => $key,
                'method' => request()->method(),
                'path' => request()->path(),
                'group_id' => $groupId,
                'user_id' => $userId,
                'expires_at' => now()->addDays(7),
            ]);

            return ['duplicate' => false, 'entity_type' => null, 'entity_id' => null];
        } catch (UniqueConstraintViolationException) {
            // Concurrent request won the race — treat as duplicate.
            $existing = IdempotencyKey::where('key', $key)
                ->where('group_id', $groupId)
                ->first();

            return [
                'duplicate' => true,
                'entity_type' => $existing?->entity_type,
                'entity_id' => $existing?->entity_id,
            ];
        }
    }

    /**
     * Binds the created entity to the claimed key so duplicate retries can
     * return the original resource.
     */
    public static function mark(string $key, ?int $groupId, string $entityType, int $entityId): void
    {
        IdempotencyKey::where('key', $key)
            ->where('group_id', $groupId)
            ->update([
                'entity_type' => $entityType,
                'entity_id' => $entityId,
            ]);
    }
}
