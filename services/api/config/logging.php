<?php

declare(strict_types=1);
use Monolog\Formatter\JsonFormatter;
use Monolog\Handler\StreamHandler;

return [
    'default' => 'stderr', 'channels' => ['stderr' => ['driver' => 'monolog', 'handler' => StreamHandler::class, 'with' => ['stream' => 'php://stderr'], 'formatter' => JsonFormatter::class, 'level' => env('LOG_LEVEL', 'info')]],
];
