<?php

declare(strict_types=1);

namespace Database\Factories;

use App\Models\Artwork;
use App\Models\ArtworkMedia;
use Illuminate\Database\Eloquent\Factories\Factory;

/** @extends Factory<ArtworkMedia> */
final class ArtworkMediaFactory extends Factory
{
    protected $model = ArtworkMedia::class;

    public function definition(): array
    {
        return ['artwork_id' => Artwork::factory(), 'disk' => 'public', 'path' => 'demo/landscape.jpg', 'alt_en' => 'Mountain landscape', 'alt_ar' => 'منظر جبلي', 'width' => 1600, 'height' => 1067, 'position' => 0, 'credit' => 'Demo reference', 'source_url' => 'https://unsplash.com'];
    }
}
