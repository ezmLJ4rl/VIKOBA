<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreLoanProductRequest;
use App\Models\LoanProduct;
use App\Services\AuditService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class LoanProductController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = auth()->user()->group
            ->loanProducts()
            ->when($request->boolean('active_only'), fn ($q) => $q->where('is_active', true))
            ->orderBy('name');

        return response()->json(['loan_products' => $query->paginate($request->integer('per_page', 50))]);
    }

    public function store(StoreLoanProductRequest $request): JsonResponse
    {
        $group = auth()->user()->group;
        $product = $group->loanProducts()->create([
            'name' => $request->input('name'),
            'description' => $request->input('description'),
            'interest_rate' => $request->input('interest_rate'),
            'interest_method' => $request->input('interest_method'),
            'max_term_months' => $request->input('max_term_months'),
            'max_multiplier' => $request->input('max_multiplier'),
            'min_amount' => $request->input('min_amount') ?? 0,
            'penalty_type' => $request->input('penalty_type'),
            'penalty_value' => $request->input('penalty_value') ?? 0,
            'penalty_grace_days' => $request->input('penalty_grace_days') ?? 0,
            'penalty_period_days' => $request->input('penalty_period_days') ?? 7,
            'installment_interval_days' => $request->input('installment_interval_days') ?? 30,
            'is_active' => $request->boolean('is_active', true),
        ]);

        AuditService::log('loan_product', $product->id, 'loan_product.create', new: $product->toArray());

        return response()->json(['loan_product' => $product], 201);
    }

    public function show(LoanProduct $loanProduct): JsonResponse
    {
        abort_unless($loanProduct->group_id === auth()->user()->group_id, 403, 'Not your group.');

        return response()->json(['loan_product' => $loanProduct]);
    }

    public function update(LoanProduct $loanProduct, StoreLoanProductRequest $request): JsonResponse
    {
        abort_unless($loanProduct->group_id === auth()->user()->group_id, 403, 'Not your group.');

        $loanProduct->fill($request->validated())->save();
        AuditService::log('loan_product', $loanProduct->id, 'loan_product.update', new: $loanProduct->fresh()->toArray());

        return response()->json(['loan_product' => $loanProduct->fresh()]);
    }

    public function destroy(LoanProduct $loanProduct): JsonResponse
    {
        abort_unless($loanProduct->group_id === auth()->user()->group_id, 403, 'Not your group.');

        $loanProduct->update(['is_active' => false]);
        AuditService::log('loan_product', $loanProduct->id, 'loan_product.deactivate', new: $loanProduct->fresh()->toArray());

        return response()->json(['ok' => true]);
    }
}
