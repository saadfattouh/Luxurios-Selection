<?php

declare(strict_types=1);

return [
    'paths' => ['api/*', 'storage/*'],
     'allowed_methods' => ['GET', 'HEAD', 'OPTIONS'], 
     'allowed_origins' => explode(',', env('CORS_ALLOWED_ORIGINS', 'http://localhost:8080,http://127.0.0.1:8080')), 
     'allowed_origins_patterns' => [], 
     'allowed_origins_patterns' => [],

    'allowed_headers' => ['*'],

    'exposed_headers' => [],

    'max_age' => 0,

    'supports_credentials' => false,

];
