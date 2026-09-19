<?php

declare(strict_types=1);

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use Symfony\Component\HttpFoundation\Response;

final class RequestContext
{
    public function handle(Request $request, Closure $next): Response
    {
        $id = (string) Str::uuid();
        $request->attributes->set('request_id', $id);
        Log::withContext(['request_id' => $id]);
        $started = microtime(true);
        $response = $next($request);
        $response->headers->set('X-Request-ID', $id);
        Log::info('http.completed', ['method' => $request->method(), 'path' => $request->path(), 'status' => $response->getStatusCode(), 'duration_ms' => round((microtime(true) - $started) * 1000)]);

        return $response;
    }
}
