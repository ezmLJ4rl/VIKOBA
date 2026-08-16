<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Loan;
use App\Models\Member;
use App\Services\VikobaService;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * PDF statements. Rendering is CPU-cheap for small groups, but for larger
 * ones the generation should be pushed to a queued job
 * (`App\Jobs\GenerateStatement`) with the file streamed from storage.
 */
class ReportController extends Controller
{
    public function memberStatement(Member $member, Request $request): mixed
    {
        abort_unless($member->group_id === auth()->user()->group_id, 403, 'Not your group.');

        $contributions = $member->contributions()->orderBy('recorded_at')->get();
        $loans = $member->loans()->get();

        $data = [
            'member' => $member,
            'group' => $member->group,
            'contributions' => $contributions,
            'loans' => $loans,
            'generated_at' => now(),
            'total_contributed' => $member->total_shares * $member->share_value,
        ];

        if ($request->boolean('pdf')) {
            $pdf = Pdf::loadView('reports.member-statement', $data);

            return $pdf->download('statement-'.$member->id.'.pdf');
        }

        return response()->json($data);
    }

    public function groupSummary(): JsonResponse
    {
        $group = auth()->user()->group;
        $members = $group->members()->get();
        $loans = $group->loans()->get();

        return response()->json([
            'group' => $group,
            'summary' => [
                'total_savings' => VikobaService::totalSavings($members),
                'interest_earned' => VikobaService::totalInterestEarned($loans),
                'member_count' => $members->count(),
                'open_loans' => $loans->where('status', Loan::STATUS_ACTIVE)->count(),
            ],
        ]);
    }
}
