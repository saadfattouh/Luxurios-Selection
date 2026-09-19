<?php

declare(strict_types=1);

namespace App\Models;

final class FrameOption extends DomainModel
{
    protected function casts(): array
    {
        return ['border_mm' => 'integer'];
    }
}
