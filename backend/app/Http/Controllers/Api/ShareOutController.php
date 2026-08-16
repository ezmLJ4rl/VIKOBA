<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\VikobaService;
use Illuminate\Http\JsonResponse;

class ShareOutController extends Controller
{
    /** Cycle-end payout preview (pure calculation — nothing stored). */
    public function calculate(): JsonResponse
    {
        $group = auth()->user()->group;
        $members = $group->members()->where('is_active', true)->get();
        $interest = VikobaService::totalInterestEarned($group->loans()->get());

        return response()->json([
            'group' => $group,
            'total_payable' => VikobaService::totalSavings($members) + $interest,
            'interest_total' => $interest,
            'rows' => VikobaService::shareOut($group, $members, $interest),
        ]);
    }
}
