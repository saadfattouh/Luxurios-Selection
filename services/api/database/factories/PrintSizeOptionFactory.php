<?php

declare(strict_types=1);

namespace Database\Factories;

use App\Models\PrintSizeOption;
use Illuminate\Database\Eloquent\Factories\Factory;

/** @extends Factory<PrintSizeOption> */
final class PrintSizeOptionFactory extends Factory
{
    protected $model = PrintSizeOption::class;

    public function definition(): array
    {
        return ['label_en' => '100 × 70 cm', 'label_ar' => '١٠٠ × ٧٠ سم', 'width_mm' => 1000, 'height_mm' => 700];
    }
}
