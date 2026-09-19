<?php

declare(strict_types=1);

namespace App\Models;

final class RoomScene extends DomainModel
{
    protected function casts(): array
    {
        return ['wall_bounds' => 'array'];
    }
}
