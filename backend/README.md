# Vikoba Backend

Laravel 12 API (SQLite) for the Vikoba group-savings app. Companion to the Flutter
client in `../vikoba_app`. Single-group MVP: one group per backend install.

## Setup

```bash
composer install
copy .env.example .env      # Windows; or `cp .env.example .env`
# ensure DB_CONNECTION=sqlite and database/database.sqlite exists
php artisan key:generate
php artisan migrate --force
php artisan db:seed --force
php artisan serve --port=8123
```

Demo login: `treasurer@vikoba.test` / `password` (seeded group with 4 members,
3 loans, 1 meeting — numbers mirror the Flutter seed data).

## Tests

```bash
php artisan test            # feature tests cover auth, roles, loan lifecycle
php artisan route:list --path=api
```

## Roles & rules (mirrors the Flutter app)

| Role        | Add members | Record contributions | Decide loans | Repay loans | Group settings |
|-------------|:-----------:|:--------------------:|:------------:|:-----------:|:--------------:|
| admin       | ✓           | ✓                    | ✓            | ✓           | ✓              |
| chairperson | ✓           | ✓                    | ✓            | ✓           | ✗              |
| treasurer   | ✓           | ✓                    | ✓            | ✓           | ✓              |
| secretary   | ✓           | ✓                    | ✗            | ✓           | ✗              |
| member      | ✗           | ✗                    | ✗            | ✗           | ✗              |

- Members may **request** loans (pinned to their own account; enforced server-side).
- Loan eligibility + interest are computed **server-side**; client previews are ignored.
- Leaving members are **archived** (`is_active=false`), never deleted.
- Money is whole TZS.

Policies: `app/Policies/*`, registered as gates in `app/Providers/AppServiceProvider.php`.
The API contract lives in `docs/openapi.yaml`.

## Endpoints

`POST /api/v1/auth/login` → Bearer token (Sanctum). See `docs/openapi.yaml` for the
full contract. Idempotency keys (`idempotency_key`) are honoured for loans,
contributions and repayments so the offline client can retry safely.

## Stack notes

- `app/Services/VikobaService.php` — the money rules (eligibility, interest, repayment clamp).
- `app/Services/IdempotencyGuard.php` — dedupe table for offline sync retries.
- `app/Services/AuditService.php` — audit log rows for every mutation.
- `app/Http/Controllers/Api/SyncController.php` — bulk push of offline operations.
