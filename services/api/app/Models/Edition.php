<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

final class Edition extends DomainModel
{
    protected function casts(): array
    {
        return ['is_limited' => 'boolean', 'total' => 'integer'];
    }

    public function artwork(): BelongsTo
    {
        return $this->belongsTo(Artwork::class);
    }

    public function printSizes(): BelongsToMany
    {
        return $this->belongsToMany(PrintSizeOption::class, 'edition_print_size')->withTimestamps();
    }
}
