<?php

declare(strict_types=1);

namespace App\Http\Controllers;

use App\Actions\GetCuration;
use App\Http\Requests\IndexRequest;
use App\Http\Resources\CollectionResource;
use App\Http\Resources\CurationResource;
use App\Http\Resources\ExhibitionResource;
use App\Models\Collection;
use App\Models\Exhibition;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

final class ExhibitionController
{
    private function exhibitions(): Builder
    {
        return Exhibition::query()->whereNotNull('published_at')->where('published_at', '<=', now())->with(['heroArtwork' => fn ($q) => $q->where('published_at', '<=', now())->with(GetCuration::ARTWORK_RELATIONS)]);
    }

    public function index(IndexRequest $request): AnonymousResourceCollection
    {
        return ExhibitionResource::collection($this->exhibitions()->orderBy('position')->orderBy('id')->paginate($request->pageSize())->withQueryString());
    }

    public function show(string $slug): ExhibitionResource
    {
        return new ExhibitionResource($this->exhibitions()->where('slug', $slug)->firstOrFail());
    }

    public function collections(IndexRequest $request): AnonymousResourceCollection
    {
        return CollectionResource::collection(Collection::query()->orderBy('position')->orderBy('id')->paginate($request->pageSize())->withQueryString());
    }

    public function curation(GetCuration $action): CurationResource
    {
        return new CurationResource($action->execute());
    }
}
