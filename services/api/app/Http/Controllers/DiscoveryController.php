<?php

declare(strict_types=1);

namespace App\Http\Controllers;

use App\Actions\GetArtworkStream;
use App\Http\Requests\ArtworkStreamRequest;
use App\Http\Resources\ArtworkResource;
use App\Http\Resources\ArtworkSummaryResource;
use App\Http\Resources\CollectionResource;
use App\Http\Resources\PhotographerResource;
use App\Models\Artwork;
use App\Models\Collection;
use App\Models\Exhibition;
use App\Models\Photographer;
use Illuminate\Support\Str;

final class DiscoveryController
{
    public function collection(string $slug): CollectionResource
    {
        return new CollectionResource(Collection::where('slug', $slug)->firstOrFail());
    }

    public function collectionArtworks(string $slug, ArtworkStreamRequest $request, GetArtworkStream $action)
    {
        return ArtworkSummaryResource::collection($action->execute(Collection::where('slug', $slug)->firstOrFail(), $request));
    }

    public function exhibitionArtworks(string $slug, ArtworkStreamRequest $request, GetArtworkStream $action)
    {
        return ArtworkSummaryResource::collection($action->execute(Exhibition::where('published_at', '<=', now())->where('slug', $slug)->firstOrFail(), $request));
    }

    public function artwork(string $key): ArtworkResource
    {
        return new ArtworkResource(Artwork::where('published_at', '<=', now())
            ->where(Str::isUuid($key) ? 'id' : 'slug', $key)
            ->with(['media', 'photographer', 'editions.printSizes', 'collections'])->firstOrFail());
    }

    public function photographer(string $key): PhotographerResource
    {
        return new PhotographerResource(Photographer::where(Str::isUuid($key) ? 'id' : 'slug', $key)
            ->whereHas('artworks', fn ($q) => $q->where('published_at', '<=', now()))->firstOrFail());
    }
}
