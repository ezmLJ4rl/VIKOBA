<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Chronological, read-only feed of every financial and administrative change
 * (who changed what, from what to what, when, from which IP). Rows are
 * append-only by design — nothing here updates or deletes.
 */
class AuditLogController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = auth()->user()->group
            ->auditLogs()
            ->with('user:id,id,name,role')
            ->when($request->filled('entity_type'), fn ($q) => $q->where('entity_type', $request->input('entity_type')))
            ->when($request->filled('action'), fn ($q) => $q->where('action', $request->input('action')))
            ->when($request->filled('from'), fn ($q) => $q->where('created_at', '>=', $request->input('from')))
            ->when($request->filled('to'), fn ($q) => $q->where('created_at', '<=', $request->input('to')));

        return response()->json([
            'audit_logs' => $query->orderByDesc('created_at')->paginate($request->integer('per_page', 50)),
        ]);
    }
}
