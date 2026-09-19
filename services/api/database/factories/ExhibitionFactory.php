<?php

declare(strict_types=1);

namespace Database\Factories;

use App\Models\Artwork;
use App\Models\Exhibition;
use Illuminate\Database\Eloquent\Factories\Factory;

/** @extends Factory<Exhibition> */
final class ExhibitionFactory extends Factory
{
    protected $model = Exhibition::class;

    public function definition(): array
    {
        return ['slug' => fake()->unique()->slug(3), 'title_en' => fake()->sentence(3), 'title_ar' => 'معرض تجريبي', 'subtitle_en' => 'Contemporary photography', 'subtitle_ar' => 'تصوير معاصر', 'hero_artwork_id' => Artwork::factory(), 'published_at' => now()->subDay(), 'position' => 0];
    }
}
