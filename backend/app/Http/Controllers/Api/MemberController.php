<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreMemberRequest;
use App\Models\Member;
use App\Services\AuditService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MemberController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = auth()->user()->group
            ->members()
            ->with('user')
            ->when($request->boolean('active_only'), fn ($q) => $q->where('is_active', true))
            ->when($request->filled('search'), fn ($q) => $q
                ->where(fn ($w) => $w
                    ->where('full_name', 'like', '%'.$request->input('search').'%')
                    ->orWhere('phone', 'like', '%'.$request->input('search').'%')));

        return response()->json([
            'members' => $query->orderBy('full_name')->paginate($request->integer('per_page', 25)),
        ]);
    }

    public function store(StoreMemberRequest $request): JsonResponse
    {
        $user = auth()->user();
        $group = $user->group;
        abort_unless($user->can('member.create', [$group]), 403, 'Only committee members may add members.');
        abort_unless($group->members()->where('phone', $request->input('phone'))->exists() === false, 422, 'A member with that phone number already exists.');

        $member = $group->members()->create([
            'full_name' => $request->input('full_name'),
            'phone' => $request->input('phone'),
            'role' => $request->input('role'),
            'joined_date' => $request->input('joined_date') ?? now()->toDateString(),
            'total_shares' => $request->integer('initial_shares', 0),
            'share_value' => $group->share_value,
            'is_active' => true,
        ]);

        AuditService::log('member', $member->id, 'member.create', new: $member->toArray());

        return response()->json(['member' => $member], 201);
    }

    public function deactivate(Member $member): JsonResponse
    {
        abort_unless($member->group_id === auth()->user()->group_id, 403, 'Not your group.');
        abort_unless(auth()->user()->can('member.update', [$member]), 403, 'Only committee members may deactivate members.');

        $member->update(['is_active' => false]);
        AuditService::log('member', $member->id, 'member.deactivate', new: $member->fresh()->toArray());

        return response()->json(['member' => $member->fresh()]);
    }
}
