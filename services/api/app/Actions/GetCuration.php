<?php

declare(strict_types=1);

namespace App\Actions;

use App\Models\Artwork;
use App\Models\Collection;
use App\Models\Exhibition;
use App\Models\Photographer;

final class GetCuration
{
    public const ARTWORK_RELATIONS = ['media', 'photographer', 'editions'];

    public function execute(): array
    {
        $artworks = Artwork::query()->whereNotNull('published_at')->where('published_at', '<=', now())->with(self::ARTWORK_RELATIONS);

        return [
            'current_exhibitions' => Exhibition::query()->whereNotNull('published_at')->where('published_at', '<=', now())->with(['heroArtwork' => fn ($q) => $q->where('published_at', '<=', now())->with(self::ARTWORK_RELATIONS)])->orderBy('position')->orderBy('id')->limit(6)->get(),
            'curators_selection' => (clone $artworks)->where('is_curator_pick', true)->orderBy('id')->limit(6)->get(),
            'new_works' => (clone $artworks)->orderByDesc('published_at')->orderBy('id')->limit(6)->get(),
            'featured_photographer' => Photographer::query()->where('is_featured', true)->whereHas('artworks', fn ($q) => $q->where('published_at', '<=', now()))->orderBy('id')->first(),
            'limited_editions' => (clone $artworks)->whereHas('editions', fn ($q) => $q->where('is_limited', true))->orderBy('id')->limit(6)->get(),
            'collections' => Collection::query()->orderBy('position')->orderBy('id')->limit(6)->get(),
        ];
    }
}
