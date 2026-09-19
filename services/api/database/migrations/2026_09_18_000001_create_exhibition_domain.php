<?php

declare(strict_types=1);
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('photographers', function (Blueprint $t) {
            $t->uuid('id')->primary();
            $t->string('slug')->unique();
            $t->string('name_en');
            $t->string('name_ar');
            $t->text('bio_en');
            $t->text('bio_ar');
            $t->boolean('is_featured')->default(false)->index();
            $t->timestampsTz();
        });
        Schema::create('artworks', function (Blueprint $t) {
            $t->uuid('id')->primary();
            $t->string('slug')->unique();
            $t->foreignUuid('photographer_id')->constrained()->restrictOnDelete();
            $t->string('title_en');
            $t->string('title_ar');
            $t->text('story_en');
            $t->text('story_ar');
            $t->boolean('is_curator_pick')->default(false);
            $t->timestampTz('published_at')->nullable()->index();
            $t->timestampsTz();
        });
        Schema::create('artwork_media', function (Blueprint $t) {
            $t->uuid('id')->primary();
            $t->foreignUuid('artwork_id')->constrained()->cascadeOnDelete();
            $t->string('disk');
            $t->string('path');
            $t->string('alt_en');
            $t->string('alt_ar');
            $t->unsignedInteger('width');
            $t->unsignedInteger('height');
            $t->unsignedInteger('position')->default(0);
            $t->string('credit');
            $t->string('source_url');
            $t->timestampsTz();
            $t->unique(['artwork_id', 'position']);
        });
        Schema::create('exhibitions', function (Blueprint $t) {
            $t->uuid('id')->primary();
            $t->string('slug')->unique();
            $t->string('title_en');
            $t->string('title_ar');
            $t->string('subtitle_en');
            $t->string('subtitle_ar');
            $t->foreignUuid('hero_artwork_id')->nullable()->constrained('artworks')->nullOnDelete();
            $t->timestampTz('published_at')->nullable()->index();
            $t->unsignedInteger('position')->default(0);
            $t->timestampsTz();
        });
        Schema::create('collections', function (Blueprint $t) {
            $t->uuid('id')->primary();
            $t->string('slug')->unique();
            $t->string('title_en');
            $t->string('title_ar');
            $t->string('atmosphere');
            $t->unsignedInteger('position')->default(0);
            $t->timestampsTz();
        });
        foreach (['collection', 'exhibition'] as $relation) {
            Schema::create('artwork_'.$relation, function (Blueprint $t) use ($relation) {
                $t->foreignUuid('artwork_id')->constrained()->cascadeOnDelete();
                $t->foreignUuid($relation.'_id')->constrained()->cascadeOnDelete();
                $t->unsignedInteger('position')->default(0);
                $t->primary(['artwork_id', $relation.'_id']);
            });
        }
        Schema::create('editions', function (Blueprint $t) {
            $t->uuid('id')->primary();
            $t->foreignUuid('artwork_id')->constrained()->cascadeOnDelete();
            $t->string('label_en');
            $t->string('label_ar');
            $t->boolean('is_limited')->default(true);
            $t->unsignedInteger('total')->nullable();
            $t->timestampsTz();
        });
        Schema::create('print_size_options', function (Blueprint $t) {
            $t->uuid('id')->primary();
            $t->string('label_en');
            $t->string('label_ar');
            $t->unsignedInteger('width_mm');
            $t->unsignedInteger('height_mm');
            $t->timestampsTz();
        });
        Schema::create('edition_print_size', function (Blueprint $t) {
            $t->foreignUuid('edition_id')->constrained()->cascadeOnDelete();
            $t->foreignUuid('print_size_option_id')->constrained()->cascadeOnDelete();
            $t->timestampsTz();
            $t->primary(['edition_id', 'print_size_option_id']);
        });
        Schema::create('frame_options', function (Blueprint $t) {
            $t->uuid('id')->primary();
            $t->string('label_en');
            $t->string('label_ar');
            $t->string('material');
            $t->string('color_hex', 7);
            $t->unsignedInteger('border_mm');
            $t->timestampsTz();
        });
        Schema::create('room_scenes', function (Blueprint $t) {
            $t->uuid('id')->primary();
            $t->string('label_en');
            $t->string('label_ar');
            $t->string('disk')->nullable();
            $t->string('path')->nullable();
            $t->jsonb('wall_bounds')->nullable();
            $t->timestampsTz();
        });
        // PostgreSQL constraints are also enforced for direct SQL writes.
        DB::statement('ALTER TABLE editions ADD CONSTRAINT valid_edition_total CHECK ((is_limited AND total IS NOT NULL AND total > 0) OR (NOT is_limited AND total IS NULL))');
        DB::statement('ALTER TABLE print_size_options ADD CONSTRAINT positive_print_dimensions CHECK (width_mm > 0 AND height_mm > 0)');
        DB::statement('ALTER TABLE artwork_media ADD CONSTRAINT positive_media_dimensions CHECK (width > 0 AND height > 0)');
    }

    public function down(): void
    {
        foreach (['room_scenes', 'frame_options', 'edition_print_size', 'print_size_options', 'editions', 'artwork_exhibition', 'artwork_collection', 'collections', 'exhibitions', 'artwork_media', 'artworks', 'photographers'] as $table) {
            Schema::dropIfExists($table);
        }
    }
};
