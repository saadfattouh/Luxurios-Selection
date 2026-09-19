<?php

declare(strict_types=1);

namespace Database\Seeders;

use App\Models\Artwork;
use App\Models\ArtworkMedia;
use App\Models\Collection;
use App\Models\Edition;
use App\Models\Exhibition;
use App\Models\FrameOption;
use App\Models\Photographer;
use App\Models\PrintSizeOption;
use App\Models\RoomScene;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

final class DatabaseSeeder extends Seeder
{
    public static function id(int $value): string
    {
        return sprintf('00000000-0000-4000-8000-%012d', $value);
    }

    private function put(string $class, int $id, array $values): Model
    {
        return Model::unguarded(fn () => $class::updateOrCreate(['id' => self::id($id)], $values));
    }

    public function run(): void
    {
        if (! app()->environment(['local', 'testing'])) {
            throw new \RuntimeException('Sample data is restricted to local/testing environments.');
        }
        // Copy bundled, credited reference photos through the same disk abstraction as production.
        foreach (['landscape', 'architecture', 'wildlife', 'monochrome'] as $photo) {
            $bytes = file_get_contents(database_path('seeders/media/'.$photo.'.jpg'));
            if ($bytes === false) {
                throw new \RuntimeException('Missing bundled reference photo: '.$photo);
            }
            Storage::disk(config('filesystems.default'))->put('demo/'.$photo.'.jpg', $bytes);
        }
        DB::transaction(function (): void {
            $photographer = $this->put(Photographer::class, 1, ['slug' => 'layla-noor', 'name_en' => 'Layla Noor', 'name_ar' => 'ليلى نور', 'bio_en' => 'A fictional artist exploring the quiet between landscape and light. Reference photographs are credited individually.', 'bio_ar' => 'شخصية فنية خيالية تتأمل السكون بين الطبيعة والضوء. تُنسب الصور المرجعية إلى مصادرها بشكل مستقل.', 'is_featured' => true]);
            $categories = [['wildlife', 'Wildlife', 'الحياة البرية', 'atmospheric'], ['architecture', 'Architecture', 'العمارة', 'geometric'], ['landscape', 'Landscape', 'المناظر الطبيعية', 'expansive'], ['black-and-white', 'Black & White', 'الأبيض والأسود', 'monochrome']];
            foreach ($categories as $i => $c) {
                $this->put(Collection::class, 10 + $i, ['slug' => $c[0], 'title_en' => $c[1], 'title_ar' => $c[2], 'atmosphere' => $c[3], 'position' => $i]);
            }
            $works = [
                ['where-silence-rises', 'Where silence rises', 'حيث يرتفع الصمت', 'landscape', 12, 'A mountain rising through clouds', 'جبل يرتفع بين السحب'],
                ['a-line-of-light', 'A line of light', 'خيط من ضوء', 'architecture', 11, 'Architectural forms against the sky', 'تكوينات معمارية في مواجهة السماء'],
                ['the-watchful-hour', 'The watchful hour', 'ساعة الترقب', 'wildlife', 10, 'A lion at rest', 'أسد في لحظة سكون'],
                ['between-shadows', 'Between shadows', 'بين الظلال', 'monochrome', 13, 'Monochrome mountain landscape', 'منظر جبلي بالأبيض والأسود'],
                ['the-distance-within', 'The distance within', 'المسافة في داخلنا', 'landscape', 12, 'Mountain landscape and cloud', 'منظر جبلي وسحب'],
                ['stillness-in-stone', 'Stillness in stone', 'سكون الحجر', 'architecture', 11, 'Quiet geometry in architecture', 'هندسة هادئة في العمارة'],
            ];
            $size = $this->put(PrintSizeOption::class, 300, ['label_en' => '100 × 70 cm', 'label_ar' => '١٠٠ × ٧٠ سم', 'width_mm' => 1000, 'height_mm' => 700]);
            foreach ($works as $i => $a) {
                $art = $this->put(Artwork::class, 100 + $i, ['slug' => $a[0], 'title_en' => $a[1], 'title_ar' => $a[2], 'photographer_id' => $photographer->id, 'story_en' => 'A study in presence, distance and the spaces we leave untouched. Fictional exhibition work using a credited reference image.', 'story_ar' => 'تأمل في الحضور والمسافة والمساحات التي نتركها على حالها. عمل خيالي للعرض التجريبي بصورة مرجعية موثقة.', 'is_curator_pick' => $i < 3, 'published_at' => sprintf('2026-09-%02dT12:00:00Z', 10 + $i)]);
                $art->collections()->sync([self::id($a[4]) => ['position' => $i]]);
                $dim = getimagesize(database_path('seeders/media/'.$a[3].'.jpg'));
                $source = match ($a[3]) {
                    'architecture' => 'photo-1511818966892-d7d671e672a2','wildlife' => 'photo-1546182990-dffeafbe841d',default => 'photo-1464822759023-fed622ff2c3b'
                };
                $this->put(ArtworkMedia::class, 200 + $i, ['artwork_id' => $art->id, 'disk' => config('filesystems.default'), 'path' => 'demo/'.$a[3].'.jpg', 'alt_en' => $a[5], 'alt_ar' => $a[6], 'width' => $dim[0], 'height' => $dim[1], 'position' => 0, 'credit' => 'Unsplash reference image; fictional artwork attribution', 'source_url' => 'https://images.unsplash.com/'.$source]);
                $edition = $this->put(Edition::class, 400 + $i, ['artwork_id' => $art->id, 'label_en' => 'Collector edition', 'label_ar' => 'إصدار لهواة الاقتناء', 'is_limited' => true, 'total' => 10 + $i * 5]);
                $edition->printSizes()->sync([$size->id]);
            }
            $ex = $this->put(Exhibition::class, 500, ['slug' => 'beyond-the-horizon', 'title_en' => 'Beyond the horizon', 'title_ar' => 'ما وراء الأفق', 'subtitle_en' => 'On distance, light, and the art of being still.', 'subtitle_ar' => 'عن المسافة والضوء وفن السكون.', 'hero_artwork_id' => self::id(100), 'published_at' => '2026-09-01T00:00:00Z', 'position' => 0]);
            $ex->artworks()->sync(collect(range(100, 105))->mapWithKeys(fn ($id) => [self::id($id) => ['position' => $id - 100]])->all());
            $ex = $this->put(Exhibition::class, 501, ['slug' => 'silent-structures', 'title_en' => 'Silent structures', 'title_ar' => 'بنى صامتة', 'subtitle_en' => 'Photography at the edge of architecture.', 'subtitle_ar' => 'التصوير على تخوم العمارة.', 'hero_artwork_id' => self::id(101), 'published_at' => '2026-09-01T00:00:00Z', 'position' => 1]);
            $ex->artworks()->sync([self::id(101) => ['position' => 0], self::id(105) => ['position' => 1]]);
            $this->put(FrameOption::class, 600, ['label_en' => 'Dark oak', 'label_ar' => 'بلوط داكن', 'material' => 'oak', 'color_hex' => '#29251F', 'border_mm' => 20]);
            $this->put(RoomScene::class, 700, ['label_en' => 'Quiet residence', 'label_ar' => 'مسكن هادئ', 'disk' => null, 'path' => null, 'wall_bounds' => null]);
        });
    }
}
