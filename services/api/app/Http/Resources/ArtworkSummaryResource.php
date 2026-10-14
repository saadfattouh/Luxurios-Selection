<?php

declare(strict_types=1);

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

final class ArtworkSummaryResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $artist = $this->photographer;
        $editions = $this->editions;

        return [
            'id' => $this->id, 'slug' => $this->slug,
            'title' => ['en' => $this->title_en, 'ar' => $this->title_ar],
            'photographer' => $artist ? ['id' => $artist->id, 'slug' => $artist->slug, 'name' => ['en' => $artist->name_en, 'ar' => $artist->name_ar]] : null,
            'media' => MediaResource::collection($this->media),
            'edition_summary' => $editions->isEmpty() ? null : ['is_limited' => $editions->every(fn ($e) => $e->is_limited), 'total' => $editions->count() === 1 ? $editions->first()->total : null],
            'availability' => $editions->contains('availability', 'available') ? 'available' : ($editions->isNotEmpty() && $editions->pluck('availability')->unique()->count() === 1 ? $editions->first()->availability : 'unknown'),
        ];
    }
}
