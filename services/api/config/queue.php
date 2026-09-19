<?php

declare(strict_types=1);

return [
    'default' => env('QUEUE_CONNECTION', 'database'), 'connections' => ['database' => ['driver' => 'database', 'connection' => 'pgsql', 'table' => 'jobs', 'queue' => 'default', 'retry_after' => 120, 'after_commit' => true], 'sync' => ['driver' => 'sync']], 'failed' => ['driver' => 'database-uuids', 'database' => 'pgsql', 'table' => 'failed_jobs'],
];
