<?php

namespace App\Console\Commands;

use App\Models\Loan;
use App\Services\VikobaService;
use Illuminate\Console\Command;

/**
 * Brings every overdue active loan's late-payment penalties up to date.
 * Schedule this to run daily (e.g. `* * * * * php artisan vikoba:accrue-penalties`).
 */
class AccrueLoanPenalties extends Command
{
    protected $signature = 'vikoba:accrue-penalties';

    protected $description = 'Accrue late-payment penalties for every overdue active loan.';

    public function handle(): int
    {
        $loans = Loan::query()
            ->where('status', Loan::STATUS_ACTIVE)
            ->whereNotNull('due_date')
            ->where('due_date', '<', now()->toDateString())
            ->get();

        $added = 0;
        $affected = 0;
        foreach ($loans as $loan) {
            $delta = VikobaService::syncPenalties($loan);
            if ($delta > 0) {
                $added += $delta;
                $affected++;
            }
        }

        $this->info("Accrued {$added} TZS in penalties across {$affected} loans.");

        return self::SUCCESS;
    }
}
