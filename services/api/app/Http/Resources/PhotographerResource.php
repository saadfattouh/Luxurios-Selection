<?php

declare(strict_types=1);

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

final class PhotographerResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return ['id' => $this->id, 'slug' => $this->slug, 'name' => ['en' => $this->name_en, 'ar' => $this->name_ar], 'bio' => ['en' => $this->bio_en, 'ar' => $this->bio_ar]];
    }
}
