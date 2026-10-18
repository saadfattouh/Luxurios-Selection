<?php

declare(strict_types=1);

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

final class PublicContentCache
{
    public function handle(Request $request, Closure $next)
    {
        $response = $next($request);
        if ($request->isMethod('GET') && $response->getStatusCode() === 200) {
            // Hash the actual serialization: relationship changes invalidate the ETag too.
            $response->setEtag(hash('sha256', $response->getContent()));
            $response->headers->set('Cache-Control', 'public, max-age=0, must-revalidate');
            $response->setVary(['Accept', 'Origin']);
            $response->isNotModified($request);
        }

        return $response;
    }
}
