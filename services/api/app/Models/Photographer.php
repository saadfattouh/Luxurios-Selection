<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Relations\HasMany;

final class Photographer extends DomainModel
{
    protected function casts(): array
    {
        return ['is_featured' => 'boolean'];
    }

    public function artworks(): HasMany
    {
        return $this->hasMany(Artwork::class);
    }
}
