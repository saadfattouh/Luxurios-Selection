<?php

declare(strict_types=1);

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

final class ExhibitionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return ['id' => $this->id, 'slug' => $this->slug, 'title' => ['en' => $this->title_en, 'ar' => $this->title_ar], 'subtitle' => ['en' => $this->subtitle_en, 'ar' => $this->subtitle_ar], 'hero_artwork' => new ArtworkResource($this->whenLoaded('heroArtwork'))];
    }
}
