<?php

declare(strict_types=1);
use App\Http\Controllers\ExhibitionController;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function (): void {
    Route::get('health', fn () => response()->json(['data' => ['status' => 'ok', 'service' => 'luxurious-selection', 'version' => 'v1']]));
    Route::get('ready', function () {
        try {
            DB::select('select 1');
        } catch (Throwable $e) {
            report($e);
            abort(503);
        }

        return response()->json(['data' => ['status' => 'ready']]);
    });
    Route::middleware('throttle:api')->group(function (): void {
        Route::get('exhibitions', [ExhibitionController::class, 'index']);
        Route::get('exhibitions/{slug}', [ExhibitionController::class, 'show'])->where('slug', '[a-z0-9-]+');
        Route::get('collections', [ExhibitionController::class, 'collections']);
        Route::get('home/curation', [ExhibitionController::class, 'curation']);
    });
});

Route::get('/media/{path}', function ($path) {

    if (!Storage::disk('public')->exists($path)) {
        abort(404);
    }

    return response()->file(
        Storage::disk('public')->path($path),
        [
            'Access-Control-Allow-Origin' => 'http://localhost:8080',
            'Cross-Origin-Resource-Policy' => 'cross-origin',
        ]
    );

})->where('path', '.*');
