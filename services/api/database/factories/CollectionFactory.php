<?php

declare(strict_types=1);

namespace Database\Factories;

use App\Models\Collection;
use Illuminate\Database\Eloquent\Factories\Factory;

/** @extends Factory<Collection> */
final class CollectionFactory extends Factory
{
    protected $model = Collection::class;

    public function definition(): array
    {
        return ['slug' => fake()->unique()->slug(3), 'title_en' => 'Landscape', 'title_ar' => 'الطبيعة', 'atmosphere' => 'expansive', 'position' => 0];
    }
}
