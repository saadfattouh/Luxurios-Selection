<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Models\Artwork;
use App\Models\Edition;
use App\Models\Exhibition;
use Illuminate\Database\QueryException;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

final class ExhibitionApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        Storage::fake('public');
        $this->travelTo(now()->setDate(2026, 9, 18));
    }

    public function test_seed_is_repeatable_and_curation_is_explicit(): void
    {
        $this->seed();
        $this->seed();
        $this->assertDatabaseCount('artworks', 6);
        $this->assertDatabaseCount('collections', 4);
        $this->getJson('/api/v1/home/curation')->assertOk()->assertJsonCount(2, 'data.current_exhibitions')->assertJsonCount(3, 'data.curators_selection')->assertJsonPath('data.featured_photographer.name.en', 'Layla Noor')->assertJsonPath('data.current_exhibitions.0.hero_artwork.title.en', 'Where silence rises')->assertJsonMissingPath('data.current_exhibitions.0.created_at');
        Storage::disk('public')->assertExists('demo/landscape.jpg');
    }

    public function test_pagination_and_validation(): void
    {
        Exhibition::factory()->count(3)->create();
        $this->getJson('/api/v1/exhibitions?per_page=2')->assertOk()->assertJsonCount(2, 'data')->assertJsonPath('meta.total', 3);
        foreach (['per_page=25', 'page=0', 'per_page=abc'] as $query) {
            $this->getJson('/api/v1/exhibitions?'.$query)->assertStatus(422)->assertHeader('Content-Type', 'application/problem+json')->assertJsonStructure(['type', 'title', 'status', 'detail', 'instance', 'request_id', 'errors']);
        }
    }

    public function test_draft_and_future_exhibitions_are_hidden(): void
    {
        $draft = Exhibition::factory()->create(['published_at' => null]);
        Exhibition::factory()->create(['published_at' => now()->addDay()]);
        $this->getJson('/api/v1/exhibitions')->assertJsonCount(0, 'data');
        $this->getJson('/api/v1/exhibitions/'.$draft->slug)->assertNotFound()->assertJsonPath('status', 404);
    }

    public function test_draft_hero_and_artworks_cannot_leak(): void
    {
        $art = Artwork::factory()->create(['published_at' => null, 'is_curator_pick' => true]);
        $ex = Exhibition::factory()->create(['hero_artwork_id' => $art->id]);
        $this->getJson('/api/v1/exhibitions/'.$ex->slug)->assertOk()->assertJsonPath('data.hero_artwork', null);
        $this->getJson('/api/v1/home/curation')->assertOk()->assertJsonCount(0, 'data.curators_selection')->assertJsonCount(0, 'data.new_works');
    }

    public function test_read_only_and_problem_errors(): void
    {
        $this->postJson('/api/v1/exhibitions', [])->assertStatus(405)->assertJsonPath('status', 405);
        $this->get('/api/v1/missing')->assertNotFound()->assertHeader('Content-Type', 'application/problem+json');
    }

    public function test_health_readiness_and_empty_curation(): void
    {
        $this->getJson('/api/v1/health')->assertOk()->assertJsonPath('data.status', 'ok');
        $this->getJson('/api/v1/ready')->assertOk()->assertJsonPath('data.status', 'ready');
        $this->getJson('/api/v1/home/curation')->assertOk()->assertJsonPath('data.featured_photographer', null);
    }

    public function test_collection_pagination_and_stable_media_urls(): void
    {
        $this->seed();
        $this->getJson('/api/v1/collections?per_page=2')->assertJsonCount(2, 'data')->assertJsonPath('meta.total', 4);
        $url = $this->getJson('/api/v1/home/curation')->json('data.curators_selection.0.media.0.url');
        $this->assertStringContainsString('/storage/demo/', $url);
    }

    public function test_readiness_failure_is_a_safe_problem(): void
    {
        $connection = DB::connection();
        DB::shouldReceive('connection')->andReturn($connection);
        DB::shouldReceive('select')->once()->with('select 1')->andThrow(new \RuntimeException('private database detail'));
        $this->getJson('/api/v1/ready')->assertStatus(503)->assertHeader('Content-Type', 'application/problem+json')->assertJsonPath('detail', 'The exhibition service is temporarily unavailable.')->assertDontSee('private database detail');
    }

    public function test_limited_editions_require_a_non_null_positive_total(): void
    {
        $this->expectException(QueryException::class);
        Edition::factory()->create(['is_limited' => true, 'total' => null]);
    }
}
