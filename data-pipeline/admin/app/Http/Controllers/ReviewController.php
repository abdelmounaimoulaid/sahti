<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ReviewController extends Controller
{
    private const STATUSES = ['ai_to_verify', 'incomplete', 'complete', 'validated'];

    public function index(Request $request)
    {
        $status = in_array($request->query('status'), self::STATUSES, true)
            ? $request->query('status')
            : 'ai_to_verify';

        $counts = DB::table('products')
            ->select('status', DB::raw('COUNT(*) as n'))
            ->groupBy('status')
            ->pluck('n', 'status');

        $products = DB::table('products')
            ->where('status', $status)
            ->when($request->query('q'), function ($q, $term) {
                $q->where(fn ($w) => $w->where('barcode', 'like', "%$term%")
                    ->orWhere('name', 'like', "%$term%")
                    ->orWhere('brand', 'like', "%$term%"));
            })
            ->orderByDesc('updated_at')
            ->select('id', 'barcode', 'name', 'brand', 'missing_fields', 'image_url', 'updated_at')
            ->paginate(50)
            ->withQueryString();

        return view('review.index', compact('products', 'counts', 'status'));
    }

    public function show(int $id)
    {
        $product = DB::table('products')->find($id) ?? abort(404);
        $sources = DB::table('product_sources')->where('product_id', $id)->orderBy('field')->get();
        $run = DB::table('enrichment_runs')->where('product_id', $id)->orderByDesc('id')->first();
        $next = DB::table('products')->where('status', 'ai_to_verify')->where('id', '!=', $id)
            ->orderByDesc('updated_at')->value('id');

        return view('review.show', compact('product', 'sources', 'run', 'next'));
    }

    public function validateProduct(Request $request, int $id)
    {
        $product = DB::table('products')->find($id) ?? abort(404);
        $data = $request->validate([
            'name' => 'nullable|string|max:255',
            'brand' => 'nullable|string|max:255',
            'ingredients_text' => 'nullable|string',
            'additives' => 'nullable|string',
            'allergens' => 'nullable|string',
        ]);
        $data = array_map(fn ($v) => $v === null ? null : trim($v), $data);

        $changed = false;
        foreach ($data as $field => $value) {
            if ((string) $value !== (string) ($product->$field ?? '')) {
                $changed = true;
            }
        }

        DB::transaction(function () use ($id, $data, $changed) {
            DB::table('products')->where('id', $id)->update($data + [
                'status' => 'validated',
                'missing_fields' => null,
                'validated_at' => now(),
            ]);
            $this->recordReview($id, $changed ? 'corrected' : 'correct', request('review_note'));
        });

        return $this->goNext($id, $changed ? 'Fiche corrigée et validée.' : 'Fiche validée.');
    }

    public function reject(Request $request, int $id)
    {
        DB::table('products')->find($id) ?? abort(404);
        DB::transaction(function () use ($id, $request) {
            DB::table('products')->where('id', $id)->update(['status' => 'incomplete']);
            $this->recordReview($id, 'rejected', $request->input('review_note'));
        });

        return $this->goNext($id, 'Fiche rejetée, remise en « incomplète ».');
    }

    private function recordReview(int $id, string $result, ?string $note): void
    {
        $run = DB::table('enrichment_runs')->where('product_id', $id)->orderByDesc('id')->first();
        if (! $run) {
            return;
        }
        $notes = trim(($run->notes ?? '').($note ? "\n[Revue] ".$note : ''));
        DB::table('enrichment_runs')->where('id', $run->id)
            ->update(['review_result' => $result, 'notes' => $notes ?: null]);
    }

    private function goNext(int $id, string $message)
    {
        $next = DB::table('products')->where('status', 'ai_to_verify')->orderByDesc('updated_at')->value('id');

        return $next
            ? redirect()->route('review.show', $next)->with('ok', $message)
            : redirect()->route('review.index')->with('ok', $message.' Plus rien à vérifier.');
    }
}
