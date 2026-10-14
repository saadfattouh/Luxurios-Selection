<?php

use App\Actions\BuildMediaRenditions;
use App\Models\ArtworkMedia;
use Illuminate\Support\Facades\Artisan;

Artisan::command('media:renditions', function () {
    ArtworkMedia::query()->eachById(function ($media) {
        app(BuildMediaRenditions::class)->execute($media);
    });
    $this->info('Public display renditions prepared.');
})->purpose('Generate public display images outside the HTTP request path');
