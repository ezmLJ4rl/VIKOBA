<?php

use App\Http\Controllers\Api\AuditLogController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ContributionController;
use App\Http\Controllers\Api\GroupController;
use App\Http\Controllers\Api\LoanController;
use App\Http\Controllers\Api\LoanProductController;
use App\Http\Controllers\Api\MeetingController;
use App\Http\Controllers\Api\MemberController;
use App\Http\Controllers\Api\ReportController;
use App\Http\Controllers\Api\ShareOutController;
use App\Http\Controllers\Api\SyncController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes (v1)
|--------------------------------------------------------------------------
|
| Token auth via Laravel Sanctum. Write endpoints accept an optional
| `Idempotency-Key` header (or `idempotency_key` field in the JSON body)
| so the mobile offline-sync queue can retry safely.
|
*/

Route::prefix('v1')->group(function () {
    // Public (throttled: 5 attempts / 60 min per IP).
    Route::post('auth/register', [AuthController::class, 'register'])->middleware('throttle:5,1');
    Route::post('auth/login', [AuthController::class, 'login'])->middleware('throttle:5,1');

    Route::middleware('auth:sanctum')->group(function () {
        Route::get('auth/me', [AuthController::class, 'me']);
        Route::post('auth/logout', [AuthController::class, 'logout']);

        Route::get('groups/current', [GroupController::class, 'show']);
        Route::put('groups/current', [GroupController::class, 'update']);
        Route::get('groups/current/summary', [GroupController::class, 'summary']);

        Route::get('members', [MemberController::class, 'index']);
        Route::post('members', [MemberController::class, 'store']);
        Route::post('members/{member}/deactivate', [MemberController::class, 'deactivate']);

        Route::get('contributions', [ContributionController::class, 'index']);
        Route::post('contributions', [ContributionController::class, 'store']);

        Route::get('loans', [LoanController::class, 'index']);
        Route::get('loans/{loan}', [LoanController::class, 'show']);
        Route::post('loans/quote', [LoanController::class, 'quote']);
        Route::post('loans', [LoanController::class, 'store']);
        Route::post('loans/{loan}/approve', [LoanController::class, 'approve']);
        Route::post('loans/{loan}/reject', [LoanController::class, 'reject']);
        Route::post('loans/{loan}/disburse', [LoanController::class, 'disburse']);
        Route::post('loans/{loan}/repayments', [LoanController::class, 'repay']);
        Route::post('loans/{loan}/penalties/accrue', [LoanController::class, 'accruePenalties']);
        Route::get('loans/{loan}/penalties', [LoanController::class, 'penalties']);

        Route::get('loan-products', [LoanProductController::class, 'index']);
        Route::post('loan-products', [LoanProductController::class, 'store']);
        Route::get('loan-products/{loanProduct}', [LoanProductController::class, 'show']);
        Route::put('loan-products/{loanProduct}', [LoanProductController::class, 'update']);
        Route::delete('loan-products/{loanProduct}', [LoanProductController::class, 'destroy']);

        Route::get('meetings', [MeetingController::class, 'index']);
        Route::post('meetings', [MeetingController::class, 'store']);

        Route::get('shareout', [ShareOutController::class, 'calculate']);

        Route::get('reports/member-statement/{member}', [ReportController::class, 'memberStatement']);
        Route::get('reports/group-summary', [ReportController::class, 'groupSummary']);

        Route::get('audit-logs', [AuditLogController::class, 'index']);

        // Offline sync ingest (60 req/min is plenty for batch pushes).
        Route::post('sync', [SyncController::class, 'synchronize'])->middleware('throttle:60,1');
    });
});
