<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

final class Artwork extends DomainModel
{
    protected function casts(): array
    {
        return ['published_at' => 'immutable_datetime', 'is_curator_pick' => 'boolean'];
    }

    public function photographer(): BelongsTo
    {
        return $this->belongsTo(Photographer::class);
    }

    public function media(): HasMany
    {
        return $this->hasMany(ArtworkMedia::class)->orderBy('position');
    }

    public function editions(): HasMany
    {
        return $this->hasMany(Edition::class);
    }

    public function collections(): BelongsToMany
    {
        return $this->belongsToMany(Collection::class)->withPivot('position');
    }

    public function exhibitions(): BelongsToMany
    {
        return $this->belongsToMany(Exhibition::class)->withPivot('position');
    }
}
