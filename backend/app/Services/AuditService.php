<?php

namespace App\Services;

use App\Models\AuditLog;
use Illuminate\Support\Facades\Log;
use Throwable;

/**
 * Append-only audit writing. Every financial mutation calls `AuditService::log`
 * so transactions can be reconstructed later (who changed what, from what to
 * what, timestamp, IP). Rows in `audit_logs` are never updated or deleted.
 */
final class AuditService
{
    public static function log(
        string $entityType,
        int $entityId,
        string $action,
        array|object|null $old = null,
        array|object|null $new = null,
    ): void {
        $user = auth()->user();

        try {
            AuditLog::create([
                'group_id' => $user?->group_id,
                'user_id' => $user?->id,
                'entity_type' => $entityType,
                'entity_id' => $entityId,
                'action' => $action,
                'old' => $old ? json_decode(json_encode($old), true) : null,
                'new' => $new ? json_decode(json_encode($new), true) : null,
                'ip' => request()->ip(),
            ]);
        } catch (Throwable $e) {
            // Audit failures must never break the financial write itself.
            Log::error('AuditService failed', ['error' => $e->getMessage()]);
        }
    }
}
