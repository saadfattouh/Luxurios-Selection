<?php

declare(strict_types=1);

namespace App\Support;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpKernel\Exception\HttpExceptionInterface;
use Throwable;

final class Problem
{
    public static function fromException(Throwable $e, Request $request): JsonResponse
    {
        $status = $e instanceof ValidationException ? 422 : ($e instanceof HttpExceptionInterface ? $e->getStatusCode() : 500);

        return response()->json([
            'type' => 'about:blank', 'title' => Response::$statusTexts[$status] ?? 'Error', 'status' => $status,
            'detail' => $status === 422 ? 'One or more query parameters are invalid.' : ($status >= 500 ? 'The exhibition service is temporarily unavailable.' : (Response::$statusTexts[$status] ?? 'Request failed')),
            'instance' => $request->getPathInfo(), 'request_id' => $request->attributes->get('request_id'),
            ...($e instanceof ValidationException ? ['errors' => $e->errors()] : []),
        ], $status, array_merge($e instanceof HttpExceptionInterface ? $e->getHeaders() : [], ['Content-Type' => 'application/problem+json']));
    }
}
