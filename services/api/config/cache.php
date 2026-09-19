<?php

declare(strict_types=1);

return [
    'default' => env('CACHE_STORE', 'file'), 'stores' => ['array' => ['driver' => 'array'], 'file' => ['driver' => 'file', 'path' => storage_path('framework/cache/data')]], 'prefix' => 'luxurious_cache_',
];
