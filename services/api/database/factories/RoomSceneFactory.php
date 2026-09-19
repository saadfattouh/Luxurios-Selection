<?php

declare(strict_types=1);

namespace Database\Factories;

use App\Models\RoomScene;
use Illuminate\Database\Eloquent\Factories\Factory;

/** @extends Factory<RoomScene> */
final class RoomSceneFactory extends Factory
{
    protected $model = RoomScene::class;

    public function definition(): array
    {
        return ['label_en' => 'Quiet residence', 'label_ar' => 'مسكن هادئ', 'wall_bounds' => null];
    }
}
