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
        Schema::table('artwork_media', function (Blueprint $t) {
            $t->jsonb('renditions')->nullable();
            $t->string('dominant_color', 7)->nullable();
        });
        Schema::table('editions', function (Blueprint $t) {
            $t->string('availability', 20)->default('unknown');
            $t->unsignedBigInteger('starting_price_minor')->nullable();
            $t->string('currency', 3)->nullable();
            $t->index(['artwork_id', 'availability', 'is_limited']);
        });
        DB::statement("ALTER TABLE editions ADD CONSTRAINT edition_availability CHECK (availability IN ('available','sold_out','unavailable','unknown'))");
        DB::statement("ALTER TABLE editions ADD CONSTRAINT edition_price CHECK ((starting_price_minor IS NULL AND currency IS NULL) OR (starting_price_minor IS NOT NULL AND currency IS NOT NULL AND starting_price_minor >= 0 AND currency ~ '^[A-Z]{3}$'))");
        Schema::table('artworks', fn (Blueprint $t) => $t->index(['photographer_id', 'published_at', 'id']));
        Schema::table('exhibitions', fn (Blueprint $t) => $t->index(['position', 'id', 'published_at']));
        foreach (['collection', 'exhibition'] as $kind) {
            Schema::table('artwork_'.$kind, fn (Blueprint $t) => $t->index([$kind.'_id', 'artwork_id']));
        }
    }

    public function down(): void
    {
        foreach (['collection', 'exhibition'] as $kind) {
            Schema::table('artwork_'.$kind, fn (Blueprint $t) => $t->dropIndex([$kind.'_id', 'artwork_id']));
        }
        Schema::table('artworks', fn (Blueprint $t) => $t->dropIndex(['photographer_id', 'published_at', 'id']));
        Schema::table('exhibitions', fn (Blueprint $t) => $t->dropIndex(['position', 'id', 'published_at']));
        DB::statement('ALTER TABLE editions DROP CONSTRAINT edition_price, DROP CONSTRAINT edition_availability');
        Schema::table('editions', function (Blueprint $t) {
            $t->dropIndex(['artwork_id', 'availability', 'is_limited']);
            $t->dropColumn(['availability', 'starting_price_minor', 'currency']);
        });
        Schema::table('artwork_media', fn (Blueprint $t) => $t->dropColumn(['renditions', 'dominant_color']));
    }
};
