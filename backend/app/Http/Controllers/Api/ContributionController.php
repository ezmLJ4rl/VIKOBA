<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreContributionRequest;
use App\Models\Contribution;
use App\Services\AuditService;
use App\Services\IdempotencyGuard;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ContributionController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = auth()->user()->group
            ->contributions()
            ->with('member:id,id,full_name')
            ->when($request->filled('member_id'), fn ($q) => $q->where('member_id', $request->integer('member_id')));

        return response()->json([
            'contributions' => $query->orderByDesc('recorded_at')->paginate($request->integer('per_page', 25)),
        ]);
    }

    /**
     * Records shares bought. Shares are booked and the member's running total
     * is bumped in the SAME transaction; the client's key makes retries safe.
     */
    public function store(StoreContributionRequest $request): JsonResponse
    {
        $user = auth()->user();
        $group = $user->group;
        $member = $group->members()->findOrFail($request->integer('member_id'));

        $idempotencyKey = $request->input('idempotency_key');
        if ($idempotencyKey) {
            $claim = IdempotencyGuard::claim($idempotencyKey, $group->id, $user->id);
            if ($claim['duplicate']) {
                $existing = Contribution::find($claim['entity_id']);

                return response()->json([
                    'duplicated' => true,
                    'contribution' => $existing,
                ], 200);
            }
        }

        $contribution = DB::transaction(function () use ($group, $member, $request, $user, $idempotencyKey) {
            $shares = $request->integer('shares');
            $amount = $shares * $group->share_value;

            $contribution = $group->contributions()->create([
                'member_id' => $member->id,
                'recorded_by' => $user->id,
                'shares' => $shares,
                'share_value' => $group->share_value,
                'amount_total' => $amount,
                'note' => $request->input('note'),
                'recorded_at' => $request->input('recorded_at') ?? now(),
                'idempotency_key' => $idempotencyKey,
            ]);

            $member->increment('total_shares', $shares);

            return $contribution;
        });

        if ($idempotencyKey) {
            IdempotencyGuard::mark($idempotencyKey, $group->id, 'contribution', $contribution->id);
        }

        AuditService::log('contribution', $contribution->id, 'contribution.create', new: $contribution->toArray());

        return response()->json(['contribution' => $contribution], 201);
    }
}
