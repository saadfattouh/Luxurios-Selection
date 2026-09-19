<?php

declare(strict_types=1);

namespace Tests;

abstract class TestCase extends \Illuminate\Foundation\Testing\TestCase
{
    public function createApplication()
    {
        $app = parent::createApplication();
        // Guard before RefreshDatabase can run migrations, including DB_URL overrides.
        $connection = $app['db']->connection();
        if ($connection->getDriverName() !== 'pgsql' || ! str_ends_with($connection->getDatabaseName(), '_test')) {
            throw new \RuntimeException('Tests require a dedicated PostgreSQL database ending in _test.');
        }

        return $app;
    }
}
