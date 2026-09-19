<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Relations\BelongsTo;

final class ArtworkMedia extends DomainModel
{
    protected function casts(): array
    {
        return [];
    }

    protected $table = 'artwork_media';

    public function artwork(): BelongsTo
    {
        return $this->belongsTo(Artwork::class);
    }
}
