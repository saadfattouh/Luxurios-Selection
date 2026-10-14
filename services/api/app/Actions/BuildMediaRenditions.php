<?php

declare(strict_types=1);

namespace App\Actions;

use App\Models\ArtworkMedia;
use Illuminate\Support\Facades\Storage;

// Invoked from CLI/seeding only. Originals stay unchanged; no processing in reads.
final class BuildMediaRenditions
{
    public function execute(ArtworkMedia $media): void
    {
        $disk = Storage::disk($media->disk);
        $bytes = $disk->get($media->path);
        $source = imagecreatefromstring($bytes);
        if (! $source) {
            throw new \RuntimeException('Media could not be decoded.');
        }
        $width = imagesx($source);
        $height = imagesy($source);
        $renditions = [];
        try {
            foreach (['thumbnail' => 480, 'hero' => 1280, 'fullscreen' => 1920] as $name => $limit) {
                $scale = min(1, $limit / max($width, $height));
                $w = max(1, (int) round($width * $scale));
                $h = max(1, (int) round($height * $scale));
                $image = imagecreatetruecolor($w, $h);
                imagecopyresampled($image, $source, 0, 0, 0, 0, $w, $h, $width, $height);
                ob_start();
                imagejpeg($image, null, 85);
                $encoded = ob_get_clean();
                imagedestroy($image);
                $path = 'renditions/'.substr(hash('sha256', $encoded), 0, 32).'.jpg';
                if (! $disk->put($path, $encoded)) {
                    throw new \RuntimeException('Rendition write failed.');
                }
                $renditions[$name] = ['path' => $path, 'width' => $w, 'height' => $h];
            }
            $pixel = imagecreatetruecolor(1, 1);
            imagecopyresampled($pixel, $source, 0, 0, 0, 0, 1, 1, $width, $height);
            $color = sprintf('#%06X', imagecolorat($pixel, 0, 0) & 0xFFFFFF);
            imagedestroy($pixel);
            $media->update(['renditions' => $renditions, 'dominant_color' => $color]);
        } finally {
            imagedestroy($source);
        }
    }
}
