<?php

declare(strict_types=1);
use App\Http\Controllers\DiscoveryController;
use App\Http\Controllers\ExhibitionController;
use App\Http\Middleware\PublicContentCache;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Storage;

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
    Route::middleware(['throttle:api', PublicContentCache::class])->group(function (): void {
        Route::get('exhibitions', [ExhibitionController::class, 'index']);
        Route::get('exhibitions/{slug}', [ExhibitionController::class, 'show'])->where('slug', '[a-z0-9-]+');
        Route::get('collections', [ExhibitionController::class, 'collections']);
        Route::get('collections/{slug}', [DiscoveryController::class, 'collection']);
        Route::get('collections/{slug}/artworks', [DiscoveryController::class, 'collectionArtworks']);
        Route::get('exhibitions/{slug}/artworks', [DiscoveryController::class, 'exhibitionArtworks']);
        Route::get('artworks/{key}', [DiscoveryController::class, 'artwork']);
        Route::get('photographers/{key}', [DiscoveryController::class, 'photographer']);
        Route::get('home/curation', [ExhibitionController::class, 'curation']);
    });
});

// Only public disk media; never accept a client-supplied disk or remote URL.
Route::get('/media/{path}', function (string $path) {
    abort_if(str_contains($path, '..') || str_contains($path, '\\') || str_starts_with($path, '/'), 404);
    $disk = Storage::disk('public');
    abort_unless($disk->exists($path) && in_array(strtolower(pathinfo($path, PATHINFO_EXTENSION)), ['jpg', 'jpeg', 'png', 'webp'], true), 404);

    return response()->file($disk->path($path), ['Cache-Control' => 'public, max-age=3600', 'Cross-Origin-Resource-Policy' => 'cross-origin']);
})->where('path', '.*');
