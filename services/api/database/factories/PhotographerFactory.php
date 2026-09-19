<?php

declare(strict_types=1);

namespace Database\Factories;

use App\Models\Photographer;
use Illuminate\Database\Eloquent\Factories\Factory;

/** @extends Factory<Photographer> */
final class PhotographerFactory extends Factory
{
    protected $model = Photographer::class;

    public function definition(): array
    {
        return ['slug' => fake()->unique()->slug(3), 'name_en' => fake()->name(), 'name_ar' => 'مصور تجريبي', 'bio_en' => 'Fictional demonstration profile.', 'bio_ar' => 'سيرة تجريبية خيالية', 'is_featured' => false];
    }
}
