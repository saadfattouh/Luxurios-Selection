<?php

declare(strict_types=1);

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

final class EditionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return ['id' => $this->id, 'label' => ['en' => $this->label_en, 'ar' => $this->label_ar], 'is_limited' => $this->is_limited, 'total' => $this->total, 'availability' => $this->availability, 'starting_price' => $this->starting_price_minor === null ? null : ['amount_minor' => (int) $this->starting_price_minor, 'currency' => $this->currency], 'sizes' => $this->whenLoaded('printSizes', fn () => $this->printSizes->map(fn ($size) => ['id' => $size->id, 'label' => ['en' => $size->label_en, 'ar' => $size->label_ar], 'width_mm' => $size->width_mm, 'height_mm' => $size->height_mm]))];
    }
}
