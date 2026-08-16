<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Member Statement — {{ $group->name }}</title>
    <style>
        body { font-family: DejaVu Sans, sans-serif; font-size: 12px; color: #1a1d1a; }
        h1 { font-size: 18px; margin: 0 0 2px; }
        h2 { font-size: 14px; margin: 18px 0 8px; }
        .muted { color: #6b7570; }
        table { width: 100%; border-collapse: collapse; margin-top: 6px; }
        th, td { border: 1px solid #dde3de; padding: 6px 8px; text-align: left; }
        th { background: #f0f5f1; }
        .right { text-align: right; }
        .total-row td { font-weight: bold; background: #f0f5f1; }
    </style>
</head>
<body>
    <h1>{{ $group->name }}</h1>
    <div class="muted">Member statement · generated {{ $generated_at->format('d M Y H:i') }}</div>

    <h2>{{ $member->full_name }} <span class="muted">({{ $member->phone }})</span></h2>
    <div class="muted">Shares held: {{ $member->total_shares }} · Total contributed: {{ number_format($total_contributed) }} TZS</div>

    <h2>Contributions</h2>
    @if ($contributions->isEmpty())
        <p class="muted">No contributions recorded.</p>
    @else
        <table>
            <thead>
                <tr><th>Date</th><th>Shares</th><th class="right">Amount (TZS)</th><th>Note</th></tr>
            </thead>
            <tbody>
                @foreach ($contributions as $c)
                    <tr>
                        <td>{{ \Carbon\Carbon::parse($c->recorded_at)->format('d M Y') }}</td>
                        <td>{{ $c->shares }}</td>
                        <td class="right">{{ number_format($c->amount_total) }}</td>
                        <td>{{ $c->note }}</td>
                    </tr>
                @endforeach
                <tr class="total-row">
                    <td colspan="3" class="right">Total</td>
                    <td>{{ number_format($contributions->sum('amount_total')) }}</td>
                </tr>
            </tbody>
        </table>
    @endif

    <h2>Loans</h2>
    @if ($loans->isEmpty())
        <p class="muted">No loans taken.</p>
    @else
        <table>
            <thead>
                <tr><th>Issued</th><th>Principal</th><th class="right">Payable (TZS)</th><th class="right">Repaid (TZS)</th><th>Status</th></tr>
            </thead>
            <tbody>
                @foreach ($loans as $loan)
                    <tr>
                        <td>{{ $loan->issued_at?->format('d M Y') ?: '—' }}</td>
                        <td>{{ number_format($loan->principal) }}</td>
                        <td class="right">{{ number_format($loan->total_payable) }}</td>
                        <td class="right">{{ number_format($loan->amount_repaid) }}</td>
                        <td>{{ ucfirst($loan->status) }}</td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    @endif

    <p class="muted" style="margin-top:24px">This statement is generated automatically by the Vikoba system.</p>
</body>
</html>
