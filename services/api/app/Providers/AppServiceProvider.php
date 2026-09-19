<?php

declare(strict_types=1);

namespace App\Providers;

use App\Contracts\MediaUrlResolver;
use App\Services\FilesystemMediaUrlResolver;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;

final class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->app->bind(MediaUrlResolver::class, FilesystemMediaUrlResolver::class);
    }

    public function boot(): void
    {
        RateLimiter::for('api', fn (Request $request) => Limit::perMinute(120)->by($request->ip()));
    }
}
