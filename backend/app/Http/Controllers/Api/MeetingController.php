<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreMeetingRequest;
use App\Services\AuditService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MeetingController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $meetings = auth()->user()->group
            ->meetings()
            ->withCount('attendance')
            ->orderByDesc('held_at')
            ->paginate($request->integer('per_page', 25));

        return response()->json(['meetings' => $meetings]);
    }

    public function store(StoreMeetingRequest $request): JsonResponse
    {
        $group = auth()->user()->group;
        $meeting = $group->meetings()->create([
            'created_by' => auth()->id(),
            'held_at' => $request->input('held_at'),
            'agenda' => $request->input('agenda'),
            'minutes' => $request->input('minutes'),
        ]);

        foreach ($request->input('member_ids', []) as $memberId) {
            $meeting->attendance()->create(['member_id' => $memberId, 'present' => true]);
        }

        AuditService::log('meeting', $meeting->id, 'meeting.create', new: $meeting->toArray());

        return response()->json(['meeting' => $meeting->load('attendance')], 201);
    }
}
