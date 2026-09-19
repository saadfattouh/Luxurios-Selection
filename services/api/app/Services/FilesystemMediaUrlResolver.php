<?php

declare(strict_types=1);

namespace App\Services;

use App\Contracts\MediaUrlResolver;
use Illuminate\Support\Facades\Storage;

final class FilesystemMediaUrlResolver implements MediaUrlResolver
{
    public function url(string $disk, string $path): string
    {
        return Storage::disk($disk)->url($path);
    }
}
