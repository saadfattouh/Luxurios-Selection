<?php

declare(strict_types=1);

namespace App\Contracts;

interface MediaUrlResolver
{
    public function url(string $disk, string $path): string;
}
