<?php

declare(strict_types=1);

namespace Database\Factories;

use App\Models\Artwork;
use App\Models\Edition;
use Illuminate\Database\Eloquent\Factories\Factory;

/** @extends Factory<Edition> */
final class EditionFactory extends Factory
{
    protected $model = Edition::class;

    public function definition(): array
    {
        return ['artwork_id' => Artwork::factory(), 'label_en' => 'Collector edition', 'label_ar' => 'إصدار لهواة الاقتناء', 'is_limited' => true, 'total' => 10];
    }
}
