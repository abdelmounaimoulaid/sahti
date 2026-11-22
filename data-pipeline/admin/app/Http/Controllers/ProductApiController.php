<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\DB;

/**
 * Public read-only API used by the Sahti app when a product is scanned.
 * Response mimics the Open Food Facts v2 shape so the app can reuse Product.fromOff().
 * Only reviewed data is served: OFF-complete or human/auto validated, never 'ai_to_verify'.
 */
class ProductApiController extends Controller
{
    public function show(string $barcode)
    {
        if (! preg_match('/^\d{6,14}$/', $barcode)) {
            return response()->json(['status' => 0, 'status_verbose' => 'invalid barcode'], 400);
        }

        $p = DB::table('products')
            ->where('barcode', $barcode)
            ->whereIn('status', ['complete', 'validated'])
            ->first();

        $nonFood = $p && DB::table('enrichment_runs')
            ->where('product_id', $p->id)
            ->where('notes', 'like', 'Produit non alimentaire%')
            ->exists();

        if (! $p || $nonFood) {
            return response()->json(['status' => 0, 'status_verbose' => 'product not found'], 404);
        }

        $tags = fn (?string $s) => array_values(array_filter(array_map('trim', explode(',', (string) $s))));
        $slug = fn (string $s) => str_contains($s, ':') ? $s : 'fr:'.\Illuminate\Support\Str::slug($s);

        $sources = DB::table('product_sources')
            ->where('product_id', $p->id)
            ->where('field', 'ingredients_text')
            ->select('source_type', 'source_url', 'source_country')
            ->get();

        $product = [
            'code' => $p->barcode,
            'product_name' => $p->name,
            'product_name_fr' => $p->name,
            'brands' => $p->brand,
            'quantity' => $p->quantity,
            'image_front_url' => $p->image_url,
            'image_url' => $p->image_url,
            'nutriscore_grade' => $p->nutriscore_grade,
            'nutrition_grades' => $p->nutriscore_grade,
            'nova_group' => $p->nova_group,
            'categories_tags' => array_map($slug, $tags($p->categories)),
            'additives_tags' => $tags($p->additives),
            'allergens_tags' => $tags($p->allergens),
            'traces_tags' => [],
            'labels_tags' => [],
            'ingredients_text' => $p->ingredients_text,
            'ingredients_text_fr' => $p->ingredients_lang === 'fr' || $p->ingredients_lang === null ? $p->ingredients_text : null,
            'nutriments' => json_decode($p->nutriments ?: '{}', true) ?: new \stdClass,
            'sahti' => [
                'status' => $p->status,
                'validated_at' => $p->validated_at,
                'sources' => $sources,
            ],
        ];

        return response()->json(['status' => 1, 'code' => $p->barcode, 'product' => $product])
            ->header('Cache-Control', 'public, max-age=3600');
    }
}
