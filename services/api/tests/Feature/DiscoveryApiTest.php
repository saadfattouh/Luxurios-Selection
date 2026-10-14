<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Models\Artwork;
use App\Models\ArtworkMedia;
use App\Models\Edition;
use App\Models\Exhibition;
use Database\Seeders\DatabaseSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

final class DiscoveryApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        Storage::fake('public');
        $this->travelTo(now()->setDate(2026, 9, 19));
    }

    public function test_collection_identity_and_stream_are_lightweight(): void
    {
        $this->seed();
        $this->getJson('/api/v1/collections/landscape')->assertOk()->assertJsonPath('data.atmosphere', 'expansive')->assertJsonMissingPath('data.artworks');
        $this->getJson('/api/v1/collections/landscape/artworks')->assertOk()->assertJsonCount(2, 'data')
            ->assertJsonMissingPath('data.0.story')->assertJsonMissingPath('data.0.photographer.bio')->assertJsonMissingPath('data.0.editions')
            ->assertJsonStructure(['data' => [['id', 'title', 'media', 'edition_summary', 'availability']], 'meta' => ['next_cursor']]);
    }

    public function test_detail_by_id_and_slug_includes_progressive_information(): void
    {
        $this->seed();
        foreach (['where-silence-rises', DatabaseSeeder::id(100)] as $key) {
            $this->getJson('/api/v1/artworks/'.$key)->assertOk()->assertJsonPath('data.photographer.slug', 'layla-noor')
                ->assertJsonPath('data.editions.0.availability', 'available')->assertJsonPath('data.editions.0.starting_price.currency', 'AED')
                ->assertJsonCount(1, 'data.editions.0.sizes')->assertJsonStructure(['data' => ['story', 'collections']]);
        }
        $this->getJson('/api/v1/photographers/layla-noor')->assertOk()->assertJsonStructure(['data' => ['bio']]);
        $this->getJson('/api/v1/photographers/'.DatabaseSeeder::id(1))->assertOk();
    }

    public function test_drafts_future_and_unknown_identities_are_hidden(): void
    {
        $this->seed();
        Artwork::query()->update(['published_at' => null]);
        $this->getJson('/api/v1/artworks/where-silence-rises')->assertNotFound();
        $this->getJson('/api/v1/photographers/layla-noor')->assertNotFound();
        $this->getJson('/api/v1/collections/landscape/artworks')->assertJsonCount(0, 'data');
        Exhibition::query()->update(['published_at' => now()->addDay()]);
        $this->getJson('/api/v1/exhibitions/beyond-the-horizon/artworks')->assertNotFound();
        foreach (['artworks', 'collections', 'photographers', 'exhibitions'] as $resource) {
            $this->getJson('/api/v1/'.$resource.'/not-found')->assertNotFound()->assertHeader('Content-Type', 'application/problem+json');
        }
    }

    public function test_filters_and_validation(): void
    {
        $this->seed();
        $path = '/api/v1/exhibitions/beyond-the-horizon/artworks';
        $this->getJson($path.'?collection=landscape&photographer=layla-noor&edition_status=limited&availability=available')->assertOk()->assertJsonCount(2, 'data');
        $this->getJson($path.'?availability=sold_out')->assertJsonCount(1, 'data');
        $this->getJson($path.'?edition_status=open')->assertJsonCount(0, 'data');
        foreach (['per_page=25', 'per_page=0', 'orientation=diagonal', 'edition_status=all', 'availability=maybe', 'cursor=bad', 'sort=story', 'photographer[]=x', 'collection=%27%20OR%201=1'] as $query) {
            $this->getJson($path.'?'.$query)->assertUnprocessable()->assertJsonStructure(['errors', 'request_id']);
        }
    }

    public function test_orientation_uses_primary_image_and_filters_same_edition(): void
    {
        $this->seed();
        ArtworkMedia::where('artwork_id', DatabaseSeeder::id(100))->update(['width' => 800, 'height' => 1200]);
        $this->getJson('/api/v1/collections/landscape/artworks?orientation=portrait')->assertJsonCount(1, 'data')->assertJsonPath('data.0.id', DatabaseSeeder::id(100));
        Edition::where('artwork_id', DatabaseSeeder::id(100))->update(['availability' => 'sold_out']);
        Edition::factory()->create(['artwork_id' => DatabaseSeeder::id(100), 'is_limited' => false, 'total' => null, 'availability' => 'available']);
        $this->getJson('/api/v1/collections/landscape/artworks?orientation=portrait&availability=available&edition_status=limited')->assertJsonCount(0, 'data');
    }

    public function test_cursor_walk_and_insertion_do_not_duplicate_or_skip_existing_works(): void
    {
        $this->seed();
        $path = '/api/v1/exhibitions/beyond-the-horizon/artworks?per_page=2';
        $first = $this->getJson($path)->assertOk();
        $seen = array_column($first->json('data'), 'id');
        $extra = Artwork::factory()->create(['id' => DatabaseSeeder::id(99)]);
        Exhibition::where('slug', 'beyond-the-horizon')->first()->artworks()->attach($extra->id);
        $cursor = $first->json('meta.next_cursor');
        while ($cursor) {
            $page = $this->getJson($path.'&cursor='.urlencode($cursor))->assertOk();
            $seen = array_merge($seen, array_column($page->json('data'), 'id'));
            $cursor = $page->json('meta.next_cursor');
        }
        $this->assertSame(array_map(fn ($id) => DatabaseSeeder::id($id), range(100, 105)), $seen);
        $this->assertCount(6, array_unique($seen));
    }

    public function test_stream_query_count_does_not_grow_with_page_size(): void
    {
        $this->seed();
        DB::enableQueryLog();
        $this->getJson('/api/v1/exhibitions/beyond-the-horizon/artworks?per_page=1')->assertOk();
        $small = count(DB::getQueryLog());
        DB::flushQueryLog();
        $this->getJson('/api/v1/exhibitions/beyond-the-horizon/artworks?per_page=24')->assertOk();
        $large = count(DB::getQueryLog());
        DB::disableQueryLog();
        $this->assertLessThanOrEqual($small, $large);
        $this->assertLessThanOrEqual(7, $large);
    }

    public function test_etag_revalidation_and_relationship_invalidation(): void
    {
        $this->seed();
        $path = '/api/v1/artworks/where-silence-rises';
        $etag = $this->getJson($path)->assertHeader('Cache-Control', 'max-age=0, must-revalidate, public')->headers->get('ETag');
        $this->withHeader('If-None-Match', $etag)->getJson($path)->assertStatus(304)->assertContent('');
        Edition::where('artwork_id', DatabaseSeeder::id(100))->update(['availability' => 'sold_out']);
        $this->withHeader('If-None-Match', $etag)->getJson($path)->assertOk()->assertJsonPath('data.editions.0.availability', 'sold_out');
    }

    public function test_renditions_have_real_dimensions_and_no_internal_paths(): void
    {
        $this->seed();
        $media = $this->getJson('/api/v1/artworks/where-silence-rises')->json('data.media.0');
        foreach (['thumbnail' => 480, 'hero' => 1280, 'fullscreen' => 1920] as $name => $cap) {
            $variant = $media['renditions'][$name];
            $this->assertLessThanOrEqual($cap, max($variant['width'], $variant['height']));
            $this->assertArrayNotHasKey('path', $variant);
            $response = $this->get($variant['url'], ['Origin' => 'http://localhost:8080'])->assertOk()->assertHeader('Access-Control-Allow-Origin', 'http://localhost:8080');
            $this->assertSame('image/jpeg', $response->headers->get('Content-Type'));
        }
        $this->assertMatchesRegularExpression('/^#[0-9A-F]{6}$/', $media['dominant_color']);
        $this->get('/api/media/../.env')->assertNotFound();
    }

    public function test_unknown_availability_and_price_remain_unknown(): void
    {
        $work = Artwork::factory()->create();
        Edition::factory()->create(['artwork_id' => $work->id]);
        $this->getJson('/api/v1/artworks/'.$work->id)->assertOk()->assertJsonPath('data.editions.0.availability','unknown')->assertJsonPath('data.editions.0.starting_price',null);
    }
}
