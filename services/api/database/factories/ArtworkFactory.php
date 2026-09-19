<?php

declare(strict_types=1);

namespace Database\Factories;

use App\Models\Artwork;
use App\Models\Photographer;
use Illuminate\Database\Eloquent\Factories\Factory;

/** @extends Factory<Artwork> */
final class ArtworkFactory extends Factory
{
    protected $model = Artwork::class;

    public function definition(): array
    {
        return ['slug' => fake()->unique()->slug(3), 'photographer_id' => Photographer::factory(), 'title_en' => fake()->sentence(3), 'title_ar' => 'عمل تجريبي', 'story_en' => 'Sample story.', 'story_ar' => 'قصة تجريبية', 'published_at' => now()->subDay(), 'is_curator_pick' => false];
    }
}
