<?php

declare(strict_types=1);

return [
    'default' => env('FILESYSTEM_DISK', 'public'), 'disks' => ['public' => ['driver' => 'local', 'root' => storage_path('app/public'), 'url' => env('APP_URL', 'http://localhost:8000').'/storage', 'visibility' => 'public', 'throw' => true], 's3' => ['driver' => 's3', 'key' => env('AWS_ACCESS_KEY_ID'), 'secret' => env('AWS_SECRET_ACCESS_KEY'), 'region' => env('AWS_DEFAULT_REGION', 'us-east-1'), 'bucket' => env('AWS_BUCKET'), 'url' => env('AWS_URL'), 'endpoint' => env('AWS_ENDPOINT'), 'use_path_style_endpoint' => (bool) env('AWS_USE_PATH_STYLE_ENDPOINT', false), 'throw' => true]], 'links' => [public_path('storage') => storage_path('app/public')],
];
