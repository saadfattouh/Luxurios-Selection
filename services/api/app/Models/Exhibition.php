<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

final class Exhibition extends DomainModel
{
    protected function casts(): array
    {
        return ['published_at' => 'immutable_datetime'];
    }

    public function artworks(): BelongsToMany
    {
        return $this->belongsToMany(Artwork::class)->withPivot('position')->orderByPivot('position');
    }

    public function heroArtwork(): BelongsTo
    {
        return $this->belongsTo(Artwork::class, 'hero_artwork_id');
    }
}
