<?php

declare(strict_types=1);

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

final class EditionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return ['id' => $this->id, 'label' => ['en' => $this->label_en, 'ar' => $this->label_ar], 'is_limited' => $this->is_limited, 'total' => $this->total];
    }
}
