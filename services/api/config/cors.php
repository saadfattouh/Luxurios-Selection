<?php

return ['paths' => ['api/*'], 'allowed_methods' => ['GET', 'HEAD', 'OPTIONS'], 'allowed_origins' => explode(',', env('CORS_ALLOWED_ORIGINS', 'http://localhost:8080,http://127.0.0.1:8080')), 'allowed_origins_patterns' => [], 'allowed_headers' => ['*'], 'exposed_headers' => ['ETag', 'X-Request-ID'], 'max_age' => 600, 'supports_credentials' => false];
