<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Relations\BelongsToMany;

final class PrintSizeOption extends DomainModel
{
    protected function casts(): array
    {
        return ['width_mm' => 'integer', 'height_mm' => 'integer'];
    }

    public function editions(): BelongsToMany
    {
        return $this->belongsToMany(Edition::class, 'edition_print_size')->withTimestamps();
    }
}
