<?php

declare(strict_types=1);

namespace Tests\Unit;

use App\Services\FilesystemMediaUrlResolver;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

final class FilesystemMediaUrlResolverTest extends TestCase
{
    public function test_uses_configured_disk_without_rewriting_path(): void
    {
        Storage::shouldReceive('disk')->once()->with('s3')->andReturnSelf();
        Storage::shouldReceive('url')->once()->with('demo/a.jpg')->andReturn('https://cdn.example/demo/a.jpg');
        $this->assertSame('https://cdn.example/demo/a.jpg', (new FilesystemMediaUrlResolver)->url('s3', 'demo/a.jpg'));
    }
}
