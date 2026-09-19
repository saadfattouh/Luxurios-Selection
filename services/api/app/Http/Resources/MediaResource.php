<?php

declare(strict_types=1);

namespace App\Http\Resources;

use App\Contracts\MediaUrlResolver;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

final class MediaResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return ['id' => $this->id, 'url' => app(MediaUrlResolver::class)->url($this->disk, $this->path), 'alt' => ['en' => $this->alt_en, 'ar' => $this->alt_ar], 'width' => $this->width, 'height' => $this->height, 'credit' => $this->credit, 'source_url' => $this->source_url];
    }
}
