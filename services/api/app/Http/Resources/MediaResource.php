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
        $resolver = app(MediaUrlResolver::class);
        $variants = [];
        foreach (($this->renditions ?? []) as $kind => $value) {
            if (! in_array($kind, ['thumbnail', 'hero', 'fullscreen'], true)) {
                continue;
            }
            $variants[$kind] = ['url' => $this->disk === 'public' ? url('/api/media/'.$value['path']) : $resolver->url($this->disk, $value['path']), 'width' => $value['width'], 'height' => $value['height'], 'aspect_ratio' => $value['width'] / $value['height']];
        }

        return [
            'id' => $this->id, 'url' => $resolver->url($this->disk, $this->path),
            'alt' => ['en' => $this->alt_en, 'ar' => $this->alt_ar],
            'width' => $this->width, 'height' => $this->height, 'aspect_ratio' => $this->width / $this->height,
            'dominant_color' => $this->dominant_color, 'renditions' => (object) $variants,
            'credit' => $this->credit, 'source_url' => $this->source_url,
        ];
    }
}
