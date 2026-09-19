<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Relations\BelongsToMany;

final class Collection extends DomainModel
{
    protected function casts(): array
    {
        return [];
    }

    public function artworks(): BelongsToMany
    {
        return $this->belongsToMany(Artwork::class)->withPivot('position')->orderByPivot('position');
    }
}
