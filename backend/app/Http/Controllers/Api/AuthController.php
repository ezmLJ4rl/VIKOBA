<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\LoginRequest;
use App\Http\Requests\RegisterRequest;
use App\Models\Group;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    /**
     * Register a new treasurer + a brand-new group (single-group MVP). The
     * registering user becomes the group's treasurer/admin so they can approve
     * loans and configure settings.
     */
    public function register(RegisterRequest $request): JsonResponse
    {
        $group = Group::create([
            'name' => $request->input('group_name'),
            'created_by' => null, // set after user is created below
        ]);

        $user = User::create([
            'name' => $request->input('name'),
            'email' => $request->input('email'),
            'phone' => $request->input('phone'),
            'password' => Hash::make($request->input('password')),
            'role' => User::ROLE_TREASURER,
            'group_id' => $group->id,
        ]);

        $group->update(['created_by' => $user->id]);

        return $this->tokenResponse($user, 'Registered successfully.');
    }

    public function login(LoginRequest $request): JsonResponse
    {
        $user = User::where('email', $request->input('email'))->first();

        if (! $user || ! Hash::check($request->input('password'), $user->password)) {
            return response()->json([
                'message' => 'Invalid credentials.',
            ], 422);
        }

        return $this->tokenResponse($user, 'Logged in successfully.');
    }

    public function me(): JsonResponse
    {
        $user = auth()->user();
        $user->load(['group', 'member']);

        return response()->json(['user' => $user]);
    }

    public function logout(): JsonResponse
    {
        auth()->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Logged out.']);
    }

    private function tokenResponse(User $user, string $message): JsonResponse
    {
        $token = $user->createToken('vikoba-mobile')->plainTextToken;

        return response()->json([
            'message' => $message,
            'token' => $token,
            'user' => $user->load('group'),
        ], 201);
    }
}
