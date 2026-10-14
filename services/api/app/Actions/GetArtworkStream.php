<?php

declare(strict_types=1);

namespace App\Actions;

use App\Http\Requests\ArtworkStreamRequest;
use App\Models\Artwork;
use App\Models\Collection;
use App\Models\Exhibition;
use Illuminate\Contracts\Pagination\CursorPaginator;
use Illuminate\Support\Str;

final class GetArtworkStream
{
    public function execute(Collection|Exhibition $parent, ArtworkStreamRequest $request): CursorPaginator
    {
        $filters = $request->validated();
        $relation = $parent instanceof Collection ? 'collections' : 'exhibitions';
        $query = Artwork::query()->select(['id', 'slug', 'title_en', 'title_ar', 'photographer_id'])->where('published_at', '<=', now())
            ->whereHas($relation, fn ($q) => $q->where($relation.'.id', $parent->id))
            ->with(['media' => fn ($q) => $q->where('position', 0), 'photographer:id,slug,name_en,name_ar', 'editions:id,artwork_id,is_limited,total,availability']);
        if (isset($filters['collection'])) {
            $query->whereHas('collections', fn ($q) => $q->where('slug', $filters['collection']));
        }
        if (isset($filters['photographer'])) {
            $value = $filters['photographer'];
            $query->whereHas('photographer', fn ($q) => $q->where(Str::isUuid($value) ? 'id' : 'slug', $value));
        }
        if (isset($filters['orientation'])) {
            $operator = ['landscape' => '>', 'portrait' => '<', 'square' => '='][$filters['orientation']];
            $query->whereHas('media', fn ($q) => $q->where('position', 0)->whereColumn('width', $operator, 'height'));
        }
        if (isset($filters['availability']) || isset($filters['edition_status'])) {
            // Both predicates must match the SAME edition.
            $query->whereHas('editions', function ($q) use ($filters) {
                if (isset($filters['availability'])) {
                    $q->where('availability', $filters['availability']);
                }
                if (isset($filters['edition_status'])) {
                    $q->where('is_limited', $filters['edition_status'] === 'limited');
                }
            });
        }

        // Immutable unique UUID order avoids offset drift and equal-sort-key omissions.
        return $query->orderBy('id')->cursorPaginate((int) ($filters['per_page'] ?? 12))->withQueryString();
    }
}
