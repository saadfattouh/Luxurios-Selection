<?php

declare(strict_types=1);

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

final class CurationResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return ['current_exhibitions' => ExhibitionResource::collection($this->resource['current_exhibitions']), 'curators_selection' => ArtworkResource::collection($this->resource['curators_selection']), 'new_works' => ArtworkResource::collection($this->resource['new_works']), 'featured_photographer' => new PhotographerResource($this->resource['featured_photographer']), 'limited_editions' => ArtworkResource::collection($this->resource['limited_editions']), 'collections' => CollectionResource::collection($this->resource['collections']), 'section_limit' => 6];
    }
}
