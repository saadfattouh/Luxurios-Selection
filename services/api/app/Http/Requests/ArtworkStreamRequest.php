<?php

declare(strict_types=1);

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Pagination\Cursor;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

final class ArtworkStreamRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'per_page' => ['sometimes', 'integer', 'min:1', 'max:24'],
            'cursor' => ['sometimes', 'string', 'max:1024', function ($attribute, $value, $fail) {
                try {
                    $cursor = Cursor::fromEncoded($value);
                    if (! $cursor || ! Str::isUuid($cursor->parameter('id'))) {
                        $fail('Invalid artwork cursor.');
                    }
                } catch (\Throwable) {
                    $fail('Invalid artwork cursor.');
                }
            }],
            'orientation' => ['sometimes', Rule::in(['landscape', 'portrait', 'square'])],
            'availability' => ['sometimes', Rule::in(['available', 'sold_out', 'unavailable', 'unknown'])],
            'edition_status' => ['sometimes', Rule::in(['limited', 'open'])],
            'collection' => ['sometimes', 'string', 'max:120', 'regex:/^[a-z0-9-]+$/'],
            'photographer' => ['sometimes', 'string', 'max:120', 'regex:/^[a-z0-9-]+$/'],
        ];
    }

    public function withValidator($validator): void
    {
        $validator->after(function ($validator) {
            foreach (array_diff(array_keys($this->query()), array_keys($this->rules())) as $key) {
                $validator->errors()->add($key, 'Unsupported filter.');
            }
        });
    }
}
