<?php

declare(strict_types=1);

namespace Database\Factories;

use App\Models\FrameOption;
use Illuminate\Database\Eloquent\Factories\Factory;

/** @extends Factory<FrameOption> */
final class FrameOptionFactory extends Factory
{
    protected $model = FrameOption::class;

    public function definition(): array
    {
        return ['label_en' => 'Dark oak', 'label_ar' => 'بلوط داكن', 'material' => 'oak', 'color_hex' => '#29251F', 'border_mm' => 20];
    }
}
