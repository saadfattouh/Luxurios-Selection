<?php

declare(strict_types=1);

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

final class ArtworkResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return ['id' => $this->id, 'slug' => $this->slug, 'title' => ['en' => $this->title_en, 'ar' => $this->title_ar], 'story' => ['en' => $this->story_en, 'ar' => $this->story_ar], 'published_at' => $this->published_at?->toIso8601String(), 'photographer' => new PhotographerResource($this->whenLoaded('photographer')), 'media' => MediaResource::collection($this->whenLoaded('media')), 'editions' => EditionResource::collection($this->whenLoaded('editions')), 'collections' => CollectionResource::collection($this->whenLoaded('collections'))];
    }
}
